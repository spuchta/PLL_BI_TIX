WITH raw AS (
  -- 2025 TM Venues
  SELECT
    CAST(EXTRACT(YEAR FROM PARSE_DATE(
      IF(
        LENGTH(SPLIT(event_date, '/')[OFFSET(2)]) = 2, -- Check if year is 2 digits
        '%m/%d/%y', -- Format for 2-digit year
        '%m/%d/%Y'  -- Format for 4-digit year
      ), 
      event_date)) AS INT64) AS year,
    ref_dim_event_name.market, --market tied to price code
    ticket_day,
    acct_id,
    LOWER(TRIM(email_addr)) AS email_address, -- email/zip attached to acct_id
    CASE
      -- WHEN SUBSTR(ticket_type, -7, 7) = "Renewal" THEN "group"
      WHEN
        LOWER(ticket_type_category) = "premium experience" OR
        LOWER(ticket_type_category) = "upgrade" OR
        premium_add_on_event = true
      THEN "premium_add_on"
      WHEN
        ticket_type_category IS NULL OR 
        LOWER(ticket_type_category) = "nan" OR 
        LOWER(ticket_type_category) = "full price" OR -- new SP adjust
        (LOWER(ticket_type_category) = "package" AND add_usr = "inet01") -- new SP adjust
        -- LOWER(ticket_type_category) = "full price" OR ( OLD MB
        --   (ticket_type_category = "Package" OR lower(ticket_type_category) = "hcp renewal") AND  
        --   add_usr = "inet01"
        -- ) 
        THEN "non_internal"
      WHEN ticket_type_category = "Complimentary" THEN "comp"
      WHEN LOWER(ticket_type_category) = "suites" THEN "suite"
      WHEN
        LOWER(ticket_type_category) = "group" OR -- adjust
        LOWER(ticket_type_category) = "hcp renewal" OR --adjust
        (LOWER(ticket_type_category) = "package" AND add_usr != "inet01") --adjust
      THEN "group"
      ELSE LOWER(ticket_type_category)
    END AS ticket_category,
    CASE
      WHEN plan_event_name = "25CSALL" THEN "all_access"
      WHEN plan_event_name = "25CSFLEX" THEN "flex_pass"
      WHEN SUBSTR(ticket_type, -7, 7) = "Renewal" THEN "homecoming_pass_renewal"
      WHEN SUBSTR(event_name, -4, 4) = "PLUS" THEN "homecoming_pass_plus"
      WHEN SUBSTR(event_name, -3, 3) = "VIP" THEN "homecoming_pass_vip"
      WHEN SUBSTR(plan_event_name, -2, 2) = "HP" THEN "homecoming_pass"
      ELSE NULL
    END AS plan_name,
    CASE WHEN comp = "Y" THEN TRUE WHEN comp = "N" THEN FALSE ELSE NULL END AS comp,
    price_code,
    LEFT(price_code, 1) AS parent_price_code,
    PARSE_DATE(
      IF(
        LENGTH(SPLIT(SPLIT(add_datetime, " ")[OFFSET(0)], '/')[OFFSET(2)]) = 2, -- Check if year is 2 digits
        '%m/%d/%y', -- Format for 2-digit year
        '%m/%d/%Y'  -- Format for 4-digit year
      ), 
      SPLIT(add_datetime, " ")[OFFSET(0)]
    ) AS purchase_date,
    PARSE_DATE(
      IF(
        LENGTH(SPLIT(event_date, '/')[OFFSET(2)]) = 2, -- Check if year is 2 digits
        '%m/%d/%y', -- Format for 2-digit year
        '%m/%d/%Y'  -- Format for 4-digit year
      ),
      event_date
    ) AS event_date,
    time_of_day,
    DATE_DIFF(end_date, PARSE_DATE(
      IF(
        LENGTH(SPLIT(SPLIT(add_datetime, " ")[OFFSET(0)], '/')[OFFSET(2)]) = 2, -- Check if year is 2 digits
        '%m/%d/%y', -- Format for 2-digit year
        '%m/%d/%Y'  -- Format for 4-digit year
      ), 
      SPLIT(add_datetime, " ")[OFFSET(0)]
    ), DAY) AS days_from_event,
    (purchase_price + coalesce(retail_facility_fee, 0)) * num_seats AS revenue,
    CASE
      WHEN event_name = "25CSALL" THEN num_seats*9 
      WHEN STARTS_WITH(event_name, "D") THEN 0
      ELSE num_seats 
    END AS num_seats,
    CASE
      WHEN substr(price_code, -3, 3) = "OWC" THEN num_seats -- Community or Club Program tickets
      WHEN
        ticket_type_category = "Premium Add On" OR 
        STARTS_WITH(event_name, "D") OR
        comp = "Y" OR 
        purchase_price = 0 OR 
        premium_add_on_event = TRUE OR
        SUBSTR(event_name, -4, 4) = "PLUS" OR
        SUBSTR(event_name, -3, 3) = "VIP"
        THEN 0
      WHEN event_name = "25CSALL" THEN num_seats*9
      ELSE num_seats
    END AS paid_tickets,
    CASE
      WHEN premium_add_on_event = TRUE then 0
      WHEN substr(price_code, -3, 3) = "OWC" THEN 0 -- Community or Club Program tickets
      WHEN comp = "Y" OR purchase_price = 0 THEN num_seats 
      WHEN STARTS_WITH(event_name, "D") THEN 0
      ELSE 0
    END AS comp_tickets,
    CAST(cs.zip AS STRING) AS zip,
    NULL AS legacy_event_name,
    NULL AS legacy_ticket_type_category,
    CASE 
      WHEN STARTS_WITH(event_name, '25') AND ENDS_WITH(event_name, 'VIP') THEN 'plan_not_expanded' --'plan_vip_upgrade'
      WHEN STARTS_WITH(event_name, '25') AND ENDS_WITH(event_name, 'PLUS') THEN 'plan_not_expanded' -- 'plan_plus_upgrade'
      WHEN (plan_event_name IS NULL OR lower(plan_event_name) = "nan" or TRIM(plan_event_name) = '')
          AND NOT (
            (STARTS_WITH(event_name, '25') AND ENDS_WITH(event_name, 'HP')) OR
            (STARTS_WITH(event_name, '25') AND ENDS_WITH(event_name, 'WK')) OR
            (STARTS_WITH(event_name, '25') AND ENDS_WITH(event_name, 'all')) OR
            (STARTS_WITH(event_name, '25') AND CONTAINS_SUBSTR(event_name, 'FLEX'))
          ) THEN 'No'
      WHEN event_name = plan_event_name THEN 'plan_not_expanded'
      ELSE 'plan_expanded'
    END AS plan_status,
    event_name,
    promo_code
  FROM
    `archtics.raw_seats_sold_2025` cs
  -- LEFT JOIN
  --   `archtics.dim_ticket_buyer_demo`
  -- USING
  --   (acct_id)
  LEFT JOIN
    `tickets.ref_dim_event_name` ref_dim_event_name
  USING
    (event_name)
  LEFT JOIN
    `tickets.ref_market_info` ref
  ON
    CAST(EXTRACT(YEAR FROM PARSE_DATE(
      IF(
        LENGTH(SPLIT(event_date, '/')[OFFSET(2)]) = 2, -- Check if year is 2 digits
        '%m/%d/%y', -- Format for 2-digit year
        '%m/%d/%Y'  -- Format for 4-digit year
      ), 
      event_date
    )) AS INT64) = ref.year AND
    ref_dim_event_name.market = ref.market
  WHERE
    ticket_type != "Championship Series Deposit" 
    -- AND REGEXP_CONTAINS(SUBSTR(event_name, 1, 2), r'^\d+$')
    -- AND acct_id != 794001
    AND consignment != 'Y'

  UNION ALL 

  SELECT
    *
  FROM (
  -- 2025 Non TM Venues ORDER IS plan_status, event_name, promo_code
    SELECT *, CAST(NULL AS STRING) AS promo_code  FROM `non_tm_venues.fact_denver_tickets_sold_2025` UNION ALL
    SELECT * FROM `non_tm_venues.fact_fairfield_tickets_sold_2025` UNION ALL
    SELECT * FROM `non_tm_venues.fact_chicago_tickets_sold_2025` UNION ALL
    SELECT * FROM `non_tm_venues.fact_subaru_tickets_sold_2025` UNION ALL
    SELECT * FROM `non_tm_venues.fact_red_bull_tickets_sold_2025`
  )

  UNION ALL

  -- Historic Ticket Data
  SELECT
    year,
    market,
    ticket_day,
    acct_id,
    email_address,
    ticket_category,
    CASE
      -- WHEN ticket_category = "homecoming_pass" OR legacy_event_product = "HomecomingPass" THEN "homecoming_pass" 
      WHEN legacy_event_product = "HomecomingPass" THEN "homecoming_pass"
      WHEN legacy_event_product = "Weekend" THEN "weekend_pass"
      WHEN legacy_event_product LIKE "%All Access%" THEN "all_access"
      ELSE NULL
    END AS plan_name,
    CASE WHEN comp = "Y" THEN TRUE WHEN comp = "N" THEN FALSE ELSE NULL END AS comp,
    price_code,
    purchase_date,
    event_date,
    NULL AS time_of_day,
    days_from_event,
    revenue,
    num_seats,
    paid_tickets,
    comp_tickets,
    zip,
    legacy_event_name,
    legacy_ticket_type_category,
    NULL AS plan_status,
    CAST(NULL AS STRING) AS event_name,
    CAST(NULL AS STRING) AS promo_code
  FROM
    `tickets.legacy_tickets_sold_2022_2024`
)

, expand_helper AS (
  SELECT DISTINCT
    2025 AS year,
    market,
    ticket_day AS ticket_day_new,
    COALESCE(time_of_day, "") AS time_of_day_new,
    date as event_date_new,
    "plan_not_expanded" AS plan_status,
    event_count
  FROM (
    SELECT
      *,
      COUNT(*) OVER(PARTITION BY market) AS event_count
    FROM
      `tickets.ref_dim_event_name`
    WHERE
      start_time IS NOT NULL AND
      premium_add_on_event = false AND
      EXTRACT(YEAR from date) = 2025
  )
  WHERE
    start_time IS NOT NULL AND
    premium_add_on_event = false AND
    EXTRACT(YEAR from date) = 2025
  ORDER BY
    1,2,3
)

, all_expanded AS (
  SELECT
    raw.* EXCEPT(revenue, ticket_day, time_of_day, event_date),
    COALESCE(ticket_day_new, ticket_day) AS ticket_day,
    COALESCE(time_of_day_new, time_of_day) AS time_of_day,
    COALESCE(event_date_new, event_date) AS event_date,
    CASE WHEN event_count IS NULL THEN revenue ELSE revenue / event_count END AS revenue
  from
    raw
  LEFT JOIN
    expand_helper USING(year, market, plan_status)
)

, sold AS (
  SELECT
    * EXCEPT(legacy_event_name),
    CASE
      WHEN plan_name = "all_access" THEN "all_access" 
      WHEN plan_name LIKE "%homecoming_pass%" THEN "homecoming_pass"
      ELSE "single_day" END AS ticket_type,
    -- legacy cols at the end
    legacy_event_name
  FROM
    all_expanded
)

-- TESTING
SELECT
  * except(ticket_category, paid_tickets, num_seats),
  if(price_code = "AS0" and market = "Chicago", 0, paid_tickets) as paid_tickets,
  if(price_code = "AS0" and market = "Chicago", 0, num_seats) as num_seats,
  CASE
    WHEN hcp_renewal_flag = 1 AND ticket_category = "non_internal" then "group" -- MB REMOVED 5/9/23
    WHEN promo_code in ("253DNEWENGLAND", "25TOMAHAWKS", "25IMLAX", "PLLTL", "PLLIBLA", "25NULC", "25PCSS", "25USL", "25LYNX", "25TRIBAL", "25WEBBER", "25MYL", '25PLL2', '25PLL3', '25PLL4', '25PLL5', '25PLL6', '25PLL7', '25PLL8', '25PLL9', '25PLL10', '25PLL11', '25PLL12') then "group"
    
    else ticket_category 
  END AS ticket_category,
  DATE_DIFF(CASE
    WHEN CAST(year AS STRING) = "2025" THEN DATE("2025-09-14")
    WHEN CAST(year AS STRING) = "2024" THEN DATE("2024-09-15")
    WHEN CAST(year AS STRING) = "2023" THEN DATE("2023-09-24")
    WHEN CAST(year AS STRING) = "2022" THEN DATE("2022-09-18")
  END, purchase_date, DAY) AS days_from_championship,
FROM (
  SELECT
    sold.*,
    COALESCE(hcp_renewal_flag, 0) AS hcp_renewal_flag
  FROM
    sold
  LEFT JOIN ( -- Flag HCP Renewals for a given year
    SELECT DISTINCT
      year, 
      market, 
      acct_id,
      1 AS hcp_renewal_flag
    FROM
      `pll-data-warehouse.tickets.ref_hcp_renewals_2025`
  ) USING(year, market, acct_id)
)

