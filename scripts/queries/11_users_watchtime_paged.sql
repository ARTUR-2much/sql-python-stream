-- Суммарное время просмотров по пользователям, страница 2 (по 20 строк)
-- оконные/агрегат + LIMIT/OFFSET
WITH totals AS (
  SELECT u.user_id, u.email, SUM(w.watch_seconds) AS total_sec
  FROM users u
  LEFT JOIN watch_events w ON w.user_id = u.user_id
  GROUP BY u.user_id, u.email
)
SELECT *
FROM totals
ORDER BY total_sec DESC NULLS LAST, user_id
LIMIT 20 OFFSET 20;  -- страница 2
