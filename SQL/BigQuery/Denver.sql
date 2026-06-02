with denver_item_code_adj AS (
  SELECT
    raw_denver.* EXCEPT(`Item Code`),
    COALESCE(item_code_adj, `Item Code`) AS item_code_adj,
    `Item Code`
  FROM
    `pll-data-warehouse.non_tm_venues.denver_2026` raw_denver
  LEFT JOIN (
    SELECT "PLLWP" AS `Item Code`, "PLL1" AS item_code_adj UNION ALL
    SELECT "PLLWP" AS `Item Code`, "PLL2" AS item_code_adj UNION ALL
    SELECT "PLLWP" AS `Item Code`, "PLL3" AS item_code_adj
  ) USING(`Item Code`)
)

SELECT
  2026 AS year,
  "Denver" AS market,
  CASE
      WHEN item_code_adj = "PLL1" THEN "Day 1"
      WHEN item_code_adj = "PLL2" THEN "Day 2" 
      WHEN item_code_adj = "PLL3" THEN "Day 2" 
    END AS ticket_day,
  `Customer ID` AS acct_id,
  LOWER(TRIM(`Email Address`)) AS email_address,
  CASE
    WHEN `Price Type` IN ("WEEKEND INDIVIDUAL RENEWAL - 2") THEN "group"
    WHEN UPPER(`Sale Code`) IN ("PDI FEVO INTEGRATION", "PHONE") THEN "group"
    ELSE "non_internal"
  END AS ticket_category,
  case
    when `Item Code` = "PLLWP" then "homecoming_pass"
    when `Item Code` = "PLUS" then "homecoming_pass_plus"
    else CAST(NULL as STRING)
  end as plan_name,
  CASE
    WHEN LOWER(`Price Type`) LIKE "%comp%" THEN TRUE
    ELSE FALSE
  END AS comp,
  CAST(`Pr Level Code` AS STRING) AS price_code,
  date(denver.`Date`) AS purchase_date,
  case 
    when item_code_adj = "PLL1" then date("2026-07-24") 
    when item_code_adj = "PLL2" then date("2026-07-25") 
    when item_code_adj = "PLL3" then date("2026-07-25") 
  END AS event_date,
  case 
    when item_code_adj = "PLL1" then null 
    when item_code_adj = "PLL2" then "Morning" 
    when item_code_adj = "PLL3" then "Night" 
  END AS time_of_day,
  DATE_DIFF("2026-07-25", date(denver.`Date`), DAY) AS days_from_event,
  CASE
    when `Item Code` = "PLLWP" THEN (`Item Pmt Total` + `Ticket Chrg Pmt Total` + `Fac Fee Pmt Total`) / 3
    else `Item Pmt Total` + `Ticket Chrg Pmt Total` + `Fac Fee Pmt Total`
  end AS revenue,
  if(`Item Code` != 'PLUS', `Order Qty Total`, 0) AS num_seats,
  CASE
    WHEN `Item Code` = 'PLUS' THEN 0
    WHEN LOWER(`Price Type`) LIKE "%comp%" THEN 0
    ELSE `Order Qty Total`
  END AS paid_tickets,
  CASE
    WHEN `Item Code` = 'PLUS' THEN 0
    WHEN LOWER(`Price Type`) LIKE "%comp%" THEN `Order Qty Total`
    ELSE 0
  END AS comp_tickets,
  CAST(`Primary Zip Code` AS STRING) AS zip,
  CAST(NULL AS STRING) AS legacy_event_name,
  CAST(NULL AS STRING) AS legacy_ticket_type_category,
  CAST(NULL AS STRING) AS plan_status,
  `Item Code` AS event_name,
  cast(null as string) as promo_code,
  cast(null as datetime) as add_datetime
FROM (
  SELECT
    *
  FROM denver_item_code_adj denver
  WHERE
    `Item Pmt Total` != 0
    AND LOWER(TRIM(`Email Address`)) NOT IN ("em1@oneelevate.com", "account5@logitix.com", "tickets@jampack.com")
) denver