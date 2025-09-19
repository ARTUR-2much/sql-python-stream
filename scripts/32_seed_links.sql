-- ========= 32_seed_links.sql =========
SET TIME ZONE 'UTC';

-- каждому пользователю 1–3 устройства → обычно > 100 связок
INSERT INTO user_devices(user_id, device_id, bound_at)
SELECT DISTINCT u.user_id, d.device_id,
       now() - (random()*180 || ' days')::interval
FROM users u
JOIN LATERAL (
  SELECT device_id FROM devices ORDER BY random() LIMIT (1 + floor(random()*3))::int
) d ON TRUE
ON CONFLICT DO NOTHING;

-- каждому контенту 1–3 жанра → обычно > 50 связок
INSERT INTO content_genres(content_id, genre_id)
SELECT DISTINCT c.content_id, g.genre_id
FROM content c
JOIN LATERAL (
  SELECT genre_id FROM genres ORDER BY random() LIMIT (1 + floor(random()*3))::int
) g ON TRUE
ON CONFLICT DO NOTHING;
