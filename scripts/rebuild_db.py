import os, sys, psycopg2
from dotenv import load_dotenv

load_dotenv()
url = os.getenv("DATABASE_URL")
if not url:
    print("ERROR: DATABASE_URL not set in .env")
    sys.exit(1)

files = [
    "scripts/00_reset_schema.sql",
    "scripts/10_tables.sql",
    "scripts/20_indexes.sql",
    "scripts/30_seed_static.sql",
    "scripts/31_seed_users.sql",
    "scripts/32_seed_links.sql",
    "scripts/33_seed_facts.sql",
    "scripts/99_smoke.sql",
]

def run_sql(cur, path):
    with open(path, "r", encoding="utf-8") as f:
        sql = f.read()
    print(f">> {path}")
    cur.execute(sql)

try:
    with psycopg2.connect(url) as conn:
        conn.autocommit = True
        with conn.cursor() as cur:
            for p in files:
                run_sql(cur, p)
    print("OK: rebuild done, smoke passed")
except Exception as e:
    print("ERROR:", e)
    sys.exit(1)
