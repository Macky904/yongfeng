from pathlib import Path
import os
import re
import sys

import psycopg2


BASE_DIR = Path(__file__).resolve().parents[1]
DEFAULT_SQL_PATH = BASE_DIR / "exports" / "hedging_announcements_2010_to_2026.sql"


def split_sql_statements(sql: str):
    statements = []
    start = 0
    i = 0
    in_single_quote = False
    dollar_tag = None

    while i < len(sql):
        char = sql[i]
        next_char = sql[i + 1] if i + 1 < len(sql) else ""

        if dollar_tag:
            if sql.startswith(dollar_tag, i):
                i += len(dollar_tag)
                dollar_tag = None
                continue
            i += 1
            continue

        if in_single_quote:
            if char == "'" and next_char == "'":
                i += 2
                continue
            if char == "'":
                in_single_quote = False
            i += 1
            continue

        if char == "'":
            in_single_quote = True
            i += 1
            continue

        if char == "$":
            tag_end = sql.find("$", i + 1)
            if tag_end != -1:
                tag = sql[i:tag_end + 1]
                if tag == "$$" or tag[1:-1].replace("_", "").isalnum():
                    dollar_tag = tag
                    i = tag_end + 1
                    continue

        if char == ";":
            statement = sql[start:i + 1].strip()
            if statement:
                statements.append(statement)
            start = i + 1

        i += 1

    tail = sql[start:].strip()
    if tail:
        statements.append(tail)
    return statements


def has_executable_sql(statement: str) -> bool:
    without_block_comments = re.sub(r"/\*.*?\*/", "", statement, flags=re.DOTALL)
    without_line_comments = re.sub(r"(?m)^\s*--.*$", "", without_block_comments)
    return bool(without_line_comments.strip())


def main() -> int:
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        print("请先在 PowerShell 设置 $env:DATABASE_URL")
        return 1

    sql_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SQL_PATH
    if not sql_path.exists():
        print(f"sql_file_not_found = {sql_path}")
        return 1

    sql = sql_path.read_text(encoding="utf-8")
    statements = [
        statement
        for statement in split_sql_statements(sql)
        if has_executable_sql(statement)
    ]

    print(f"sql_file = {sql_path}")
    print(f"statements = {len(statements)}")

    with psycopg2.connect(database_url) as conn:
        with conn.cursor() as cur:
            for idx, statement in enumerate(statements, start=1):
                cur.execute(statement)
                if idx % 20 == 0 or idx == len(statements):
                    print(f"executed_statements = {idx}/{len(statements)}")

    print("import_finished = true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
