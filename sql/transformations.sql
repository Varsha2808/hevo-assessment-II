--Cleaned Customer model

SELECT
    t.customer_id,
    t.email,
    t.phone,
    COALESCE(d.iso_code, 'Unknown') AS country_code,
    t.created_at,
    t.updated_at
FROM (

    SELECT
        customer_id,
--Standardize emails to lowercase
        LOWER(TRIM(email)) AS email,

        CASE
            WHEN phone IS NULL OR TRIM(phone) = '' THEN 'Unknown'
            ELSE REGEXP_REPLACE(phone, '[^0-9]', '')
        END AS phone,

        /* Normalize country variations */
        CASE
            WHEN country_code IS NULL OR TRIM(country_code) = '' THEN 'Unknown'
            WHEN UPPER(TRIM(country_code)) IN ('US', 'USA', 'UNITEDSTATES')
                THEN 'United States'
            WHEN UPPER(TRIM(country_code)) IN ('IND', 'IN', 'INDIA')
                THEN 'India'
            WHEN UPPER(TRIM(country_code)) IN ('SG', 'SINGAPORE')
                THEN 'Singapore'
            ELSE TRIM(country_code)
        END AS normalized_country,

        COALESCE(created_at, '1900-01-01') AS created_at,
        updated_at,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC
        ) AS rn

    FROM customers_raw

) as t

LEFT JOIN country_dim d
    ON t.normalized_country = d.country_name

WHERE t.rn = 1
order by customer_id;


--Cleaned Orders table 

SELECT *
FROM (
    SELECT
        order_id,
        customer_id,
        product_id,
        CASE
            WHEN amount IS NULL OR amount < 0 THEN 0
            ELSE amount
        END AS cleaned_amount,
        UPPER(currency) AS currency,
        created_at,

        -- convert to USD
        CASE
            WHEN UPPER(currency) = 'USD' THEN cleaned_amount
            WHEN UPPER(currency) = 'INR' THEN cleaned_amount * 0.012
            WHEN UPPER(currency) = 'EUR' THEN cleaned_amount * 1.1
            WHEN UPPER(currency) = 'SGD' THEN cleaned_amount * 0.75
            ELSE amount
        END AS amount_usd,

        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY created_at
        ) AS rn
    FROM orders_raw
)
WHERE rn = 1
order by customer_id;





--Cleaned Product table

SELECT
    product_id,
    INITCAP(TRIM(product_name)) AS product_name,  -- Capitalizes first letter of each word
    INITCAP(TRIM(category)) AS category,          -- Capitalizes category
    CASE
        WHEN active_flag = 'N' THEN 'Discontinued Product'
        ELSE active_flag
    END AS product_status
FROM products_raw;




--Final dataset

SELECT
    o.order_id,
    o.customer_id,
    o.product_id,
    o.cleaned_amount AS amount,
    o.currency,
    o.amount_usd,
    o.created_at,

    -- Product info
    COALESCE(p.product_status, 'Unknown Product') AS product_status,
    COALESCE(p.category, 'Unknown Category') AS category,

    -- Customer info with edge cases
    CASE
        WHEN c.customer_id IS NULL THEN 'Orphan Customer'
        WHEN c.customer_id IS NOT NULL
             AND (c.email IS NULL OR TRIM(c.email) = '')
             AND (c.phone IS NULL OR TRIM(c.phone) = '')
             AND (c.country_code IS NULL OR TRIM(c.country_code) = '')
        THEN 'Invalid Customer'
        ELSE c.email
    END AS customer_email,

    CASE
        WHEN c.customer_id IS NULL THEN 'Unknown'
        ELSE COALESCE(c.phone, 'Unknown')
    END AS customer_phone,

    CASE
        WHEN c.customer_id IS NULL THEN 'Unknown'
        ELSE COALESCE(c.country_code, 'Unknown')
    END AS country_code

FROM cleaned_orders o
LEFT JOIN cleaned_customers c
    ON o.customer_id = c.customer_id
LEFT JOIN cleaned_products p
    ON o.product_id = p.product_id;
