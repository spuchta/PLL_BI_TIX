--Credential List
--SMP 6/14/2025


Parameters  Event_Name --Enter Event Name

;

drop table #temp_tkt
;
drop table #temp_tkt_secondary
;
drop table #temp_tkt_final
;

create table #temp_tkt
(acct_id int
,ticket_seq_id int
,retail_acct_num varchar(10)
,event_id int
,event_name varchar(8)
,plan_event_id int
,plan_event_name varchar(8)
,section_id int
,section_name varchar(8)
,row_id int
,row_name  varchar(8)
,seat_num  int
,last_seat  int
,num_seats   int
,inet_status  char(2)
,assoc_acct_id  int
,ticket_status  char(2)
,cust_name_id int
,name_last_first_mi  varchar(60)
,full_name_1  varchar(60)
,company_name  varchar(40)
,email_addr  varchar(50)
,acct_type varchar(8)
,acct_type_desc varchar(20)
,portal_low  varchar(40)
,portal_high  varchar(40)
)
;

create table #temp_tkt_secondary
(acct_id int
,ticket_seq_id int
,retail_acct_num varchar(10)
,event_id int
,event_name varchar(8)
,plan_event_id int
,plan_event_name varchar(8)
,section_id int
,section_name varchar(8)
,row_id int
,row_name  varchar(8)
,seat_num  int
,last_seat  int
,num_seats   int
,inet_status  char(2)
,assoc_acct_id  int
,ticket_status  char(2)
,cust_name_id int
,name_last_first_mi  varchar(60)
,full_name_1  varchar(60)
,company_name  varchar(40)
,email_addr  varchar(50)
,acct_type varchar(8)
,acct_type_desc varchar(20)
,portal_low  varchar(40)
,portal_high  varchar(40)
)
;
create table #temp_tkt_final
(acct_id int
,retail_acct_num varchar(10)
,name_last_first_mi varchar(60)
,full_name_1 varchar(60)
,company_name varchar(40)
,email_addr varchar(50)
,event_name varchar(8)
,section_name varchar(8)
,row_name varchar(8)
,seat_num int
,last_seat int
,num_seats int
,portal_low varchar(30)
,portal_high varchar(30)
)
;


--Status Running
insert into #temp_tkt
(acct_id, ticket_seq_id, retail_acct_num, event_id, event_name, plan_event_id, plan_event_name, section_id, section_name, 
row_id, row_name, seat_num, last_seat, num_seats, inet_status, assoc_acct_id, ticket_status
,cust_name_id, name_last_first_mi, full_name_1, company_name, email_addr,acct_type, acct_type_desc, portal_low, portal_high)
select
a.acct_id
,a.ticket_seq_id
,a.retail_acct_num
,a.event_id
,a.event_name
,a.plan_event_id
,a.plan_event_name
,a.section_id
,a.section_name
,a.row_id
,a.row_name
,a.seat_num
,a.last_seat
,a.num_seats
,a.inet_status
,a.assoc_acct_id
,a.ticket_status
,a.cust_name_id
,b.name_last_first_mi
,b.full_name_1
,b.company_name
,b.email_addr
,b.acct_type
,b.acct_type_desc
,c.portal_low
,c.portal_high
into #temp_tkt
from dba.v_ticket_and_retail_basic a, dba.v_customer b, dba.v_manifest_row c
where a.event_name like '{Event_Name}'
and a.cust_name_id = b.cust_name_id
and a.section_id = c.section_id
and a.row_id = c.row_id
;
commit
;


insert into #temp_tkt_secondary
(acct_id, ticket_seq_id, retail_acct_num, event_id, event_name, plan_event_id, plan_event_name, section_id, section_name, 
row_id, row_name, seat_num, last_seat, num_seats, inet_status, assoc_acct_id, ticket_status
,cust_name_id, name_last_first_mi, full_name_1, company_name, email_addr, acct_type, acct_type_desc,portal_low, portal_high)
select 
a.acct_id
,a.ticket_seq_id
,CAST(NULL as varchar) as retail_acct_num
,a.event_id
,a.event_name
,a.plan_event_id
,a.plan_event_name
,a.section_id
,a.section_name
,a.row_id
,a.row_name
,a.seat_num
,a.last_seat
,a.num_seats
,a.inet_status
,a.assoc_acct_id
,a.ticket_status
,a.cust_name_id
,c.name_last_first_mi
,c.full_name_1
,c.company_name
,c.email_addr
,c.acct_type
,c.acct_type_desc
,d.portal_low
,d.portal_high
into #temp_tkt_secondary
from #temp_tkt b, dba.v_ticket_secondary a, dba.v_customer c, dba.v_manifest_row d
where a.event_name like '{Event_Name}'
and a.status = 'Y'
and b.inet_status in ('f','r','y')
and a.ticket_acct_id = b.acct_id
and a.ticket_seq_id = b.ticket_seq_id
and a.cust_name_id = c.cust_name_id
and a.section_id = d.section_id
and a.row_id = d.row_id

;
commit
;


insert into #temp_tkt_final
(acct_id,retail_acct_num, name_last_first_mi, full_name_1, company_Name, email_addr, event_name, section_name, row_name, seat_num, last_seat, num_seats
)
select acct_id,retail_acct_num, name_last_first_mi, full_name_1, company_Name, email_addr, event_name, section_name, row_name, seat_num, last_seat, num_seats

into #temp_tkt_final
from #temp_tkt
where inet_status not in ('R', 'F','y')
;

insert into #temp_tkt_final
(acct_id,retail_acct_num, name_last_first_mi, full_name_1, company_Name, email_addr, event_name, section_name, row_name, seat_num, last_seat, num_seats
)
select acct_id,retail_acct_num, name_last_first_mi, full_name_1, company_Name, email_addr, event_name, section_name, row_name, seat_num, last_seat, num_seats
from #temp_tkt_secondary
;
commit
;


select * from #temp_tkt_final
order by event_name, section_name, row_name, seat_num
;

--Status Done!






