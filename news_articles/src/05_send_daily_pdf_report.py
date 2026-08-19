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
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

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
    # 微软雅黑覆盖中英文，避免 CID 中文字体将英文标题拆散显示。
    font_path = Path(os.environ.get("REPORT_FONT_PATH", r"C:\Windows\Fonts\msyh.ttc"))
    if font_path.exists():
        font_name = "MicrosoftYaHei"
        pdfmetrics.registerFont(TTFont(font_name, str(font_path), subfontIndex=0))
    else:
        font_name = "STSong-Light"
        pdfmetrics.registerFont(UnicodeCIDFont(font_name))
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name="CNTitle", parent=styles["Title"], fontName=font_name, fontSize=19, leading=25, alignment=TA_CENTER))
    styles.add(ParagraphStyle(name="CNHead", parent=styles["Heading2"], fontName=font_name, fontSize=12, leading=17, textColor=colors.HexColor("#1F4E78"), spaceBefore=8, spaceAfter=5))
    styles.add(ParagraphStyle(name="CNBody", parent=styles["BodyText"], fontName=font_name, fontSize=8.8, leading=13))
    styles.add(ParagraphStyle(name="CNAlert", parent=styles["BodyText"], fontName=font_name, fontSize=9, leading=14, textColor=colors.HexColor("#9C1C1C")))
    doc = SimpleDocTemplate(path, pagesize=A4, leftMargin=15 * mm, rightMargin=15 * mm, topMargin=14 * mm, bottomMargin=14 * mm)
    story = [
        Paragraph("永丰数据仓 - 每日数据状态简报", styles["CNTitle"]),
        Spacer(1, 4 * mm),
        Paragraph(f"生成时间：{now:%Y-%m-%d %H:%M}（北京时间） | 国内/外盘目标交易日：{expected_day}", styles["CNBody"]),
        Paragraph("数据更新状态", styles["CNHead"]),
    ]
    status_table = Table([["模块", "最新时间", "累计条数", "状态", "检查规则"]] + status_rows, colWidths=[30 * mm, 37 * mm, 24 * mm, 19 * mm, 55 * mm])
    status_table.setStyle(TableStyle([
        ("FONTNAME", (0, 0), (-1, -1), font_name), ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#D9EAF7")), ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#B7C9D6")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"), ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7FAFC")]),
        ("LEFTPADDING", (0, 0), (-1, -1), 4), ("RIGHTPADDING", (0, 0), (-1, -1), 4), ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    story += [status_table, Paragraph("套保公告识别", styles["CNHead"]), Paragraph(f"近两日：已识别 {classified} 条；待复核 {unresolved} 条。", styles["CNBody"])]
    story.append(Paragraph("重点海外资讯（近 24 小时）", styles["CNHead"]))
    if news:
        for source, topic, title, published, url in news:
            line = (
                f"<b>[{escape(str(source))} | {escape(str(topic))}]</b> {escape(str(title))}"
                f"<br/><font size=7>{escape(display_time(published))}  {escape(str(url or ''))}</font>"
            )
            story.append(Paragraph(line, styles["CNBody"]))
            story.append(Spacer(1, 2 * mm))
    else:
        story.append(Paragraph("近 24 小时没有可展示的重点资讯。", styles["CNBody"]))
    story.append(Paragraph("异常与待处理事项", styles["CNHead"]))
    if alerts:
        for alert in alerts:
            story.append(Paragraph(f"• {alert}", styles["CNAlert"]))
    else:
        story.append(Paragraph("• 未检测到需要人工处理的异常。", styles["CNBody"]))
    doc.build(story)


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
