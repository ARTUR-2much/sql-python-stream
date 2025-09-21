--smoke-tests


-- версии/БД
select version();
select current_database();

-- сводные количества
SELECT 'countries' t, count(*) FROM countries
UNION ALL SELECT 'devices', count(*) FROM devices
UNION ALL SELECT 'genres', count(*) FROM genres
UNION ALL SELECT 'content', count(*) FROM content
UNION ALL SELECT 'users', count(*) FROM users
UNION ALL SELECT 'subscription_plan_scd2', count(*) FROM subscription_plan_scd2
UNION ALL SELECT 'user_devices (M:N)', count(*) FROM user_devices
UNION ALL SELECT 'content_genres (M:N)', count(*) FROM content_genres
UNION ALL SELECT 'subscriptions', count(*) FROM subscriptions
UNION ALL SELECT 'watch_events', count(*) FROM watch_events
UNION ALL SELECT 'ratings', count(*) FROM ratings;

-- нормы ТЗ (должно вернуть 0 строк)
WITH significant AS (
  SELECT 'users' n, count(*) c, 15 min_req FROM users
  UNION ALL SELECT 'content', count(*), 15 FROM content
  UNION ALL SELECT 'devices', count(*), 15 FROM devices
  UNION ALL SELECT 'countries', count(*), 15 FROM countries
  UNION ALL SELECT 'genres', count(*), 15 FROM genres
  UNION ALL SELECT 'subscriptions', count(*), 15 FROM subscriptions
  UNION ALL SELECT 'watch_events', count(*), 15 FROM watch_events
  UNION ALL SELECT 'ratings', count(*), 15 FROM ratings
),
links AS (
  SELECT 'user_devices' n, count(*) c, 30 min_req FROM user_devices
  UNION ALL SELECT 'content_genres', count(*), 30 FROM content_genres
),
scd AS (
  SELECT 'subscription_plan_scd2' n, count(*) c, 30 min_req FROM subscription_plan_scd2
)
SELECT * FROM (
  SELECT * FROM significant
  UNION ALL SELECT * FROM links
  UNION ALL SELECT * FROM scd
) x
WHERE c < min_req;

-- SCD2: одна current-версия на план (должно вернуть 0 строк)
SELECT plan_code
FROM subscription_plan_scd2
GROUP BY plan_code
HAVING SUM(CASE WHEN is_current THEN 1 ELSE 0 END) <> 1;
