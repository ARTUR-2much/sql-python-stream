-- =========================================================
-- 20_indexes.sql — индексы и уникальности
-- =========================================================

-- FK/часто используемые поля
CREATE INDEX IF NOT EXISTS idx_users_country           ON users(country_code);
CREATE INDEX IF NOT EXISTS idx_user_devices_user       ON user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_device     ON user_devices(device_id);
CREATE INDEX IF NOT EXISTS idx_content_genres_content  ON content_genres(content_id);
CREATE INDEX IF NOT EXISTS idx_content_genres_genre    ON content_genres(genre_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user      ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_watch_user_time         ON watch_events(user_id, watched_at);
CREATE INDEX IF NOT EXISTS idx_watch_content_time      ON watch_events(content_id, watched_at);
CREATE INDEX IF NOT EXISTS idx_ratings_content         ON ratings(content_id);

-- SCD2: единственная «текущая» версия на план
CREATE UNIQUE INDEX IF NOT EXISTS uq_plan_current
  ON subscription_plan_scd2(plan_code)
  WHERE is_current;

-- ускорение поиска версий «на дату X»
CREATE INDEX IF NOT EXISTS idx_plan_valid_from ON subscription_plan_scd2(plan_code, valid_from);
CREATE INDEX IF NOT EXISTS idx_plan_valid_to   ON subscription_plan_scd2(plan_code, valid_to);
