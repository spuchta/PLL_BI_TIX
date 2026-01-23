-- Created by SMP 9/9/25 to inactivate unused ticket types
DROP TABLE #InactivateCodes;

CREATE TABLE #InactivateCodes (
    ticket_type VARCHAR(50) -- adjust size to match dba.t_ticket_type.ticket_type
);
INPUT INTO #InactivateCodes
 FROM t:\sql\inactivate_ticket_types.csv
 ;
UPDATE dba.t_ticket_type
SET active = 'N'
WHERE ticket_type IN (
    SELECT ticket_type
    FROM #InactivateCodes
)
;