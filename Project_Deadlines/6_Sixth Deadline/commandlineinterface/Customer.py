import mysql.connector
from mysql.connector import Error

def customer_menu(cursor, customerID, connection):
    while True:
        print("\n-----------------------------------------\n")
        print("\nCustomer Menu:")
        print("\n-----------------------------------------\n")
        print("1. View All Products")
        print("2. View My Cart")
        print("3. View My Orders")
        print("4. Logout")
        print("\n-----------------------------------------\n")

        choice = input("Enter your choice: ")

        if choice == "1":
            View_All_Items(cursor, customerID, connection)
        elif choice == "2":
            View_My_Cart(cursor, customerID, connection)
        elif choice == "3":
            View_My_Orders(cursor, customerID, connection)
        elif choice == "4":
            print("\nLogging out...\n")
            break
        else:
            print("\nInvalid choice. Please enter a number from 1 to 4.\n")

def View_All_Items(mycursor, customerID, mydb):

    # Example: Querying customer data from the database
    query = "SELECT * FROM product"
    mycursor.execute(query)
    products = mycursor.fetchall()

    # Example: Analyzing customer data
    total_products = len(products)
    print(f"\nTotal number of products: {total_products}")

    if products:
        print("All Products:")
        for product in products:
            print("\n-----------------------------------------\n")
            print(f"Name: {product[2]}")
            print(f"Product ID: {product[0]}")
            print(f"Price: {product[3]}")
            print(f"Quantity: {product[4]}")
            print(f"Description: {product[5]}")
            print("\n-----------------------------------------\n")  # Add an empty line for better readability

        order_choice = input("Do you wish to order any item? (1 for yes/ 0 for no): ")
        print()
        if order_choice == "1":
            product_id_to_order = int(input("Enter the Product ID you want to order: "))
            quantity_to_order = int(input("Enter the quantity you want to order: "))
            print()

            # Find the product in the products list
            product_found = False
            for product in products:
                if product[0] == product_id_to_order:
                    product_found = True
                    if product[4] >= quantity_to_order:
                        print(str(quantity_to_order) + " of Product ID " + str(
                            product_id_to_order) + " will be added to cart.")
                        add_to_cart(mycursor, customerID, product_id_to_order, quantity_to_order, mydb)
                    else:
                        print("Sorry, there is not enough quantity in stock for Product ID " + str(
                            product_id_to_order) + ".\n")
                        print("\n------------------------------------------------------\n")

            if not product_found:
                print("Product ID " + str(product_id_to_order) + " not found.")

            choice = input("Do you wish to see the item list again? (1 for yes/ 0 for no): ")
            print()
            if choice == 1:
                View_All_Items(mycursor, customerID)

        else:

            print("Thank you for visiting!\n")

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu



def add_to_cart(mycursor, customerID, prodID, quantity, mydb):
    try:
        # Check if the product exists and has enough quantity
        mycursor.execute("SELECT price, quantity FROM product WHERE productID = %s", (prodID,))
        product_info = mycursor.fetchone()
        if product_info:
            unit_price = product_info[0]
            available_quantity = product_info[1]
            if available_quantity >= quantity:
                # Calculate total price for the item
                total_price = unit_price * quantity


                # Insert into cart_items table
                mycursor.execute(
                    "INSERT INTO cart_items (cart_id, product_id, quantity, unitPrice, totalPrice) VALUES (%s, %s, %s, %s, %s)",
                    (customerID, prodID, quantity, unit_price, total_price))

                mycursor.fetchall()

                # Update total cost in cart table
                mycursor.execute("SELECT totalCost FROM cart WHERE customerID = %s", (customerID,))
                cart_total = mycursor.fetchone()
                if cart_total:
                    current_total_cost = cart_total[0]
                else:
                    current_total_cost = 0
                new_total_cost = current_total_cost + total_price

                mycursor.fetchall()

                mycursor.execute(
                    "INSERT INTO cart (customerID, totalCost) VALUES (%s, %s) ON DUPLICATE KEY UPDATE totalCost = %s",
                    (customerID, new_total_cost, new_total_cost))

                mycursor.fetchall()

                print(f"{quantity} of Product ID {prodID} has been successfully added to the cart.")
                print("\n------------------------------------------------------\n")
                mydb.commit()
            else:
                print("Sorry, there is not enough quantity in stock for Product ID " + str(prodID) + ".")
                print("\n------------------------------------------------------\n")
        else:
            print("Product ID " + str(prodID) + " not found.")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu


def View_My_Cart(mycursor, customerID, mydb):
    try:
        # Retrieve cart items and total cost for the given customerID
        mycursor.execute(
            "SELECT ci.product_id, p.name, ci.quantity, ci.unitPrice, ci.totalPrice FROM cart_items ci JOIN product p ON ci.product_id = p.productID WHERE ci.cart_id = %s",
            (customerID,))
        cart_items = mycursor.fetchall()

        total_cost = 0

        if cart_items:
            print("Cart Items:")
            for item in cart_items:
                print(f"Product ID: {item[0]}")
                print(f"Name: {item[1]}")
                print(f"Quantity: {item[2]}")
                print(f"Unit Price: {item[3]}")
                print(f"Total Price: {item[4]}")
                total_cost += item[4]

                # Update available quantity in product table
                prodID = item[0]
                mycursor.execute("SELECT price, quantity FROM product WHERE productID = %s", (prodID,))
                product_info = mycursor.fetchone()
                available_quantity = product_info[1]
                updated_quantity = available_quantity - item[2]
                mycursor.execute("UPDATE product SET quantity = %s WHERE productID = %s", (updated_quantity, prodID))
                mycursor.fetchall()

                print("-----------------------")

            print(f"Total Cost: {total_cost}")
            print("\n------------------------------------------------------\n")

            choice = input("Do you wish to order all the items in cart? (1 for Yes/ 0 for No): ")
            if choice == '1':

                order_status = "Pending"  # Assuming initial status is pending
                order_amount = total_cost

                mycursor.execute(
                    "INSERT INTO `order` (customerID, agentID, status, order_amount) VALUES (%s, %s, %s, %s)",
                    (customerID, 1, order_status, order_amount))
                mydb.commit()

                mycursor.execute("DELETE FROM cart_items WHERE cart_id = %s", (customerID,))
                mydb.commit()

                print("Order placed successfully!")
                print("\n------------------------------------------------------\n")

        else:
            print("Your cart is empty.")
    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu


def View_My_Orders(cursor, customerID, connection):
    try:
        # Retrieve orders for the given customerID
        query = "SELECT * FROM `order` WHERE customerID = %s"
        cursor.execute(query, (customerID,))
        orders = cursor.fetchall()

        if orders:
            print("Your Orders:")
            for order in orders:
                print("\n-----------------------------------------\n")
                print(f"Order ID: {order[0]}")
                print(f"Status: {order[3]}")
                print(f"Order Date: {order[4]}")
                print(f"Order Amount: {order[5]}")
                print("\n-----------------------------------------\n")  # Add an empty line for better readability
        else:
            print("You have not placed any orders yet.")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu







