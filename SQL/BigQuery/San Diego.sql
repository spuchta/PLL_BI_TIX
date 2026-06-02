WITH seats_sold_clean AS (
  SELECT
    2026 AS year,
    "San Diego" AS market,
    CASE
      WHEN `Item Code` IN ("PLL0627A", "PLL0627B") THEN "Day 1"
      WHEN `Item Code` = "PLL0628" THEN "Day 2"
    END AS ticket_day,
    CAST(`Customer ID` AS INT64) AS acct_id,
    LOWER(TRIM(`Email Address`)) AS email_address,

    CASE
      WHEN `Price Type Full Name` IN ("Homecoming Package - Renewal") THEN "group"
      WHEN `Item Code` = "PLLHC" AND `Price Type Code` = "HCP" THEN "non_internal"
      WHEN `Item Code` = "PLLHC" AND `Price Type Code` = "HCPR" THEN "group"
      ELSE "group"
    END AS ticket_category,
    CASE
      WHEN `Price Type Code` = "HCP" OR `Item Code` = "PLLHC" THEN "homecoming_pass"
      ELSE "single_day"
    END AS plan_name,
    `Price Type Code` = "C" AS comp,
    CAST(`Price Level Code` AS STRING) AS price_code,
    sd.`Date` AS purchase_date,
    CASE
      WHEN `Item Code` IN ("PLL0627A", "PLL0627B") THEN DATE("2026-06-27")
      WHEN `Item Code` = "PLL0628" THEN DATE("2026-06-28")
    END AS event_date,
    CASE
      WHEN `Item Code` = "PLL0627A" THEN "Morning"
      WHEN `Item Code` = "PLL0627B" THEN "Night"
      ELSE NULL
    END AS time_of_day,
    DATE_DIFF(DATE("2026-06-28"), sd.`Date`, DAY) AS days_from_event,
    `Item Payment` AS revenue,
    COALESCE(`Order Qty`, 0) AS num_seats,
    IF(`Price Type Code` = "C", 0, COALESCE(`Order Qty`, 0)) AS paid_tickets,
    IF(`Price Type Code` = "C", COALESCE(`Order Qty`, 0), 0) AS comp_tickets,
    CAST(`Primary Zip Code` AS STRING) AS zip,
    CAST(NULL AS STRING) AS legacy_event_name,
    CAST(NULL AS STRING) AS legacy_ticket_type_category,
    CAST(NULL AS STRING) AS plan_status,
    `Item Code` AS event_name,
    IF(`Promo Code` = "(none)", CAST(NULL AS STRING), `Promo Code`) AS promo_code,
    CAST(NULL AS DATETIME) AS add_datetime
  FROM
    `pll-data-warehouse.non_tm_venues.san_diego_2026` sd
)

SELECT
  *
FROM
  seats_sold_clean
WHERE
  email_address NOT IN ("em1@oneelevate.com", "account5@logitix.com", "tickets@jampack.com")