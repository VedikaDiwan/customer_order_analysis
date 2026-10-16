Create database SHOPSPHERE_DB;

USE SHOPSPHERE_DB;

CREATE TABLE CUSTOMERS(
CUSTOMER_ID INT PRIMARY KEY,
CUSTOMER_NAME VARCHAR(50),
CITY VARCHAR(50),
SIGN_UP_DATE DATE
);

CREATE TABLE PRODUCTS(
PRODUCT_ID INT PRIMARY KEY,
PRODUCT_NAME VARCHAR(50),
CATEGORY VARCHAR(50),
PRICE DECIMAL(10,2)
);

CREATE TABLE ORDERS (
    ORDER_ID INT PRIMARY KEY,
    CUSTOMER_ID INT,
    ORDER_DATE DATE,
    STATUS VARCHAR(20),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
);

CREATE TABLE ORDER_ITEMS(
ORDER_ITEM_ID INT PRIMARY KEY,
ORDER_ID INT,
PRODUCT_ID INT,
QUANTITY INT,
FOREIGN KEY (ORDER_ID) references ORDERS(ORDER_ID),
FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
);

INSERT INTO customers (customer_id, customer_name, city, sign_up_date) VALUES
(1, 'Rohan Sharma', 'Mumbai', '2023-01-15'),
(2, 'Priya Patel', 'Delhi', '2023-02-20'),
(3, 'Amit Kumar', 'Bangalore', '2023-03-10'),
(4, 'Sneha Reddy', 'Hyderabad', '2023-01-25'),
(5, 'Vikram Singh', 'Mumbai', '2023-04-05'),
(6, 'Anjali Gupta', 'Delhi', '2023-05-12'),
(7, 'Karan Mehta', 'Pune', '2023-02-28'),
(8, 'Neha Joshi', 'Bangalore', '2023-06-01'),
(9, 'Rahul Verma', 'Chennai', '2023-03-22'),
(10, 'Isha Kapoor', 'Mumbai', '2023-07-08');

INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Wireless Mouse', 'Electronics', 799.00),
(2, 'Bluetooth Speaker', 'Electronics', 2499.00),
(3, 'Cotton T-shirt', 'Clothing', 599.00),
(4, 'Running Shoes', 'Clothing', 3499.00),
(5, 'Coffee Maker', 'Home', 4999.00),
(6, 'Table Lamp', 'Home', 1299.00),
(7, 'Novel - Fiction', 'Books', 399.00),
(8, 'Notebook Set', 'Books', 249.00);


INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2024-01-10', 'Completed'),
(102, 2, '2024-01-15', 'Completed'),
(103, 1, '2024-02-05', 'Completed'),
(104, 3, '2024-02-20', 'Completed'),
(105, 4, '2024-02-28', 'Cancelled'),
(106, 5, '2024-03-10', 'Completed'),
(107, 2, '2024-03-15', 'Completed'),
(108, 6, '2024-03-20', 'Cancelled'),
(109, 1, '2024-04-02', 'Completed'),
(110, 7, '2024-04-10', 'Completed'),
(111, 3, '2024-04-25', 'Completed'),
(112, 5, '2024-05-05', 'Completed');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES
(1, 101, 1, 2),
(2, 101, 7, 1),
(3, 102, 3, 3),
(4, 103, 1, 1),
(5, 104, 5, 1),
(6, 105, 5, 1),
(7, 106, 6, 2),
(8, 107, 1, 1),
(9, 108, 8, 5),
(10, 109, 3, 2),
(11, 110, 7, 3),
(12, 111, 2, 1);     

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed';

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed';

SELECT
    p.category,
    SUM(oi.quantity * p.price) AS category_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;

WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_spend,
    DENSE_RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM customer_spend;

SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(oi.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY order_year, order_month;

WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_spend
FROM customer_spend
WHERE total_spend > (
    SELECT AVG(total_spend)
    FROM customer_spend
)
ORDER BY total_spend DESC;

CREATE VIEW customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity * p.price), 0) AS total_spend,
    CASE
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) > 5000
            THEN 'VIP'
        WHEN COALESCE(SUM(oi.quantity * p.price), 0) BETWEEN 1000 AND 5000
            THEN 'Regular'
        ELSE 'New / Inactive'
    END AS customer_segment
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.status = 'Completed'
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city;

SELECT *
FROM customer_summary;
