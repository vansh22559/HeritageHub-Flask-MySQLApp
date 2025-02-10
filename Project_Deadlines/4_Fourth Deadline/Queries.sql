-- 1. Query to retrieve customer information who have placed orders with a total amount greater than SOME of the orders placed by other customers

SELECT DISTINCT c.*
FROM customer c
JOIN `order` o ON c.customerID = o.customerID
WHERE o.order_amount > SOME (
    SELECT order_amount
    FROM `order`
    WHERE customerID <> c.customerID
);


---------------------------------------------------------------------------------------------------------------------

-- 2. Query to retrieve customer reviews along with their corresponding product names, sorted by the number of reviews each product has:

SELECT c.firstName, c.lastName, pr.comment, pr.rating, p.name
FROM customer c
JOIN productReview pr ON c.customerID = pr.customerID
JOIN (
    SELECT productID, COUNT(*) AS num_reviews
    FROM productReview
    GROUP BY productID
) AS review_counts ON pr.productID = review_counts.productID
JOIN product p ON pr.productID = p.productID
ORDER BY review_counts.num_reviews DESC;

-----------------------------------------------------------------------------------------------------------------------

-- 3. Query to retrieve customer information regarding people who have not placed any orders

SELECT c.customerID, c.firstName, c.lastName
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM `order` o
    WHERE c.customerID = o.customerID
);

-----------------------------------------------------------------------------------------------------------------------

-- 4. Query to find the top 5 customers who have made the highest total purchases:

SELECT c.customerID, c.firstName, c.lastName, SUM(o.order_amount) AS total_purchases
FROM customer c
JOIN `order` o ON c.customerID = o.customerID
GROUP BY c.customerID
ORDER BY total_purchases DESC
LIMIT 5;

------------------------------------------------------------------------------------------------------------------------

-- 5. Query to update the price of products by applying a discount of 10% for products with more than 100 units in stock:

UPDATE product
SET price = price * 0.9
WHERE quantity > 100;

-------------------------------------------------------------------------------------------------------------------------

-- 6. Query to update the status of orders where the payment method is 'Cancelled' i.e. order is cancelled:

UPDATE `order`
SET status = 'Cancelled'
WHERE orderID IN (
    SELECT * FROM (
        SELECT o.orderID
        FROM `order` o
        JOIN payment p ON o.orderID = p.orderID
        WHERE p.payment_method = 'Cancelled'
    ) AS temp
);

------------------------------------------------------------------------------------------------------------------------

-- 7. Query to delete records from the order table where the payment method is 'Cancelled'.

DELETE FROM `order`
WHERE orderID IN (
    SELECT * FROM (
        SELECT o.orderID
        FROM `order` o
        JOIN payment p ON o.orderID = p.orderID
        WHERE p.payment_method = 'Cancelled'
    ) AS temp
);

------------------------------------------------------------------------------------------------------------------------

-- 8. Query to retrieve information about delivery agents who have delivered more than 3 orders:

SELECT 
    da.agentID,
    da.firstName,
    da.lastName,
    COUNT(o.orderID) AS num_orders_delivered
FROM 
    deliveryAgent da
LEFT JOIN 
    `order` o ON da.agentID = o.agentID
GROUP BY 
    da.agentID, da.firstName, da.lastName
HAVING 
    COUNT(o.orderID) > 3;

-----------------------------------------------------------------------------------------------------------------------

-- 9. Query to retrieve customers who have both items in their cart and wishlist

SELECT c.*
FROM customer c
NATURAL JOIN cart_items ci
INTERSECT
SELECT c.*
FROM customer c
NATURAL JOIN wishlist_items w;

-----------------------------------------------------------------------------------------------------------------------

-- 10. Query for retriveing customers who have placed orders with a total amount greater than the average order amount

SELECT DISTINCT c.*
FROM customer c
JOIN `order` o ON c.customerID = o.customerID
WHERE (SELECT AVG(order_amount) FROM `order`) < 
      (SELECT SUM(order_amount) FROM `order` WHERE customerID = c.customerID);

-----------------------------------------------------------------------------------------------------------------------


-- Miscellaneous: 


-- # Showcasing constraints using a query attempts to insert a customer with the phone number 'invalid_phone', which violates the constraint chk_customer_phoneDigits that ensures the phone number contains only digits. 

INSERT INTO customer (customerID, firstName, middleName, lastName, streetName, aptNo, city, state, pin_code, phoneNumber, dateOfBirth, password)
VALUES 
(11, 'Test', '', 'User', '123 Test St', '', 'Test City', 'Test State', '12345', 'invalid_phone', '2000-01-01', 'testpassword');


-- # Showcasing constraints using a query attempts to insert a customer with with password length less than 8 characters. 

INSERT INTO customer (customerID, firstName, middleName, lastName, streetName, aptNo, city, state, pin_code, phoneNumber, dateOfBirth, password)
VALUES 
(11, 'Test', '', 'User', '123 Test St', '', 'Test City', 'Test State', '12345', '1234567890', '2000-01-01', '123');


-- # Query to retrieve customer information along with their orders and the most recent order date:

SELECT c.firstName, c.lastName, o.orderID, o.order_date, o.order_amount, recent_orders.max_order_date
FROM customer c
JOIN `order` o ON c.customerID = o.customerID
JOIN (
    SELECT customerID, MAX(order_date) AS max_order_date
    FROM `order`
    GROUP BY customerID
) AS recent_orders ON c.customerID = recent_orders.customerID;



-- # Alter commands to  delete records from the parent tables, related records in child tables will be automatically deleted, avoiding integrity constraint violations.


-- Enable cascading delete for the customerPhone table
ALTER TABLE customerPhone
DROP FOREIGN KEY customerPhone_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE;

-- Enable cascading delete for the agentPhone table
ALTER TABLE agentPhone
DROP FOREIGN KEY agentPhone_ibfk_1,
ADD FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE;

-- Enable cascading delete for the ownerPhone table
ALTER TABLE ownerPhone
DROP FOREIGN KEY ownerPhone_ibfk_1,
ADD FOREIGN KEY (ownerID) REFERENCES shopOwner(ownerID) ON DELETE CASCADE;

-- Enable cascading delete for the order table
ALTER TABLE `order`
DROP FOREIGN KEY `order_ibfk_1`,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
DROP FOREIGN KEY `order_ibfk_2`,
ADD FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE;

-- Enable cascading delete for the payment table
ALTER TABLE payment
DROP FOREIGN KEY payment_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
DROP FOREIGN KEY payment_ibfk_2,
ADD FOREIGN KEY (orderID) REFERENCES `order`(orderID) ON DELETE CASCADE;

-- Enable cascading delete for the deliversTo table
ALTER TABLE deliversTo
DROP FOREIGN KEY deliversTo_ibfk_1,
ADD FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE,
DROP FOREIGN KEY deliversTo_ibfk_2,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE;

-- Enable cascading delete for the agentReview table
ALTER TABLE agentReview
DROP FOREIGN KEY agentReview_ibfk_1,
ADD FOREIGN KEY (agentID) REFERENCES deliveryAgent(agentID) ON DELETE CASCADE,
DROP FOREIGN KEY agentReview_ibfk_2,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE;

-- Enable cascading delete for the product table
ALTER TABLE product
DROP FOREIGN KEY product_ibfk_1,
ADD FOREIGN KEY (ownerID) REFERENCES shopOwner(ownerID) ON DELETE CASCADE;

-- Enable cascading delete for the cart table
ALTER TABLE cart
DROP FOREIGN KEY cart_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE;

-- Enable cascading delete for the cart_items table
ALTER TABLE cart_items
DROP FOREIGN KEY cart_items_ibfk_1,
ADD FOREIGN KEY (cart_id) REFERENCES cart(cartID) ON DELETE CASCADE,
DROP FOREIGN KEY cart_items_ibfk_2,
ADD FOREIGN KEY (product_id) REFERENCES product(productID) ON DELETE CASCADE;

-- Enable cascading delete for the wishlist table
ALTER TABLE wishlist
DROP FOREIGN KEY wishlist_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE;

-- Enable cascading delete for the wishlist_items table
ALTER TABLE wishlist_items
DROP FOREIGN KEY wishlist_items_ibfk_1,
ADD FOREIGN KEY (wishlist_id) REFERENCES wishlist(wishlistID) ON DELETE CASCADE,
DROP FOREIGN KEY wishlist_items_ibfk_2,
ADD FOREIGN KEY (product_id) REFERENCES product(productID) ON DELETE CASCADE;

-- Enable cascading delete for the sells table
ALTER TABLE sells
DROP FOREIGN KEY sells_ibfk_1,
ADD FOREIGN KEY (ownerID) REFERENCES shopOwner(ownerID) ON DELETE CASCADE,
DROP FOREIGN KEY sells_ibfk_2,
ADD FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE;

-- Enable cascading delete for the orderCONTAINSproduct table
ALTER TABLE orderCONTAINSproduct
DROP FOREIGN KEY orderCONTAINSproduct_ibfk_1,
ADD FOREIGN KEY (orderID) REFERENCES `order`(orderID) ON DELETE CASCADE,
DROP FOREIGN KEY orderCONTAINSproduct_ibfk_2,
ADD FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE;

-- Enable cascading delete for the productReview table
ALTER TABLE productReview
DROP FOREIGN KEY productReview_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
DROP FOREIGN KEY productReview_ibfk_2,
ADD FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE;

-- Enable cascading delete for the orderHistory table
ALTER TABLE orderHistory
DROP FOREIGN KEY orderHistory_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE,
DROP FOREIGN KEY orderHistory_ibfk_2,
ADD FOREIGN KEY (orderID) REFERENCES `order`(orderID) ON DELETE CASCADE;

-- Enable cascading delete for the wallet table
ALTER TABLE wallet
DROP FOREIGN KEY wallet_ibfk_1,
ADD FOREIGN KEY (customerID) REFERENCES customer(customerID) ON DELETE CASCADE;

-- Enable cascading delete for the offer table
ALTER TABLE offer
DROP FOREIGN KEY offer_ibfk_1,
ADD FOREIGN KEY (adminID) REFERENCES web_admin(adminID) ON DELETE CASCADE;



