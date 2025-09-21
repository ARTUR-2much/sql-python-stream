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

-- subscriptions: корректные интервалы (ended_at >= started_at)
WITH pairs AS (
  /* 80 случайных пользователей + случайная версия плана */
  SELECT
    u.user_id,               -- ВАЖНО: user_id идёт из u, а не из p
    p.plan_code,
    p.version_num
  FROM (
    SELECT user_id
    FROM users
    ORDER BY random()
    LIMIT 80
  ) AS u
  JOIN LATERAL (
    SELECT plan_code, version_num
    FROM subscription_plan_scd2
    ORDER BY random()
    LIMIT 1
  ) AS p ON true
),
dated AS (
  SELECT
    user_id,
    plan_code,
    version_num,
    /* старт: 30..120 дней назад */
    (now() - ((30 + floor(random()*90))::int || ' days')::interval) AS started_at
  FROM pairs
)
INSERT INTO subscriptions (user_id, plan_code, version_num, started_at, ended_at)
SELECT
  d.user_id,
  d.plan_code,
  d.version_num,
  d.started_at,
  /* 50% активных (NULL), иначе закончилась 1..60 дней ПОСЛЕ старта */
  CASE WHEN random() < 0.5 THEN NULL
       ELSE d.started_at + ((1 + floor(random()*60))::int || ' days')::interval
  END AS ended_at
FROM dated AS d
ON CONFLICT DO NOTHING;
