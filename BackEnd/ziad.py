from flask import Flask, request, jsonify
import random
import mysql.connector
from mysql.connector import Error
from mysql.connector import IntegrityError
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import secrets
from flask_mail import Mail, Message
from flask import url_for

app = Flask(__name__)

# Database configuration
db_config = {
    'host': '34.31.110.154',
    'port': 3306,
    'user': 'ziadym',
    'password': '112233',
    'database': 'grocerystore'
}

# Flask-Mail configuration
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'Info.Groceryshop@gmail.com'
app.config['MAIL_PASSWORD'] = 'mkyg vojf mjjx mxst'
mail = Mail(app)

# Helper function to generate OTP
def generate_otp():
    return str(random.randint(1000, 9999))

# Helper function to send verification email
def send_verification_email(email, verification_code):
    try:
        msg = Message('Verify Your Account', sender='your_email@example.com', recipients=[email])
        msg.body = f'Your verification code is: {verification_code}'
        mail.send(msg)
    except Exception as e:
        print(f"Error sending email: {e}")

# Initialize MySQL connection pool
db_connection = mysql.connector.connect(**db_config)

# Initialize MySQL connection pool
#db_connection = mysql.connector.pooling.MySQLConnectionPool(pool_name="mypool", pool_size=10, **db_config)


SECRET_KEY = secrets.token_hex(32)

# Endpoint for user login
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        email = data.get('email')
        password = data.get('password')

        # Fetch user from the database
        connection = mysql.connector.connect(**db_config)
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
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE email = %s", (email,))
            existing_user = cursor.fetchone()

            if existing_user:
                return jsonify({"error": "User already exists"}), 400

            # Insert new user into the database with 'is_verified' set to False
            verification_code = generate_otp()
            cursor.execute("INSERT INTO client (email, password, user_name, b_date, address, profile_image, is_verified, verification_code) "
                            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                            (email, password, user_name, b_date, address, profile_image, False, verification_code))
            db_connection.commit()

            # Send verification email
            send_verification_email(email, verification_code)

        return jsonify({"message": "User registered successfully! Please check your email for verification."})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500

#verify endpoint
@app.route('/verify', methods=['POST'])
def verify():
    try:
        data = request.json
        email = data.get('email')
        verification_code = data.get('verification_code')

        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE email = %s AND verification_code = %s", (email, verification_code))
            user = cursor.fetchone()

            if not user:
                return jsonify({"error": "Invalid verification code"}), 401

            # Update the user's record to mark them as verified
            cursor.execute("UPDATE client SET is_verified = True WHERE email = %s", (email,))
            db_connection.commit()

        return jsonify({"message": "Account verified successfully!"})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    

# Helper function to generate a unique token for password reset
def generate_reset_token():
    return secrets.token_urlsafe(32)

# Endpoint for requesting a password reset
@app.route('/forgot-password', methods=['POST'])
def forgot_password():
    try:
        data = request.json
        email = data.get('email')

        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE email = %s", (email,))
            user = cursor.fetchone()

            if not user:
                return jsonify({"error": "Email not registered!"}), 404

            # Generate a unique token for password reset
            reset_token = generate_reset_token()

            # Store the reset token in the database
            cursor.execute("UPDATE client SET reset_token = %s WHERE email = %s", (reset_token, email))
            db_connection.commit()

            # Send an email with the reset token
            msg = Message('Password Reset', sender='your_email@example.com', recipients=[email])
            msg.body = f'Your password reset token is: {reset_token}'
            mail.send(msg)

        return jsonify({"message": "Password reset instructions sent to your email"})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500
        
# Endpoint for handling password reset
@app.route('/reset-password/<token>', methods=['POST'])
def reset_password(token):
    try:
        data = request.json
        new_password = data.get('new_password')

        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM client WHERE reset_token = %s", (token,))
            user = cursor.fetchone()

            if not user:
                return jsonify({"error": "Invalid or expired token"}), 401

            # Update the user's password and clear the reset token
            hashed_password = generate_password_hash(new_password)
            cursor.execute("UPDATE client SET password = %s, reset_token = NULL WHERE email = %s", (hashed_password, user['email']))
            db_connection.commit()

        return jsonify({"message": "Password reset successful"})

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
        
        with db_connection.cursor(dictionary=True) as cursor:

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

            db_connection.commit()

        return jsonify({"message": "Order placed successfully"})

    except Error as e:
        return jsonify({"error": f"Place order error: {e}"}), 500

def is_product_available(product_id, requested_quantity):
    
    with db_connection.cursor(dictionary=True) as cursor:
        # Retrieve the product's information
        cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
        product = cursor.fetchone()

        # Check if the product exists and is in stock
        return product and int(product['quantity']) >= int(requested_quantity)

# Function to create a new cart for the user and return the cart_id
def create_cart(client_email):
    
    with db_connection.cursor(dictionary=True) as cursor:
        # Insert a new cart for the user
        cursor.execute("INSERT INTO cart (client_email, quantity, total_price) VALUES (%s, 0, 0)", (client_email,))
        cart_id = cursor.lastrowid
        db_connection.commit()
    return cart_id

# Function to calculate the total price based on product price and quantity
def calculate_total_price(product_id, quantity):
    
    with db_connection.cursor(dictionary=True) as cursor:
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
    
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("INSERT INTO payment (user_id, card_owner, card_number, cvv) VALUES (%s, %s, %s, %s)",
                            (client_email, card_owner, card_number, cvv))
            db_connection.commit()

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
        
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("DELETE FROM payment WHERE user_id = %s AND id = %s", (client_email, payment_method_id))
            affected_rows = cursor.rowcount
            db_connection.commit()

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
        
        with db_connection.cursor(dictionary=True) as cursor:
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
        
        with db_connection.cursor(dictionary=True) as cursor:
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
    
    with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product")
            products = cursor.fetchall()

    return jsonify(products)

@app.route('/getProductInfo', methods=['GET'])
def get_product_info():
    product_id = request.args.get('product_id', type=int)

    if product_id is None:
        return jsonify({"error": "Product ID is required"}), 400

    
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
        product = cursor.fetchone()

    if not product:
        return jsonify({"error": "Product not found"}), 404

    return jsonify(product)




@app.route('/filterByPrice', methods=['GET'])
def filter_by_price():
    price_from = request.args.get('from')
    price_to = request.args.get('to')

    
    with db_connection.cursor(dictionary=True) as cursor:
        query = "SELECT * FROM product WHERE price BETWEEN %s AND %s"
        cursor.execute(query,(price_from, price_to))
        products = cursor.fetchall()

    return jsonify(products)




@app.route('/filterByBrand', methods=['GET'])
def filter_by_brand():
    brand_name = request.args.get('brandName')

   
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT * FROM product WHERE brand = %s", (brand_name,))
        products = cursor.fetchall()

    return jsonify(products)

@app.route('/filterByNationality', methods=['GET'])
def filter_by_nationality():

    nationality = request.args.get('nationality')

    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT * FROM product WHERE nationality = %s", (nationality,))
        products = cursor.fetchall()

    return jsonify(products)


@app.route('/filterEgyptian', methods=['GET'])
def filter_Egypt():
    nationality = request.args.get('nationality')

    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT * FROM product WHERE nationality = 'Egyptian'")
        products = cursor.fetchall()

    return jsonify(products)

@app.route('/getBySearch', methods=['GET'])
def search_products():
    # Get search query from query parameters
    search_query = request.args.get('q')

    # Query the database to search products by keyword
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT * FROM product WHERE product_name LIKE %s", (f"%{search_query}%",))
        products = cursor.fetchall()

    return jsonify(products)


@app.route('/addToCart', methods=['POST'])
def add_to_cart():
    try:
        data = request.json
        client_email = data.get('client_email')
        product_id = data.get('product_id')
        cart_id = data.get('cart_id')
        quantity = data.get('quantity')

        # Validate input parameters
        if not all([client_email, product_id, quantity]):
            return jsonify({"error": "Invalid request parameters"}), 400

        def is_product_available(product_id, requested_quantity):
            
            with db_connection.cursor(dictionary=True) as cursor:
                cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
                product = cursor.fetchone()
                return product and int(product['quantity']) >= int(requested_quantity)

        def create_cart(client_email):
            with db_connection.cursor(dictionary=True) as cursor:
                cursor.execute("INSERT INTO cart (client_email, quantity, total_price) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE client_email=client_email", (client_email,))
                cart_id = cursor.lastrowid
                db_connection.commit()
            return cart_id

        # Check if the product is in stock and has enough quantity
        if not is_product_available(product_id, quantity):
            return jsonify({"error": "Product is out of stock or insufficient quantity"}), 400

        if cart_id is None:
            cart_id = create_cart(client_email)

        # Insert the product into the cart
        
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("INSERT INTO product_cart (product_id, cart_id, quantity) VALUES (%s, %s, %s)", (product_id, cart_id, quantity))

            db_connection.commit()

        return jsonify({"message": "Product added to the cart successfully"})

    except mysql.connector.Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Add to cart error: {e}"}), 500



@app.route('/view_cart')
def view_my_cart () :
    data = request.json
    client_email = data.get('client_email')
    product_id = data.get('product_id')
    cart_id = data.get('cart_id')
    
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT product_cart.product_id , product_cart.product_quantity FROM product_cart INNER JOIN cart   on  cart.id = product_cart.cart_id ")
        product = cursor.fetchall()



#OtherEndpoints..... 


# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)