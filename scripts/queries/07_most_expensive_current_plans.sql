-- Самые дорогие текущие планы (price >= ALL(...))
-- подзапрос + ALL
SELECT plan_code, price
FROM subscription_plan_scd2
WHERE is_current
  AND price >= ALL (SELECT price FROM subscription_plan_scd2 WHERE is_current)
ORDER BY plan_code;
