Parameters
  Date -- DATE
;

SELECT
  team,
  event_name,
  event_date,
  plan_event_name,
  plan_abv,
  status,
  class_name,
  orig_price_code,
  price_code,
  SUM(total_num_seats) AS total_num_seats,
  SUM(total_purchase_price) AS total_purchase_price
FROM
  DBA.v_event_summary
WHERE
  event_date > '{date}'
  AND plan_abv IN ('E', 'FS')
GROUP BY
  team,
  event_name,
  event_date,
  plan_event_name,
  plan_abv,
  status,
  class_name,
  orig_price_code,
  price_code
ORDER BY
  team,
  event_date
;