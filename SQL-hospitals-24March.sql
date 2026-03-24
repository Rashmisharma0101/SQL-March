-- Find the latest hospital (based on Hospital_id) in each city.
select * from (
select *, row_number() over(partition by hospitals.city order by orders.orderdate desc) as rn
from hospitals join orders
on hospitals.hospital_id = orders.hospitalid) r
where rn = 1;
--------------------------------------------------------------

-- Find all orders where order amount is greater than overall average.
select * from 
(select orders.orderid, (orders.quantity * products.unitprice) as amounts,
avg(orders.quantity * products.unitprice) over () as overall_average
from orders join products
on orders.productid = products.productid) r
where amounts > overall_average

--------------------------------------------------------------

-- Get product(s) having maximum price.
select * from products where unitprice = (
select max(unitprice) from products)

--------------------------------------------------------------

-- Find number of shipments per warehouse.
select warehouses.warehouseid, count(shipments.shipmentid) as cnts
from orders join shipments
on orders.orderid = shipments.orderid
join warehouses
on warehouses.warehouseid = orders.warehouseid
group by warehouses.warehouseid

--------------------------------------------------------------

-- Find the most recent quality event for each product.
select * from (select  orders.productid, qualityevents.eventtype, orders.orderdate, row_number() over (partition by orders.productid order by orders.orderdate desc)
as rn
from orders join qualityevents
on orders.orderid = qualityevents.orderid
)
where rn = 1

--------------------------------------------------------------

-- Return last 3 orders for each hospital.
select * from (
select *, row_number() over(partition by hospitalid order by orderdate desc) as rn
from orders)
where rn <= 3

--------------------------------------------------------------

-- Find products whose price is higher than their category average price.
select * from ( 
select productid, unitprice, category,
avg(unitprice) over (partition by category) as category_avg
from products) r
where unitprice > category_avg

--------------------------------------------------------------

-- Calculate cumulative order amount by hospital.
select orders.hospitalid , orders.orderdate, (orders.quantity * products.unitprice) as amounts,
sum(orders.quantity * products.unitprice) over (partition by orders.hospitalid  order by orders.orderdate) as rn
from orders join products
on orders.productid = products.productid

--------------------------------------------------------------

-- First vs Last Order Comparison
select *, first_values - last_values as difference  from (
select orders.hospitalid , orders.orderdate, (orders.quantity * products.unitprice) as amounts,
first_value(orders.quantity * products.unitprice) over (partition by orders.hospitalid order by orders.orderdate) as first_values,
last_value(orders.quantity * products.unitprice) over (partition by orders.hospitalid order by orders.orderdate rows between
unbounded preceding and unbounded following) as last_values
from orders join products
on orders.productid = products.productid) r

--------------------------------------------------------------
-- Rank products by price within category using

select * , rank() over (partition by category order by unitprice desc) as ranks,
dense_rank() over (partition by category order by unitprice desc) as dense_ranks
from products

--------------------------------------------------------------
-- Get top 2 expensive products per category.
select * from (select * ,
dense_rank() over (partition by category order by unitprice desc) as dense_ranks
from products) r
where dense_ranks <= 2

--------------------------------------------------------------
-- For each customer, find days difference between consecutive orders.
select *, orderdate - prev_date as diff from 
(select hospitalid, orderdate, lag(orderdate) over (partition by hospitalid order by orderdate) as prev_date
from orders) r






