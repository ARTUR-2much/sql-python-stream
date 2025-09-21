-- Пары контента, которые делят ≥2 общих жанра
-- самосоединение + HAVING
SELECT
  LEAST(cg1.content_id, cg2.content_id) AS content_a,
  GREATEST(cg1.content_id, cg2.content_id) AS content_b,
  COUNT(*) AS common_genres
FROM content_genres cg1
JOIN content_genres cg2
  ON cg1.genre_id = cg2.genre_id
 AND cg1.content_id < cg2.content_id
GROUP BY LEAST(cg1.content_id, cg2.content_id), GREATEST(cg1.content_id, cg2.content_id)
HAVING COUNT(*) >= 2
ORDER BY common_genres DESC, content_a, content_b
LIMIT 20;
