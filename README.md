# Mini Streaming — SQL + Python

Учебный мини-стриминг: пользователи смотрят контент, ставят оценки и оформляют подписки. Тарифы ведём с историей версий (**SCD2**) — можем корректно отвечать на вопрос «что действовало на дату X».

---

## О проекте
Мини-стриминг с сущностями:
- **users**, **devices**, **user_devices (M:N)**
- **content**, **genres**, **content_genres (M:N)**
- **watch_events** (просмотры), **ratings** (оценки)
- **subscription_plan_scd2** (версионные тарифы, SCD2), **subscriptions** (факты подписок со ссылкой на *конкретную версию* тарифа).

Цель: показать полный путь от ER‑моделей до физической реализации, загрузки данных, аналитики (JOIN/подзапросы/оконные) и воспроизводимости проекта «с нуля» одной командой.

---

## Структура репозитория
```text
.
├─ .gitignore
├─ .gitlab-ci.yml
├─ .github/workflows/ci.yml
├─ README.md
├─ requirements.txt
├─ .env.example
├─ docs/
│  ├─ conceptual-model.mmd
│  ├─ logical-model.mmd
│  ├─ physical-model.md
│  └─ physical-model.png          # экспорт ER из DBeaver
├─ scripts/
│  ├─ 00_reset_schema.sql
│  ├─ 10_tables.sql
│  ├─ 20_indexes.sql
│  ├─ 30_seed_static.sql
│  ├─ 31_seed_users.sql
│  ├─ 32_seed_links.sql
│  ├─ 33_seed_facts.sql
│  ├─ 99_smoke.sql
│  ├─ rebuild_db.bat              # Windows
│  └─ rebuild_db.sh               # Linux/Mac
├─ scripts/queries/               # ≥10 аналитических запросов .sql
├─ src/
│  └─ run_queries.py              # выгрузка результатов queries/ в CSV
└─ data/
   └─ out/
      └─ .gitkeep                 # CSV не коммитятся
```

---

## Модели
- **Концептуальная** (без нормализации, ≥5 сущностей): `docs/conceptual-model.mmd`
- **Логическая** (3НФ + SCD2): `docs/logical-model.mmd`
- **Физическая**: обоснование — `docs/physical-model.md`, диаграмма — `docs/physical-model.png` (экспорт из DBeaver)

---

## Почему 3НФ и как устроен SCD2
**3НФ.** Нормализация до 3НФ убирает транзитивные зависимости и дубли: справочники вынесены отдельно, связи многие‑ко‑многим оформлены отдельными таблицами (`user_devices`, `content_genres`), факты содержат только ключевые зависимости от измерений.

**SCD2.** Таблица `subscription_plan_scd2(plan_code, version_num, plan_name, price, valid_from, valid_to, is_current)` хранит историю версий тарифов.
- Единичность «текущей» версии на `plan_code` обеспечивает **partial unique** индекс: `UNIQUE (plan_code) WHERE is_current`.
- Факт `subscriptions` хранит ссылку на **конкретную версию** `(plan_code, version_num)` — аналитика «на дату X» корректна и воспроизводима.

---

## Физическая модель
- **Картинка:** `docs/physical-model.png` (ER‑диаграмма, экспорт из DBeaver).
- **Комментарии:** `docs/physical-model.md` — типы данных, PK/FK/UNIQUE/CHECK, `ON DELETE CASCADE` для M:N, частичные индексы для SCD2.

---

## Требования к окружению
- Windows / Linux / macOS
- Python 3.11+
- PostgreSQL 16+ (включая `psql` client)
- (опционально) DBeaver

---

## Сценарии использования

### 1) Подготовка окружения
```bash
python -m venv .venv
# Windows:
.\.venv\Scripts\activate
# Linux/Mac:
# source .venv/bin/activate
pip install -r requirements.txt
# Windows:
copy .env.example .env
# Linux/Mac:
# cp .env.example .env

Если `psql` не найден (Windows):
1) Установите PostgreSQL с «Command Line Tools».
2) На эту сессию CMD добавьте путь:
    ```
    set "PATH=C:\Program Files\PostgreSQL\16\bin;%PATH%"
    ```
    (подставьте вашу версию 15/16/17)
3) Проверка: `where psql`

```

### 2) Указать пароль
Откройте `.env` и задайте строку подключения к своей локальной БД:
```text
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/mini_stream
```

### 3) Пересобрать БД одной командой
**Windows:**
```
scripts\rebuild_db.bat
```
**Linux/Mac:**
```bash
bash scripts/rebuild_db.sh

**Нет psql?** Можно пересобрать через Python:
python scripts\rebuild_db.py

```
Скрипты выполняют: сброс схемы → DDL (`10_tables.sql`, `20_indexes.sql`) → сиды (`30..33`) → smoke (`99_smoke.sql`). При ошибке процесс останавливается.

### 4) Выполнить аналитические запросы и выгрузить CSV
```bash
# при необходимости активируйте venv
python src/run_queries.py
# CSV → data/out/*.csv  (файлы игнорируются .gitignore)
```

---

## Проверки (smoke)
Чтобы убедиться, что всё соответствует ТЗ, просто запустите:
```bash
# Windows
psql "%DATABASE_URL%" -v ON_ERROR_STOP=1 -f scripts/99_smoke.sql
# Linux/Mac
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f scripts/99_smoke.sql
```
Внутри `scripts/99_smoke.sql`:
- проверка порогов по количеству строк (значимые ≥15; M:N ≥30; SCD2 ≥30);
- в каждом `plan_code` ровно одна текущая версия (`is_current=true`).

---

## Скрипты и очередность запуска
| Файл | Назначение |
|---|---|
| `scripts/00_reset_schema.sql` | Полный сброс/создание схемы `public` |
| `scripts/10_tables.sql` | DDL таблиц (PK/FK/UNIQUE/CHECK, SCD2) |
| `scripts/20_indexes.sql` | Индексы, в т.ч. partial unique для SCD2 |
| `scripts/30_seed_static.sql` | Страны/устройства/жанры/контент + версии SCD2 |
| `scripts/31_seed_users.sql` | Пользователи |
| `scripts/32_seed_links.sql` | Связи M:N (`user_devices`, `content_genres`) |
| `scripts/33_seed_facts.sql` | Подписки/просмотры/оценки |
| `scripts/99_smoke.sql` | Комплексные проверки ТЗ |
| `scripts/rebuild_db.bat` / `scripts/rebuild_db.sh` | Полная пересборка локально |
| `src/run_queries.py` | Выполняет все `scripts/queries/*.sql`, сохраняет в `data/out/` |

**Очередность:** `00 → 10 → 20 → 30 → 31 → 32 → 33 → 99`.

---

## Где это можно использовать
- Обучение и демонстрация моделирования (концепт → логика → физика + SCD2).
- Мини‑шаблон ODS/DWH для стриминговой доменной области.
- Демоданные и проверка аналитических запросов (JOIN/подзапросы/оконные).

---

## CI (GitHub Actions / GitLab)
**GitHub Actions:**
1) Settings → Secrets and variables → Actions → New repository secret:
   - Name: `PGPASSWORD`
   - Value: пароль для контейнера (используется в workflow).
2) Запустите workflow на ветке `main` — он поднимет контейнер Postgres и выполнит 10/20/30/31/32/33/99.
3) **GitLab**: `.gitlab-ci.yml` приложен для соответствия ТЗ (на GitHub не исполняется).

> CI работает только с контейнерной БД на раннере и не взаимодействует с вашей локальной установкой.

---

## Безопасность секретов
- `.env` не коммитится (`.gitignore`), `.env.example` — без паролей.
- Хардкода секретов в коде/README нет.
- В CI используется Secret `PGPASSWORD`; GitHub маскирует значение в логах.

---

## Лицензия
MIT — см. `LICENSE`.
