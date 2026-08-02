import os

import psycopg2
from psycopg2 import sql


SCHEMA_NAME = "public"
CREATED_ALIASES = ["created_time", "create_time", "创建时间"]
UPDATED_ALIASES = ["updated_time", "update_time", "修改时间"]


def fetch_public_tables(cur):
    cur.execute(
        """
        select table_name
        from information_schema.tables
        where table_schema = %s
          and table_type = 'BASE TABLE'
        order by table_name
        """,
        (SCHEMA_NAME,),
    )
    return [row[0] for row in cur.fetchall()]


def fetch_columns(cur, table_name):
    cur.execute(
        """
        select column_name
        from information_schema.columns
        where table_schema = %s
          and table_name = %s
        order by ordinal_position
        """,
        (SCHEMA_NAME, table_name),
    )
    return [row[0] for row in cur.fetchall()]


def rename_first_available(cur, table_ident, columns, aliases, target_name):
    if target_name in columns:
        return None
    for old_name in aliases:
        if old_name in columns:
            cur.execute(
                sql.SQL("ALTER TABLE {} RENAME COLUMN {} TO {}").format(
                    table_ident,
                    sql.Identifier(old_name),
                    sql.Identifier(target_name),
                )
            )
            return f"{old_name}->{target_name}"
    return None


def add_timestamp_column(cur, table_ident, column_name):
    cur.execute(
        sql.SQL("ALTER TABLE {} ADD COLUMN IF NOT EXISTS {} TIMESTAMPTZ").format(
            table_ident,
            sql.Identifier(column_name),
        )
    )
    cur.execute(
        sql.SQL("UPDATE {} SET {} = now() WHERE {} IS NULL").format(
            table_ident,
            sql.Identifier(column_name),
            sql.Identifier(column_name),
        )
    )
    cur.execute(
        sql.SQL("ALTER TABLE {} ALTER COLUMN {} SET DEFAULT now()").format(
            table_ident,
            sql.Identifier(column_name),
        )
    )
    cur.execute(
        sql.SQL("ALTER TABLE {} ALTER COLUMN {} SET NOT NULL").format(
            table_ident,
            sql.Identifier(column_name),
        )
    )


def add_updated_at_trigger(cur, table_ident, table_name):
    function_name = f"set_{table_name}_updated_at"
    trigger_name = f"trg_{table_name}_updated_at"

    cur.execute(
        sql.SQL(
            """
            CREATE OR REPLACE FUNCTION {}.{}()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.updated_at = now();
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql
            """
        ).format(sql.Identifier(SCHEMA_NAME), sql.Identifier(function_name))
    )
    cur.execute(
        sql.SQL("DROP TRIGGER IF EXISTS {} ON {}").format(
            sql.Identifier(trigger_name),
            table_ident,
        )
    )
    cur.execute(
        sql.SQL(
            """
            CREATE TRIGGER {}
            BEFORE UPDATE ON {}
            FOR EACH ROW
            EXECUTE FUNCTION {}.{}()
            """
        ).format(
            sql.Identifier(trigger_name),
            table_ident,
            sql.Identifier(SCHEMA_NAME),
            sql.Identifier(function_name),
        )
    )


def standardize_table(cur, table_name):
    table_ident = sql.SQL("{}.{}").format(
        sql.Identifier(SCHEMA_NAME),
        sql.Identifier(table_name),
    )
    actions = []
    columns = fetch_columns(cur, table_name)

    action = rename_first_available(cur, table_ident, columns, CREATED_ALIASES, "created_at")
    if action:
        actions.append(action)
    columns = fetch_columns(cur, table_name)

    action = rename_first_available(cur, table_ident, columns, UPDATED_ALIASES, "updated_at")
    if action:
        actions.append(action)
    columns = fetch_columns(cur, table_name)

    if "created_at" not in columns:
        add_timestamp_column(cur, table_ident, "created_at")
        actions.append("add created_at")
    else:
        add_timestamp_column(cur, table_ident, "created_at")
        actions.append("normalize created_at")

    columns = fetch_columns(cur, table_name)
    if "updated_at" not in columns:
        add_timestamp_column(cur, table_ident, "updated_at")
        actions.append("add updated_at")
    else:
        add_timestamp_column(cur, table_ident, "updated_at")
        actions.append("normalize updated_at")

    add_updated_at_trigger(cur, table_ident, table_name)
    actions.append("add updated_at trigger")
    return actions


def main():
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("missing_DATABASE_URL = true")
        print("请先在 PowerShell 设置 $env:DATABASE_URL")
        return 1

    with psycopg2.connect(database_url) as conn:
        with conn.cursor() as cur:
            table_names = fetch_public_tables(cur)
            for table_name in table_names:
                actions = standardize_table(cur, table_name)
                print(f"table = {table_name}")
                print("actions = " + ", ".join(actions))

    print("standardize_finished = true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
