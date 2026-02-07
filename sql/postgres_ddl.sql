--To create tables
CREATE TABLE customers_raw(
customer_id INT,
email TEXT,
phone TEXT,
country_code TEXT,
updated_at TIMESTAMP,
created_at TIMESTAMP);


CREATE TABLE orders_raw(
order_id INT,
customer_id INT,
product_id TEXT,
amount FLOAT,
created_at TIMESTAMP,
currency TEXT);


CREATE TABLE products_raw(
product_id text,
product_name text,
category text,
active_flag CHAR(1));

CREATE TABLE country_dim(
country_name text,
iso_code text);

--To insert data
INSERT INTO products_raw(product_id,product_name,category,active_flag)
VALUES ('P01','keyboard','hardware','Y'),
('P02','MOUSE','Hardware','Y'),
('P03','Monitor','Hardware','N'),
('P04','Premium Cable','Accessory','Y');

INSERT INTO country_dim(country_name,iso_code)
VALUES ('United States','US'),
('India','IN'),
('Singapore','SG'),
('Unknown',null);

INSERT INTO orders_raw (order_id,customer_id,product_id,amount,created_at,currency)
VALUES(5001,101,'P01',120.00,'2025-07-10 09:00:00','USD'),
(5002, 102, 'P02', 80.5,  '2025-07-10 09:05:00','usd'),
(5003, 103, null , 200.00,'2025-07-10 09:15:00','INR'),
(5004, 105, 'P99', null,  '2025-07-10 09:20:00',null),
(5002, 102, 'P02', 80.50, '2025-07-10 09:05:00','USD'),
(5005, 106, 'P03', -50,   '2025-07-10 09:25:00','SGD'),
(5006, 107, null, 300,  '2025-07-11 10:00:00','usd'),
(5007, 108, 'P04', 500,   '2025-07-11 10:15:00','EUR');


INSERT INTO customers_raw(customer_id,email,phone,country_code,updated_at,created_at)
VALUES (101,'John@example.com','111-222-3333','US','2025-07-01 10:15:00', '2025-01-01 08:00:00'),
(101,'john.d@example.com','(111)2223333', 'usa', '2025-07-03 14:25:00',	'2025-01-01 8:00:00'),
(102,'alice@example.com',null,'UnitedStates','2025-07-01 9:10:00',null),
(103,'michael@abc.com','9998887777', null , '2025-07-02 12:45:00', '2025-03-01 10:00:00'),
(104,'bob@xyz.com',null,'IND','2025-07-05 15:00:00',	'2025-03-10 9:30:00'),
(104,'bob@xyz.com',null,'India','2025-07-06 18:00:00','2025-03-10 9:30:00'),
(106,'duplicate@email.com',1234567890,'SINGAPORE','2025-07-01 8:00:00','2025-04-01 11:45:00'),
(106,'duplicate@email.com',123-456-7890,'SG','2025-07-10 12:00:00','2025-04-01 11:45:00'),
(108, null, null, null, null, null);
