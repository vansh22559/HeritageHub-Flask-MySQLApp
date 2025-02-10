import mysql.connector
from mysql.connector import Error


def vendor_menu(cursor, ownerID, connection):
    while True:
        print("\n-----------------------------------------\n")
        print("\nVendor Menu:")
        print("\n-----------------------------------------\n")
        print("1. View My Products")
        print("2. Add New Product")
        print("3. Logout")
        print("\n-----------------------------------------\n")

        choice = input("Enter your choice: ")

        if choice == "1":
            View_My_Products(cursor, ownerID, connection)
        elif choice == "2":
            Add_New_Product(cursor, ownerID, connection)
        elif choice == "3":
            print("\nLogging out...\n")
            break
        else:
            print("\nInvalid choice. Please enter a number from 1 to 3.\n")

def View_My_Products(cursor, ownerID, connection):
    try:
        # Retrieve products for the given ownerID
        query = "SELECT * FROM product WHERE ownerID = %s"
        cursor.execute(query, (ownerID,))
        products = cursor.fetchall()

        if products:
            print("Your Products:")
            for product in products:
                print("\n-----------------------------------------\n")
                print(f"Product ID: {product[0]}")
                print(f"Name: {product[2]}")
                print(f"Price: {product[3]}")
                print(f"Quantity: {product[4]}")
                print(f"Description: {product[5]}")
                print("\n-----------------------------------------\n")  # Add an empty line for better readability
        else:
            print("You have not added any products yet.")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu

def Add_New_Product(cursor, ownerID, connection):
    try:
        name = input("Enter product name: ")
        price = float(input("Enter product price: "))
        quantity = int(input("Enter product quantity: "))
        description = input("Enter product description: ")

        # Insert the new product into the database
        query = "INSERT INTO product (ownerID, name, price, quantity, description) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(query, (ownerID, name, price, quantity, description))
        connection.commit()

        print("Product added successfully!")

    except mysql.connector.Error as err:
        print("Error:", err)

    input("\nPress Enter to continue...")  # Wait for user input before returning to the menu
