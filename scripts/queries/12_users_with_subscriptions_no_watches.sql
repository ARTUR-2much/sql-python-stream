-- Пользователи с подпиской, но без просмотров
-- EXISTS/NO EXISTS
SELECT u.user_id, u.email
FROM users u
WHERE EXISTS (
  SELECT 1 FROM subscriptions s WHERE s.user_id = u.user_id
)
AND NOT EXISTS (
  SELECT 1 FROM watch_events w WHERE w.user_id = u.user_id
)
ORDER BY u.user_id
LIMIT 50;
