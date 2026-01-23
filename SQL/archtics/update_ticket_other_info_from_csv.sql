--TITLE Update Ticket Attribute from CSV File
--HELP CSV Fields column order: Acct_ID, Event Name, Section Name, Row Name, Seat Num, Attribute Value
--HELP Pick Seat Attribute Number 1 through 10
--MK 2022-10-20

parameters file_name --file select file
,ticket_attribute --enum(1,2,3,4,5,6,7,8,9,10)[1] Enter Seat Attribute Number
;


drop table if exists #temp
;

create table #temp(acct_id integer
,event_name char(8)
,section_name char(6)
,row_name char(4)
,seat_num int
,attrib_value varchar(50)
,ticket_seq_id int
);

input into #temp from {file_name}
;

update #temp a,dba.v_ticket_and_retail_basic b
set a.ticket_seq_id=b.ticket_seq_id
where a.acct_id=b.acct_id
and a.event_name=b.event_name
and a.section_name=b.section_name
and a.row_name=b.row_name
and a.seat_num between b.seat_num and b.last_seat
;

update dba.t_ticket a,#temp b
set a.other_info_{ticket_attribute} =b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
;


commit
;

select acct_id, event_name, section_name, row_name, seat_num, other_info_{ticket_attribute}, ticket_seq_id from dba.v_ticket
where ticket_seq_id in (select ticket_seq_id from #temp)
order by acct_id
;


--STATUS Done!