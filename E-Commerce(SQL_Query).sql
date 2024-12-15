-- Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

SELECT 
    location, COUNT(customer_id) AS number_of_customers
FROM
    customers
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;

-- Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

with cte as 
(
    select customer_id,count(order_id) as NumberOfOrders,
    case
    when count(order_id)=1 then 'one-time buyer'
    when count(order_id) between 2 and 4 then 'Occasional Shoppers' else 'Regular customers' end as customer_segment
    from orders
    group by customer_id
)

select NumberOfOrders,count(*) as CustomerCount
from cte
group by NumberOfOrders
order by NumberOfOrders;

-- Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

SELECT 
    product_id,
    AVG(quantity) AS avgquantity,
    SUM(price_per_unit * quantity) AS TotalRevenue
FROM
    OrderDetails
GROUP BY product_id
HAVING avgquantity = 2
ORDER BY avgquantity DESC , TotalRevenue DESC;

-- For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.

SELECT 
    category, COUNT(DISTINCT customer_id) AS unique_customers
FROM
    products
        JOIN
    orderdetails ON products.product_id = orderdetails.product_id
        JOIN
    orders ON orders.order_id = orderdetails.order_id
GROUP BY category
ORDER BY unique_customers DESC;

-- Analyze the month-on-month percentage change in total sales to identify growth trends.

with cte as
(
    select date_format(order_date,'%Y-%m') as Month,
    sum(total_amount) as TotalSales,
    lag(sum(total_amount)) over (order by date_format(order_date,'%Y-%m')) as prev
    from orders
    group by Month
)
select Month,TotalSales,
round(((TotalSales-prev)/prev)*100,2) as PercentChange from cte;

-- Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

with cte as
(
    select date_format(order_date,'%Y-%m') as Month,
    avg(total_amount) as AvgOrderValue,
    lag(avg(total_amount)) over (order by date_format(order_date,'%Y-%m'),avg(total_amount)) as prev
    from orders
    group by month
)
select 
Month,
AvgOrderValue,
round((AvgOrderValue-prev),2) as ChangeInValue
from cte
order by ChangeInValue desc;

-- Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

SELECT 
    product_id, COUNT(product_id) AS SalesFrequency
FROM
    OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;

-- List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

SELECT 
    products.product_id,
    products.name,
    COUNT(DISTINCT customers.customer_id) AS UniqueCustomerCount
FROM
    products
        JOIN
    orderdetails ON orderdetails.product_id = products.product_id
        JOIN
    orders ON orders.order_id = orderdetails.order_id
        JOIN
    customers ON customers.customer_id = orders.customer_id
GROUP BY products.product_id , products.name
HAVING UniqueCustomerCount < 0.4 * (SELECT 
        COUNT(customers.customer_id)
    FROM
        customers);
        
-- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

with cte as
(
    select customer_id,
    min(date_format(order_date,'%Y-%m')) as FirstPurchaseMonth
    from orders
    group by customer_id
)
select 
FirstPurchaseMonth,
count(*) as TotalNewCustomers
from cte 
group by FirstPurchaseMonth
order by FirstPurchaseMonth asc;

-- Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(Total_amount) AS TotalSales
FROM
    orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;