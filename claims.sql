create table claims(
ClaimID	varchar,
ProviderID varchar,
PatientID varchar,
DateofService date,
BilledAmount int,
ProcedureCode int,
DiagnosisCode text,
AllowedAmount int,
PaidAmount int,
InsuranceType text,
ClaimStatus text,
ReasonCode text,
FollowupRequired text,
ARStatus text,
Outcome text
);
drop table claims;


-- Select all columns from the claims table.
select * from claims;

-- Show only Claim ID, Provider ID, Charge Amount.
select claimid, providerid, billedamount from claims;


-- Count total number of claims.
select count(claimid) as claim_counts from claims;

-- Find distinct Insurance Types.
select distinct insurancetype from claims;

-- Filter claims where Claim Status = 'Denied'.
select * from claims
where claimstatus = 'Denied';

-- Find claims where Charge Amount > 10,000
select * from claims
where billedamount > 100;

-- Sort claims by Charge Amount descending.
select * from claims
order by billedamount desc;

-- Count claims per Insurance Type.
select insurancetype, count(claimid) as claimcounts
from claims
group by insurancetype

-- Find average Charge Amount
select avg(billedamount) as avg_billed_amount
from claims

-- Get min and max Paid Amount.
select min(paidamount) as min_paid,
max(paidamount) as max_paid
from claims

-------------------------------------------------------------------------------------------------

-- Remove commas from Charge Amount (string → numeric).
update claims
set billedamount = regexp_replace(billedamount, ',', '')

update claims
set dateofservice = cast(dateofservice) as date

-- Find duplicate Claim IDs.
select claimid, count(*) as cnts
from claims
group by claimid
having count(*) > 1

-- Delete duplicate records using CTE + ROW_NUMBER.
with cte1 as (select ctid, *, row_number() over (partition by claimid order by dateofservice desc) as rn from claims)
delete from claims where ctid in (select ctid from cte1 where rn > 1)

-- Replace NULL Insurance Type with 'Unknown'.
update claims
set insurancetype = 'Unknown'
where insurancetype is null

-- Replace NULL Reason Code with 'Not Provided'.
update claims
set reasoncode = 'Not Provided'
where reasoncode is null

-- Find invalid Paid Amount (negative values).
select paidamount from claims
where paidamount < 0

-- Remove future Date of Service records.
delete from claims
where dateofservice > current_date

-------------------------------------------------------------------------------------------------------
-- Find rows where Paid Amount > Charge Amount.
select * from claims
where paidamount > billedamount

-- Validate Claim Status values (not in Paid/Denied/Partial).
select * from claims where claimstatus not in ('Paid', 'Denied', 'Partial Paid', 'Under Review')

-- Find rows where Follow-up Required NOT IN ('Yes','No').
select * from claims where followuprequired not in ('Yes', 'No')

-- Check ICD-10 format using LIKE or regex (if supported).


-- Paid → AR Status should be 'Closed'
select * from claims
where claimstatus = 'Paid' and arstatus != 'Closed'

-- Create a column flagging invalid records
select claimid, 
case when length(claimid) > 10 then 'Invalid'
else 'Valid'
end as flag
from claims;


alter table claims
add flag varchar(10)

update claims
set flag = 
case when length(claimid) > 10 then 'Invalid'
else 'Valid'
end

select * from claims

-------------------------------------------------------------------------------------------------------
-- Calculate total claim amount per Provider.
select providerid, sum(billedamount) as summedamount
from claims
group by providerid

-- Rank top 5 providers by total Charge Amount.
with cte1 as ( select providerid, sum(billedamount) as summedamount
from claims group by providerid),
cte2 as (select providerid, summedamount, 
dense_rank() over (order by summedamount desc) as rn
from cte1)
select providerid, summedamount from cte2 where rn <= 5

-- Calculate running total of claims by Date of Service.
select dateofservice, billedamount,
sum(billedamount) over (order by dateofservice rows between unbounded preceding and current row) as running_sum
from claims

-- Calculate denial rate per Insurance Type.
select insurancetype, 
count(case when Outcome = 'Denial' then 1 else 0 end) * 100.0 / count(*) as denial_rate
from claims
group by insurancetype












