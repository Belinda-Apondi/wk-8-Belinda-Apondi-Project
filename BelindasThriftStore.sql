-- Thrift Store Database Management System
-- This database manages inventory, donors, customers, employees, and sales for a thrift store.
-- BELINDA APONDI

CREATE DATABASE thrift_store_db;
USE thrift_store_db;

-- Table for store locations
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(10) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    phone VARCHAR(16) NOT NULL,
    manager_id INT, 
    UNIQUE (address, city, state)
);

-- Table for item categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(200)
);

-- Table for donors
CREATE TABLE donors (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(14),
    address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(10),
    zip_code VARCHAR(15),
    donation_count INT DEFAULT 0,
    first_donation_date DATE,
    last_donation_date DATE
);

-- Table for employees
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) NOT NULL,
    hire_date DATE NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    location_id INT NOT NULL,
    manager_id INT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Now we can set the manager_id in locations table
ALTER TABLE locations
ADD CONSTRAINT fk_manager
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Table for inventory items
CREATE TABLE items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    category_id INT NOT NULL,
    donor_id INT,
    acquisition_date DATE NOT NULL,
    acquisition_price DECIMAL(10,2),
    list_price DECIMAL(10,2) NOT NULL,
    condition VARCHAR(20) NOT NULL CHECK (condition IN ('New', 'Like New', 'Good', 'Fair', 'Poor')),
    location_id INT NOT NULL,
    is_sold BOOLEAN DEFAULT FALSE,
    sale_id INT, -- Will be set after sales table exists
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Table for customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    join_date DATE DEFAULT (CURRENT_DATE),
    purchase_count INT DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0.00
);

-- Table for sales
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT NOT NULL,
    sale_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('Cash', 'Credit', 'Debit', 'Gift Card')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Now we can set the sale_id in items table
ALTER TABLE items
ADD CONSTRAINT fk_sale
FOREIGN KEY (sale_id) REFERENCES sales(sale_id);

-- Junction table for items in sales (handles M-M relationship)
CREATE TABLE sale_items (
    sale_id INT NOT NULL,
    item_id INT NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (sale_id, item_id),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- Table for discounts/promotions
CREATE TABLE promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('Percentage', 'Fixed Amount')),
    discount_value DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    applicable_category_id INT,
    FOREIGN KEY (applicable_category_id) REFERENCES categories(category_id)
);

-- Table for volunteer hours tracking
CREATE TABLE volunteer_hours (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT NOT NULL,
    date_worked DATE NOT NULL,
    hours_worked DECIMAL(4,2) NOT NULL,
    location_id INT NOT NULL,
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Insert sample data
INSERT INTO categories (name, description) VALUES 
('Clothing', 'All types of wearable items'),
('Furniture', 'Home and office furniture'),
('Books', 'Fiction and non-fiction books'),
('Electronics', 'Electronic devices and accessories'),
('Housewares', 'Kitchen and home items');

INSERT INTO locations (address, city, state, zip_code, phone) VALUES
('123 Main St', 'Springfield', 'IL', '62704', '217-555-1001'),
('456 Oak Ave', 'Springfield', 'IL', '62704', '217-555-1002'),
('789 Elm Blvd', 'Chicago', 'IL', '60601', '312-555-2001');

-- Add employees (managers first)
INSERT INTO employees (first_name, last_name, email, phone, hire_date, position, salary, location_id) VALUES
('Sarah', 'Johnson', 's.johnson@example.com', '217-555-1101', '2020-01-15', 'Store Manager', 48000.00, 1),
('Michael', 'Chen', 'm.chen@example.com', '217-555-1102', '2020-03-10', 'Store Manager', 48000.00, 2),
('David', 'Williams', 'd.williams@example.com', '312-555-2101', '2019-11-05', 'Store Manager', 52000.00, 3);

-- Update location managers
UPDATE locations SET manager_id = 1 WHERE location_id = 1;
UPDATE locations SET manager_id = 2 WHERE location_id = 2;
UPDATE locations SET manager_id = 3 WHERE location_id = 3;

-- Add more employees
INSERT INTO employees (first_name, last_name, email, phone, hire_date, position, salary, location_id, manager_id) VALUES
('Emily', 'Rodriguez', 'e.rodriguez@example.com', '217-555-1103', '2021-02-20', 'Assistant Manager', 38000.00, 1, 1),
('James', 'Wilson', 'j.wilson@example.com', '217-555-1104', '2021-05-15', 'Sales Associate', 28000.00, 1, 1),
('Lisa', 'Brown', 'l.brown@example.com', '217-555-1105', '2021-06-10', 'Inventory Specialist', 30000.00, 2, 2),
('Robert', 'Garcia', 'r.garcia@example.com', '312-555-2102', '2020-08-12', 'Assistant Manager', 40000.00, 3, 3);

-- Add donors
INSERT INTO donors (first_name, last_name, email, phone, address, city, state, zip_code, donation_count, first_donation_date, last_donation_date) VALUES
('Jennifer', 'Smith', 'j.smith@example.com', '217-555-1201', '100 Maple St', 'Springfield', 'IL', '62704', 5, '2021-01-10', '2022-05-15'),
('Thomas', 'Lee', 't.lee@example.com', '217-555-1202', '200 Pine Ave', 'Springfield', 'IL', '62704', 3, '2021-03-05', '2022-04-20'),
('Amanda', 'Taylor', 'a.taylor@example.com', '312-555-2201', '300 Cedar Ln', 'Chicago', 'IL', '60605', 8, '2020-11-15', '2022-06-10');

-- Add customers
INSERT INTO customers (first_name, last_name, email, phone) VALUES
('Daniel', 'Martinez', 'd.martinez@example.com', '217-555-1301'),
('Jessica', 'Anderson', 'j.anderson@example.com', '217-555-1302'),
('Christopher', 'Thomas', 'c.thomas@example.com', '312-555-2301');

-- Add inventory items
INSERT INTO items (name, description, category_id, donor_id, acquisition_date, acquisition_price, list_price, condition, location_id) VALUES
('Red Winter Coat', 'Women''s size M red wool coat', 1, 1, '2022-05-10', NULL, 25.99, 'Good', 1),
('Wooden Dining Table', '4-seat oak table, minor scratches', 2, 2, '2022-04-15', NULL, 120.00, 'Fair', 1),
('Smartphone', 'Used iPhone 11, 64GB', 4, 3, '2022-06-01', NULL, 250.00, 'Like New', 3),
('Coffee Table Book', '"National Geographic: Wonders of the World"', 3, NULL, '2022-05-20', 2.00, 8.99, 'Good', 2),
('Blender', 'Oster 10-speed blender', 5, 1, '2022-05-05', NULL, 15.50, 'Fair', 1);

-- Add a sale
INSERT INTO sales (customer_id, employee_id, sale_date, subtotal, tax, total, payment_method) VALUES
(1, 2, '2022-06-15 14:30:00', 25.99, 2.08, 28.07, 'Credit');

-- Update the sold item
UPDATE items SET is_sold = TRUE, sale_id = 1 WHERE item_id = 1;

-- Add sale item
INSERT INTO sale_items (sale_id, item_id, sale_price) VALUES
(1, 1, 25.99);

-- Update customer purchase count and total spent
UPDATE customers SET purchase_count = 1, total_spent = 28.07 WHERE customer_id = 1;

-- Add promotions
INSERT INTO promotions (name, description, discount_type, discount_value, start_date, end_date, applicable_category_id) VALUES
('Summer Clothing Sale', '25% off all clothing', 'Percentage', 25.00, '2022-06-01', '2022-08-31', 1),
('Furniture Clearance', '$50 off all furniture over $200', 'Fixed Amount', 50.00, '2022-05-15', '2022-07-15', 2);

-- Add volunteer hours
INSERT INTO volunteer_hours (donor_id, date_worked, hours_worked, location_id) VALUES
(1, '2022-05-10', 4.00, 1),
(2, '2022-05-15', 3.50, 1),
(3, '2022-06-05', 5.00, 3);



