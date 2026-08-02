import csv
import os
from pathlib import Path

import psycopg2
from psycopg2 import sql


BASE_DIR = Path(__file__).resolve().parents[1]
EXPORT_DIR = BASE_DIR / "exports"
DEFAULT_TABLE = "public.symbol"
DEFAULT_OUTPUT = EXPORT_DIR / "symbol.csv"


def parse_table_name(table_name: str):
    parts = table_name.split(".")
    if len(parts) == 1:
        schema_name = "public"
        relation_name = parts[0]
    elif len(parts) == 2:
        schema_name, relation_name = parts
    else:
        raise ValueError("PG_TABLE 只支持 table 或 schema.table 格式")

    for value in (schema_name, relation_name):
        if not value or "\x00" in value:
            raise ValueError(f"非法表名片段: {value}")
    return schema_name, relation_name


def main() -> int:
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        print("请先在 PowerShell 设置 $env:DATABASE_URL")
        return 1

    table_name = os.environ.get("PG_TABLE", DEFAULT_TABLE)
    output_path = Path(os.environ.get("OUTPUT_CSV", DEFAULT_OUTPUT))
    schema_name, relation_name = parse_table_name(table_name)

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    query = sql.SQL("SELECT * FROM {}.{}").format(
        sql.Identifier(schema_name),
        sql.Identifier(relation_name),
    )

    with psycopg2.connect(database_url) as conn:
        with conn.cursor() as cur:
            cur.execute(query)
            columns = [desc.name for desc in cur.description]
            rows = cur.fetchall()

    with output_path.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(columns)
        writer.writerows(rows)

    print(f"table = {schema_name}.{relation_name}")
    print(f"rows = {len(rows)}")
    print(f"columns = {len(columns)}")
    print(f"csv = {output_path}")
    print("export_finished = true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
