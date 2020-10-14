--1. Taking a look at the first 100 rows of data in the subscriptions table

 SELECT *
 FROM subscriptions
 LIMIT 100;

--2. Determining the range of months of data provided

 SELECT MIN(subscription_start), MAX(subscription_start)
 FROM subscriptions;

--3. Creating a temporary table of months

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  )
SELECT *
FROM months;

--4. Creating a temporary table, cross_join, from subscriptions and months.

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months)

SELECT *
FROM cross_join
LIMIT 9; 

--5. Creating a temporary table, 

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, 
  first_day AS month,
  CASE
    WHEN segment = 87
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN segment = 30 
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0 
  END AS is_active_30
  FROM cross_join)
  SELECT *
  FROM status
  LIMIT 9;

--6.
 
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, 
  first_day AS month,
  CASE
    WHEN segment = 87
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN segment = 30 
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0 
  END AS is_active_30,  
  CASE
    WHEN segment = 87 
      AND subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled_87,
  CASE
    WHEN segment = 30 
      AND subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled_30  
FROM cross_join)
SELECT *
FROM status
LIMIT 9;

--7. 

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, 
  first_day AS month,
  CASE
    WHEN segment = 87
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN segment = 30 
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0 
  END AS is_active_30,  
  CASE
    WHEN segment = 87 
      AND subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled_87,
  CASE
    WHEN segment = 30 
      AND subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled_30  
FROM cross_join),
status_aggregate AS
(SELECT month,
  sum(is_active_87) AS sum_is_active_87,
  sum(is_active_30) AS sum_is_active_30,
  sum(is_canceled_87) AS sum_is_canceled_87,
  sum(is_canceled_30) AS sum_is_canceled_30
FROM status
GROUP BY month)

SELECT *
FROM status_aggregate;

--8. Calculating the churn rate

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT id, 
  first_day AS month,
  CASE
    WHEN segment = 87
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN segment = 30 
      AND (
        subscription_start < first_day
      ) 
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0 
  END AS is_active_30,  
  CASE
    WHEN segment = 87 
      AND subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled_87,
  CASE
    WHEN segment = 30 
      AND subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled_30  
FROM cross_join),
status_aggregate AS
(SELECT month,
  sum(is_active_87) AS sum_is_active_87,
  sum(is_active_30) AS sum_is_active_30,
  sum(is_canceled_87) AS sum_is_canceled_87,
  sum(is_canceled_30) AS sum_is_canceled_30
FROM status
GROUP BY month)

SELECT ROUND(1.0*SUM(sum_is_canceled_87)/SUM(sum_is_active_87),4) AS churn_rate_87, 
  ROUND(1.0*SUM(sum_is_canceled_30)/SUM(sum_is_active_30),4) AS churn_rate_30
FROM status_aggregate;

--9.

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT segment, id, 
  first_day AS month,
  CASE
    WHEN subscription_start < first_day
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0
  END AS is_active,
  CASE
    WHEN subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled 
FROM cross_join),
status_aggregate AS
(SELECT month, segment, SUM(is_active), SUM(is_canceled)
FROM status
GROUP BY segment, month)
SELECT *
FROM status_aggregate;

WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
  ),
cross_join AS
(SELECT subscriptions.* , months.*
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT segment, id, 
  first_day AS month,
  CASE
    WHEN subscription_start < first_day
      AND (
          subscription_end > first_day
          OR subscription_end IS NULL
      ) THEN 1 
    ELSE 0
  END AS is_active,
  CASE
    WHEN subscription_end > first_day 
      AND subscription_end < last_day
      THEN 1 
    ELSE 0
  END AS is_canceled 
FROM cross_join),
status_aggregate AS
(SELECT segment, 
ROUND(1.0*SUM(is_canceled)/SUM(is_active),4) AS churn_rate
FROM status
GROUP BY segment)

SELECT *
FROM status_aggregate;