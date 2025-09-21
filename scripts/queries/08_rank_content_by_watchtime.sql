-- Ранжирование контента по суммарному времени просмотров
-- Оконный sum() и dense_mark() !
WITH sums AS (
  SELECT c.content_id, c.title, SUM(w.watch_seconds) AS total_sec
  FROM content c
  JOIN watch_events w ON w.content_id = c.content_id
  GROUP BY c.content_id, c.title
)
SELECT
  content_id,
  title,
  total_sec,
  DENSE_RANK() OVER (ORDER BY total_sec DESC) AS rnk
FROM sums
ORDER BY rnk, content_id
LIMIT 25;
