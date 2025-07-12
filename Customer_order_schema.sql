Create Database Customer_order_db;
USE Customer_order_db;

CREATE TABLE Customer(
customer_id INT PRIMARY KEY AUTO_INCREMENT,
customer_name VARCHAR(100) NOT NULL,
email VARCHAR(50) UNIQUE,
phone_no VARCHAR(20),
address TEXT NOT NULL,
created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(50) DEFAULT 'Pending',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

INSERT INTO Customer (customer_name, email, phone_no, address) VALUES
('John Smith', 'john.smith@email.com', '555-0101', '123 Main Street, New York, NY 10001'),
('Sarah Johnson', 'sarah.johnson@email.com', '555-0102', '456 Oak Avenue, Los Angeles, CA 90210'),
('Michael Brown', 'michael.brown@email.com', '555-0103', '789 Pine Road, Chicago, IL 60601'),
('Emily Davis', 'emily.davis@email.com', '555-0104', '321 Elm Street, Houston, TX 77001');

Select * from Customer;

INSERT INTO orders (customer_id, order_date, total_amount, order_status) VALUES
(1, '2024-06-15', 299.99, 'Completed'),
(2, '2024-06-20', 149.50, 'Pending'),
(3, '2024-06-25', 599.00, 'Shipped'),
(4, '2024-06-28', 89.95, 'Processing');

SELECT * FROM orders;

-- inner join that returns only the customers who have placed order
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Customer c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- right outer join 
-- Returns all orders, including those without associated customers
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Customer c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- Left Outer Join
-- Returns all customers, including those without orders
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Full Outer Join
-- makes use of UNION keyword as MySQL doesnt directly support Full Outer Join 
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Customer c
RIGHT JOIN orders o ON c.customer_id = o.customer_id;

--  CROSS JOIN
-- Returns Cartesian product (every customer with every order)
SELECT 
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM Customer c
CROSS JOIN orders o;

--  SELF JOIN on Customer table
-- Find customers from the same city 
SELECT 
    c1.customer_name as Customer1,
    c2.customer_name as Customer2,
    SUBSTRING_INDEX(c1.address, ',', -2) as Location
FROM Customer c1
JOIN Customer c2 ON SUBSTRING_INDEX(c1.address, ',', -2) = SUBSTRING_INDEX(c2.address, ',', -2)
AND c1.customer_id < c2.customer_id;

-- NATURAL JOIN (automatically joins on common column names)
-- This works because both tables have customer_id column
SELECT 
    customer_id,
    customer_name,
    email,
    order_id,
    order_date,
    total_amount,
    order_status
FROM Customer
NATURAL JOIN orders;

--  INNER JOIN with WHERE clause
-- Get customers with orders over $200
SELECT 
    c.customer_name,
    c.email,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Customer c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > 200.00;

-- Subqueries 
-- 1. Scalar Subquery (Returns one single value)
SELECT customer_name, email
FROM Customer c
WHERE c.customer_id IN (
    SELECT customer_id 
    FROM orders 
    WHERE total_amount > (SELECT AVG(total_amount) FROM orders) -- Scalar query
);

-- 2. Multi-row Query (Returns mutiple values )
-- Find customers who have placed orders (using IN)
SELECT customer_name, email, phone_no
FROM Customer
WHERE customer_id IN (
    SELECT DISTINCT customer_id 
    FROM orders
);

-- 3. CORRELATED SUBQUERY (Depends on outer query)
-- Find customers with their highest order amount
SELECT customer_name, 
       email,
       (SELECT MAX(total_amount) 
        FROM orders o 
        WHERE o.customer_id = c.customer_id) as highest_order
FROM Customer c;

-- 4. EXISTS SUBQUERY (Checks existence)
-- Find customers who have placed at least one order
SELECT customer_name, email, address
FROM Customer c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);

-- Find customers who have NOT placed any orders
SELECT customer_name, email, phone_no
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);

-- NESTED SUBQUERIES (Multiple levels)
-- Find customers in the same city as the highest spender
SELECT customer_name, address
FROM Customer
WHERE SUBSTRING_INDEX(address, ',', -2) = (
    SELECT SUBSTRING_INDEX(address, ',', -2)
    FROM Customer
    WHERE customer_id = (
        SELECT customer_id
        FROM orders
        WHERE total_amount = (SELECT MAX(total_amount) FROM orders)
    )
);

-- Views and various features related to views.

-- 1.Create a simple view that shows customer order summary
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone_no,
    COUNT(o.order_id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM Customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email, c.phone_no;

SELECT * FROM customer_order_summary;

-- 2. COMPLEX VIEW WITH JOINS AND CALCULATIONS
CREATE VIEW active_customers_view AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.address,
    SUBSTRING_INDEX(c.address, ',', -2) as city_state,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status,
    CASE 
        WHEN o.total_amount > 500 THEN 'High Value'
        WHEN o.total_amount > 200 THEN 'Medium Value'
        ELSE 'Low Value'
    END as order_category,
    DATEDIFF(CURDATE(), o.order_date) as days_since_order
FROM Customer c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Completed', 'Shipped', 'Processing');

SELECT * FROM active_customers_view;

-- 3. SECURITY VIEW - Hide sensitive information
CREATE VIEW public_customer_info AS
SELECT 
    customer_id,
    customer_name,
    email,
    SUBSTRING_INDEX(address, ',', -2) as city_state,
    created_date
FROM Customer;

SELECT * FROM public_customer_info;

-- 4. VIEW WITH AGGREGATION AND RANKING

CREATE VIEW customer_rankings AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COUNT(o.order_id) as order_count,
    RANK() OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC) as spending_rank,
    CASE 
        WHEN COALESCE(SUM(o.total_amount), 0) > 400 THEN 'VIP'
        WHEN COALESCE(SUM(o.total_amount), 0) > 200 THEN 'Premium'
        WHEN COALESCE(SUM(o.total_amount), 0) > 0 THEN 'Regular'
        ELSE 'New Customer'
    END as customer_tier
FROM Customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email;


SELECT * FROM customer_rankings ORDER BY spending_rank;

-- 5. UPDATABLE VIEW EXAMPLE

CREATE VIEW customer_contact_view AS
SELECT 
    customer_id,
    customer_name,
    email,
    phone_no
FROM Customer;


SELECT * FROM customer_contact_view WHERE customer_id = 1;

-- 6. VIEW WITH CHECK OPTION

CREATE VIEW high_value_orders AS
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    order_status
FROM orders
WHERE total_amount > 200
WITH CHECK OPTION;


SELECT * FROM high_value_orders;



-- 7. NESTED VIEW (View based on another view)

CREATE VIEW vip_customers AS
SELECT 
    customer_id,
    customer_name,
    email,
    total_spent,
    order_count
FROM customer_rankings
WHERE customer_tier = 'VIP';

SELECT * FROM vip_customers;

-- 8. VIEW FOR REPORTING AND ANALYTICS
CREATE VIEW monthly_sales_report AS
SELECT 
    YEAR(order_date) as year,
    MONTH(order_date) as month,
    MONTHNAME(order_date) as month_name,
    COUNT(order_id) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
ORDER BY year, month;


SELECT * FROM monthly_sales_report;

DELIMITER  //

-- ========================================
-- STORED PROCEDURES
-- ========================================

-- 1. BASIC STORED PROCEDURE - Get customer orders
CREATE PROCEDURE GetCustomerOrders(
    IN p_customer_id INT
)
BEGIN
    SELECT 
        c.customer_name,
        c.email,
        o.order_id,
        o.order_date,
        o.total_amount,
        o.order_status
    FROM Customer c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END //

-- 2. PROCEDURE WITH IN/OUT PARAMETERS
CREATE PROCEDURE GetCustomerStats(
    IN p_customer_id INT,
    OUT p_total_orders INT,
    OUT p_total_spent DECIMAL(10,2),
    OUT p_avg_order_value DECIMAL(10,2),
    OUT p_last_order_date DATE
)
BEGIN
    SELECT 
        COUNT(order_id),
        COALESCE(SUM(total_amount), 0),
        COALESCE(AVG(total_amount), 0),
        MAX(order_date)
    INTO p_total_orders, p_total_spent, p_avg_order_value, p_last_order_date
    FROM orders
    WHERE customer_id = p_customer_id;
END //

-- 3. PROCEDURE WITH CONDITIONAL LOGIC
CREATE PROCEDURE ProcessOrder(
    IN p_customer_id INT,
    IN p_order_date DATE,
    IN p_total_amount DECIMAL(10,2),
    OUT p_order_id INT,
    OUT p_status_message VARCHAR(100)
)
BEGIN
    DECLARE customer_exists INT DEFAULT 0;
    DECLARE customer_tier VARCHAR(20) DEFAULT 'Regular';
    
    -- Check if customer exists
    SELECT COUNT(*) INTO customer_exists
    FROM Customer
    WHERE customer_id = p_customer_id;
    
    IF customer_exists = 0 THEN
        SET p_order_id = 0;
        SET p_status_message = 'Error: Customer not found';
    ELSE
        -- Determine customer tier based on previous orders
        SELECT 
            CASE 
                WHEN COALESCE(SUM(total_amount), 0) > 1000 THEN 'VIP'
                WHEN COALESCE(SUM(total_amount), 0) > 500 THEN 'Premium'
                ELSE 'Regular'
            END INTO customer_tier
        FROM orders
        WHERE customer_id = p_customer_id;
        
        -- Insert order with appropriate status
        INSERT INTO orders (customer_id, order_date, total_amount, order_status)
        VALUES (p_customer_id, p_order_date, p_total_amount, 
                CASE 
                    WHEN customer_tier = 'VIP' THEN 'Priority Processing'
                    WHEN customer_tier = 'Premium' THEN 'Fast Processing'
                    ELSE 'Standard Processing'
                END);
        
        SET p_order_id = LAST_INSERT_ID();
        SET p_status_message = CONCAT('Order created successfully for ', customer_tier, ' customer');
    END IF;
END //

-- 4. PROCEDURE WITH LOOPS
CREATE PROCEDURE GenerateOrderReport(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customer_id INT;
    DECLARE v_customer_name VARCHAR(100);
    DECLARE v_total_orders INT;
    DECLARE v_total_spent DECIMAL(10,2);
    
    -- Cursor for customers
    DECLARE customer_cursor CURSOR FOR
        SELECT DISTINCT c.customer_id, c.customer_name
        FROM Customer c
        INNER JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.order_date BETWEEN p_start_date AND p_end_date;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create temporary table for report
    CREATE TEMPORARY TABLE temp_report (
        customer_id INT,
        customer_name VARCHAR(100),
        total_orders INT,
        total_spent DECIMAL(10,2),
        avg_order_value DECIMAL(10,2)
    );
    
    OPEN customer_cursor;
    
    read_loop: LOOP
        FETCH customer_cursor INTO v_customer_id, v_customer_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calculate stats for each customer
        SELECT 
            COUNT(order_id),
            SUM(total_amount)
        INTO v_total_orders, v_total_spent
        FROM orders
        WHERE customer_id = v_customer_id
        AND order_date BETWEEN p_start_date AND p_end_date;
        
        -- Insert into temporary table
        INSERT INTO temp_report VALUES (
            v_customer_id,
            v_customer_name,
            v_total_orders,
            v_total_spent,
            v_total_spent / v_total_orders
        );
    END LOOP;
    
    CLOSE customer_cursor;
    
    -- Return the report
    SELECT * FROM temp_report ORDER BY total_spent DESC;
    
    -- Clean up
    DROP TEMPORARY TABLE temp_report;
END //

-- 5. PROCEDURE WITH TRANSACTION HANDLING
CREATE PROCEDURE TransferCustomerOrders(
    IN p_from_customer_id INT,
    IN p_to_customer_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(200)
)
BEGIN
    DECLARE v_order_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Error: Transaction failed';
    END;
    
    START TRANSACTION;
    
    -- Check if both customers exist
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE customer_id = p_from_customer_id) THEN
        SET p_success = FALSE;
        SET p_message = 'Error: Source customer not found';
        ROLLBACK;
    ELSEIF NOT EXISTS (SELECT 1 FROM Customer WHERE customer_id = p_to_customer_id) THEN
        SET p_success = FALSE;
        SET p_message = 'Error: Target customer not found';
        ROLLBACK;
    ELSE
        -- Count orders to transfer
        SELECT COUNT(*) INTO v_order_count
        FROM orders
        WHERE customer_id = p_from_customer_id;
        
        -- Transfer orders
        UPDATE orders
        SET customer_id = p_to_customer_id
        WHERE customer_id = p_from_customer_id;
        
        COMMIT;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Successfully transferred ', v_order_count, ' orders');
    END IF;
END //

-- ========================================
-- FUNCTIONS
-- ========================================

-- 1. SCALAR FUNCTION - Calculate customer lifetime value
CREATE FUNCTION GetCustomerLifetimeValue(p_customer_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total_spent DECIMAL(10,2) DEFAULT 0;
    
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total_spent
    FROM orders
    WHERE customer_id = p_customer_id;
    
    RETURN v_total_spent;
END //

-- 2. FUNCTION WITH CONDITIONAL LOGIC
CREATE FUNCTION GetCustomerTier(p_customer_id INT)
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total_spent DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tier VARCHAR(20) DEFAULT 'New Customer';
    
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total_spent
    FROM orders
    WHERE customer_id = p_customer_id;
    
    IF v_total_spent > 1000 THEN
        SET v_tier = 'VIP';
    ELSEIF v_total_spent > 500 THEN
        SET v_tier = 'Premium';
    ELSEIF v_total_spent > 0 THEN
        SET v_tier = 'Regular';
    END IF;
    
    RETURN v_tier;
END //

-- 3. FUNCTION FOR DATE CALCULATIONS
CREATE FUNCTION GetDaysSinceLastOrder(p_customer_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_last_order_date DATE;
    DECLARE v_days_since INT DEFAULT 0;
    
    SELECT MAX(order_date)
    INTO v_last_order_date
    FROM orders
    WHERE customer_id = p_customer_id;
    
    IF v_last_order_date IS NOT NULL THEN
        SET v_days_since = DATEDIFF(CURDATE(), v_last_order_date);
    ELSE
        SET v_days_since = -1; -- No orders found
    END IF;
    
    RETURN v_days_since;
END //

-- 4. FUNCTION FOR VALIDATION
CREATE FUNCTION ValidateEmail(p_email VARCHAR(100))
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END //

-- 5. FUNCTION FOR BUSINESS LOGIC
CREATE FUNCTION CalculateDiscount(p_customer_id INT, p_order_amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_tier VARCHAR(20);
    DECLARE v_discount DECIMAL(10,2) DEFAULT 0;
    
    SET v_tier = GetCustomerTier(p_customer_id);
    
    CASE v_tier
        WHEN 'VIP' THEN SET v_discount = p_order_amount * 0.15;
        WHEN 'Premium' THEN SET v_discount = p_order_amount * 0.10;
        WHEN 'Regular' THEN SET v_discount = p_order_amount * 0.05;
        ELSE SET v_discount = 0;
    END CASE;
    
    RETURN v_discount;
END //

-- Reset delimiter
DELIMITER ;
