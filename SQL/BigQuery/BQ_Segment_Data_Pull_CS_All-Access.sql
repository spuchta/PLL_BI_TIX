WITH filtered_sales AS (
SELECT f.*
  FROM `tickets.fact_tickets_sold` AS f
  WHERE f.year = 2025
    AND f.market = 'Champ Series'
    AND ticket_type = 'all_access'
)

SELECT DISTINCT dem.*, f.num_seats
FROM `pll-data-warehouse.ticketmaster.data_enrich_master` AS dem
JOIN `tickets.fact_ticket_to_pll_id` AS m
  ON dem.acct_id = m.PLL_ID         -- adjust column name case if needed
JOIN filtered_sales AS f
  ON LOWER(TRIM(m.email)) = LOWER(TRIM(f.email_address));
