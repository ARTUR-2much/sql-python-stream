-- Топ-10 контента по суммарному времени просмотров
SELECT
  c.content_id,
  c.title,
  SUM(w.watch_seconds) AS total_seconds
FROM watch_events w
JOIN content c ON c.content_id = w.content_id
GROUP BY c.content_id, c.title
HAVING SUM(w.watch_seconds) > 0
ORDER BY total_seconds DESC
LIMIT 10;
