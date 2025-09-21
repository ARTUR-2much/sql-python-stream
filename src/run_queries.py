import os, csv, glob
from pathlib import Path
from datetime import datetime

import psycopg2
from dotenv import load_dotenv

# --- пути ---
ROOT = Path(__file__).resolve().parents[1]
QUERIES_DIR = ROOT / "scripts" / "queries"
OUT_DIR = ROOT / "data" / "out"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# --- подключение ---
load_dotenv(ROOT / ".env")
DATABASE_URL = os.getenv("DATABASE_URL")
assert DATABASE_URL, "DATABASE_URL is missing in .env"

def run_sql(sql: str, conn):
    with conn.cursor() as cur:
        cur.execute(sql)
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        return cols, rows

def save_csv(path: Path, cols, rows):
    # utf-8-sig, чтобы Excel открыл русские заголовки корректно
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(cols)
        w.writerows(rows)

def main():
    files = sorted(QUERIES_DIR.glob("*.sql"))
    if not files:
        print(f"Нет SQL-файлов в {QUERIES_DIR}")
        return

    print(f"Нашёл {len(files)} .sql, запускаю...")
    ok, fail = 0, 0
    with psycopg2.connect(DATABASE_URL) as conn:
        for fp in files:
            sql = fp.read_text(encoding="utf-8")
            try:
                cols, rows = run_sql(sql, conn)
                out_name = fp.stem + ".csv"
                save_csv(OUT_DIR / out_name, cols, rows)
                print(f"[OK] {fp.name} -> {out_name} ({len(rows)} rows)")
                ok += 1
            except Exception as e:
                fail += 1
                err = f"{datetime.now().isoformat()} {fp.name}: {e}\n"
                (OUT_DIR / "_errors.log").write_text(
                    ((OUT_DIR / "_errors.log").read_text(encoding="utf-8") if (OUT_DIR / "_errors.log").exists() else "") + err,
                    encoding="utf-8"
                )
                print(f"[FAIL] {fp.name}: {e}")

    print(f"Готово. Успешно: {ok}, ошибок: {fail}. Результаты: {OUT_DIR}")

if __name__ == "__main__":
    main()
