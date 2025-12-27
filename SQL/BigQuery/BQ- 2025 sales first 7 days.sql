-- Params: replace @target_year if you want to filter a single season
-- or remove the WHERE to include all years.
WITH base AS (
  SELECT
    year,
    market,
    event_name,
    -- Price level = first character of price_code
    SUBSTR(price_code, 1, 1) AS price_level,
    DATE(purchase_date) AS purchase_date,
    SUM(paid_tickets) AS tix -- in case your source has multiple rows per day/PL
  FROM `tickets.fact_tickets_sold`
  WHERE year = 2025  -- optional filter
  GROUP BY 1,2,3,4,5
),

on_sale AS (
  SELECT
    year, market, event_name, price_level,
    MIN(purchase_date) AS on_sale_date
  FROM base
  GROUP BY 1,2,3,4
),

joined AS (
  SELECT
    b.year,
    b.market,
    b.event_name,
    b.price_level,
    o.on_sale_date,
    DATE_ADD(o.on_sale_date, INTERVAL 6 DAY) AS first_week_end,
    b.purchase_date,
    b.tix
  FROM base b
  JOIN on_sale o
    USING (year, market, event_name, price_level)
)

SELECT
  year,
  market,
  event_name,
  price_level,
  on_sale_date,
  first_week_end,
  SUM(CASE
        WHEN purchase_date BETWEEN on_sale_date AND first_week_end
        THEN tix ELSE 0 END) AS first_week_tix,
  SUM(tix) AS total_tix,
  SAFE_DIVIDE(
    SUM(CASE WHEN purchase_date BETWEEN on_sale_date AND first_week_end THEN tix ELSE 0 END),
    SUM(tix)
  ) AS svi_pct_first_week
FROM joined
GROUP BY
  year, market, event_name, price_level, on_sale_date, first_week_end
ORDER BY market, event_name, price_level;