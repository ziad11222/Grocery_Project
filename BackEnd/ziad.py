from flask import Flask, request, jsonify
import random
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Database configuration
db_config = {
    'host': 'mysql-156959-0.cloudclusters.net',
    'port': 18579,
    'user': 'admin',
    'password': '9n8ZbOza',
    'database': 'Groceyshop'
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
        otp = generate_otp()
        send_otp_email(email, otp)

        return jsonify({"message": "User registered successfully. OTP sent to your email"})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500



        # You would normally send an email with this OTP

        return jsonify({"message": "User registered successfully. OTP sent to your email"})

    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500

# ... (Other endpoints)

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
    Test