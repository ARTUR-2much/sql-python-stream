-- Длительность версии тарифа и зазор до следующей версии
-- оконные LEAD() + расчет длительности
SELECT
  plan_code,
  version_num,
  valid_from,
  valid_to,
  (COALESCE(valid_to, NOW()) - valid_from) AS duration,
  (LEAD(valid_from) OVER (PARTITION BY plan_code ORDER BY version_num) - valid_from) AS gap_to_next_start
FROM subscription_plan_scd2
ORDER BY plan_code, version_num;
