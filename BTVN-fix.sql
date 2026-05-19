      
CREATE DATABASE sales_management_system;
USE sales_management_system;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    gender ENUM('Male', 'Female') NOT NULL,
    birth_date DATE
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL CHECK(price >= 0),
    category_id INT,

    FOREIGN KEY(category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,

    FOREIGN KEY(customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK(quantity > 0),
    unit_price DECIMAL(18,2) NOT NULL CHECK(unit_price >= 0),

    PRIMARY KEY(order_id, product_id),

    FOREIGN KEY(order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);

INSERT INTO customers(full_name, email, gender, birth_date)
VALUES
('Nguyen Van An', 'an@gmail.com', 'Male', '2001-05-10'),
('Tran Thi Bich', 'bich@gmail.com', 'Female', '2000-09-21'),
('Le Hoang Nam', 'nam@gmail.com', 'Male', '1999-12-15'),
('Pham Thu Trang', 'trang@gmail.com', 'Female', '2002-03-08'),
('Vo Minh Quan', 'quan@gmail.com', 'Male', '2003-11-30');

INSERT INTO categories(category_name)
VALUES
('Dien tu'),
('Laptop'),
('Phu kien'),
('Gaming'),
('Van phong');

INSERT INTO products(product_name, price, category_id)
VALUES
('iPhone 15', 25000000, 1),
('Samsung S24', 22000000, 1),
('MacBook Air M2', 29000000, 2),
('Dell XPS 15', 31000000, 2),
('Tai nghe Bluetooth', 1200000, 3),
('Chuot Gaming', 900000, 4),
('Ban phim co', 1500000, 4),
('May in Canon', 3500000, 5);

INSERT INTO orders(customer_id, order_date)
VALUES
(1, '2026-05-01'),
(2, '2026-05-02'),
(1, '2026-05-03'),
(4, '2026-05-04'),
(5, '2026-05-05');

INSERT INTO order_details(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 25000000),
(1, 5, 2, 1200000),
(2, 3, 1, 29000000),
(3, 2, 1, 22000000),
(3, 6, 1, 900000),
(4, 4, 1, 31000000),
(5, 7, 2, 1500000);

UPDATE products
SET price = 27000000
WHERE product_name = 'iPhone 15';

-- Cập nhật email khách hàng
UPDATE customers
SET email = 'new_an@gmail.com'
WHERE customer_id = 1;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM order_details
WHERE order_id = 5
AND product_id = 7;
SET SQL_SAFE_UPDATES = 1;

SELECT full_name AS 'hoten',email as 'email',
case
	when gender = 'male' then 'nam'
    else 'nu'
end 'gioitinh' from customers;

select full_name, year(now())-year(birth_date) as 'age' from customers order by age asc limit 3;

select o.*, c.full_name
from orders o join customers c on o.customer_id=c.customer_id;

SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products
FROM categories c
JOIN products p
ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) >= 2;

SELECT *
FROM products
WHERE price >
(
    SELECT AVG(price)
    FROM products
);

SELECT *
FROM customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM orders
);

SELECT
    c.category_name,
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN order_details od
    ON p.product_id = od.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(od.quantity * od.unit_price)
>
(
    SELECT AVG(total_money) * 1.2
    FROM
    (
        SELECT
            SUM(od.quantity * od.unit_price) AS total_money
        FROM categories c
        JOIN products p
            ON c.category_id = p.category_id
        JOIN order_details od
            ON p.product_id = od.product_id
        GROUP BY c.category_id
    ) temp
);

SELECT *
FROM products p1
WHERE price =
(
    SELECT MAX(price)
    FROM products p2
    WHERE p1.category_id = p2.category_id
);

SELECT DISTINCT full_name
FROM customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM orders
    WHERE order_id IN
    (
        SELECT order_id
        FROM order_details
        WHERE product_id IN
        (
            SELECT product_id
            FROM products
            WHERE category_id IN
            (
                SELECT category_id
                FROM categories
                WHERE category_name = 'Dien tu'
            )
        )
    )
);

    