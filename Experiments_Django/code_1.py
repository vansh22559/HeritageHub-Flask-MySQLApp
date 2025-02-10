import mysql.connector
from mysql.connector import Error

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


def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        print("Query successful")
    except Error as err:
        print(f"Error: '{err}'")


mydb = create_db_connection("localhost", "root", "ihatesql1234!@", "heritagehub")
 
mycursor = mydb.cursor() 

 
def order_items(customer_id, product_id, quantity, connection):

    try:
        # cursor object
        cursor = connection.cursor()

        # Execute SQL query to insert order details
        query = "INSERT INTO `orderCONTAINSproduct` (orderID, productID, quantity) VALUES (%s, %s, %s)"
        cursor.execute(query, (customer_id, product_id, quantity))

        # Commit changes to the database
        connection.commit()

        print("Items ordered successfully!")
        
    except mysql.connector.Error as error:
        print("Error ordering items:", error)


# Example usage:
order_items(1, 1, 2, mydb)  # Order 2 quantities of product with ID 1 for customer with ID 1

 

def analyze_inventory(connection):
    try:
    
        # Create cursor object
        cursor = connection.cursor()

        # Execute SQL query to get inventory analysis
        query = "SELECT productID, name, price, quantity FROM product"
        cursor.execute(query)

        # Fetch all rows
        inventory_data = cursor.fetchall()

        # Display inventory analysis
        print("Inventory Analysis:")
        for row in inventory_data:
            product_id, name, price, quantity = row
            print(f"Product ID: {product_id}, Name: {name}, Price: {price}, Quantity: {quantity}")

    except mysql.connector.Error as error:
        print("Error analyzing inventory:", error)


def analyze_customers(connection):
    try:
       
        # Create cursor object
        cursor = connection.cursor()

        # Execute SQL query to get customer analysis
        query = "SELECT customerID, firstName, lastName, phoneNumber FROM customer"
        cursor.execute(query)

        # Fetch all rows
        customer_data = cursor.fetchall()

        # Display customer analysis
        print("Customer Analysis:")
        for row in customer_data:
            customer_id, first_name, last_name, phone_number = row
            print(f"Customer ID: {customer_id}, Name: {first_name} {last_name}, Phone Number: {phone_number}")

    except mysql.connector.Error as error:
        print("Error analyzing customers:", error)


# Example usage:
analyze_inventory(mydb)  # Analyze inventory
analyze_customers(mydb)  # Analyze customers

if mydb.is_connected():
    mycursor.close()
    mydb.close()
    print("MySQL connection is closed")

