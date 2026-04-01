create database fraud_detection;

use fraud_detection;

select *
from bank_transactions;

-- Checking for Missing Values
select 
    sum(case when transactionid is null then 1 else 0 end) as missing_transactionid,
    sum(case when accountid is null then 1 else 0 end) as missing_accountid,
    sum(case when transactionamount is null then 1 else 0 end) as missing_transactionamount,
    sum(case when transactiondate is null then 1 else 0 end) as missing_transactiondate,
    sum(case when transactiontype is null then 1 else 0 end) as missing_transactiontype
from bank_transactions;


-- Fraudulent Patterns: Frequent High-Value Transactions/ Duplicate Transactions/ Unusual Withdrawals

-- 1. Frequent High-Value Transactions (Identifying customers making unusually high transactions in a short time.)
with highvaluetx as (
    select t1.accountid, t1.transactiondate, t1.transactionamount,
           (select count(*) 
            from bank_transactions t2 
            where t2.accountid = t1.accountid 
              and t2.transactiondate >= t1.transactiondate - interval 1 hour 
              and t2.transactiondate <= t1.transactiondate
           ) as tx_count,
           (select sum(t2.transactionamount) 
            from bank_transactions t2 
            where t2.accountid = t1.accountid 
              and t2.transactiondate >= t1.transactiondate - interval 1 hour 
              and t2.transactiondate <= t1.transactiondate
           ) as total_value
    from bank_transactions t1)
select accountid, transactiondate, transactionamount
from highvaluetx
where tx_count > 3 and total_value > 5000;


-- 2. Duplicate Transactions (Detecting multiple transactions with the same amount, timestamp, and recipient.)
with duplicatetx as (
    select transactionid, accountid, transactionamount, transactiondate, merchantid,
           count(*) over (partition by accountid, transactionamount, merchantid, transactiondate) as duplicate_count
    from bank_transactions)
select * from duplicatetx where duplicate_count > 1;


-- 3. Unusual Withdrawals (Identifying withdrawals at odd hours or from different locations in a short period.)
with oddhourtx as (
    select t1.transactionid, t1.accountid, t1.transactiondate, t1.transactiontype, t1.location,
           hour(t1.transactiondate) as tx_hour,
           (select count(distinct t2.location) 
            from bank_transactions t2 
            where t2.accountid = t1.accountid 
              and t2.transactiondate >= t1.transactiondate - interval 24 hour 
              and t2.transactiondate <= t1.transactiondate
           ) as location_changes
    from bank_transactions t1)
select * 
from oddhourtx 
where (tx_hour < 6 or tx_hour > 22) or location_changes > 2;


-- Storing flagged transactions in a separate table.
create table flaggedtransactions as
with highvaluetx as (
    select t1.accountid, t1.transactiondate, t1.transactionamount,
           (select count(*) 
            from bank_transactions t2 
            where t2.accountid = t1.accountid 
              and t2.transactiondate >= t1.transactiondate - interval 1 hour 
              and t2.transactiondate <= t1.transactiondate
           ) as tx_count,
           (select sum(t2.transactionamount) 
            from bank_transactions t2 
            where t2.accountid = t1.accountid 
              and t2.transactiondate >= t1.transactiondate - interval 1 hour 
              and t2.transactiondate <= t1.transactiondate
           ) as total_value
    from bank_transactions t1),
duplicatetx as (
    select transactionid, accountid, transactionamount, transactiondate, merchantid,
           count(*) over (partition by accountid, transactionamount, merchantid, transactiondate) as duplicate_count
    from bank_transactions),
oddhourtx as (
    select t1.transactionid, t1.accountid, t1.transactiondate, t1.transactiontype, t1.location, 
           t1.transactionamount, 
           hour(t1.transactiondate) as tx_hour,
           (select count(distinct t2.location) 
            from bank_transactions t2 
            where t2.accountid = t1.accountid 
              and t2.transactiondate >= t1.transactiondate - interval 24 hour 
              and t2.transactiondate <= t1.transactiondate
           ) as location_changes
    from bank_transactions t1)

select * from (
    select accountid, transactiondate, transactionamount, 'high_value' as fraud_type
    from highvaluetx where tx_count > 3 and total_value > 5000
    union all
    select accountid, transactiondate, transactionamount, 'duplicate' as fraud_type
    from duplicatetx where duplicate_count > 1
    union all
    select accountid, transactiondate, transactionamount, 'odd_hour' as fraud_type
    from oddhourtx where (tx_hour < 6 or tx_hour > 22) or location_changes > 2
) as fraud_records;


select * from flaggedtransactions;
