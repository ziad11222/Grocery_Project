from flask import Flask, request, jsonify
import random
import mysql.connector
from mysql.connector import Error
from mysql.connector import IntegrityError
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import secrets
app = Flask(__name__)

# Database configuration
db_config = {
    'host': '34.31.110.154',
    'port': 3306,
    'user': 'ziadym',
    'password': '112233',
    'database': 'grocerystore'
}

# Initialize MySQL connection pool
db_connection = mysql.connector.pooling.MySQLConnectionPool(pool_name="mypool", pool_size=10, **db_config)

# Helper function to generate OTP
def generate_otp():
    return str(random.randint(1000, 9999))

SECRET_KEY = secrets.token_hex(32)

# Endpoint for user login
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        email = data.get('email')
        password = data.get('password')

        # Fetch user from the database
        connection = db_connection.get_connection()
        with connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE email = %s", (email,))
            user = cursor.fetchone()

            if not user or not check_password_hash(user['password'], password):
                return jsonify({"error": "Invalid credentials"}), 401

            # Generate JWT token with user information
            token_payload = {
                'email': user['email'],
                'username': user['user_name'],
                'profile_image': user.get('profile_image', ''),  # Adjust accordingly
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=2)  # Token expiration time
            }

            # Encode the token using the secret key
            token = jwt.encode(token_payload, SECRET_KEY, algorithm='HS256')

        # Send the token along with other user data to the frontend
        user_data = {
            'email': user['email'],
            'username': user['user_name'],
            'profile_image': user.get('profile_image', '')
        }

        return jsonify({"message": "Logged in successfully", "token": token, "user_data": user_data})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500


# Endpoint for user registration
@app.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.json
        email = data.get('email')
        password = generate_password_hash(data.get('password'))
        user_name = data.get('user_name')
        b_date = data.get('b_date')
        address = data.get('address')
        profile_image = data.get('profile_image')

        # Check if user already exists
        connection = db_connection.get_connection()
        with connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE email = %s", (email,))
            existing_user = cursor.fetchone()

            if existing_user:
                return jsonify({"error": "User already exists"}), 400

            # Insert new user into the database
            cursor.execute("INSERT INTO client (email, password, user_name, b_date, address, profile_image) "
                            "VALUES (%s, %s, %s, %s, %s, %s)",
                            (email, password, user_name, b_date, address, profile_image))
            connection.commit()

        # Generate and send OTP
        otp = generate_otp()

        return jsonify({"message": "User registered successfully. OTP sent to your email"})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500



        # You would normally send an email with this OTP

        return jsonify({"message": "User registered successfully. OTP sent to your email"})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500

# Endpoint to place an order (Buy Now)
@app.route('/placeOrder', methods=['POST'])
def place_order():
    try:
        data = request.json
        client_email = data.get('client_email')
        product_id = data.get('product_id')
        quantity = data.get('quantity')
        payment_method_id = data.get('payment_method_id')

        # Check if the product is in stock and has enough quantity
        if not is_product_available(product_id, quantity):
            return jsonify({"error": "Product is out of stock or insufficient quantity"}), 400
        #Creation of a new cart and assigning id to it for the order
        cart_id = create_cart(client_email)

        # Insert the order into the orders table
        with db_connection.get_connection() as db_conn:
            with db_conn.cursor(dictionary=True) as cursor:

                # Calculate total price of the order based on product id and quantity
                total_price = calculate_total_price(product_id,quantity)

                # Insert the order into the orders table
                cursor.execute(
                    "INSERT INTO orders (user_id, cart_id, payment_method, total_price, order_date) "
                    "VALUES (%s, %s, %s, %s, NOW())",
                    (client_email,cart_id, payment_method_id,total_price)  # You may need to modify this query based on your schema
                )
                order_id = cursor.lastrowid

                # Insert the product and quantity into the product_order table
                cursor.execute(
                    "INSERT INTO product_order (product_id, order_id, product_quantity) "
                    "VALUES (%s, %s, %s)",
                    (product_id, order_id, quantity)
                )

                db_conn.commit()

        return jsonify({"message": "Order placed successfully"})

    except Error as e:
        return jsonify({"error": f"Place order error: {e}"}), 500

def is_product_available(product_id, requested_quantity):
    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            # Retrieve the product's information
            cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
            product = cursor.fetchone()

            # Check if the product exists and is in stock
            return product and int(product['quantity']) >= int(requested_quantity)

# Function to create a new cart for the user and return the cart_id
def create_cart(client_email):
    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            # Insert a new cart for the user
            cursor.execute("INSERT INTO cart (client_email, quantity, total_price) VALUES (%s, 0, 0)", (client_email,))
            cart_id = cursor.lastrowid
            db_conn.commit()
    return cart_id

# Function to calculate the total price based on product price and quantity
def calculate_total_price(product_id, quantity):
    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            # Retrieve the product's information
            cursor.execute("SELECT price FROM product WHERE id = %s", (product_id,))
            product = cursor.fetchone()

            # Check if the product exists
            if product:
                # Calculate total price by multiplying quantity and product price
                total_price = int(quantity) * int(product['price'])
                return total_price
    return 0  # Return 0 if the product is not found or if there's an issue retrieving the price

# Endpoint to add a payment method
@app.route('/addPaymentMethod', methods=['POST'])
def add_payment_method():
    try:
        data = request.json
        client_email = data.get('client_email')
        card_owner = data.get('card_owner')
        card_number = data.get('card_number')
        cvv = data.get('cvv')

        # Insert the payment method into the database
        with db_connection.get_connection() as db_conn:
            with db_conn.cursor(dictionary=True) as cursor:
                cursor.execute("INSERT INTO payment (user_id, card_owner, card_number, cvv) VALUES (%s, %s, %s, %s)",
                               (client_email, card_owner, card_number, cvv))
                db_conn.commit()

        return jsonify({"message": "Payment method added successfully"})

    except Error as e:
        return jsonify({"error": f"Add payment method error: {e}"}), 500


# Endpoint to remove a payment method
@app.route('/removePaymentMethod', methods=['POST'])
def remove_payment_method():
    try:
        data = request.json
        client_email = data.get('client_email')
        payment_method_id = data.get('payment_method_id')

        # Remove the payment method from the database
        with db_connection.get_connection() as db_conn:
            with db_conn.cursor(dictionary=True) as cursor:
                cursor.execute("DELETE FROM payment WHERE user_id = %s AND id = %s", (client_email, payment_method_id))
                affected_rows = cursor.rowcount
                db_conn.commit()

                if affected_rows == 0:
                    return jsonify({"error": "Payment method not found"}), 404

        return jsonify({"message": "Payment method removed successfully"})

    except IntegrityError as e:
        return jsonify({"error": f"Remove payment method error: {e}"}), 500

@app.route('/getPaymentMethods', methods=['GET'])
def get_payment_methods():
    try:
        client_email = request.args.get('client_email')
        # Query the database to retrieve payment methods
        with db_connection.get_connection() as db_conn:
            with db_conn.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT * FROM payment WHERE user_id = %s", (client_email,))
                payment_methods = cursor.fetchall()

        if not payment_methods:
            return jsonify({"message": "No payment methods found for the given client_email"}), 404

        return jsonify(payment_methods)

    except Error as e:
        return jsonify({"error": f"Get payment methods error: {e}"}), 500

@app.route('/myOrders', methods=['GET'])
def get_my_orders():
    try:
        client_email = request.args.get('client_email')

        # Query the database to retrieve user's orders
        with db_connection.get_connection() as db_conn:
            with db_conn.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT * FROM orders WHERE user_id = %s", (client_email,))
                orders = cursor.fetchall()
        if not orders:
            return jsonify({"message": "No orders found for the given client_email"}), 404

        return jsonify(orders)

    except Error as e:
        return jsonify({"error": f"Get orders error: {e}"}), 500

@app.route('/getAllProduct', methods=['GET'])
def get_all_products():
    # Query the database to retrieve all products
    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
             cursor.execute("SELECT * FROM product")
             products = cursor.fetchall()

    return jsonify(products)

@app.route('/getAllProduct', methods=['GET'])
def get_all_products():
    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
             cursor.execute("SELECT * FROM product")
             products = cursor.fetchall()

    return jsonify(products)

@app.route('/getProductInfo', methods=['GET'])
def get_product_info():
    product_id = request.args.get('product_id', type=int)

    if product_id is None:
        return jsonify({"error": "Product ID is required"}), 400

    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
            product = cursor.fetchone()

    if not product:
        return jsonify({"error": "Product not found"}), 404

    return jsonify(product)




@app.route('/filterByPrice', methods=['GET'])
def filter_by_price():
    price_from = request.args.get('from')
    price_to = request.args.get('to')

    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            query = "SELECT * FROM product WHERE price BETWEEN %s AND %s"
            cursor.execute(query,(price_from, price_to))
            products = cursor.fetchall()

    return jsonify(products)




@app.route('/filterByBrand', methods=['GET'])
def filter_by_brand():
    brand_name = request.args.get('brandName')

    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product WHERE brand = %s", (brand_name,))
            products = cursor.fetchall()

    return jsonify(products)

@app.route('/filterByNationality', methods=['GET'])
def filter_by_nationality():

    nationality = request.args.get('nationality')

    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product WHERE nationality = %s", (nationality,))
            products = cursor.fetchall()

    return jsonify(products)


@app.route('/filterEgyptian', methods=['GET'])
def filter_Egypt():
    nationality = request.args.get('nationality')

    with db_connection.get_connection() as db_conn:
        with db_conn.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product WHERE nationality = 'Egyptian'")
            products = cursor.fetchall()

    return jsonify(products)

#OtherEndpoints..... 


# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)