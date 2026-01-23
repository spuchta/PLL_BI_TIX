PARAMETERS 
fevo_file --File
;



-- Step 1: Create the temporary table
CREATE TABLE #temp_ticket_update (
    order_id VARCHAR(255),
    other_info_1 VARCHAR(255)
);

-- Step 2: Load data into the temporary table
INPUT INTO #temp_ticket_update
FROM {fevo_file}
;

-- Step 3: Update t_ticket using the temporary table
UPDATE dba.t_ticket AS t
JOIN #temp_ticket_update AS temp
ON t.order_num = temp.order_id
SET t.other_info_1 = temp.other_info_1;

-- Step 4: Drop the temporary table 
DROP TABLE #temp_ticket_update;