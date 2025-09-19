-- ========= 31_seed_users.sql =========
SET TIME ZONE 'UTC';

INSERT INTO users(email, full_name, country_code, registered_at)
SELECT
  format('user%02s@example.com', g) AS email,
  format('User %02s', g)            AS full_name,
  (SELECT country_code FROM countries ORDER BY random() LIMIT 1),
  now() - (random()*365 || ' days')::interval
FROM generate_series(1,50) g
ON CONFLICT (email) DO NOTHING;
