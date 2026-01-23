SELECT
  2025 AS year,
  "Denver" AS market,
  dim_event_name.ticket_day,
  `Customer ID` AS acct_id,
  LOWER(TRIM(`Email Address`)) AS email_address,
  CASE
    WHEN
      UPPER(`Sale Code`) IN ("PDI FEVO INTEGRATION", "PHONE") OR 
      `Price Type Code` = "AWPR" OR `Price Type Code` = "AWR"
      THEN "group"
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
  date(parse_datetime('%b %d, %Y %I:%M:%S %p', denver.`Date`)) AS purchase_date,
  CAST(dim_event_name.date AS DATE) AS event_date,
  CAST(dim_event_name.time_of_day AS STRING) AS time_of_day,
  DATE_DIFF("2025-08-03", date(parse_datetime('%b %d, %Y %I:%M:%S %p', denver.`Date`)), DAY) AS days_from_event,
  `Item Pmt Total` + `Ticket Chrg Pmt Total` + `Fac Fee Pmt Total` AS revenue,
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
  if(`Item Code` in ('PLLWP', 'PLUS'), 'plan_not_expanded', CAST(NULL AS STRING)) AS plan_status,
  `Item Code` AS event_code
FROM (
  SELECT
    *
  FROM `non_tm_venues.raw_denver_2025_live` 
  WHERE `Item Code` != "PLLWP" or `Item Pmt Total` != 0
) denver
LEFT JOIN
  `tickets.ref_dim_event_name` dim_event_name ON denver.`Item Code` = dim_event_name.event_name

