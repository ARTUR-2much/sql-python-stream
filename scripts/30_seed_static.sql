-- ========= 30_seed_static.sql =========
SET TIME ZONE 'UTC';

-- страны (20 шт.)
INSERT INTO countries(country_code, country_name)
SELECT code, 'Country '||code
FROM (
  SELECT lpad(i::text,2,'0') AS num, ('C'||lpad(i::text,2,'0')) AS code
  FROM generate_series(1,20) AS g(i)
) s
ON CONFLICT (country_code) DO NOTHING;

-- устройства (15 шт.)
INSERT INTO devices(device_type)
SELECT 'device_type_'||g
FROM generate_series(1,15) g
ON CONFLICT DO NOTHING;

-- жанры (12 шт.)
INSERT INTO genres(genre_name)
SELECT unnest(ARRAY[
  'Action','Drama','Comedy','Sci-Fi','Thriller','Documentary',
  'Animation','Fantasy','Adventure','Crime','Romance','Mystery'
])
ON CONFLICT DO NOTHING;

-- контент (25 шт.)
INSERT INTO content(title, release_year, age_rating)
SELECT
  'Movie '||g,
  (1990 + (random()*34)::int),
  (ARRAY['G','PG','PG-13','R'])[1 + floor(random()*4)::int]
FROM generate_series(1,25) g
ON CONFLICT DO NOTHING;

-- SCD2: 5 планов * 6 версий = 30 версий (последняя текущая)
WITH plans AS (
  SELECT unnest(ARRAY['BASIC','STANDARD','FAMILY','KIDS','PRO']) AS plan_code
),
v AS (
  SELECT generate_series(1,6) AS version_num
)
INSERT INTO subscription_plan_scd2
  (plan_code, version_num, plan_name, price, valid_from, valid_to, is_current)
SELECT
  p.plan_code,
  v.version_num,
  p.plan_code||' v'||v.version_num,
  CASE p.plan_code
    WHEN 'BASIC'    THEN 4.99
    WHEN 'STANDARD' THEN 7.99
    WHEN 'FAMILY'   THEN 9.99
    WHEN 'KIDS'     THEN 3.99
    WHEN 'PRO'      THEN 12.99
  END + v.version_num*0.5,
  (DATE '2022-01-01' + (v.version_num-1)*INTERVAL '90 day')::timestamptz,
  CASE WHEN v.version_num<6
       THEN (DATE '2022-01-01' + (v.version_num)*INTERVAL '90 day')::timestamptz
       ELSE NULL
  END,
  (v.version_num = 6)
FROM plans p
CROSS JOIN v
ON CONFLICT DO NOTHING;

