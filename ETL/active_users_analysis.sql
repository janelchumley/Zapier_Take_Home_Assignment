--CREATING VIEW IN MY SCHEMA
CREATE jchumley.active_users_analysis
AS
SELECT date, user_id, account_id,sum_tasks_used,
       SUM(sum_tasks_used) OVER (order by user_id, date rows unbounded preceding) as cum_sum_tasks_used,
    COALESCE(date - LAG(date) OVER (PARTITION BY user_id, account_id ORDER BY date),0) as num_days_since_last_active,
    CASE
        WHEN num_days_since_last_active < 28 THEN CAST(1 AS BOOLEAN)
        ELSE CAST(0 AS BOOLEAN)
    END
    AS active,
    CASE
       WHEN num_days_since_last_active > 27 and num_days_since_last_active < 56 THEN CAST(1 as BOOLEAN)
        ELSE CAST(0 as BOOLEAN)
    END
        AS churned,
    DATE_PART('month', date) as month_num,
   CASE
       WHEN DATE_PART('month', date) = 1 THEN 'January'
       WHEN DATE_PART('month', date) = 2 THEN 'February'
       WHEN DATE_PART('month', date) = 3 THEN 'March'
       WHEN DATE_PART('month', date) = 4 THEN 'April'
       WHEN DATE_PART('month', date) = 5 THEN 'May'
       WHEN DATE_PART('month', date) = 6 THEN 'June'
    END
       AS month,
    EXTRACT(DOW FROM date) as dow_num,
    CASE
       WHEN EXTRACT(DOW FROM date) = 0 THEN 'Sunday'
       WHEN EXTRACT(DOW FROM date) = 1 THEN 'Monday'
       WHEN EXTRACT(DOW FROM date) = 2 THEN 'Tuesday'
       WHEN EXTRACT(DOW FROM date) = 3 THEN 'Wednesday'
       WHEN EXTRACT(DOW FROM date) = 4 THEN 'Thursday'
       WHEN EXTRACT(DOW FROM date) = 5 THEN 'Friday'
       ELSE 'Saturday'
    END
       AS dow
FROM source_data.tasks_used_da
ORDER BY user_id, account_id, date;

CREATE VIEW jchumley.user_aggregates_by_date
AS(
SELECT date, SUM(sum_tasks_used) AS cum_sum_task_used, COUNT(distinct(user_id)) AS num_users,
       SUM(sum_tasks_used) as total_sum_tasks_used,
       SUM(sum_tasks_used)/count(user_id) AS average_tasks_used
FROM jchumley.active_users_analysis
GROUP BY date
ORDER BY date);

CREATE VIEW jchumley.total_sum_tasks_used
AS(
SELECT user_id, SUM(sum_tasks_used) as total_sum_tasks_used
FROM jchumley.active_users_analysis
GROUP BY user_id
ORDER BY user_id);
