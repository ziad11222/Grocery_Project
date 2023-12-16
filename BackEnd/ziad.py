from flask import Flask, request, jsonify
import random
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Database configuration
db_config = {
    'host': '34.27.244.125',
    'port': 3306,
    'user': 'ziadym',
    'password': '112233',
    'database': 'grocerystore'
}

# Initialize MySQL connection pool
db_connection = mysql.connector.pooling.MySQLConnectionPool(pool_name="mypool", pool_size=5, **db_config)

# Helper function to generate OTP
def generate_otp():
    return str(random.randint(1000, 9999))

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

        return jsonify({"message": "Logged in successfully"})

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

        # Check if user already exists
        connection = db_connection.get_connection()
        with connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE email = %s", (email,))
            existing_user = cursor.fetchone()

            if existing_user:
                return jsonify({"error": "User already exists"}), 400

            # Insert new user into the database
            cursor.execute("INSERT INTO client (email, password, user_name, b_date, address) "
                            "VALUES (%s, %s, %s, %s, %s)",
                            (email, password, user_name, b_date, address))
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
        # Insert the order into the orders table
        with db_connection.get_connection() as db_conn:
            with db_conn.cursor(dictionary=True) as cursor:
                # Insert the order into the orders table
                cursor.execute(
                    "INSERT INTO orders (user_id, cart_id, payment_method, total_price, order_date) "
                    "VALUES (%s, %s, %s, %s, NOW())",
                    (client_email, None, payment_method_id, None)  # You may need to modify this query based on your schema
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

#OtherEndpoints..... 


# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)