-- Пользователи, смотревшие что-либо жанра 'Action'
-- использование подзапроса IN
SELECT DISTINCT w.user_id
FROM watch_events w
WHERE w.content_id IN (
  SELECT cg.content_id
  FROM content_genres cg
  JOIN genres g ON g.genre_id = cg.genre_id
  WHERE g.genre_name = 'Action'
)
ORDER BY w.user_id
LIMIT 50;
