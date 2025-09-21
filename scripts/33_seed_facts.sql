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

-- subscriptions: создаём корректные интервалы (ended_at >= started_at)
WITH pairs AS (
  -- тут как у тебя было: откуда берём пары пользователей/планов
  SELECT p.user_id, p.plan_code, p.version_num
  FROM (
    SELECT u.user_id
    FROM users u
    ORDER BY random()
    LIMIT 80
  ) u
  JOIN LATERAL (
    SELECT plan_code, version_num
    FROM subscription_plan_scd2
    ORDER BY random()
    LIMIT 1
  ) p ON true
),
dated AS (
  SELECT
    user_id,
    plan_code,
    version_num,
    /* старт: от 30 до 120 дней назад */
    (now() - ((30 + floor(random()*90))::int || ' days')::interval) AS started_at
  FROM pairs
)
INSERT INTO subscriptions (user_id, plan_code, version_num, started_at, ended_at)
SELECT
  d.user_id,
  d.plan_code,
  d.version_num,
  d.started_at,
  /* 50% активная подписка, иначе закончилась 1..60 дней спустя */
  CASE WHEN random() < 0.5 THEN NULL
       ELSE d.started_at + ((1 + floor(random()*60))::int || ' days')::interval
  END AS ended_at
FROM dated d
ON CONFLICT DO NOTHING;
