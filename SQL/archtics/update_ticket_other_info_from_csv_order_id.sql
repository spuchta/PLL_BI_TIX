--TITLE Update Ticket Attribute from CSV File
--HELP CSV Fields column order: Order_num, Acct_ID, Offer_name, Attribute Value
--HELP Pick Seat Attribute Number 1 through 10
--SP 2025-03-14

parameters file_name --file select file
,ticket_attribute --enum(1,2,3,4,5,6,7,8,9,10)[1] Enter Seat Attribute Number
;


drop table if exists #temp
;

create table #temp
	(order_num integer
,acct_id integer
,attrib_value varchar(100)
,ticket_seq_id int
);

input into #temp from {file_name}
;

update #temp a,dba.v_ticket_and_retail_basic b
set a.ticket_seq_id=b.ticket_seq_id
where a.acct_id=b.acct_id
and a.order_num=b.order_num
;


update dba.t_ticket a,#temp b
set a.other_info_1=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='1'
;

update dba.t_ticket a,#temp b
set a.other_info_2=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='2'
;

update dba.t_ticket a,#temp b
set a.other_info_3=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='3'
;

update dba.t_ticket a,#temp b
set a.other_info_4=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='4'
;


update dba.t_ticket a,#temp b
set a.other_info_5=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='5'
;

update dba.t_ticket a,#temp b
set a.other_info_6=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='6'
;

update dba.t_ticket a,#temp b
set a.other_info_7=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='7'
;

update dba.t_ticket a,#temp b
set a.other_info_8=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='8'
;

update dba.t_ticket a,#temp b
set a.other_info_9=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='9'
;

update dba.t_ticket a,#temp b
set a.other_info_10=b.attrib_value
where a.acct_id=b.acct_id
and a.ticket_seq_id=b.ticket_seq_id
and '{ticket_attribute}'='10'
;

select * from #temp
order by 1
;

commit
;

--STATUS Done!