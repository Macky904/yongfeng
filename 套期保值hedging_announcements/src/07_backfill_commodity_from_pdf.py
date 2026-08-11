"""回补 hedging_announcements 中 commodity 为空的记录。

策略（与增量脚本一致，遵循"不硬猜"原则）：
  1) 先用 标题 + 公司名 抽品种（infer_commodity 默认行为）；
  2) 抽不到时，下载该公告 PDF 正文，从正文补抽；
  3) 正文也抽不到 → 保持空，不瞎编。

约束：
  - 只读 commodity 为 NULL/空的行，绝不覆盖已有值（幂等可重跑）；
  - 每条 PDF 下载后 sleep 节流，失败返回空串不中断；
  - 直接 UPDATE 数据库，并生成 SQL 迁移文件便于审计/入库 GitHub。

用法：
  python 07_backfill_commodity_from_pdf.py            # 全量回补
  python 07_backfill_commodity_from_pdf.py 30         # 仅前 30 条（验证用）
"""
import importlib.util
import os
import sys
import time
from datetime import datetime
from pathlib import Path

import psycopg2


BASE_DIR = Path(__file__).resolve().parents[1]
SRC_DIR = BASE_DIR / "src"
SQL_DIR = BASE_DIR / "sql"


def load_module(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


enrich_mod = load_module(SRC_DIR / "02_enrich_and_build_database.py", "enrich_hedging")

# 框架类文件（管理制度/办法）正文只泛列品种要素，不列真实套保品种，跳过不抽
SKIP_TITLE_KEYWORDS = ("管理制度", "管理办法", "管理办")


def fetch_empty_rows(conn):
    """返回所有 commodity 为空的记录。"""
    with conn.cursor() as cur:
        cur.execute(
            """
            select announcement_id, company_name, industry, announcement_title, pdf_url
            from public.hedging_announcements
            where commodity is null or commodity = ''
            order by announcement_date desc, announcement_id desc
            """
        )
        return cur.fetchall()


def main():
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true；请先设置环境变量 DATABASE_URL")
        return 1

    limit = int(sys.argv[1]) if len(sys.argv) > 1 else None

    conn = psycopg2.connect(database_url)
    try:
        rows = fetch_empty_rows(conn)
    finally:
        conn.close()

    total = len(rows)
    print(f"empty_commodity_rows = {total}")
    if limit:
        print(f"limit = {limit} (验证模式)")
        rows = rows[:limit]

    updates = []          # (commodity, announcement_id)
    from_body = []        # 来自正文补抽的明细，便于复核
    still_empty = 0
    for idx, (aid, company, industry, title, pdf_url) in enumerate(rows, 1):
        commodity = enrich_mod.infer_commodity(company or "", industry or "", title or "")
        source = "title"
        if not commodity:
            # 框架类文件（管理制度/办法）不单独抽品种，保持空，避免正文泛列污染
            if any(k in (title or "") for k in SKIP_TITLE_KEYWORDS):
                print(f"[{idx}/{len(rows)}] {aid} {company} | 框架文件(跳过)")
                still_empty += 1
                time.sleep(0.5)
                continue
            pdf_text = enrich_mod.download_pdf_text(pdf_url)
            if pdf_text:
                commodity = enrich_mod.infer_commodity(
                    company or "", industry or "", title or "", pdf_text=pdf_text
                )
                if commodity:
                    source = "pdf_body"
        if commodity:
            updates.append((commodity, aid))
            if source == "pdf_body":
                from_body.append((aid, company, title, commodity))
            # 进度
            tag = "正文" if source == "pdf_body" else "标题"
            print(f"[{idx}/{len(rows)}] {aid} {company} | {tag} -> {commodity}")
        else:
            still_empty += 1
            print(f"[{idx}/{len(rows)}] {aid} {company} | 仍为空（正文也无明确品种）")
        time.sleep(0.5)  # 节流，避免对 cninfo 请求过快

    # 落库
    if updates:
        with psycopg2.connect(database_url) as wconn:
            with wconn.cursor() as cur:
                cur.executemany(
                    "update public.hedging_announcements set commodity=%s where announcement_id=%s",
                    updates,
                )
            wconn.commit()

    filled = len(updates)
    from_body_n = len(from_body)
    print(f"\n=== 结果 ===")
    print(f"本次处理 = {len(rows)}，成功补抽 = {filled}（其中读正文补出 {from_body_n}），仍空 = {still_empty}")
    print(f"全库剩余空 commodity = {total - filled if limit is None else '（仅样本，未全量）'}")

    # 生成 SQL 迁移文件（仅当本批有更新时）
    if updates:
        stamp = datetime.now().strftime("%Y-%m-%d")
        sql_path = SQL_DIR / f"07_backfill_commodity_from_pdf_{stamp}.sql"
        SQL_DIR.mkdir(parents=True, exist_ok=True)
        lines = [
            "-- 回补 hedging_announcements.commodity：标题无品种时回退读取 PDF 正文补抽",
            f"-- 生成时间：{datetime.now().isoformat(timespec='seconds')}",
            f"-- 本批处理 {len(rows)} 条，补抽 {filled} 条（其中读正文补出 {from_body_n} 条），仍空 {still_empty} 条",
            "-- 原则：只更新 commodity 为空的行，不覆盖已有值；正文也无明确品种的保持空，不硬猜。",
            "begin;",
            "",
        ]
        for commodity, aid in updates:
            esc = commodity.replace("'", "''")
            lines.append(f"update public.hedging_announcements set commodity='{esc}' where announcement_id={aid};")
        lines.append("")
        lines.append("commit;")
        sql_path.write_text("\n".join(lines), encoding="utf-8")
        print(f"sql_file = {sql_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
