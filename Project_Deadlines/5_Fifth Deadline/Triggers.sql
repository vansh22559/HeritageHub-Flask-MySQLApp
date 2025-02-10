-- a trigger that prevents the deletion of a customer if they have associated orders in the order table

DELIMITER //
CREATE TRIGGER prevent_customer_deletion
BEFORE DELETE ON customer
FOR EACH ROW
BEGIN
    DECLARE order_count INT;

    -- Check if the customer has associated orders
    SELECT COUNT(*) INTO order_count
    FROM `order`
    WHERE customerID = OLD.customerID;

    -- If associated orders exist, prevent deletion
    IF order_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TRIGGER!! Cannot delete customer with associated orders';
    END IF;
END;
//
DELIMITER ;



-- a customer cannot add more of a product to their cart than the quantity available in stock

DELIMITER //

CREATE TRIGGER check_cart_quantity BEFORE INSERT ON cart_items
FOR EACH ROW
BEGIN
    DECLARE stock_quantity INT;
    DECLARE cart_total_quantity INT;

    -- Get the available quantity of the product in stock
    SELECT quantity INTO stock_quantity
    FROM product
    WHERE productID = NEW.product_id;

    -- Get the total quantity of the product already in the customer's cart
    SELECT COALESCE(SUM(quantity), 0) INTO cart_total_quantity
    FROM cart_items
    WHERE product_id = NEW.product_id
    AND cart_id = NEW.cart_id;

    -- Check if the total quantity in the cart plus the new quantity exceeds the available stock
    IF (cart_total_quantity + NEW.quantity) > stock_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TRIGGER ACTIVATED!!! Cannot add more quantity than available in stock';
    END IF;
END;
//
DELIMITER ;
