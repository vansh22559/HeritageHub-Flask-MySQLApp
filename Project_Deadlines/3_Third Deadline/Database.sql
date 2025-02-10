
Project Deadline-3
CREATE DATABASE IF NOT EXISTS HeritageHub;

SHOW DATABASES;

USE Heritagehub;

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE customer(

customerID	INT		NOT NULL,

firstName	VARCHAR(50)	NOT NULL,
middleName	VARCHAR(50),
lastName	VARCHAR(50),

Name 		VARCHAR(150) 	AS (CONCAT_WS(' ', firstName, middleName, lastName)),

streetName 	VARCHAR(100) 	NOT NULL,
aptNo 		VARCHAR(20),
city 		VARCHAR(50) 	NOT NULL,
state 		VARCHAR(50) 	NOT NULL,
pin_code 	VARCHAR(20) 	NOT NULL,

Address 	VARCHAR(255)	AS (CONCAT_WS(', ', streetName, aptNo, city, state, pin_code)),

password 	VARCHAR(255)	NOT NULL,
 
phoneNumber VARCHAR(20)		NOT NULL,

dateOfBirth DATE 			NOT NULL,

-- age INT GENERATED ALWAYS AS (YEAR(CURRENT_DATE) - YEAR(dateOfBirth) - (DATE_FORMAT(CURRENT_DATE, '%m%d') < DATE_FORMAT(dateOfBirth, '%m%d'))),
    
PRIMARY KEY(customerID),

CONSTRAINT chk_customer_address CHECK (address <> ''),
CONSTRAINT chk_customer_name CHECK (firstName <> '' AND lastName <> ''),
CONSTRAINT chk_customer_state_length CHECK (CHAR_LENGTH(state) >=0),
CONSTRAINT chk_customer_pin_code_length CHECK (CHAR_LENGTH(pin_code) = 6),
CONSTRAINT chk_customer_password_length CHECK (CHAR_LENGTH(password) >= 8),
CONSTRAINT chk_customer_phone_length CHECK (CHAR_LENGTH(phoneNumber) = 10),
CONSTRAINT chk_customer_phone UNIQUE (customerID, phoneNumber),
CONSTRAINT chk_customer_phoneDigits CHECK (phoneNumber REGEXP '^[0-9]+$')
-- CONSTRAINT chk_customer_date_of_birth CHECK (dateOfBirth <= CURRENT_DATE)
-- CONSTRAINT chk_customer_age CHECK (age > 18)
);

CREATE TABLE customerPhone (
    phoneID INT AUTO_INCREMENT PRIMARY KEY,
    customerID INT NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
    CONSTRAINT chk_customer_phoneLength CHECK (CHAR_LENGTH(phoneNumber) = 10),
    CONSTRAINT chk_customer_Digits CHECK (phoneNumber REGEXP '^[0-9]+$')
);

CREATE INDEX idx_customer_name ON customer(Name);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE deliveryAgent (

agentID		INT		NOT NULL,

firstName 	VARCHAR(50) 	NOT NULL,
middleName 	VARCHAR(50),
lastName 	VARCHAR(50)	NOT NULL,

Name 		VARCHAR(150) 	AS (CONCAT_WS(' ', firstName, middleName, lastName)),

password 	VARCHAR(255) 	NOT NULL,

phoneNumber	VARCHAR(20)	NOT NULL,

PRIMARY KEY (agentID),
CONSTRAINT chk_agent_name CHECK (firstName <> '' AND lastName <> ''),
CONSTRAINT chk_agent_password_length CHECK (CHAR_LENGTH(password) >= 8),
CONSTRAINT chk_agent_phone_length CHECK (CHAR_LENGTH(phoneNumber) = 10),
CONSTRAINT chk_agent_phoneDigits CHECK (phoneNumber REGEXP '^[0-9]+$')

);

CREATE INDEX idx_agent_name ON deliveryAgent(Name);

CREATE TABLE agentPhone (
    phoneID INT AUTO_INCREMENT PRIMARY KEY,
    agentID INT NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE,
    CONSTRAINT chk_agent_phoneLength CHECK (CHAR_LENGTH(phoneNumber) = 10),
    CONSTRAINT chk_agent_Digits CHECK (phoneNumber REGEXP '^[0-9]+$')
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE shopOwner(

ownerID		INT		NOT NULL,

firstName	VARCHAR(50)	NOT NULL,
middleName	VARCHAR(50),
lastName	VARCHAR(50)	NOT NULL,

Name 		VARCHAR(150) 	AS (CONCAT_WS(' ', firstName, middleName, lastName)),

streetName 	VARCHAR(100) 	NOT NULL,
shopNo 		VARCHAR(255),
city 		VARCHAR(50) 	NOT NULL,
state 		VARCHAR(50) 	NOT NULL,
pin_code 	VARCHAR(20) 	NOT NULL,

Address 	VARCHAR(255)	AS (CONCAT_WS(', ', streetName, shopNo, city, state, pin_code)),

password 	VARCHAR(255)	NOT NULL,
 
phoneNumber VARCHAR(20)		NOT NULL,

PRIMARY KEY(ownerID),

CONSTRAINT chk_shop_address CHECK (address <> ''),
CONSTRAINT chk_owner_name CHECK (firstName <> '' AND lastName <> ''),
CONSTRAINT chk_owner_pin_code_length CHECK (CHAR_LENGTH(pin_code) = 6),
CONSTRAINT chk_owner_password_length CHECK (CHAR_LENGTH(password) >= 8),
CONSTRAINT chk_owner_phone_length CHECK (CHAR_LENGTH(phoneNumber) = 10),
CONSTRAINT chk_owner_phone UNIQUE (ownerID, phoneNumber),
CONSTRAINT chk_owner_phoneDigits CHECK (phoneNumber REGEXP '^[0-9]+$')
);

CREATE INDEX idx_owner_name ON shopOwner(Name);

CREATE TABLE ownerPhone (
    phoneID INT AUTO_INCREMENT PRIMARY KEY,
    ownerID INT NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    FOREIGN KEY (ownerID) REFERENCES shopOwner(ownerID) ON DELETE CASCADE,
    CONSTRAINT chk_owner_phoneLength CHECK (CHAR_LENGTH(phoneNumber) = 10),
    CONSTRAINT chk_owner_Digits CHECK (phoneNumber REGEXP '^[0-9]+$')
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE `order` (
    orderID 	INT 	NOT NULL AUTO_INCREMENT,
    customerID 	INT 	NOT NULL,
    agentID 	INT	NOT NULL,
    status 	VARCHAR(50),
    order_date 	DATE,
    order_amount DECIMAL(10,2),
    PRIMARY KEY (orderID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID),
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE payment (
    paymentID 		INT NOT NULL AUTO_INCREMENT,
    customerID 		INT NOT NULL,
    orderID 		INT NOT NULL,
    payment_date 	DATE,
    payment_method 	VARCHAR(50),
    payment_amount 	DECIMAL(10,2),
    PRIMARY KEY (paymentID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID),
    FOREIGN KEY (orderID) REFERENCES `order`(orderID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE deliversTo (
    agentID INT NOT NULL,
    customerID INT NOT NULL,
    PRIMARY KEY (agentID, customerID),
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE agentReview (
    reviewID INT NOT NULL AUTO_INCREMENT,
    agentID INT NOT NULL,
    customerID INT NOT NULL,
    comment TEXT,
    rating INT,
    review_date DATE,
    PRIMARY KEY (reviewID),
    FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE product (
  productID INT AUTO_INCREMENT,
  ownerID INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  description TEXT,
  FOREIGN KEY (ownerID) REFERENCES shopOwner(ownerID),
  PRIMARY KEY (productID, ownerID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE cart (
  cartID INT AUTO_INCREMENT,
  customerID INT NOT NULL,
  totalCost DECIMAL(10,2),
  FOREIGN KEY (customerID) REFERENCES customer(customerID),
  PRIMARY KEY (cartID, customerID)
);

CREATE TABLE cart_items (
  cartItem_id INT AUTO_INCREMENT PRIMARY KEY,
  cart_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unitPrice DECIMAL(10,2) NOT NULL,
  totalPrice DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (cart_id) REFERENCES cart(cartID),
  FOREIGN KEY (product_id) REFERENCES product(productID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE wishlist (
  wishlistID INT AUTO_INCREMENT,
  customerID INT NOT NULL ,
  FOREIGN KEY (customerID) REFERENCES customer(customerID),
  PRIMARY KEY (wishlistID, customerID)
);

CREATE TABLE wishlist_items (
  wishlistItem_id INT AUTO_INCREMENT PRIMARY KEY,
  wishlist_id INT NOT NULL,
  product_id INT NOT NULL,
  FOREIGN KEY (wishlist_id) REFERENCES wishlist(wishlistID),
  FOREIGN KEY (product_id) REFERENCES product(productID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE sells (
    ownerID INT NOT NULL ,
    productID INT NOT NULL,
    PRIMARY KEY (ownerID, productID),
    FOREIGN KEY (ownerID) REFERENCES shopOwner(ownerID),
    FOREIGN KEY (productID) REFERENCES product(productID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE catalogue (
    catalogueID INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(255),
    description TEXT
);

CREATE TABLE catalogHASproducts (
    catalogueID INT NOT NULL,
    productID INT NOT NULL,
    PRIMARY KEY (catalogueID, productID),
    FOREIGN KEY (catalogueID) REFERENCES catalogue(catalogueID),
    FOREIGN KEY (productID) REFERENCES product(productID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE orderCONTAINSproduct (
    orderID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (orderID, productID),
    FOREIGN KEY (orderID) REFERENCES `order`(orderID),
    FOREIGN KEY (productID) REFERENCES product(productID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE productReview (
    customerID INT NOT NULL,
    productID INT NOT NULL,
    reviewID INT NOT NULL,
    comment TEXT,
    rating INT,
    review_date DATE,
    PRIMARY KEY (customerID, productID, reviewID),
    FOREIGN KEY (customerID) REFERENCES customer(customerID),
    FOREIGN KEY (productID) REFERENCES product(productID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE orderHistory (
    historyID INT AUTO_INCREMENT PRIMARY KEY,
    customerID INT NOT NULL,
    orderID INT NOT NULL,
    number_of_orders INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customerID) REFERENCES customer(customerID),
    FOREIGN KEY (orderID) REFERENCES `order`(orderID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE wallet (
    walletID INT AUTO_INCREMENT PRIMARY KEY,
    govtID VARCHAR(20) NOT NULL UNIQUE,
    balance DECIMAL(10, 2) NOT NULL,
    pin_code VARCHAR(20) NOT NULL,
    customerID INT NOT NULL UNIQUE,
    FOREIGN KEY (customerID) REFERENCES customer(customerID)
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE web_admin (
    adminID INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(255) NOT NULL
);

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE offer (
    offerID INT AUTO_INCREMENT PRIMARY KEY,
    adminID INT NOT NULL,
    discount_percent DECIMAL(5, 2) NOT NULL,
    coupon_code VARCHAR(50) NOT NULL,
    FOREIGN KEY (adminID) REFERENCES web_admin(adminID)
);

------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO customer (customerID, firstName, middleName, lastName, streetName, aptNo, city, state, pin_code, phoneNumber, dateOfBirth, password)
VALUES 
(1, 'John', 'Michael', 'Doe', '123 Main St', 'Apt 2', 'New York', 'NY', '100081', '5551234567', '1980-01-01', 'password'),
(2, 'Rani', '', 'Patel', 'Gandhi Nagar Colony', 'Flat 3B', 'Ahmedabad', 'Gujarat', '380006', '9876543210', '1995-02-14', 'password'),
(3, 'Vikram', 'Singh', 'Kohli', 'Rajendra Nagar', 'House No. 12', 'Jaipur', 'Rajasthan', '302001', '9911223344', '1988-08-21', 'password'),
(4, 'Priya', '', 'Das', 'Sector 42', 'Apartment 502', 'Chandigarh', 'Chandigarh', '160042', '9087654321', '1990-05-12', 'password'),
(5, 'Rahul', 'Kumar', 'Gupta', 'Vidya Nagar', 'Block C-1', 'Pune', 'Maharashtra', '411040', '9123456789', '1979-12-25', 'password'),
(6, 'Seema', '', 'Khan', 'Gali No. 3', '', 'Old Delhi', 'Delhi', '110002', '9234567890', '1992-09-07', 'password'),
(7, 'Rajesh', 'Kumar', 'Yadav', 'Main Road', 'Shop No. 2', 'Lucknow', 'Uttar Pradesh', '226001', '9345678901', '1985-03-10', 'password'),
(8, 'Anita', '', 'Sharma', 'Agra Road', 'Building No. 4', 'Mumbai', 'Maharashtra', '400056', '9456789012', '1998-11-19', 'password'),
(9, 'Arun', '', 'Rao', 'Gandhi Bazaar', '', 'Bangalore', 'Karnataka', '560001', '9567890123', '1982-06-04', 'password'),
(10, 'Maya', '', 'Sen', 'Vivekananda Marg', 'Flat No. 7', 'Kolkata', 'West Bengal', '700020', '9678901234', '1993-04-28', 'password');

INSERT INTO customerPhone (customerID, phoneNumber)
VALUES (1, '5551234568');

INSERT INTO deliveryAgent (agentID, firstName, middleName, lastName, phoneNumber, password)
VALUES 
(1, 'Mark', '', 'Robinson', '5553456789', 'password'),
(2, 'Ravi', '', 'Joshi', '9597654321', 'password'),
(3, 'Aisha', '', 'Kaur', '9876593210', 'password'),
(4, 'Rajiv', '', 'Mehta', '9123458765', 'password'),
(5, 'Priya', '', 'Sarkar', '9609875432', 'password'),
(6, 'Arun', '', 'Dasgupta', '9012347856', 'password'),
(7, 'Seema', '', 'Singh', '9345608712', 'password'),
(8, 'Vikram', '', 'Khan', '9756340128', 'password'),
(9, 'Anita', '', 'Patel', '9267809543', 'password'),
(10, 'Rahul', '', 'Sharma', '9812307659', 'password');

INSERT INTO agentPhone (agentID, phoneNumber)
VALUES (1, '5553456790');

INSERT INTO shopOwner (ownerID, firstName, middleName, lastName, streetName, shopNo, city, state, pin_code, phoneNumber, password)
VALUES 
(1, 'Alice', '', 'Williams', '567 Elm St', '1A', 'San Francisco', 'CA', '941802', '5554567890', 'password'),
(2, 'Rajesh', '', 'Gupta', 'Gandhi Road', 'Shop 2B', 'Agra', 'Uttar Pradesh', '282001', '8521473690', 'password'),
(3, 'Meena', '', 'Shah', 'Nariman Point', 'Building 5, Flat 302', 'Mumbai', 'Maharashtra', '400021', '7984561230', 'password'),
(4, 'Akash', '', 'Kumar', 'MG Road', 'Shop No. 7', 'Bangalore', 'Karnataka', '560001', '9876543210', 'password'),
(5, 'Priya', '', 'Desai', 'Jayaprakash Nagar', 'Block A-4', 'Ahmedabad', 'Gujarat', '380061', '9012345678', 'password'),
(6, 'Rahul', '', 'Singh', 'Gariahat Road', 'Shop 1, South City Mall', 'Kolkata', 'West Bengal', '700031', '8123456790', 'password'),
(7, 'Seema', '', 'Khan', 'Sector 18', 'Shop No. 12', 'Chandigarh', 'Chandigarh', '160047', '9234567891', 'password'),
(8, 'Vikram', '', 'Patel', 'Jaipur Road', 'Shop No. 3', 'Jaipur', 'Rajasthan', '302001', '9345678902', 'password'),
(9, 'Anita', '', 'Sharma', 'Connaught Place', 'Shop No. 5', 'New Delhi', 'Delhi', '110001', '9456789013', 'password'),
(10, 'Arun', '', 'Rao', 'Marina Beach Road', 'Shop No. 8', 'Chennai', 'Tamil Nadu', '600001', '9567890124', 'password');

INSERT INTO ownerPhone (ownerID, phoneNumber)
VALUES (1, '5554567891');

INSERT INTO product (productID, ownerID, name, price, quantity, description)
VALUES 
(1, 1, 'T-shirt', 19.99, 20, 'This is a comfortable and stylish t-shirt.'),
(2, 2, 'Madhubani Hand-Painted Silk Scarf', 49.99, 10, 'Made with vibrant Madhubani motifs, this silk scarf showcases traditional Mithila folk art.'),
(3, 3, 'Bidri Silver Hookah Base', 99.99, 5, 'Crafted in Bidar, this intricate hookah base features unique silver inlay work on black metal.'),
(4, 4, 'Warli Hand-Painted Wall Hanging', 34.99, 8, 'Adorned with geometric Warli designs, this wall hanging brings tribal art to your home.'),
(5, 5, 'Kalamkari Cotton Table Runner', 29.99, 12, 'Printed with traditional Kalamkari vegetable dyes, this table runner adds a touch of elegance.'),
(6, 6, 'Pattachitra Painted Wooden Box', 69.99, 3, 'This hand-painted wooden box from Odisha features vibrant folk tales and scenes.'),
(7, 7, 'Phulkari Embroidered Cushion Cover', 54.99, 7, 'Made with colorful Phulkari embroidery, this cushion cover adds a vibrant touch to your décor.'),
(8, 8, 'Bandhani Saree', 149.99, 2, 'This exquisite Bandhani saree features intricate tie-dye patterns, a symbol of Rajasthani craftsmanship.'),
(9, 9, 'Dhokra Metal Elephant Figurine', 24.99, 15, 'Hand-cast in Dhokra metal, this elephant figurine symbolizes prosperity and good luck.'),
(10, 10, 'Kerala Kasavu Mundu', 79.99, 6, 'Woven with fine cotton, this traditional Kerala mundu is perfect for special occasions.');


INSERT INTO `order` (customerID, agentID, status, order_date, order_amount)
VALUES 
(1, 1, 'Processing', '2024-02-12', 29.99),
(2, 3, 'Shipped', '2024-02-10', 49.99), 
(3, 4, 'Delivered', '2024-02-08', 34.99),
(4, 2, 'Processing', '2024-02-13', 69.99),
(5, 5, 'Cancelled', '2024-02-11', 0.00), 
(6, 6, 'Processing', '2024-02-12', 24.99),
(7, 7, 'Shipped', '2024-02-09', 149.99),  
(3, 8, 'Delivered', '2024-02-07', 54.99),  
(9, 8, 'Processing', '2024-02-14', 79.99),  
(10, 10, 'Shipped', '2024-02-11', 129.99); 

INSERT INTO payment (customerID, orderID, payment_date, payment_method, payment_amount)
VALUES 
(1, 1, '2024-02-12', 'VISA', 29.99),
(2, 2, '2024-02-12', 'Mastercard', 49.99),
(3, 3, '2024-02-10', 'VISA', 34.99),
(4, 4, '2024-02-14', 'UPI', 69.99), 
(5, 5, '2024-02-11', 'Cancelled', 0.00),
(6, 6, '2024-02-12', 'Cash on Delivery', 24.99),
(7, 7, '2024-02-09', 'VISA', 149.99),
(8, 8, '2024-02-07', 'Debit Card', 54.99),
(9, 9, '2024-02-14', 'Payment Pending', 79.99), 
(10, 10, '2024-02-11', 'VISA', 129.99);

INSERT INTO deliversTo (agentID, customerID)
VALUES 
(1, 1),
(3, 2), 
(4, 3), 
(2, 4), 
(5, 5), 
(6, 6), 
(7, 7), 
(3, 8), 
(9, 8), 
(10, 10);

INSERT INTO agentReview (agentID, customerID, comment, rating, review_date)
VALUES
(1, 1, 'Mark was very professional and prompt!', 5, '2024-02-12'),
(3, 2, 'The delivery was completed without any issues.', 3, '2024-02-14'),
(4, 3, 'The agent went above and beyond to ensure a smooth delivery.', 5, '2024-02-12'),
(2, 4, 'The delivery was professional and efficient.', 4, '2024-02-11'),
(5, 5, 'The delivery was completed as expected.', 3, '2024-02-10'),
(6, 6, 'The agent was helpful in answering my questions about the product.', 4, '2024-02-15'),
(7, 7, 'The delivery was contactless and followed safety protocols.', 5, '2024-02-14'),
(3, 8, 'The agent provided updates on the delivery status efficiently.', 4, '2024-02-13'),
(9, 8, 'The delivery experience was overall positive.', 3, '2024-02-12'),
(10, 10, 'The agent ensured the package was handled with care.', 4, '2024-02-11');

Select * from cart_items;
INSERT INTO cart (customerID, totalCost)
VALUES
(1, 49.99), 
(2, 99.99),
(3, 84.97),
(4, 0.00),
(5, 59.98),
(6, 124.95),
(7, 169.96),
(8, 204.97),
(9, 99.98),
(10, 209.97);

INSERT INTO cart_items (cart_id, product_id, quantity, unitPrice, totalPrice)
VALUES
(1, 2, 1, 49.99, 49.99), 
(2, 3, 1, 99.99, 99.99), 
(3, 1, 2, 19.99, 39.98),
(5, 5, 2, 29.99, 59.98),
(6, 6, 1, 69.99, 69.99), 
(7, 9, 2, 24.99, 49.98),
(8, 10, 1, 79.99, 79.99),
(9, 1, 3, 19.99, 59.97),
(10, 4, 3, 34.99, 104.97);

INSERT INTO wishlist (customerID)
VALUES 
(1),
(2), 
(3),
(4), 
(5),
(6),
(7), 
(8),
(9), 
(10);

INSERT INTO wishlist_items (wishlist_id, product_id)
VALUES
(1, 4), 
(1, 3),
(2, 8), 
(3, 1), 
(4, 7),
(5, 6),
(6, 5), 
(7, 9), 
(8, 3), 
(9, 10),
(10, 2);

INSERT INTO sells (ownerID, productID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

INSERT INTO catalogue (category, description)
VALUES 
('Clothing', 'A wide variety of clothing for all occasions.'),
('Home Decor', 'Traditional and modern home decor items for every room.'),
('Jewelry', 'Exquisite handmade jewelry inspired by Indian culture.'),
('Art and Crafts', 'Authentic Indian arts and crafts for collectors.'),
('Accessories', 'Fashionable accessories to complement any outfit.'),
('Footwear', 'Comfortable and stylish footwear for men and women.'),
('Bags and Purses', 'Handcrafted bags and purses for all occasions.'),
('Kitchenware', 'Functional and decorative kitchenware with Indian motifs.'),
('Toys and Games', 'Traditional toys and games for children.'),
('Gifts and Souvenirs', 'Unique gifts and souvenirs to cherish memories.');

INSERT INTO catalogHASproducts (catalogueID, productID)
VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10);

INSERT INTO orderCONTAINSproduct (orderID, productID, quantity)
VALUES
(1, 2, 1),
(1, 3, 1),
(1, 4, 2),
(1, 5, 1),
(1, 6, 3),
(1, 7, 1),
(1, 8, 2),
(1, 9, 1),
(1, 10, 2);

INSERT INTO productReview (customerID, productID, reviewID, comment, rating, review_date)
VALUES 
(1, 1, 1, 'Great t-shirt, fits perfectly!', 5, '2024-02-12'),
(2, 2, 2, 'Beautiful scarf, love the design!', 4, '2024-02-15'),
(3, 3, 3, 'Absolutely stunning hookah base!', 5, '2024-02-18'),
(4, 4, 4, 'Love the Warli design, perfect for my living room.', 4, '2024-02-20'),
(5, 5, 5, 'Elegant table runner, great quality!', 5, '2024-02-22'),
(6, 6, 6, 'The wooden box is even more beautiful in person!', 5, '2024-02-25'),
(7, 7, 7, 'Gorgeous cushion cover, adds so much color!', 5, '2024-02-28'),
(8, 8, 8, 'The Bandhani saree is exquisite, highly recommend!', 5, '2024-03-02'),
(9, 9, 9, 'The Dhokra elephant figurine is a lovely addition to my home.', 4, '2024-03-05'),
(10, 10, 10, 'Love the Kerala mundu, perfect for special occasions!', 4, '2024-03-08');

INSERT INTO orderHistory (customerID, orderID, number_of_orders, total_amount)
VALUES 
(1, 1, 1, 29.99),
(2, 2, 1, 49.99),
(3, 3, 1, 34.99),
(4, 4, 1, 69.99),
(5, 5, 1, 0.00),
(6, 6, 1, 24.99),
(7, 7, 1, 149.99),
(8, 8, 1, 54.99),
(9, 9, 1, 79.99),
(10, 10, 1, 129.99);

INSERT INTO wallet (customerID, govtID, balance, pin_code)
VALUES 
(1, '1234567890', 0.00, '1234'),
(2, '2345678901', 1000.00, '2345'),
(3, '3456789012', 500.00, '3456'),
(4, '4567890123', 0.00, '4567'),
(5, '5678901234', 250.00, '5678'),
(6, '6789012345', 0.00, '6789'),
(7, '7890123456', 750.00, '7890'),
(8, '8901234567', 0.00, '8901'),
(9, '9012345678', 150.00, '9012'),
(10, '0123456789', 0.00, '0123');

INSERT INTO web_admin (password)
VALUES ('admin_password');

INSERT INTO offer (adminID, discount_percent, coupon_code) VALUES
(1, 10, 'WELCOME10'),
(1, 15, 'NEW15'),
(1, 20, 'FEB20'),
(1, 25, 'SALE25'),
(1, 30, 'SPRING30'),
(1, 5, 'FIRST5'),
(1, 12, 'FEBRUARY12'),
(1, 18, 'MARCH18'),
(1, 22, 'SPRING22'),
(1, 8, 'SUMMER8');