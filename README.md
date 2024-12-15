# Comprehensive E-Commerce Data Analysis Using SQL
![E-Commerce Logo](https://github.com/Bhavana570/E-Commerce-Company/blob/16a76a48b84e791ac5e05559eb2511c8fd0b5d3c/e-commerce(pic).png)

## Overview
Led an e-commerce project focused on improving customer satisfaction and driving sales growth through data-driven strategies. Conducted in-depth analysis of sales trends, customer behavior, and product performance to refine marketing approaches and optimize inventory management. Utilized data cleaning techniques and advanced visualization tools like Tableau to uncover actionable insights. Successfully streamlined operations, enhanced product availability, and reduced excess stock for improved efficiency.

## Objective
1.Utilize advanced data analysis techniques to identify sales trends and business opportunities.
2.Conduct comprehensive customer insights and product performance evaluations to enhance marketing strategies.
3.Optimize inventory management to improve product availability and minimize excess stock.
4.Leverage data cleaning and visualization tools like Tableau to deliver actionable insights and drive business growth.

## Business Problems and Solutions

### 1. Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

```sql
SELECT 
    location, COUNT(customer_id) AS number_of_customers
FROM
    customers
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;
```

### 2. Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

```sql
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
```

### 3. Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

```sql
SELECT 
    product_id,
    AVG(quantity) AS avgquantity,
    SUM(price_per_unit * quantity) AS TotalRevenue
FROM
    OrderDetails
GROUP BY product_id
HAVING avgquantity = 2
ORDER BY avgquantity DESC , TotalRevenue DESC;
```

### 4. For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.

```sql
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
```

### 5. Analyze the month-on-month percentage change in total sales to identify growth trends.

```sql
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
```

### 6. Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

```sql
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
```

### 7. Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

```sql
SELECT 
    product_id, COUNT(product_id) AS SalesFrequency
FROM
    OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;
```

### 8. List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

```sql
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
```

### 9. Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

```sql
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
```

### 10. Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

```sql
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(Total_amount) AS TotalSales
FROM
    orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;
```








