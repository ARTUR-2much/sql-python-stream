-- Пользователи без единой оценки
-- Использую LEFT JOIN + HAVING
SELECT
  u.user_id,
  u.email
FROM users u
LEFT JOIN ratings r ON r.user_id = u.user_id
GROUP BY u.user_id, u.email
HAVING COUNT(r.*) = 0
ORDER BY u.user_id
LIMIT 20;
