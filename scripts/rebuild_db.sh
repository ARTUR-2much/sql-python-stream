#!/usr/bin/env bash
set -euo pipefail

# загрузим .env
if [ -f ".env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' .env | xargs)
fi

if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: DATABASE_URL is empty. Fill .env first."
  exit 1
fi

command -v psql >/dev/null 2>&1 || { echo "ERROR: psql not found in PATH"; exit 1; }

STEPS=(
  scripts/00_reset_schema.sql
  scripts/10_tables.sql
  scripts/20_indexes.sql
  scripts/30_seed_static.sql
  scripts/31_seed_users.sql
  scripts/32_seed_links.sql
  scripts/33_seed_facts.sql
  scripts/99_smoke.sql
)

for s in "${STEPS[@]}"; do
  echo "===== Running $s ====="
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$s"
done

echo "SUCCESS"
