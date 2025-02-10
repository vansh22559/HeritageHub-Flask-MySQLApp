from flask import Flask, render_template, request, redirect, flash, session,jsonify,url_for
import mysql.connector 
from datetime import datetime
import os

app = Flask(__name__)

app.secret_key = 'this_is_my_secret_key_yola'

# Connect to MySQL database
db = mysql.connector.connect(
    host="127.0.0.1",
    user="root",
    passwd="ihatesql1234!@",
    database="Heritagehub"
)

@app.route('/')
def home(): 
    # Fetch product data using raw SQL query
    return render_template('home.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/login')
def login():
    # Logic for login will be handled here, for now redirecting to home
    return render_template('index.html')

@app.route('/admin', methods=['GET', 'POST'])
def admin_login():
    error = None
    if request.method == 'POST':
        admin_name = request.form['admin_name']
        password = request.form['password']
        if admin_name == 'admin' and password == 'pass':
            return redirect('/admin_dashboard')
        else:
            error = 'Incorrect admin name or password. Please try again.'
    return render_template('admin_login.html', error=error)



@app.route('/admin_dashboard')
def admin_dashboard():
    return render_template('admin_dashboard.html')
 
 
@app.route('/customer_login', methods=['GET', 'POST'])
def customer_login():
    error = None
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        password = request.form['password']
        cursor = db.cursor()
        try:
            cursor.execute("SELECT * FROM customer WHERE customerID = %s AND password = %s", (customer_id, password))
            customer = cursor.fetchone()
            if customer:
                # Customer authenticated successfully, redirect to customer dashboard
                session['cust_id'] = customer_id 
                return redirect(f'/customer_dashboard/{customer_id}')
            else:
                error = 'Incorrect customer ID or password. Please try again.'
        except mysql.connector.Error as err:
            error = f"Error accessing database: {err}"
        finally:
            cursor.close()
    return render_template('customer_login.html', error=error)

@app.route('/customerHome')
def homepage():
    error = None
    customer_id = session.get('cust_id')
    cursor = db.cursor()
    try:
        session['cust_id'] = customer_id
        return redirect(f'/customer_dashboard/{customer_id}')
    except mysql.connector.Error as err:
        error = f"Error accessing database: {err}"
    finally:
        cursor.close()
    return render_template('customer_login.html', error=error)


@app.route('/customer_dashboard/<int:customer_id>')
def customer_dashboard(customer_id):
    cursor = db.cursor()
    cursor.execute("SELECT * FROM product")
    products = cursor.fetchall()
    cursor.close()

    return render_template('customer_dashboard.html', products=products)

    
@app.route('/add_to_cart/<int:product_id>', methods=['POST'])
def add_to_cart(product_id):
    # Perform your database operations here
    # You can use the provided SQL query to add the product to the cart
    # Remember to replace `db` with your actual database connection

    with db.cursor() as cursor:
        cust_id = session.get('cust_id')
        query = f"SELECT * FROM product WHERE productID = {product_id}"
        cursor.execute(query)
        product = cursor.fetchall()
        if product:
            available_quantity = product[0][4]  # Assuming quantity is the 4th column in products table
            if available_quantity >= 1:
                # Add product to cart
                cursor.execute("INSERT INTO cart_items (cart_id, product_id, quantity, unitPrice, totalPrice) VALUES (%s, %s, %s, %s, %s)", (cust_id, product_id, 1, 1, 1))
                
                db.commit()
                return jsonify({"message": "Product added to cart successfully!"}), 200
            else:
                return jsonify({"message": "Prod ct could not be added!"}), 400
        else:
            return jsonify({"message": "Product not found!"}), 404



@app.route('/view_cart/')
def view_cart():
    # Retrieve cust_id from session
    cust_id = session.get('cust_id')
    if cust_id is None:
        # Handle case when cust_id is not found in session
        flash('Please log in to view your cart.', 'error')
        return redirect(url_for('customer_login'))  # Redirect to login page or handle as needed

    # Fetch cart items for the customer 
    cursor = db.cursor()  
    cursor.execute("SELECT * FROM cart_items WHERE cart_id = %s", (cust_id,))
    cart_items = cursor.fetchall() 
    cursor.close()
    
    cursor = db.cursor()
    cursor.execute("SELECT * FROM product")
    products = cursor.fetchall()
    cursor.close()
    
    
    return render_template('view_cart.html', cart_items=cart_items, products=products)




def place_order(cust_id, cost):
    cursor = db.cursor()
    current_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # Convert current_date to string

    # Decrease quantity in product table
    decrease_quantity_query = "UPDATE product p INNER JOIN (SELECT product_id, SUM(quantity) as total_quantity FROM cart_items WHERE cart_id IN (SELECT cartID FROM cart WHERE customerID = %s) GROUP BY product_id) ci ON p.productID = ci.product_id SET p.quantity = p.quantity - ci.total_quantity"
    cursor.execute(decrease_quantity_query, (cust_id,))

    # Delete entry from cart_items table
    delete_cart_items_query = "DELETE FROM cart_items WHERE cart_id IN (SELECT cartID FROM cart WHERE customerID = %s)"
    cursor.execute(delete_cart_items_query, (cust_id,))

 

    # Insert order into order table
    insert_order_query = "INSERT INTO `order` (customerID, agentID, status, order_date, order_amount) VALUES (%s, %s, %s, %s, %s);"
    order_data = (cust_id, 1, 'pending', current_date, cost)
    cursor.execute(insert_order_query, order_data)

    # # Delete entry from cart table
    # delete_cart_query = "DELETE FROM cart WHERE customerID = %s"
    # cursor.execute(delete_cart_query, (cust_id,))

    db.commit()
    cursor.close()



@app.route('/order_all_items/')
def order_all_items():
    cust_id = session.get('cust_id')
    if cust_id is None:
        # Handle case when cust_id is not found in session
        flash('Please log in to order items.', 'error')
        return redirect(url_for('customer_login'))  # Redirect to login page or handle as needed

    cursor = db.cursor()  
    
    select_cart_query = "SELECT customerID, totalCost FROM cart WHERE customerID = %s"
    cursor.execute(select_cart_query, (cust_id,))
    cart_items = cursor.fetchall()
    cursor.close()

    for item in cart_items:
        place_order(item[0], item[1])
    
    return render_template('items_ordered.html')


@app.route('/orders')
def orders():
    cursor = db.cursor()
    cursor.execute("SELECT COUNT(orderID) AS order_count FROM `order`")
    result = cursor.fetchone()[0]
    return f"<div style='font-size: 40px; font-weight: bold;'>Total Number of orders placed: {result}</div>"

@app.route('/products')
def products():
    cursor = db.cursor()
    cursor.execute("SELECT * from product where quantity > 0")
    results = cursor.fetchall()
    return render_template('products.html', products=results)

@app.route('/customer_details')
def customer_details():
    cursor = db.cursor()
    cursor.execute("SELECT * from customer")
    results = cursor.fetchall()
    return render_template('customer_details.html', customer_details=results)


@app.route('/delete_customer', methods=['GET'])
def show_delete_customer_form():
    return render_template('delete_customer.html')


@app.route('/delete_customer', methods=['POST'])
def delete_customer():
    customer_id = request.form['customer_id']
    cursor = db.cursor()
    try:
        # Delete customer from the database
        cursor.execute("DELETE FROM customer WHERE customerID = %s", (customer_id,))
        db.commit()
        flash('Customer deleted successfully', 'success')  # Flash success message
    except mysql.connector.Error as err:
        flash(f"Error deleting customer: {err}", 'error')
    finally:
        cursor.close()
    return redirect(url_for('admin_dashboard'))




if __name__ == "__main__":
    app.run(debug=True) 
 