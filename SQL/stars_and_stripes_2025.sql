WITH stars_report AS (
    -- Fevo Source
    SELECT
        fevoPage as fevo_page
  , COUNT (ticketPrice) as tix_sold
  , SUM(ticketPrice) as revenue
FROM `pll-data-warehouse.tickets.fevo_orders_2025_season_no_cs` 
WHERE market = 'Philly/Subaru Park'
and fevoPage like 'Stars%'
group by fevoPage
order by fevoPage
)