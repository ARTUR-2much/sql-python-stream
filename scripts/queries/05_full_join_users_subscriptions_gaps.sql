-- Несостыковки: пользователи без подписок или подписки без пользователя
-- использование FULL JOIN
SELECT
  COALESCE(u.user_id, s.user_id) AS user_id,
  CASE
    WHEN u.user_id IS NULL THEN 'subscription_without_user'
    WHEN s.user_id IS NULL THEN 'user_without_subscription'
  END AS issue
FROM users u
FULL JOIN subscriptions s USING (user_id)
WHERE u.user_id IS NULL OR s.user_id IS NULL;
