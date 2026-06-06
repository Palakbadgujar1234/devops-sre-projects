# 🔧 FINAL FIX - Docker Networking Issue

## 🚨 The Real Problem

Your Flask app IS working perfectly:

- ✅ Returns correct metrics when you curl from Mac
- ✅ Prometheus IS reaching it (logs show 200 OK)
- ❌ But Prometheus thinks it's getting HTML

**This is a Docker DNS/networking issue!**

---

## 🎯 The Solution

The issue is that Prometheus is trying to scrape `http://flask-app:5000/metrics` but something is wrong with the container name resolution or the response format.

### Fix 1: Update Prometheus Configuration

**Run these commands:**

```bash
# Stop everything
cd ~/Desktop/apm-monitoring-demo
docker compose down

# Update prometheus.yml with correct scrape config
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
    metrics_path: '/metrics'
    static_configs:
      - targets: ['flask-app:5000']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: 'flask-app'
EOF

# Restart everything
docker compose up -d

# Wait 10 seconds
sleep 10

# Check Prometheus logs
docker logs prometheus --tail 20
```

---

### Fix 2: Check Flask App Response Headers

The error says "text/html" but your app should be returning "text/plain". Let's verify:

```bash
# Check from inside Prometheus container
docker exec prometheus wget -O- http://flask-app:5000/metrics 2>&1 | head -20

# Check the Content-Type header specifically
docker exec prometheus wget -S -O- http://flask-app:5000/metrics 2>&1 | grep -i content-type
```

**Expected output:**

```
Content-Type: text/plain; version=0.0.4; charset=utf-8
```

**If you see:**

```
Content-Type: text/html; charset=utf-8
```

Then the Flask app needs to be fixed!

---

### Fix 3: Verify Flask App Code

Let's check if your Flask app has the correct `/metrics` endpoint:

```bash
# Check what's in your app.py
cat ~/Desktop/apm-monitoring-demo/app/app.py | grep -A 5 "def metrics"
```

**It should look like this:**

```python
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}
```

**If it's different, update it:**

```bash
# Backup current app
cp ~/Desktop/apm-monitoring-demo/app/app.py ~/Desktop/apm-monitoring-demo/app/app.py.backup

# Create correct app.py
cat > ~/Desktop/apm-monitoring-demo/app/app.py << 'EOF'
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
EOF

# Rebuild and restart
docker compose up -d --build flask-app

# Wait for restart
sleep 10

# Test again
curl -I http://localhost:5000/metrics
```

---

### Fix 4: Nuclear Option - Complete Rebuild

If nothing else works, let's rebuild everything from scratch:

```bash
cd ~/Desktop/apm-monitoring-demo

# Stop and remove everything
docker compose down -v
docker system prune -f

# Remove old images
docker rmi apm-monitoring-demo-flask-app 2>/dev/null || true

# Rebuild everything
docker compose up -d --build

# Wait 15 seconds
sleep 15

# Check logs
echo "=== Flask App Logs ==="
docker logs flask-app --tail 10

echo ""
echo "=== Prometheus Logs ==="
docker logs prometheus --tail 10

# Test metrics
echo ""
echo "=== Testing /metrics endpoint ==="
curl -I http://localhost:5000/metrics

# Test from Prometheus container
echo ""
echo "=== Testing from Prometheus container ==="
docker exec prometheus wget -S -O- http://flask-app:5000/metrics 2>&1 | head -20
```

---

## 🔍 Diagnostic Commands

Run these to help me understand what's happening:

```bash
# 1. Check Content-Type from your Mac
echo "=== From Mac ==="
curl -I http://localhost:5000/metrics | grep -i content-type

# 2. Check Content-Type from Prometheus container
echo ""
echo "=== From Prometheus Container ==="
docker exec prometheus wget -S -O- http://flask-app:5000/metrics 2>&1 | grep -i content-type

# 3. Check if Flask is using the right library
echo ""
echo "=== Check Flask imports ==="
docker exec flask-app python -c "from prometheus_client import generate_latest, CONTENT_TYPE_LATEST; print('✅ prometheus_client is installed'); print(f'Content-Type will be: {CONTENT_TYPE_LATEST}')"

# 4. Check Prometheus scrape config
echo ""
echo "=== Prometheus Config ==="
docker exec prometheus cat /etc/prometheus/prometheus.yml | grep -A 10 flask-app

# 5. Check network connectivity
echo ""
echo "=== Network Test ==="
docker exec prometheus ping -c 2 flask-app
```

---

## 🎯 Expected vs Actual

### What Should Happen

1. **Prometheus scrapes:** `http://flask-app:5000/metrics`
2. **Flask returns:** Metrics with `Content-Type: text/plain; version=0.0.4`
3. **Prometheus parses:** Metrics successfully
4. **Target shows:** UP (green)

### What's Actually Happening

1. **Prometheus scrapes:** `http://flask-app:5000/metrics` ✅
2. **Flask returns:** Something with `Content-Type: text/html` ❌
3. **Prometheus rejects:** "unsupported Content-Type"
4. **Target shows:** DOWN (red)

---

## 🚀 Quick Test Script

Save this as `test-metrics.sh` and run it:

```bash
#!/bin/bash

echo "🧪 Testing Metrics Endpoint"
echo "=========================="
echo ""

echo "1️⃣ Testing from Mac (localhost:5000)"
echo "-----------------------------------"
RESPONSE=$(curl -s -I http://localhost:5000/metrics)
echo "$RESPONSE"
if echo "$RESPONSE" | grep -q "text/plain"; then
    echo "✅ Content-Type is correct (text/plain)"
else
    echo "❌ Content-Type is WRONG (not text/plain)"
fi
echo ""

echo "2️⃣ Testing from Prometheus container (flask-app:5000)"
echo "----------------------------------------------------"
RESPONSE=$(docker exec prometheus wget -S -O- http://flask-app:5000/metrics 2>&1 | head -30)
echo "$RESPONSE"
if echo "$RESPONSE" | grep -q "text/plain"; then
    echo "✅ Content-Type is correct (text/plain)"
else
    echo "❌ Content-Type is WRONG (not text/plain)"
fi
echo ""

echo "3️⃣ Checking Prometheus targets"
echo "------------------------------"
echo "Open: http://localhost:9091/targets"
echo ""

echo "4️⃣ Checking Flask logs"
echo "----------------------"
docker logs flask-app --tail 5
echo ""

echo "Done! 🎉"
```

**Run it:**

```bash
chmod +x test-metrics.sh
./test-metrics.sh
```

---

## 💡 Most Likely Cause

Based on your logs showing successful 200 responses, but Prometheus still seeing HTML, this is likely:

1. **Flask is catching the /metrics route but returning JSON instead of metrics**
2. **The prometheus_client library isn't installed in the container**
3. **There's a Flask error handler converting metrics to HTML**
4. **The /metrics endpoint exists but doesn't use `generate_latest()`**

---

## 📞 Next Steps

**Run the diagnostic commands above and share:**

1. Output of the Content-Type check from Mac
2. Output of the Content-Type check from Prometheus container
3. Output of `docker exec flask-app python -c "from prometheus_client import generate_latest; print('OK')"`

This will tell us exactly what's wrong! 🔍
