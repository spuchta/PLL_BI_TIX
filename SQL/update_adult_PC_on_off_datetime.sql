--TITLE Clear Onsale and Offsale Dates for Single-Character Price Codes
--HELP This script clears on/offsale datetimes for price codes like '_' and filters by season.


PARAMETERS season_id  --SQL "SELECT season_name from dba.v_event" Season Name
;


UPDATE dba.t_price_code
SET 
    onsale_datetime = NULL,
    offsale_datetime = NULL
FROM dba.t_price_code pc
JOIN dba.v_event ve ON pc.event_id = ve.event_id
WHERE 
    pc.onsale_datetime = '2001-01-01 00:00:00' AND
    pc.offsale_datetime = '2001-01-01 00:00:00' AND
    pc.price_code LIKE '_' AND
    ve.season_id = {season_id};


