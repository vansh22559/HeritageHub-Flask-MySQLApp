import mysql.connector
from mysql.connector import Error

import Admin
import Customer
import Vendor


def create_db_connection(host_name, user_name, user_password, db_name):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name
        )
        print("MySQL Database connection successful")
    except Error as err:
        print(f"Error: '{err}'")

    return connection


mydb = create_db_connection("localhost", "root", "ihatesql1234!@", "heritagehub")

mycursor = mydb.cursor()


def admin_login(connection):

    while True:
        admin_id = input("Enter admin ID: ")
        password = input("Enter password: ")

        try:
            cursor = connection.cursor()
            query = "SELECT * FROM web_admin WHERE adminID = %s AND password = %s"
            cursor.execute(query, (admin_id, password))
            user = cursor.fetchone()

            if user:
                print(f"Welcome! You are logged in as an Admin for the Heritage Hub!\n")
                Admin.admin_menu(mycursor, connection)

            else:
                print("\nInvalid credentials for admin.\n")
                choice = input("Enter 1 to go back to main menu (any other button to retry): ")
                if choice == '1':
                    return

        except Error as e:
            print(f"Error: {e}")


def vendor_login(connection):

    while True:
        vendor_id = input("Enter vendor ID: ")
        password = input("Enter password: ")

        try:
            cursor = connection.cursor()
            query = "SELECT * FROM shopOwner WHERE ownerID = %s AND password = %s"
            cursor.execute(query, (vendor_id, password))
            user = cursor.fetchone()

            if user:
                print(f"\nWelcome! You are logged in as a Vendor for the Heritage Hub!\n")
                Vendor.vendor_menu(mycursor, vendor_id, connection)

            else:
                print("\nInvalid credentials for vendor.\n")
                choice = input("Enter 1 to go back to main menu (any other button to retry): ")
                if choice == '1':
                    return

        except Error as e:
            print(f"Error: {e}")


def customer_login(connection):

    while True:
        customer_id = input("Enter customer ID: ")
        password = input("Enter password: ")

        try:
            cursor = connection.cursor()
            query = "SELECT * FROM customer WHERE customerID = %s AND password = %s"
            cursor.execute(query, (customer_id, password))
            user = cursor.fetchone()

            if user:
                print(f"\nWelcome! You are a beloved customer for the Heritage Hub!\n")
                Customer.customer_menu(cursor, customer_id, connection)

            else:
                print("\nInvalid credentials.\n")
                choice = input("Enter 1 to go back to main menu (any other button to retry): ")
                if choice == '1':
                    return

        except Error as e:
            print(f"Error: {e}")


def main():

    while True:

        print("\n------------------------------------------------------\n")
        print("Welcome to Heritage Hub!")
        print("Please choose an option to login:")
        print("1. Vendor")
        print("2. Admin")
        print("3. Customer")
        print("4. Exit")
        print("\n------------------------------------------------------\n")

        choice = input("Enter your choice: ")

        if choice == '1':
            vendor_login(mydb)
        elif choice == '2':
            admin_login(mydb)
        elif choice == '3':
            customer_login(mydb)
        elif choice == '4':
            print("Goodbye! Please visit us again! :) \n")
            return
        else:
            print("Invalid choice. Please enter a valid option.\n")


if __name__ == "__main__":
    main()
    mydb.close()


