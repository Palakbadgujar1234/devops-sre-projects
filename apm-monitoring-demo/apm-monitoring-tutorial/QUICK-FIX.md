# 🔧 Quick Fix for Prometheus Target Error

## Problem

Your Prometheus target shows **DOWN** with error:

```
Error scraping target: received unsupported Content-Type "text/html; charset=utf-8"
```

This means:

- ❌ Flask app is returning HTML instead of Prometheus metrics
- ❌ The `/metrics` endpoint is not properly configured
- ❌ Prometheus can't collect data

---

## Solution: Let's Check What You're Running

### Step 1: Check What's Actually Running

```bash
# See what containers are running
docker ps

# Check Flask app logs
docker logs flask-app
```

**Question:** Did you create the Flask app files I provided, or are you running something else?

---

## Option A: If You Created the Files (app.py, Dockerfile, etc.)

### Restart Everything

```bash
# Stop all containers
docker compose down

# Rebuild and start
docker compose up -d --build

# Check logs
docker logs flask-app
```

### Test the /metrics endpoint

```bash
# This should return Prometheus metrics, NOT HTML
curl http://localhost:5000/metrics
```

**Expected output:**

```
# HELP app_requests_total Total requests
# TYPE app_requests_total counter
app_requests_total{endpoint="home",method="GET",status="200"} 0.0
```

**If you see HTML like `<html>` or `<!DOCTYPE>`, the app is wrong!**

---

## Option B: If You're Running a Different Flask App

You need to add Prometheus instrumentation to your app!

### Install prometheus-client

```bash
# Enter the container
docker exec -it flask-app bash

# Install prometheus-client
pip install prometheus-client

# Exit
exit
```

### Add Metrics to Your App

Your Flask app needs this code:

```python
from flask import Flask
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Create metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration', ['endpoint', 'method'])
ACTIVE_REQUESTS = Gauge('app_active_requests', 'Active requests')
ERROR_COUNT = Counter('app_errors_total', 'Total errors', ['endpoint', 'error_type'])

# Metrics endpoint - THIS IS CRITICAL!
@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

# Your other routes...
@app.route('/')
def home():
    REQUEST_COUNT.labels(method='GET', endpoint='home', status='200').inc()
    return "Hello World"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**The key is the `/metrics` endpoint that returns `generate_latest()`!**

---

## Option C: Start Fresh with My Complete Setup

### 1. Stop Everything

```bash
cd ~/Desktop/apm-monitoring-tutorial
docker compose down
```

### 2. Create the Correct File Structure

```bash
# Create directories
mkdir -p app prometheus grafana

# Create app.py
cat > app/app.py << 'EOF'
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
    REQUEST_DURATION.labels(endpoint=request.endpoint or 'unknown', method=request.method).observe(request_duration)
    REQUEST_COUNT.labels(method=request.method, endpoint=request.endpoint or 'unknown', status=response.status_code).inc()
    ACTIVE_REQUESTS.dec()
    return response

@app.route('/metrics')
def metrics():
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
EOF

# Create requirements.txt
cat > app/requirements.txt << 'EOF'
flask==3.0.0
prometheus-client==0.19.0
EOF

# Create Dockerfile
cat > app/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF

# Create prometheus.yml
cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'flask-app'
    scrape_interval: 5s
    static_configs:
      - targets: ['flask-app:5000']
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  flask-app:
    build: ./app
    container_name: flask-app
    ports:
      - "5000:5000"
    networks:
      - monitoring

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9091:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge
EOF

echo "✅ All files created!"
```

### 3. Start Everything

```bash
# Build and start
docker compose up -d --build

# Wait 10 seconds
sleep 10

# Check logs
docker logs flask-app
```

### 4. Test

```bash
# Test metrics endpoint
curl http://localhost:5000/metrics

# Should see Prometheus metrics, NOT HTML!
```

### 5. Check Prometheus

Open: <http://localhost:9091/targets>

**flask-app should be UP (green)!**

---

## 🎯 The Root Cause

The error `received unsupported Content-Type "text/html"` means:

1. **Prometheus expects:** `Content-Type: text/plain; version=0.0.4`
2. **Your app is sending:** `Content-Type: text/html; charset=utf-8`

This happens when:

- ❌ The `/metrics` endpoint doesn't exist
- ❌ The `/metrics` endpoint returns HTML instead of metrics
- ❌ Flask is returning a 404 error page (which is HTML)
- ❌ The app isn't using `prometheus-client` library

---

## ✅ How to Verify It's Fixed

### Test 1: Metrics Endpoint

```bash
curl -I http://localhost:5000/metrics
```

**Should see:**

```
HTTP/1.1 200 OK
Content-Type: text/plain; version=0.0.4; charset=utf-8
```

**NOT:**

```
Content-Type: text/html; charset=utf-8
```

### Test 2: Metrics Content

```bash
curl http://localhost:5000/metrics | head -20
```

**Should see:**

```
# HELP app_requests_total Total requests
# TYPE app_requests_total counter
app_requests_total{endpoint="metrics",method="GET",status="200"} 1.0
```

**NOT:**

```html
<!DOCTYPE html>
<html>
```

### Test 3: Prometheus Target

Open: <http://localhost:9091/targets>

**Should see:**

- ✅ flask-app: **UP** (green)
- Last scrape: **6ms**
- State: **UP**

---

## 🚀 Next Steps After Fix

Once the target is **UP**:

1. **Generate traffic:**

   ```bash
   for i in {1..20}; do curl -s http://localhost:5000/api/users > /dev/null; done
   ```

2. **Query in Prometheus:**
   - Go to: <http://localhost:9091>
   - Query: `app_requests_total`
   - Click "Execute"
   - You should see data!

3. **Create Grafana dashboard** (as explained in previous guide)

---

## 📞 Need Help?

Tell me:

1. What do you see when you run: `curl http://localhost:5000/metrics`
2. What's in the Flask logs: `docker logs flask-app`
3. Did you create the app.py file I provided, or are you using a different app?

I'll help you fix it! 🔧
