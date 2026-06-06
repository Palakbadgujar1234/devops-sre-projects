# Import Flask
from flask import Flask, jsonify
import requests

# Create Flask app
app = Flask(__name__)

# Health check endpoint
@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "api-gateway"})

# Get users endpoint
@app.route('/api/users')
def get_users():
    # Call user service
    response = requests.get('http://user-service:5001/users')
    return response.json()

# Get products endpoint
@app.route('/api/products')
def get_products():
    # Call product service
    response = requests.get('http://product-service:5002/products')
    return response.json()

# Run app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

# Made with Bob
