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

# Endpoint to place an order using the items in the cart
@app.route('/place_order', methods=['POST']) 
def place_order_from_cart():
    try:
        data = request.json
        client_email = data.get('client_email')
        payment_method_id = data.get('payment_method_id')

        # Retrieve cart items using the view_cart endpoint
        view_cart_response = view_cart_helper(client_email)

        if 'error' in view_cart_response:
            return jsonify({"error": view_cart_response['error']}), 500

        cart_items = view_cart_response['cart_items']

        # Check if there are items in the cart
        if not cart_items:
            return jsonify({"error": "No items found in the cart"}), 400

        # Creation of a new cart and assigning id to it for the order
        cart_id = create_cart(client_email)

        # Insert the order into the orders table
        with db_connection.cursor(dictionary=True) as cursor:
            total_price = view_cart_response['total_price']
            cursor.execute(
                "INSERT INTO orders (user_id, cart_id, payment_method, total_price, order_date) "
                "VALUES (%s, %s, %s, %s, NOW())",
                (client_email, cart_id, payment_method_id, total_price)
            )
            order_id = cursor.lastrowid

            # Insert the product and quantity into the product_order table
            for item in cart_items:
                product_id = item['id']
                quantity = item['quantity']
                cursor.execute(
                    "INSERT INTO product_order (product_id, order_id, product_quantity) "
                    "VALUES (%s, %s, %s)",
                    (product_id, order_id, quantity)
                )

            db_connection.commit()

        return jsonify({"message": "Order placed successfully"})
    except Error as e:
        return jsonify({"error": f"Place order error: {e}"}), 500


# Helper function to retrieve cart items using the view_cart endpoint
def view_cart_helper(client_email):
    try:
        with app.test_client() as client:
            view_cart_response = client.get(f'/view_cart?client_email={client_email}')
            return view_cart_response.get_json()
    except Exception as e:
        return {"error": f"Error calling view_cart endpoint: {e}"}


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
    with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product")
            products = cursor.fetchall()

    return jsonify(products)

@app.route('/getProductInfo', methods=['GET'])
def get_product_info():
    if not (db_connection.is_connected()):
        db_connection.reconnect()
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


# Helper function to update the quantity of a product in the cart
def update_cart_item_quantity(client_email, product_id, quantity):
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT quantity FROM product_cart WHERE cart_id IN (SELECT id FROM cart WHERE client_email = %s) AND product_id = %s",
                       (client_email, product_id))
        current_quantity_result = cursor.fetchone()

        if current_quantity_result and 'quantity' in current_quantity_result:
            current_quantity = int(current_quantity_result['quantity'])
            new_quantity = current_quantity + int(quantity)
            cursor.execute("UPDATE product_cart SET quantity = %s "
                           "WHERE cart_id IN (SELECT id FROM cart WHERE client_email = %s) AND product_id = %s",
                           (new_quantity, client_email, product_id))
            db_connection.commit()
            return True
        else:
            return False

# Endpoint to add a product to the cart
@app.route('/addToCart', methods=['POST'])
def add_to_cart():
    try:
        data = request.json
        client_email = data.get('client_email')
        product_id = data.get('product_id')
        quantity = data.get('quantity')

        if not all([client_email, product_id, quantity]):
            return jsonify({"error": "Invalid request parameters"}), 400

        if not is_product_available(product_id, quantity):
            return jsonify({"error": "Product is out of stock or insufficient quantity"}), 400
        create_cart_if_not_exists(client_email)
        if update_cart_item_quantity(client_email, product_id, quantity):
            return jsonify({"message": "Product quantity in the cart updated successfully"})
        
        # Add the product to the cart
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("INSERT INTO product_cart (cart_id, product_id, quantity) "
                           "VALUES ((SELECT id FROM cart WHERE client_email = %s LIMIT 1), %s, %s)",
                           (client_email, product_id, quantity))
            calculate_and_update_total_price(client_email)
            db_connection.commit()

        return jsonify({"message": "Product added to the cart successfully"})

    except IntegrityError as e:
        return jsonify({"error": f"Add to cart error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Add to cart error: {e}"}), 500
    

def create_cart_if_not_exists(client_email):
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("SELECT id FROM cart WHERE client_email = %s LIMIT 1", (client_email,))
        existing_cart = cursor.fetchone()
        if not existing_cart:
            cursor.execute("INSERT INTO cart (client_email, quantity, total_price) VALUES (%s, 0, 0)", (client_email,))
            db_connection.commit()



@app.route('/view_cart', methods=['GET'])
def view_cart():
    try:
        client_email = request.args.get('client_email')

        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("""
                SELECT
                    product.id,
                    product.image,
                    product.product_name,
                    product.price,
                    product_cart.quantity
                FROM
                    product_cart
                INNER JOIN
                    product ON product_cart.product_id = product.id
                INNER JOIN
                    cart ON product_cart.cart_id = cart.id
                WHERE 
                    cart.client_email = %s
            """, (client_email,))

            cart_items = cursor.fetchall() 

        if not cart_items:
            return jsonify({"message": "No items found in the cart"}), 404
        
        total_price = sum(item['price'] * item['quantity'] for item in cart_items)
        for item in cart_items: 
            item['total_price'] = item['price'] * item['quantity']

        return jsonify({"cart_items": cart_items, "total_price": total_price})

    except Error as e:
        return jsonify({"error": f"View cart error: {e}"}), 500

    
@app.route('/discounted_products', methods=['GET'])
def discounted_products():
    try:
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("SELECT * FROM product WHERE discount > 0")
            discounted_products = cursor.fetchall()

        if not discounted_products:
            return jsonify({"message": "No products with discount found"}), 404

        return jsonify(discounted_products)

    except Error as e:
        return jsonify({"error": f"Discounted products error: {e}"}), 500


@app.route('/removeFromCart', methods=['POST'])
def remove_from_cart():
    try:
        data = request.json
        client_email = data.get('client_email')
        product_id = data.get('product_id')
        if not all([client_email, product_id]):
            return jsonify({"error": "Invalid request parameters"}), 400
        # Remove the product from the cart
        
        with db_connection.cursor(dictionary=True) as cursor:
            cursor.execute("DELETE FROM product_cart WHERE cart_id IN (SELECT id FROM cart WHERE client_email = %s) AND product_id = %s",
                            (client_email, product_id))
            affected_rows = cursor.rowcount
            db_connection.commit()
            if affected_rows == 0:
                return jsonify({"error": "Product not found in the cart"}), 404
        return jsonify({"message": "Product removed from the cart successfully"})
    except IntegrityError as e:
        return jsonify({"error": f"Remove from cart error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Remove from cart error: {e}"}), 500
    
@app.route('/decreaseProductQuantityInCart', methods=['POST'])
def decrease_product_quantity_in_cart():
    try:
        data = request.json
        client_email = data.get('client_email')
        product_id = data.get('product_id')

        if not all([client_email, product_id]):
            return jsonify({"error": "Invalid request parameters"}), 400

        # Decrease the quantity of the specified product in the cart by 1
        with db_connection.cursor(dictionary=True) as cursor:
            # Decrease the quantity, and ensure it does not go below 0
            cursor.execute(
                "UPDATE product_cart SET quantity = GREATEST(quantity - 1, 0) WHERE cart_id IN (SELECT id FROM cart WHERE client_email = %s) AND product_id = %s",
                (client_email, product_id))
            db_connection.commit()

            # Check if the product was found in the cart
            if cursor.rowcount == 0:
                return jsonify({"error": "Product not found in the cart"}), 404

            # Check if the quantity has become zero and remove the product from the cart
            cursor.execute(
                "DELETE FROM product_cart WHERE cart_id IN (SELECT id FROM cart WHERE client_email = %s) AND product_id = %s AND quantity = 0",
                (client_email, product_id))
            db_connection.commit()

        return jsonify({"message": "Product quantity in the cart decreased successfully"})

    except IntegrityError as e:
        return jsonify({"error": f"Decrease product quantity in cart error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Decrease product quantity in cart error: {e}"}), 500


@app.route('/increaseProductQuantityInCart', methods=['POST'])
def increase_product_quantity_in_cart():
    try:
        data = request.json
        client_email = data.get('client_email')
        product_id = data.get('product_id')

        # Check if the required parameters are present in the request
        if not all([client_email, product_id]):
            return jsonify({"error": "Invalid request parameters"}), 400

        # Increase the quantity of the specified product in the cart by 1
        with db_connection.cursor(dictionary=True) as cursor:
            # Increase the quantity
            cursor.execute(
                "UPDATE product_cart SET quantity = quantity + 1 WHERE cart_id IN (SELECT id FROM cart WHERE client_email = %s) AND product_id = %s",
                (client_email, product_id))
            db_connection.commit()

            # Check if the product was found in the cart
            if cursor.rowcount == 0:
                return jsonify({"error": "Product not found in the cart"}), 404

        return jsonify({"message": "Product quantity in the cart increased successfully"})

    except IntegrityError as e:
        return jsonify({"error": f"Increase product quantity in cart error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Increase product quantity in cart error: {e}"}), 500


@app.route('/confirmOrders', methods=['POST'])
def confirm_orders():
    try:
        data = request.json
        client_email = data.get('client_email')
        cart_id = data.get('cart_id')
        payment_method_id = data.get('payment_method_id')

        # Validate input parameters
        if not all([client_email, cart_id, payment_method_id]):
            return jsonify({"error": "Invalid request parameters"}), 400

        
        with db_connection.cursor(dictionary=True) as cursor:
            # Check if the cart is not empty
            cursor.execute("SELECT * FROM product_cart WHERE cart_id = %s", (cart_id,))
            cart_items = cursor.fetchall()

            if not cart_items:
                return jsonify({"error": "Cart is empty. Add products before confirming the order"}), 400

            # Calculate the total price of the order
            cursor.execute("SELECT SUM(product.price * product_cart.product_quantity) AS total_price "
                            "FROM product_cart "
                            "INNER JOIN product ON product_cart.product_id = product.id "
                            "WHERE product_cart.cart_id = %s", (cart_id,))
            total_price_result = cursor.fetchone()
            total_price = total_price_result['total_price'] if total_price_result['total_price'] else 0

            # Insert the order into the orders table
            cursor.execute(
                "INSERT INTO orders (user_id, cart_id, payment_method, total_price, order_date) "
                "VALUES (%s, %s, %s, %s, NOW())",
                (client_email, cart_id, payment_method_id, total_price)
            )
            order_id = cursor.lastrowid

            # Move products from the cart to the product_order table
            cursor.execute(
                "INSERT INTO product_order (product_id, order_id, product_quantity) "
                "SELECT product_id, %s, product_quantity FROM product_cart WHERE cart_id = %s",
                (order_id, cart_id)
            )

            # Clear the cart
            cursor.execute("DELETE FROM product_cart WHERE cart_id = %s", (cart_id,))

            db_connection.commit()

        return jsonify({"message": "Order confirmed successfully", "order_id": order_id})

    except mysql.connector.Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Confirm orders error: {e}"}), 500

# New endpoint to get the number of users who purchased a product
@app.route('/productPurchaseStats', methods=['GET'])
def product_purchase_stats():
    try:
        # Get the product ID from the query parameters
        product_id = request.args.get('product_id', type=int)

        if product_id is None:
            return jsonify({"error": "Product ID is required"}), 400

        # Calculate the total number of users who purchased the product
        total_users_purchased = get_total_users_purchased(product_id)

        # Calculate the number of users who purchased the product in the last 24 hours
        users_purchased_last_24_hours = get_users_purchased_last_24_hours(product_id)

        return jsonify({
            "product_id": product_id,
            "total_users_purchased": total_users_purchased,
            "users_purchased_last_24_hours": users_purchased_last_24_hours
        })

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500

def get_total_users_purchased(product_id):
    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("""
            SELECT COUNT(DISTINCT order_id) AS total_users
            FROM product_order
            WHERE product_id = %s
        """, (product_id,))
        result = cursor.fetchone()
        return result['total_users'] if result else 0

def get_users_purchased_last_24_hours(product_id):
    # Calculate the timestamp 24 hours ago from the current time
    twenty_four_hours_ago = datetime.datetime.utcnow() - datetime.timedelta(hours=24)

    with db_connection.cursor(dictionary=True) as cursor:
        cursor.execute("""
            SELECT COUNT(DISTINCT order_id) AS users_last_24_hours
            FROM product_order
            WHERE product_id = %s AND order_id IN (
                SELECT id FROM orders WHERE order_date >= %s
            )
        """, (product_id, twenty_four_hours_ago))
        result = cursor.fetchone()
        return result['users_last_24_hours'] if result else 0
    

def calculate_and_update_total_price(client_email):
    try:
        with db_connection.cursor(dictionary=True) as cursor:
            # Calculate total price and sum of quantities
            cursor.execute("""
                SELECT 
                    p.id,
                    p.price,
                    pc.quantity
                FROM product_cart pc
                JOIN product p ON pc.product_id = p.id
                JOIN cart c ON pc.cart_id = c.id
                WHERE c.client_email = %s 
            """, (client_email,))
            
            cart_items = cursor.fetchall()

            total_price = sum(item['price'] * item['quantity'] for item in cart_items)
            total_quantity = sum(item['quantity'] for item in cart_items)

            # Update the total price and quantity in the cart table
            cursor.execute("UPDATE cart SET total_price = %s, quantity = %s WHERE client_email = %s", (total_price, total_quantity, client_email))
            db_connection.commit()

    except Error as e:
        print(f"Error calculating and updating total price and quantity: {e}")
        raise  # You may want to handle this error more gracefully in your production code

#OtherEndpoints..... 


# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)