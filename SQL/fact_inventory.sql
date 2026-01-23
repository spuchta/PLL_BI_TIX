WITH normalized_inventory AS (
  -- Archtics Source
  SELECT
    event_name,
    orig_price_code AS price_level_orig,
    CASE
      WHEN status IN ('SOLD', 'HELD') THEN 'SOLD'
      WHEN status = 'COMP' THEN 'COMP'
      WHEN status = 'AVAIL' AND class_name IN ('OPEN', 'DOQ-VETTX1HOLD', 'DIST-OPEN', 'DOQ-WHEELCHAIR') THEN 'OPEN'
      WHEN status = 'AVAIL' AND class_name IN ('PRESIDENT', 'KILL TSL', 'SUITE KILL', 'SUITES', 'KILL', 'CAMERA KILL') THEN 'KILL'
      WHEN status = 'AVAIL' THEN 'HOLD'
      ELSE 'UNKNOWN'
    END AS status,
    SAFE_CAST(total_num_seats AS INT64) AS num_seats
  FROM `tickets_data_project_2025.raw_archtics_inventory`

  UNION ALL

  -- Subaru Source
  SELECT
    `Event Code` AS event_name,
    CAST(`Price Level Code` AS STRING) AS price_level_orig,
    CASE
      WHEN `Seat Status Code` IN ('O', 'w') THEN 'OPEN'
      WHEN `Seat Status Code` IN ('Q', 's', 't', '=', 'o') THEN 'HOLD'
      WHEN `Seat Status Code` = 'X' THEN 'SOLD'
      WHEN `Seat Status Code` IN ('!', 'K') THEN 'KILL'
      ELSE 'UNKNOWN'
    END AS status,
    SAFE_CAST(`Count` AS INT64) AS num_seats
  FROM `non_tm_venues.raw_subaru_inventory`

  UNION ALL
  -- Denver Source (unsold tickets only)
  SELECT
    `Event Code` AS event_name,
    CAST(`Price Level` AS STRING) AS price_level_orig,
    CASE
      WHEN `Event Code` = 'PLL2' AND CAST(`Price Level` AS STRING) = '5' THEN 'HOLD'
      WHEN `Event Code` = 'PLL3' AND CAST(`Price Level` AS STRING) = '5' THEN 'HOLD'
      WHEN `Hold Code` = 'O' THEN 'OPEN'
      WHEN `Hold Code` IN ('P', 'm', 'p', 'q') THEN 'HOLD'
      WHEN `Hold Code` = 's' THEN 'OPEN'
      ELSE 'UNKNOWN'
    END AS status,
    SAFE_CAST(`Qty Held` AS INT64) AS num_seats
  FROM `non_tm_venues.raw_denver_inventory`

  UNION ALL

  -- NY Red Bulls Source
  SELECT
    event_name,
    price_code AS price_level_orig,
    CASE
      WHEN status IN ('SOLD', 'HELD') THEN 'SOLD'
      WHEN status = 'COMP' THEN 'COMP'
      WHEN status = 'AVAIL' AND class_name IN ('OPEN', 'DOQ-VETTX1HOLD', 'DIST-OPEN', 'DOQ-WHEELCHAIR', 'ACCESSIBLE WC') THEN 'OPEN'
      WHEN status = 'AVAIL' AND class_name IN ('KILLS', 'EVENT KILL') THEN 'KILL'
      WHEN status = 'AVAIL' THEN 'HOLD'
      ELSE 'UNKNOWN'
    END AS status,
    SAFE_CAST(total_num_seats AS INT64) AS num_seats
  FROM `tickets_data_project_2025.raw_nyredbulls_inventory`
),

enriched_inventory AS (
  SELECT
    ni.event_name,
    de.market,
    de.event_date,
    de.event_time,
    ni.price_level_orig,
    CASE
      WHEN SAFE_CAST(ni.price_level_orig AS INT64) IS NOT NULL THEN CHR(64 + SAFE_CAST(ni.price_level_orig AS INT64))
      ELSE ni.price_level_orig
    END AS price_level,
    ni.status,
    ni.num_seats
  FROM normalized_inventory ni
  LEFT JOIN `tickets_data_project_2025.dim_event` de
    ON ni.event_name = de.event_name
)

SELECT *
FROM enriched_inventory;