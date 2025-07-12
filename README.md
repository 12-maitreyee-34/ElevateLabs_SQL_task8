This repository demonstrates the use of stored procedures and user-defined functions in MySQL to streamline business logic, automate operations, and handle complex customer-order workflows.

🛢️ Database Used
Type: Relational Database

Engine: MySQL

Use Case: Backend logic automation for a customer-order system

🔁 Stored Procedures Overview
1. Customer Order Retrieval
Retrieves detailed order history for a specific customer.

Sorts orders by date.

2. Customer Statistics
Provides total orders, total spend, average order value, and last order date via output parameters.

3. Order Processing with Logic
Automatically assigns an order status based on the customer's spending tier.

Includes validations and customized messages.

4. Loop-based Order Reporting
Generates a temporary report for customers with orders in a given date range.

Uses cursors and loops for dynamic aggregation.

5. Transactional Order Transfer
Safely transfers orders from one customer to another.

Implements transaction handling and rollback mechanisms in case of failure.

🧠 Functions Overview
1. Customer Lifetime Value
Calculates total money spent by a customer.

2. Customer Tier Evaluation
Returns customer category based on historical spending: New, Regular, Premium, or VIP.

3. Last Order Time Check
Returns number of days since a customer placed their last order.

4. Email Format Validation
Checks whether a given email follows standard formatting using regex.

5. Discount Calculator
Computes discount based on order amount and customer's tier.

