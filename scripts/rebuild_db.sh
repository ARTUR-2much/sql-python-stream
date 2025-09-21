#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export $(grep -E '^DATABASE_URL=' "$ROOT/.env" | tr -d '\r') || true
[[ -z "${DATABASE_URL:-}" ]] && echo "[ERR] DATABASE_URL not set in .env" && exit 1
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/00_reset_schema.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/10_tables.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/20_indexes.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/30_seed_static.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/31_seed_users.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/32_seed_links.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/33_seed_facts.sql"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/scripts/99_smoke.sql"
echo "[OK] DB rebuilt successfully"
