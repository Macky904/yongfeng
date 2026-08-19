"""每日数据状态 PDF 简报：09:10（北京时间）发送至指定邮箱后删除临时 PDF。

正式数据只保存在 Supabase。报告文件使用系统临时目录，邮件发送完成后立即删除；
仅保留短期日志，方便任务失败时排查。
"""
import argparse
import logging
import os
import smtplib
import ssl
import tempfile
from datetime import date, datetime, timedelta, timezone
from email.message import EmailMessage
from pathlib import Path
from xml.sax.saxutils import escape

import psycopg2
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import KeepTogether, PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
LOG_DIR = ROOT / "logs"
LOG_DIR.mkdir(exist_ok=True)
BEIJING_TZ = timezone(timedelta(hours=8))
REPORT_TO = os.environ.get("REPORT_EMAIL_TO", "2221078228@qq.com")
REPORT_FROM = os.environ.get("REPORT_EMAIL_FROM", "2221078228@qq.com")
SMTP_HOST = os.environ.get("REPORT_SMTP_HOST", "smtp.qq.com")
SMTP_PORT = int(os.environ.get("REPORT_SMTP_PORT", "465"))


def previous_business_day(day: date) -> date:
    candidate = day - timedelta(days=1)
    while candidate.weekday() >= 5:
        candidate -= timedelta(days=1)
    return candidate


def display_time(value) -> str:
    """统一以北京时间展示，防止 UTC 偏移量挤坏 PDF 表格。"""
    if value is None:
        return "无数据"
    if isinstance(value, datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.astimezone(BEIJING_TZ).strftime("%Y-%m-%d %H:%M")
    return str(value)


def make_logger(now: datetime):
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(LOG_DIR / f"daily_report_{now:%Y-%m-%d}.log", encoding="utf-8"),
            logging.StreamHandler(),
        ],
    )
    return logging.getLogger("daily_report")


def fetch_report_data(database_url: str, now: datetime):
    """读取现有业务表，不新增数据库表，也不向 Supabase 写入报告副本。"""
    expected_trade_day = previous_business_day(now.date())
    alerts, rows = [], []
    with psycopg2.connect(database_url, connect_timeout=15) as conn:
        with conn.cursor() as cur:
            checks = [
                ("国内期权", "public.option_daily", "trade_date", expected_trade_day, "按上一交易日检查"),
                ("外盘期货", "public.futures_kline_daily", "trade_date", expected_trade_day, "按上一交易日检查"),
                ("套保公告", "public.hedging_announcements", "announcement_date", now.date() - timedelta(days=1), "允许前一日公告"),
            ]
            for label, table, column, expected, note in checks:
                try:
                    cur.execute(f"select max({column}), count(*) from {table}")
                    latest, total = cur.fetchone()
                    ok = latest is not None and latest >= expected
                    status = "正常" if ok else "需关注"
                    if not ok:
                        alerts.append(f"{label}最新日期为 {latest or '无数据'}，目标至少为 {expected}。")
                    rows.append([label, display_time(latest), f"{total:,}", status, note])
                except Exception as exc:  # 单表失败仍然生成含失败说明的简报
                    conn.rollback()
                    rows.append([label, "读取失败", "-", "失败", type(exc).__name__])
                    alerts.append(f"{label}状态读取失败：{type(exc).__name__}。")

            try:
                cur.execute(
                    """
                    select max(pub_date), count(*)
                    from public.news_articles
                    where pub_date >= %s
                    """,
                    (now - timedelta(hours=24),),
                )
                latest, count = cur.fetchone()
                ok = latest is not None
                rows.append(["海外新闻 / 社交媒体", display_time(latest), f"{count:,}", "正常" if ok else "需关注", "近 24 小时"])
                if not ok:
                    alerts.append("近 24 小时未发现海外新闻或社交媒体更新。")
            except Exception as exc:
                conn.rollback()
                rows.append(["海外新闻 / 社交媒体", "读取失败", "-", "失败", type(exc).__name__])
                alerts.append(f"海外新闻状态读取失败：{type(exc).__name__}。")

            try:
                cur.execute(
                    """
                    select coalesce(source_name, '未知来源'), coalesce(topic, '未分类'),
                           coalesce(title, ''), pub_date, source_url
                    from public.news_articles
                    where pub_date >= %s
                    order by pub_date desc nulls last
                    limit 8
                    """,
                    (now - timedelta(hours=24),),
                )
                news = cur.fetchall()
            except Exception as exc:
                conn.rollback()
                news = []
                alerts.append(f"重点资讯读取失败：{type(exc).__name__}。")

            try:
                cur.execute(
                    """
                    select count(*) filter (where commodity is not null and commodity <> ''),
                           count(*) filter (where commodity is null or commodity = '')
                    from public.hedging_announcements
                    where announcement_date >= %s
                    """,
                    (now.date() - timedelta(days=1),),
                )
                classified, unresolved = cur.fetchone()
                if unresolved:
                    alerts.append(f"套保公告中有 {unresolved} 条尚未识别到品种，已保留待复核。")
            except Exception as exc:
                conn.rollback()
                classified, unresolved = 0, 0
                alerts.append(f"套保公告识别统计失败：{type(exc).__name__}。")

    return expected_trade_day, rows, news, alerts, classified, unresolved


def build_pdf(path: str, now: datetime, expected_day: date, status_rows, news, alerts, classified, unresolved):
    """生成一份两页内、适合邮件阅读的商品研究晨报风格 PDF。"""
    # 微软雅黑覆盖中英文，避免 CID 中文字体将英文标题拆散显示。
    font_path = Path(os.environ.get("REPORT_FONT_PATH", r"C:\Windows\Fonts\msyh.ttc"))
    if font_path.exists():
        font_name = "MicrosoftYaHei"
        pdfmetrics.registerFont(TTFont(font_name, str(font_path), subfontIndex=0))
    else:
        font_name = "STSong-Light"
        pdfmetrics.registerFont(UnicodeCIDFont(font_name))
    navy, ink, muted = "#102A43", "#243B53", "#627D98"
    teal, green, amber, red = "#0F766E", "#137A4A", "#A15C00", "#B42318"
    pale_blue, pale_green, pale_amber, pale_red = "#EAF2F8", "#EAF7EE", "#FFF5E5", "#FDECEC"
    styles = getSampleStyleSheet()
    def style(name, size, leading, color=ink, **kwargs):
        styles.add(ParagraphStyle(name=name, parent=styles["BodyText"], fontName=font_name,
                                  fontSize=size, leading=leading, textColor=colors.HexColor(color), **kwargs))
    style("Masthead", 21, 27, "#FFFFFF", alignment=TA_LEFT)
    style("MastheadMeta", 8.2, 12, "#D9EAF7")
    style("Section", 11.5, 15, navy, spaceBefore=10, spaceAfter=5)
    style("Body", 8.6, 13)
    style("Small", 7.4, 10.5, muted)
    style("TableHead", 7.7, 10, "#FFFFFF", alignment=TA_LEFT)
    style("TableCell", 8, 11.5)
    style("KpiLabel", 7.6, 10, muted)
    style("KpiValue", 12.5, 16, navy)
    style("KpiState", 8, 11)
    style("NewsTitle", 9, 13, ink)
    style("Alert", 8.5, 12.5, red)

    def paragraph(value, name="Body"):
        return Paragraph(escape(str(value or "-")), styles[name])

    def status_colours(status):
        if status == "正常":
            return green, pale_green
        if status == "失败":
            return red, pale_red
        return amber, pale_amber

    def kpi_card(row):
        label, latest, total, status, _ = row
        state_colour, background = status_colours(status)
        content = [
            [paragraph(label, "KpiLabel")],
            [paragraph(latest, "KpiValue")],
            [paragraph(f"{status}  |  {total} 条", "KpiState")],
        ]
        card = Table(content, colWidths=[39.5 * mm])
        card.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor(background)),
            ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#D9E2EC")),
            ("LINEBEFORE", (0, 0), (0, -1), 3, colors.HexColor(state_colour)),
            ("LEFTPADDING", (0, 0), (-1, -1), 8), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 7), ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
        ]))
        return card

    def footer(canvas, doc_obj):
        canvas.saveState()
        canvas.setStrokeColor(colors.HexColor("#D9E2EC"))
        canvas.line(doc_obj.leftMargin, 11 * mm, A4[0] - doc_obj.rightMargin, 11 * mm)
        canvas.setFont(font_name, 7)
        canvas.setFillColor(colors.HexColor(muted))
        canvas.drawString(doc_obj.leftMargin, 7 * mm, "永丰数据仓 | 仅作数据运行监控与资讯汇总")
        canvas.drawRightString(A4[0] - doc_obj.rightMargin, 7 * mm, f"第 {doc_obj.page} 页")
        canvas.restoreState()

    doc = SimpleDocTemplate(path, pagesize=A4, leftMargin=14 * mm, rightMargin=14 * mm,
                            topMargin=12 * mm, bottomMargin=17 * mm)
    masthead = Table([[Paragraph("永丰商品数据晨报", styles["Masthead"])],
                      [Paragraph(f"DAILY COMMODITY BRIEF  |  {now:%Y.%m.%d}  {now:%H:%M} 北京时间", styles["MastheadMeta"])]],
                     colWidths=[182 * mm])
    masthead.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor(navy)),
        ("LEFTPADDING", (0, 0), (-1, -1), 11), ("RIGHTPADDING", (0, 0), (-1, -1), 11),
        ("TOPPADDING", (0, 0), (-1, 0), 10), ("BOTTOMPADDING", (0, 0), (-1, 0), 1),
        ("TOPPADDING", (0, 1), (-1, 1), 1), ("BOTTOMPADDING", (0, 1), (-1, 1), 9),
    ]))
    story = [masthead, Spacer(1, 5 * mm)]
    story.append(Paragraph("数据健康概览", styles["Section"]))
    cards = [kpi_card(row) for row in status_rows]
    story.append(Table([cards], colWidths=[43 * mm] * 4, hAlign="LEFT", style=[
        ("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3), ("TOPPADDING", (0, 0), (-1, -1), 0), ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
    ]))
    story.append(Spacer(1, 4 * mm))
    story.append(Paragraph(f"检查口径：国内及外盘目标交易日为 {expected_day}；资讯统计为近 24 小时；套保公告按前一日更新情况检查。", styles["Small"]))
    story.append(Paragraph("数据状态明细", styles["Section"]))
    table_data = [[Paragraph(x, styles["TableHead"]) for x in ["模块", "最新时间", "累计条数", "状态", "检查口径"]]]
    for label, latest, total, status, note in status_rows:
        state_colour, state_bg = status_colours(status)
        table_data.append([paragraph(label, "TableCell"), paragraph(latest, "TableCell"), paragraph(total, "TableCell"),
                           Paragraph(f'<font color="{state_colour}"><b>{escape(status)}</b></font>', styles["TableCell"]),
                           paragraph(note, "Small")])
    status_table = Table(table_data, colWidths=[33 * mm, 40 * mm, 24 * mm, 20 * mm, 65 * mm], repeatRows=1)
    status_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor(navy)),
        ("LINEBELOW", (0, 0), (-1, 0), 0.5, colors.HexColor(navy)),
        ("GRID", (0, 1), (-1, -1), 0.25, colors.HexColor("#D9E2EC")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7FAFC")]),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5), ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    story.append(status_table)
    story.append(Paragraph("套保公告识别", styles["Section"]))
    hedge_state, hedge_bg = (green, pale_green) if not unresolved else (amber, pale_amber)
    hedge_strip = Table([[Paragraph(f"近两日已识别 <b>{classified}</b> 条公告；待人工复核 <b>{unresolved}</b> 条。", styles["Body"]),
                          Paragraph("原文未明确品种的公告将保留为空，避免错误归类。", styles["Small"])]], colWidths=[91 * mm, 91 * mm])
    hedge_strip.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), colors.HexColor(hedge_bg)),
                                     ("LINEBEFORE", (0, 0), (0, -1), 3, colors.HexColor(hedge_state)),
                                     ("LEFTPADDING", (0, 0), (-1, -1), 8), ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                                     ("TOPPADDING", (0, 0), (-1, -1), 7), ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
                                     ("VALIGN", (0, 0), (-1, -1), "MIDDLE")]))
    story.append(hedge_strip)
    alert_title = Paragraph("异常与待处理事项", styles["Section"])
    if alerts:
        alert_rows = [[Paragraph(f"<b>!</b>  {escape(alert)}", styles["Alert"])] for alert in alerts]
        alert_box = Table(alert_rows, colWidths=[182 * mm])
        alert_box.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor(pale_red)),
            ("LINEBEFORE", (0, 0), (0, -1), 3, colors.HexColor(red)),
            ("LEFTPADDING", (0, 0), (-1, -1), 8), ("RIGHTPADDING", (0, 0), (-1, -1), 8),
            ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]))
    else:
        alert_box = Table([[Paragraph("✓  未检测到需要人工处理的异常。", styles["Body"])]], colWidths=[182 * mm])
        alert_box.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), colors.HexColor(pale_green)),
                                       ("LINEBEFORE", (0, 0), (0, -1), 3, colors.HexColor(green)),
                                       ("LEFTPADDING", (0, 0), (-1, -1), 8), ("TOPPADDING", (0, 0), (-1, -1), 6),
                                       ("BOTTOMPADDING", (0, 0), (-1, -1), 6)]))
    # 固定在资讯前展示，避免报警标题和内容被拆到不同页面。
    story.append(KeepTogether([alert_title, alert_box]))
    # 新闻单独从第二页开始，保证状态页完整，资讯页也有一致的阅读节奏。
    story.append(PageBreak())
    story.append(Paragraph("重点海外资讯", styles["Section"]))
    story.append(Paragraph("近 24 小时采集到的官方机构与海外社交媒体商品资讯", styles["Small"]))
    if news:
        news_blocks = []
        for source, topic, title, published, url in news:
            domain = urlparse(str(url or "")).netloc.replace("www.", "") or "原文链接"
            tag = f"{escape(str(source))}  /  {escape(str(topic))}"
            link = escape(str(url or ""))
            link_text = f'<a href="{link}" color="{teal}">{escape(domain)}</a>' if link else "无原文链接"
            news_table = Table([[Paragraph(f'<font color="{teal}"><b>{tag}</b></font>', styles["Small"]), Paragraph(display_time(published), styles["Small"])],
                                [Paragraph(escape(str(title or "未命名资讯")), styles["NewsTitle"]), Paragraph(link_text, styles["Small"])]],
                               colWidths=[138 * mm, 44 * mm])
            news_table.setStyle(TableStyle([
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F7FAFC")),
                ("LINEBEFORE", (0, 0), (0, -1), 2.5, colors.HexColor(teal)),
                ("BOX", (0, 0), (-1, -1), 0.25, colors.HexColor("#D9E2EC")),
                ("LEFTPADDING", (0, 0), (-1, -1), 7), ("RIGHTPADDING", (0, 0), (-1, -1), 7),
                ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]))
            news_blocks.extend([KeepTogether([news_table, Spacer(1, 2.2 * mm)])])
        story.extend(news_blocks)
    else:
        story.append(Paragraph("近 24 小时没有可展示的重点资讯。", styles["Body"]))
    doc.build(story, onFirstPage=footer, onLaterPages=footer)


def send_email(pdf_path: str, now: datetime):
    password = os.environ.get("REPORT_SMTP_PASSWORD")
    if not password:
        raise RuntimeError("missing_REPORT_SMTP_PASSWORD")
    message = EmailMessage()
    message["Subject"] = f"永丰每日数据简报 - {now:%Y-%m-%d}"
    message["From"] = REPORT_FROM
    message["To"] = REPORT_TO
    message.set_content("附件为永丰数据仓每日 PDF 简报，包含数据状态、重点资讯与异常提醒。")
    with open(pdf_path, "rb") as file:
        message.add_attachment(file.read(), maintype="application", subtype="pdf", filename=f"永丰每日数据简报_{now:%Y-%m-%d}.pdf")
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, context=context, timeout=45) as server:
        server.login(REPORT_FROM, password)
        server.send_message(message)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-send", action="store_true", help="仅生成并校验 PDF，不发送邮件；临时文件仍会删除")
    args = parser.parse_args()
    now = datetime.now(BEIJING_TZ)
    log = make_logger(now)
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        log.error("missing_DATABASE_URL")
        return 1
    fd, pdf_path = tempfile.mkstemp(prefix="yongfeng_daily_", suffix=".pdf")
    os.close(fd)
    try:
        expected_day, rows, news, alerts, classified, unresolved = fetch_report_data(database_url, now)
        build_pdf(pdf_path, now, expected_day, rows, news, alerts, classified, unresolved)
        log.info("pdf_generated=%s", pdf_path)
        if args.no_send:
            log.info("no_send=true")
        else:
            send_email(pdf_path, now)
            log.info("email_sent_to=%s", REPORT_TO)
        return 0
    except Exception as exc:  # 任务计划程序需要非零状态来标记真正的投递失败
        log.exception("daily_report_failed=%s", exc)
        return 2
    finally:
        try:
            os.unlink(pdf_path)
            log.info("temporary_pdf_deleted=true")
        except OSError:
            pass


if __name__ == "__main__":
    raise SystemExit(main())
