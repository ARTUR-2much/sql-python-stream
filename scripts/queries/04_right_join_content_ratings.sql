-- Кол-во оценок по контенту (RIGHT JOIN для покрытия требования)
-- использую тут RIGHT JOIN
SELECT
  c.content_id,
  c.title,
  COUNT(r.rating) AS cnt_ratings
FROM ratings r
RIGHT JOIN content c ON c.content_id = r.content_id
GROUP BY c.content_id, c.title
ORDER BY cnt_ratings DESC, c.content_id
LIMIT 20;
