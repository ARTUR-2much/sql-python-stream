-- =========================================================
-- 10_tables.sql — физическая модель (DDL)
-- =========================================================

-- таймзона
SET TIME ZONE 'UTC';

-- 1) Справочники
CREATE TABLE IF NOT EXISTS countries (
  country_code TEXT PRIMARY KEY,
  country_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS genres (
  genre_id   SERIAL PRIMARY KEY,
  genre_name TEXT   NOT NULL UNIQUE
);

-- 2) Пользователи и устройства
CREATE TABLE IF NOT EXISTS users (
  user_id       SERIAL PRIMARY KEY,
  email         TEXT        NOT NULL UNIQUE,
  full_name     TEXT        NOT NULL,
  country_code  TEXT        NOT NULL REFERENCES countries(country_code),
  registered_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS devices (
  device_id   SERIAL PRIMARY KEY,
  device_type TEXT   NOT NULL
);

CREATE TABLE IF NOT EXISTS user_devices (
  user_id   INT         NOT NULL REFERENCES users(user_id)   ON DELETE CASCADE,
  device_id INT         NOT NULL REFERENCES devices(device_id) ON DELETE CASCADE,
  bound_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, device_id)
);

-- 3) Контент и жанры (M:N)
CREATE TABLE IF NOT EXISTS content (
  content_id   SERIAL PRIMARY KEY,
  title        TEXT NOT NULL,
  release_year INT  NOT NULL CHECK (release_year BETWEEN 1900 AND 2100),
  age_rating   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS content_genres (
  content_id INT NOT NULL REFERENCES content(content_id) ON DELETE CASCADE,
  genre_id   INT NOT NULL REFERENCES genres(genre_id)   ON DELETE CASCADE,
  PRIMARY KEY (content_id, genre_id)
);

-- 4) SCD2 — версии тарифов/планов подписки (история изменений)
CREATE TABLE IF NOT EXISTS subscription_plan_scd2 (
  plan_code   TEXT        NOT NULL,
  version_num INT         NOT NULL CHECK (version_num > 0),
  plan_name   TEXT        NOT NULL,
  price       NUMERIC(8,2) NOT NULL CHECK (price > 0),
  valid_from  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  valid_to    TIMESTAMPTZ,
  is_current  BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (plan_code, version_num),
  CHECK (valid_from < COALESCE(valid_to, 'infinity'::timestamptz))
);

-- 5) Факт подписок — ссылка на конкретную версию тарифа (не на «текущий»!)
CREATE TABLE IF NOT EXISTS subscriptions (
  subscription_id SERIAL PRIMARY KEY,
  user_id     INT NOT NULL REFERENCES users(user_id),
  plan_code   TEXT NOT NULL,
  version_num INT  NOT NULL,
  started_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at    TIMESTAMPTZ,
  CHECK (started_at <= COALESCE(ended_at, 'infinity'::timestamptz)),
  FOREIGN KEY (plan_code, version_num)
    REFERENCES subscription_plan_scd2(plan_code, version_num)
);

-- 6) Просмотры и оценки
CREATE TABLE IF NOT EXISTS watch_events (
  event_id      BIGSERIAL PRIMARY KEY,
  user_id       INT NOT NULL REFERENCES users(user_id),
  content_id    INT NOT NULL REFERENCES content(content_id),
  device_id     INT NOT NULL REFERENCES devices(device_id),
  watched_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  watch_seconds INT NOT NULL CHECK (watch_seconds >= 0)
);

CREATE TABLE IF NOT EXISTS ratings (
  user_id     INT NOT NULL REFERENCES users(user_id)    ON DELETE CASCADE,
  content_id  INT NOT NULL REFERENCES content(content_id) ON DELETE CASCADE,
  rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  rated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, content_id)
);

-- Комментарии для удобства физической документации
COMMENT ON TABLE subscription_plan_scd2 IS 'SCD2: исторические версии тарифных планов';
COMMENT ON COLUMN subscription_plan_scd2.is_current IS 'TRUE только у одной версии на план (гарантия индексом в 20_indexes.sql)';
