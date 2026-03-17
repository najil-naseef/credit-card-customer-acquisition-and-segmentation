-- === ANALYSIS 1: DEMOGRAPHIC CLASSIFICATION === -- 

--Customer Distribution by Age Group
SELECT 
    age_group AS segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM customers), 2) AS percentage
FROM customers
GROUP BY age_group
ORDER BY percentage DESC; 


--Customer Distribution by Gender 
SELECT 
    gender AS segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM customers), 2) AS percentage
FROM customers
GROUP BY gender
ORDER BY percentage DESC;


--Customer Distribution by Occupation
SELECT 
    occupation AS segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM customers), 2) AS percentage
FROM customers
GROUP BY occupation
ORDER BY percentage DESC;

--Customer Distribution by City
SELECT 
    city AS segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM customers), 2) AS percentage
FROM customers
GROUP BY city
ORDER BY percentage DESC;



-- === ANALYSIS 2: INCOME UTILISATION % (THE KEY METRIC) === --

--Overall Average Income Utilisation %
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.avg_income,
        SUM(t.spend) AS total_spend
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.avg_income
)
SELECT 
    ROUND(AVG((total_spend / NULLIF(avg_income * 6, 0)) * 100), 2) AS overall_avg_income_utilisation_pct
FROM customer_spending;


--Income Utilisation % by Age Group
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.age_group,
        c.avg_income,
        SUM(t.spend) AS total_spend
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.age_group, c.avg_income
)
SELECT 
    age_group,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(avg_income), 2) AS avg_monthly_income,
    ROUND(AVG(total_spend), 2) AS avg_6month_spend,
    ROUND(AVG((total_spend / NULLIF(avg_income * 6, 0)) * 100), 2) AS income_utilisation_pct
FROM customer_spending
GROUP BY age_group
ORDER BY income_utilisation_pct desc;


--Income Utilisation % by Gender
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.gender,
        c.avg_income,
        SUM(t.spend) AS total_spend
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.gender, c.avg_income
)
SELECT 
    gender,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(avg_income), 2) AS avg_monthly_income,
    ROUND(AVG(total_spend), 2) AS avg_6month_spend,
    ROUND(AVG((total_spend / NULLIF(avg_income * 6, 0)) * 100), 2) AS income_utilisation_pct
FROM customer_spending
GROUP BY gender
ORDER BY income_utilisation_pct DESC;


--Income Utilisation % by Occupation

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.occupation,
        c.avg_income,
        SUM(t.spend) AS total_spend
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.occupation, c.avg_income
)
SELECT 
    occupation,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(avg_income), 2) AS avg_monthly_income,
    ROUND(AVG(total_spend), 2) AS avg_6month_spend,
    ROUND(AVG((total_spend / NULLIF(avg_income * 6, 0)) * 100), 2) AS income_utilisation_pct
FROM customer_spending
GROUP BY occupation
ORDER BY income_utilisation_pct DESC;


--Income Utilisation % by City

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.city,
        c.avg_income,
        SUM(t.spend) AS total_spend
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.city, c.avg_income
)
SELECT 
    city,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(avg_income), 2) AS avg_monthly_income,
    ROUND(AVG(total_spend), 2) AS avg_6month_spend,
    ROUND(AVG((total_spend / NULLIF(avg_income * 6, 0)) * 100), 2) AS income_utilisation_pct
FROM customer_spending
GROUP BY city
ORDER BY income_utilisation_pct DESC;



-- === ANALYSIS 3: SPENDING INSIGHTS === --

--Spending by Category & Age Group

SELECT 
    c.age_group,
    t.category,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(SUM(t.spend), 2) AS total_spend,
    ROUND(SUM(t.spend) / COUNT(DISTINCT c.customer_id), 2) AS avg_spend_per_customer,
    ROUND(SUM(t.spend) * 100.0 / SUM(SUM(t.spend)) OVER (PARTITION BY c.age_group), 2) AS pct_of_age_group_spend
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.category IS NOT NULL
GROUP BY c.age_group, t.category
ORDER BY c.age_group, total_spend DESC;


--Spending by Category & Gender

SELECT 
    c.gender,
    t.category,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(SUM(t.spend), 2) AS total_spend,
    ROUND(SUM(t.spend) / COUNT(DISTINCT c.customer_id), 2) AS avg_spend_per_customer,
    ROUND(SUM(t.spend) * 100.0 / SUM(SUM(t.spend)) OVER (PARTITION BY c.gender), 2) AS pct_of_gender_spend
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.category IS NOT NULL
GROUP BY c.gender, t.category
ORDER BY c.gender, total_spend DESC;


-- Top Spending Categories by City

SELECT 
    c.city,
    t.category,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(SUM(t.spend), 2) AS total_spend,
    ROUND(SUM(t.spend) / COUNT(DISTINCT c.customer_id), 2) AS avg_spend_per_customer,
    ROUND(SUM(t.spend) * 100.0 / SUM(SUM(t.spend)) OVER (PARTITION BY c.city), 2) AS pct_of_city_spend
FROM customers c
INNER JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.category IS NOT NULL
GROUP BY c.city, t.category
ORDER BY c.city, total_spend DESC;


-- === ANALYSIS 4: KEY CUSTOMER SEGMENTS === --

-- High-Value Customer Segments (Income Utilisation Tiers)

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.age_group,
        c.gender,
        c.occupation,
        c.city,
        c.avg_income,
        ROUND(SUM(t.spend), 2) AS total_spend,
        ROUND((SUM(t.spend) / NULLIF(c.avg_income * 6, 0)) * 100, 2) AS income_utilisation_pct
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.age_group, c.gender, c.occupation, c.city, c.avg_income
)
SELECT 
    CASE 
        WHEN income_utilisation_pct >= 50 THEN 'High Utilisation (>=50%)'
        WHEN income_utilisation_pct >= 30 THEN 'Medium Utilisation (30-49%)'
        ELSE 'Low Utilisation (<30%)'
    END AS utilisation_segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(avg_income), 2) AS avg_monthly_income,
    ROUND(AVG(total_spend), 2) AS avg_6month_spend,
    ROUND(AVG(income_utilisation_pct), 2) AS avg_income_utilisation_pct,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customer_spending), 2) AS pct_of_total_customers
FROM customer_spending
GROUP BY utilisation_segment
ORDER BY avg_income_utilisation_pct DESC;


-- Top Segment Profiles (Demographics + Spending + Income Utilisation)

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.age_group,
        c.gender,
        c.occupation,
        c.city,
        c.avg_income,
        ROUND(SUM(t.spend), 2) AS total_spend,
        ROUND((SUM(t.spend) / NULLIF(c.avg_income * 6, 0)) * 100, 2) AS income_utilisation_pct
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.age_group, c.gender, c.occupation, c.city, c.avg_income
)
SELECT 
    age_group,
    gender,
    occupation,
    city,
    COUNT(DISTINCT customer_id) AS segment_size,
    ROUND(AVG(avg_income), 2) AS avg_monthly_income,
    ROUND(AVG(total_spend), 2) AS avg_6month_spend,
    ROUND(AVG(income_utilisation_pct), 2) AS avg_income_utilisation_pct,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customer_spending), 2) AS pct_of_total_customers
FROM customer_spending
GROUP BY age_group, gender, occupation, city
HAVING COUNT(DISTINCT customer_id) >= 15
ORDER BY avg_income_utilisation_pct DESC
LIMIT 15;















