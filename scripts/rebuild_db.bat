@echo off
setlocal enabledelayedexpansion
set "ROOT=%~dp0.."
pushd "%ROOT%"

set "DB="
for /f "usebackq tokens=1* delims==" %%A in (".env") do (
  if /I "%%A"=="DATABASE_URL" set "DB=%%B"
)
if "%DB%"=="" echo [ERR] DATABASE_URL не найден в .env & exit /b 1

where psql >nul 2>nul || (echo [ERR] psql не найден в PATH & exit /b 1)
set "OPTS=-v ON_ERROR_STOP=1"

echo [+] Reset schema
psql "%DB%" %OPTS% -f scripts/00_reset_schema.sql || goto :fail
echo [+] DDL
psql "%DB%" %OPTS% -f scripts/10_tables.sql || goto :fail
psql "%DB%" %OPTS% -f scripts/20_indexes.sql || goto :fail
echo [+] SEED
psql "%DB%" %OPTS% -f scripts/30_seed_static.sql || goto :fail
psql "%DB%" %OPTS% -f scripts/31_seed_users.sql  || goto :fail
psql "%DB%" %OPTS% -f scripts/32_seed_links.sql  || goto :fail
psql "%DB%" %OPTS% -f scripts/33_seed_facts.sql  || goto :fail
echo [+] SMOKE
psql "%DB%" %OPTS% -f scripts/99_smoke.sql || goto :fail

echo [OK] DB rebuilt successfully
popd & exit /b 0
:fail
echo [FAIL] See error above.
popd & exit /b 1
