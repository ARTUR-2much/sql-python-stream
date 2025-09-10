# Физическая модель — обоснование

**Нормальная форма:** 3НФ. Повторяющиеся группы вынесены в связки M:N (`CONTENT_GENRES`, `USER_DEVICES`), справочники (`COUNTRIES`, `GENRES`) исключают дубли. Все неключевые атрибуты зависят только от ключей своих таблиц.

**Версионирование (SCD2):** `SUBSCRIPTION_PLAN_SCD2` хранит историю тарифов: `(plan_code, version_num, valid_from, valid_to=NULL для текущей, is_current=TRUE)`. Факт `SUBSCRIPTIONS` ссылается на конкретную версию `(plan_code, version_num)`, поэтому можно отвечать «что действовало на дату X».

**Ограничения (в DDL):** PK/UK, FK с осмысленным ON DELETE, CHECK (например, `rating BETWEEN 1 AND 5`, `watch_seconds>=0`), частично-уникальный индекс на `SUBSCRIPTION_PLAN_SCD2(plan_code) WHERE is_current`.
