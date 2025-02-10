import mysql.connector
from mysql.connector import Error

def admin_menu(cursor, mydb):
    while True:
        print("\n-----------------------------------------\n")
        print("\nAdmin Menu:")
        print("\n-----------------------------------------\n")
        print("1. Customer Analysis")
        print("2. Inventory Analysis")
        print("3. Customers with Greater Orders Than Others")
        print("4. Customer Reviews Sorted by Product Reviews")
        print("5. Customers Who Have Not Placed Any Orders")
        print("6. Top 5 Customers with Highest Total Purchases")
        print("7. Delete Customer")
        print("8. Logout")
        print("\n-----------------------------------------\n")

        choice = input("Enter your choice: ")

        if choice == "1":
            Customer_Analysis(cursor)
        elif choice == "2":
            Inventory_Analysis(cursor)
        elif choice == "3":
            retrieve_customers_with_greater_orders(cursor)
        elif choice == "4":
            retrieve_customer_reviews_sorted(cursor)
        elif choice == "5":
            retrieve_customers_no_orders(cursor)
        elif choice == "6":
            retrieve_top_customers(cursor)
        elif choice == "7":
            delete_customer(cursor, mydb)
        elif choice == "8":
            print("\nLogging out...\n")
            break
        else:
            print("\nInvalid choice. Please enter a number from 1 to 8.\n")


def delete_customer(cursor, mydb):
    customer_id = input("Enter the customer ID you want to delete: ")
    try:
        sql = "DELETE FROM customer WHERE customerID = %s"
        cursor.execute(sql, (customer_id,))
        mydb.commit()
        print("Customer deleted successfully.")
    except mysql.connector.Error as err:
        print(f"Error deleting customer: {err}")

def Customer_Analysis(mycursor):

    # Example: Querying customer data from the database
    query = "SELECT * FROM customer"
    mycursor.execute(query)
    customers = mycursor.fetchall()

    # Example: Analyzing customer data
    total_customers = len(customers)
    print(f"\nTotal number of customers: {total_customers}")

    if customers:
        print("All Customers:")
        for customer in customers:
            print("\n-----------------------------------------\n")
            print(f"Customer ID: {customer[0]}")
            print(f"Name: {customer[4]} ")
            print(f"Phone: {customer[12]}")
            print("\n-----------------------------------------\n")  # Add an empty line for better readability

    # Add more analysis logic as needed
    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu

def Inventory_Analysis(mycursor):
    # Example: Querying inventory data from the database
    query = "SELECT * FROM product"
    mycursor.execute(query)
    products = mycursor.fetchall()

    # Example: Analyzing customer data
    total_products = len(products)
    print(f"\nTotal number of products: {total_products}")

    total_items = 0

    if products:
        print("All Products:")
        for product in products:
            print("\n-----------------------------------------\n")
            print(f"Name: {product[2]}")
            print(f"Product ID: {product[0]}")
            print(f"Price: {product[3]}")
            print(f"Quantity: {product[4]}")
            total_items += product[4]
            print(f"Description: {product[5]}")
            print("\n-----------------------------------------\n")  # Add an empty line for better readability

    # Example: Analyzing inventory data
    print(f"\nTotal number of items in inventory: {total_items}")

    # Add more analysis logic as needed
    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu


def retrieve_customers_with_greater_orders(cursor):
    try:
        query = """
            SELECT DISTINCT c.*
            FROM customer c
            JOIN `order` o ON c.customerID = o.customerID
            WHERE o.order_amount > SOME (
                SELECT order_amount
                FROM `order`
                WHERE customerID <> c.customerID
            );
        """
        cursor.execute(query)
        customers = cursor.fetchall()

        if customers:
            print("Customers with Orders Greater Than Others:")
            for customer in customers:
                print("-----------------------------------------")
                print(f"Customer ID: {customer[0]}")
                print(f"First Name: {customer[1]}")
                print(f"Last Name: {customer[2]}")
                print("-----------------------------------------")
        else:
            print("No customers found.")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu


def retrieve_customer_reviews_sorted(cursor):
    try:
        query = """
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
        """
        cursor.execute(query)
        reviews = cursor.fetchall()

        if reviews:
            print("Customer Reviews Sorted by Product Reviews:")
            for review in reviews:
                print("-----------------------------------------")
                print(f"Customer Name: {review[0]} {review[1]}")
                print(f"Comment: {review[2]}")
                print(f"Rating: {review[3]}")
                print(f"Product Name: {review[4]}")
                print("-----------------------------------------")
        else:
            print("No reviews found.")

    except mysql.connector.Error as err:
        print("Error:", err)
    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu


def retrieve_customers_no_orders(cursor):
    try:
        query = """
            SELECT c.customerID, c.firstName, c.lastName
            FROM customer c
            WHERE NOT EXISTS (
                SELECT 1
                FROM `order` o
                WHERE c.customerID = o.customerID
            );
        """
        cursor.execute(query)
        customers = cursor.fetchall()

        if customers:
            print("Customers Who Have Not Placed Any Orders:")
            for customer in customers:
                print("-----------------------------------------")
                print(f"Customer ID: {customer[0]}")
                print(f"First Name: {customer[1]}")
                print(f"Last Name: {customer[2]}")
                print("-----------------------------------------")
        else:
            print("No customers found.")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu


def retrieve_top_customers(cursor):
    try:
        query = """
            SELECT c.customerID, c.firstName, c.lastName, SUM(o.order_amount) AS total_purchases
            FROM customer c
            JOIN `order` o ON c.customerID = o.customerID
            GROUP BY c.customerID
            ORDER BY total_purchases DESC
            LIMIT 5;
        """
        cursor.execute(query)
        top_customers = cursor.fetchall()

        if top_customers:
            print("Top 5 Customers with Highest Total Purchases:")
            for customer in top_customers:
                print("-----------------------------------------")
                print(f"Customer ID: {customer[0]}")
                print(f"First Name: {customer[1]}")
                print(f"Last Name: {customer[2]}")
                print(f"Total Purchases: {customer[3]}")
                print("-----------------------------------------")
        else:
            print("No customers found.")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu