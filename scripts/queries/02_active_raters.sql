-- Пользователи с >=3 оценками и средней оценкой >=4
-- использование GROUP BY, HAVING, ORDER BY
SELECT
  u.user_id,
  u.email,
  COUNT(*) AS cnt_ratings,
  ROUND(AVG(r.rating)::numeric,2) AS avg_rating
FROM users u
JOIN ratings r ON r.user_id = u.user_id
GROUP BY u.user_id, u.email
HAVING COUNT(*) >= 3 AND AVG(r.rating) >= 4
ORDER BY avg_rating DESC, cnt_ratings DESC, u.user_id;
