-- ========= 33_seed_facts.sql =========
SET TIME ZONE 'UTC';

-- подписки: по 1 текущей подписке на пользователя (>=50)
INSERT INTO subscriptions(user_id, plan_code, version_num, started_at, ended_at)
SELECT
  u.user_id,
  cp.plan_code, cp.version_num,
  now() - (random()*300 || ' days')::interval AS started_at,
  CASE WHEN random() < 0.25
       THEN now() - (random()*30 || ' days')::interval
       ELSE NULL
  END AS ended_at
FROM users u
JOIN LATERAL (
  SELECT plan_code, version_num
  FROM subscription_plan_scd2
  WHERE is_current
  ORDER BY random()
  LIMIT 1
) cp ON TRUE;

-- просмотры: берём пары user-device и рандомный контент → ~300+ событий
INSERT INTO watch_events(user_id, content_id, device_id, watched_at, watch_seconds)
SELECT
  ud.user_id,
  c.content_id,
  ud.device_id,
  now() - (random()*90 || ' days')::interval,
  (30 + floor(random()*5400))::int
FROM user_devices ud
JOIN LATERAL (
  SELECT content_id FROM content ORDER BY random() LIMIT 3
) c ON TRUE;

-- оценки: 80 уникальных пар (user, content)
WITH uc AS (
  SELECT u.user_id, c.content_id
  FROM (SELECT user_id FROM users ORDER BY random() LIMIT 60) u
  CROSS JOIN (SELECT content_id FROM content ORDER BY random() LIMIT 20) c
),
pairs AS (
  SELECT DISTINCT ON (user_id, content_id) user_id, content_id
  FROM uc
  ORDER BY user_id, content_id
)
INSERT INTO ratings(user_id, content_id, rating, rated_at)
SELECT p.user_id, p.content_id,
       (1 + floor(random()*5))::int,
       now() - (random()*120 || ' days')::interval
FROM pairs p
LIMIT 80
ON CONFLICT DO NOTHING;

