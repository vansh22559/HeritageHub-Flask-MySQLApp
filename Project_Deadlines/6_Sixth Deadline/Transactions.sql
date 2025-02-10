--Non-Concflicting Transactions

-- Transaction 1: Update customer phone number
BEGIN;
SAVEPOINT before_update_customer_phone;
UPDATE customer
SET phoneNumber = '5559876543'
WHERE customerID = 1;
-- ROLLBACK; -- Use this to roll back to the savepoint
COMMIT;


-- Transaction 2: Add a new product to the catalog
BEGIN;
SAVEPOINT before_add_product;
INSERT INTO product (ownerID, name, price, quantity, description)
VALUES (3, 'Terracotta Clay Vase', 39.99, 15, 'Handcrafted terracotta vase for home decor.');
-- ROLLBACK; -- Use this to roll back to the savepoint
COMMIT;


-- Transaction 3: Add a review for a product
BEGIN;
SAVEPOINT before_add_review;
INSERT INTO productReview (customerID, productID, comment, rating, review_date, reviewID)
VALUES (2, 10, 'The Kerala mundu is beautifully crafted!', 5, '2024-03-15', 1);
-- ROLLBACK; -- Use this to roll back to the savepoint
COMMIT;


-- Transaction 4: Update agent details
BEGIN;
SAVEPOINT before_update_agent_details;
UPDATE deliveryAgent
SET phoneNumber = '9998765432'
WHERE agentID = 2;
-- ROLLBACK; -- Use this to roll back to the savepoint
COMMIT;




--Concflicting Transactions set 1


-- Transaction 5: Update order status to 'cancelled'

USE Heritagehub;
SET autocommit = 0;

BEGIN;
SAVEPOINT before_update_order_cancelled;
UPDATE `order`
SET status = 'cancelled'
WHERE orderID = 1;
-- ROLLBACK; -- Use this to roll back to the savepoint
-- COMMIT;


 
-- Transaction 6: Update order status to 'Shippping'

USE Heritagehub;
SET autocommit = 0;

BEGIN;
SAVEPOINT before_update_order_shipping;
UPDATE `order`
SET status = 'Shipping'
WHERE orderID = 1;
-- ROLLBACK; -- Use this to roll back to the savepoint
-- COMMIT;  




--Concflicting Transactions set 2


-- Transaction 7: Update product quantity (non-conflicting)
BEGIN;
SAVEPOINT before_update_product_quantity;
UPDATE product
SET quantity = quantity - 2
WHERE productID = 5;
-- ROLLBACK; -- Use this to roll back to the savepoint
-- COMMIT; 


-- Transaction 2: Update product quantity (conflicting)
BEGIN;
SAVEPOINT before_update_product_quantity;
UPDATE product
SET quantity = quantity - 3
WHERE productID = 5;
-- ROLLBACK; -- Use this to roll back to the savepoint
-- COMMIT;





