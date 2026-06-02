WITH filtered_sales AS (
  SELECT f.*
  FROM `tickets.fact_tickets_sold` AS f
  WHERE f.year = 2025
    AND (
      (f.market = 'Albany'             AND SUBSTR(f.price_code, 1, 1) IN ('A','O','J')) OR
      (f.market = 'Baltimore'          AND SUBSTR(f.price_code, 1, 1) IN ('A','M')) OR
      (f.market = 'Boston/Harvard'     AND SUBSTR(f.price_code, 1, 1) IN ('A','L','I')) OR
      (f.market = 'Champ Series'       AND SUBSTR(f.price_code, 1, 1) IN ('A','F','G','E')) OR
      (f.market = 'Red Bull'           AND SUBSTR(f.price_code, 1, 1) IN ('A')) OR
      (f.market = 'Charlotte'          AND SUBSTR(f.price_code, 1, 1) IN ('A','I','K')) OR
      (f.market = 'Denver'             AND SUBSTR(f.price_code, 1, 1) IN ('1','A')) OR
      (f.market = 'Fairfield'          AND SUBSTR(f.price_code, 1, 1) IN ('1','A','C','3')) OR
      (f.market = 'Minnesota'          AND SUBSTR(f.price_code, 1, 1) IN ('A','K','J')) OR
      (f.market = 'Philly/Nova'        AND SUBSTR(f.price_code, 1, 1) IN ('A','J','G')) OR
      (f.market = 'Salt Lake City'     AND SUBSTR(f.price_code, 1, 1) IN ('A','I','M')) OR
      (f.market = 'San Diego'          AND SUBSTR(f.price_code, 1, 1) IN ('A','K','I')) OR
      (f.market = 'Philly/Subaru Park' AND SUBSTR(f.price_code, 1, 1) IN ('1','A'))
    )
)

SELECT DISTINCT dem.*
FROM `pll-data-warehouse.ticketmaster.data_enrich_master` AS dem
JOIN `tickets.fact_ticket_to_pll_id` AS m
  ON dem.acct_id = m.PLL_ID         -- adjust column name case if needed
JOIN filtered_sales AS f
  ON LOWER(TRIM(m.email)) = LOWER(TRIM(f.email_address));
