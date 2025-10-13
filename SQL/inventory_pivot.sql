WITH enriched_inventory AS (
  SELECT
    fi.event_name,
    de.market,
    de.event_date,
    de.event_time,
    fi.status,
    fi.num_seats
  FROM `tickets_data_project_2025.fact_inventory` fi
  LEFT JOIN `tickets_data_project_2025.dim_event` de
    ON fi.event_name = de.event_name
)

SELECT
  event_name,
  market,
  event_date,
  event_time,
  SUM(IF(status = 'OPEN', num_seats, 0)) AS open_tix,
  SUM(IF(status = 'HOLD', num_seats, 0)) AS hold_tix,
  SUM(IF(status = 'KILL', num_seats, 0)) AS kill_tix,
  SUM(IF(status = 'SOLD', num_seats, 0)) AS sold_tix,
  SUM(IF(status = 'COMP', num_seats, 0)) AS comp_tix
FROM enriched_inventory
GROUP BY
  event_name,
  market,
  event_date,
  event_time
ORDER BY
  event_date,
  event_time,
  event_name