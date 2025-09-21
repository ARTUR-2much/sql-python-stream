@echo off
setlocal enabledelayedexpansion

rem === загрузим .env в текущую сессию ===
for /f "usebackq delims=" %%i in (".env") do set %%i

if "%DATABASE_URL%"=="" (
  echo ERROR: DATABASE_URL is empty. Fill .env first.
  exit /b 1
)

rem === убедимся, что psql доступен ===
where psql >nul 2>nul
if errorlevel 1 (
  echo ERROR: psql not found. Add to PATH, e.g.:
  echo   set "PATH=C:\Program Files\PostgreSQL\16\bin;%%PATH%%"
  exit /b 1
)

set PSQL=psql "%DATABASE_URL%" -v ON_ERROR_STOP=1
set STEPS=00_reset_schema.sql 10_tables.sql 20_indexes.sql 30_seed_static.sql 31_seed_users.sql 32_seed_links.sql 33_seed_facts.sql 99_smoke.sql

for %%S in (%STEPS%) do (
  echo ===== Running scripts\%%S =====
  %PSQL% -f "scripts\%%S" || goto :fail
)

echo SUCCESS
exit /b 0

:fail
echo FAILED on step %%S
exit /b 1
