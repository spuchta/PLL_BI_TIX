SELECT
  team,
  plan_abv,
  event_name,
  event_date,
  orig_price_code,
  normalized_status,
  SUM(total_num_seats) AS num_seats
FROM (
  SELECT
    es.team,
    es.plan_abv,
    es.event_name,
    es.event_date,
    es.orig_price_code,
    CASE
      WHEN es.status IN ('SOLD', 'HELD') THEN 'SOLD'
      WHEN es.status = 'COMP' THEN 'COMP'
      WHEN es.status = 'AVAIL' AND c.class_ind = 'O' THEN 'OPEN'
      WHEN es.status = 'AVAIL' AND c.class_ind = 'D' THEN 'HOLD'
      WHEN es.status = 'AVAIL' AND c.class_ind = 'K' THEN 'KILL'
      ELSE 'UNKNOWN'
    END AS normalized_status,
    es.total_num_seats
  FROM DBA.v_event_summary es
  LEFT JOIN DBA.v_class c
    ON es.class_name = c.name
) t
GROUP BY
  team,
  plan_abv,
  event_name,
  event_date,
  orig_price_code,
  normalized_status;
