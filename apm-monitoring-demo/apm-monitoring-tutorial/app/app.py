from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration', ['endpoint', 'method'])
ACTIVE_REQUESTS = Gauge('app_active_requests', 'Active requests')
ERROR_COUNT = Counter('app_errors_total', 'Total errors', ['endpoint', 'error_type'])

@app.before_request
def before_request():
    request.start_time = time.time()
    ACTIVE_REQUESTS.inc()

@app.after_request
def after_request(response):
    request_duration = time.time() - request.start_time
    REQUEST_DURATION.labels(
        endpoint=request.endpoint or 'unknown',
        method=request.method
    ).observe(request_duration)
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
    ACTIVE_REQUESTS.dec()
    return response

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint - MUST return text/plain"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/')
def home():
    return jsonify({"message": "Flask Monitoring Demo", "status": "running"})

@app.route('/api/users')
def get_users():
    time.sleep(random.uniform(0.1, 0.3))
    return jsonify({"users": ["Alice", "Bob", "Charlie"]})

@app.route('/api/database')
def database_query():
    time.sleep(random.uniform(0.2, 0.5))
    return jsonify({"records": 42, "query_time": "0.3s"})

@app.route('/api/slow')
def slow_endpoint():
    time.sleep(2)
    return jsonify({"message": "This was slow"})

@app.route('/api/error')
def error_endpoint():
    ERROR_COUNT.labels(endpoint='/api/error', error_type='random_error').inc()
    return jsonify({"error": "Something went wrong"}), 500

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
