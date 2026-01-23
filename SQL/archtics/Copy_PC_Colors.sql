PARAMETERS
source, --Event ID of source event
target --Event ID of target event 
;

UPDATE dba.t_price_code AS target
SET color = source.color
FROM dba.t_price_code AS source
WHERE target.event_id = {target}
AND source.event_id = {source}
AND target.price_code = source.price_code
AND LENGTH(target.price_code) = 1;

