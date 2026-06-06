# 🔍 Complete APM Monitoring Setup - Learn Today

## What You'll Build Today

A complete monitoring system for a Python Flask application using:

- **Prometheus** - Metrics collection (most asked in interviews!)
- **Grafana** - Beautiful dashboards
- **Flask** - Simple Python web app
- **Docker** - Easy setup

**Time Required:** 2-3 hours
**Difficulty:** Beginner-friendly

---

## 📚 What is APM?

**APM (Application Performance Monitoring)** = Tracking how your application performs

**What it monitors:**

- Response times (how fast?)
- Error rates (how many failures?)
- Request counts (how much traffic?)
- Resource usage (CPU, memory)
- User experience

**Why companies use it:**

- Find slow parts of application
- Detect errors before users complain
- Understand traffic patterns
- Plan capacity (do we need more servers?)

---

## 🎯 What We'll Monitor

```
User Request → Flask App → Response
                  ↓
            Prometheus (collects metrics)
                  ↓
            Grafana (shows dashboards)
```

**Metrics we'll track:**

1. **Request count** - How many requests per second?
2. **Response time** - How fast is the app?
3. **Error rate** - How many requests fail?
4. **Active requests** - How many requests happening now?

---

## 🛠️ Setup (Step-by-Step)

### Step 1: Install Prerequisites

**On Mac:**

```bash
# Install Docker Desktop
brew install --cask docker

# Start Docker Desktop (from Applications)
```

**On Windows:**

```bash
# Download and install Docker Desktop from:
# https://www.docker.com/products/docker-desktop
```

**On Linux:**

```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
```

**Verify installation:**

```bash
docker --version
# Should show: Docker version 24.x.x

docker-compose --version
# Should show: docker-compose version 2.x.x
```

### Step 2: Create Project Structure

```bash
# Create project directory
mkdir apm-monitoring-demo
cd apm-monitoring-demo

# Create subdirectories
mkdir app prometheus grafana
```

**Your structure:**

```
apm-monitoring-demo/
├── app/
│   ├── app.py              # Flask application
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Docker image for app
├── prometheus/
│   └── prometheus.yml      # Prometheus configuration
├── grafana/
│   └── dashboards/         # Grafana dashboards
└── docker-compose.yml      # Run everything together
```

### Step 3: Create Flask Application

Create `app/app.py`:

```python
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import time
import random

# Create Flask app
app = Flask(__name__)

# ============================================
# PROMETHEUS METRICS
# ============================================

# Counter: Counts events (always increases)
request_count = Counter(
    'app_requests_total',
    'Total number of requests',
    ['method', 'endpoint', 'status']
)

# Histogram: Measures distribution (response times)
request_duration = Histogram(
    'app_request_duration_seconds',
    'Request duration in seconds',
    ['method', 'endpoint']
)

# Gauge: Current value (can go up or down)
active_requests = Gauge(
    'app_active_requests',
    'Number of active requests'
)

# Error counter
error_count = Counter(
    'app_errors_total',
    'Total number of errors',
    ['endpoint', 'error_type']
)

# ============================================
# MIDDLEWARE - Track all requests
# ============================================

@app.before_request
def before_request():
    """Called before each request"""
    request.start_time = time.time()
    active_requests.inc()  # Increase active requests

@app.after_request
def after_request(response):
    """Called after each request"""
    # Calculate request duration
    duration = time.time() - request.start_time
    
    # Record metrics
    request_count.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
    
    request_duration.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).observe(duration)
    
    active_requests.dec()  # Decrease active requests
    
    return response

# ============================================
# APPLICATION ENDPOINTS
# ============================================

@app.route('/')
def home():
    """Home page - fast response"""
    return jsonify({
        'message': 'Welcome to APM Monitoring Demo!',
        'endpoints': {
            '/': 'Home page',
            '/api/users': 'Get users (fast)',
            '/api/slow': 'Slow endpoint (2-5 seconds)',
            '/api/error': 'Error endpoint (50% chance)',
            '/metrics': 'Prometheus metrics'
        }
    })

@app.route('/api/users')
def get_users():
    """Fast endpoint - returns user list"""
    users = [
        {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
        {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'}
    ]
    return jsonify(users)

@app.route('/api/slow')
def slow_endpoint():
    """Slow endpoint - simulates database query"""
    # Simulate slow operation (2-5 seconds)
    delay = random.uniform(2, 5)
    time.sleep(delay)
    
    return jsonify({
        'message': f'This took {delay:.2f} seconds',
        'data': 'Some heavy computation result'
    })

@app.route('/api/error')
def error_endpoint():
    """Error endpoint - 50% chance of error"""
    if random.random() < 0.5:
        # Record error
        error_count.labels(
            endpoint='/api/error',
            error_type='random_error'
        ).inc()
        
        return jsonify({'error': 'Random error occurred!'}), 500
    
    return jsonify({'message': 'Success!'})

@app.route('/api/database')
def database_query():
    """Simulates database query with variable response time"""
    # Simulate database query (0.1 - 1 second)
    delay = random.uniform(0.1, 1.0)
    time.sleep(delay)
    
    return jsonify({
        'query': 'SELECT * FROM users',
        'rows': 100,
        'duration_ms': delay * 1000
    })

# ============================================
# METRICS ENDPOINT (for Prometheus)
# ============================================

@app.route('/metrics')
def metrics():
    """Expose metrics for Prometheus to scrape"""
    return generate_latest()

# ============================================
# HEALTH CHECK
# ============================================

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'})

# ============================================
# RUN APPLICATION
# ============================================

if __name__ == '__main__':
    print("🚀 Starting Flask app with Prometheus metrics...")
    print("📊 Metrics available at: http://localhost:5000/metrics")
    print("🏠 Home page at: http://localhost:5000/")
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**What each metric does:**

```python
# Counter - Always increases
request_count.labels(method='GET', endpoint='/api/users', status=200).inc()
# Result: app_requests_total{method="GET",endpoint="/api/users",status="200"} 150

# Histogram - Tracks distribution
request_duration.labels(method='GET', endpoint='/api/users').observe(0.05)
# Result: Shows how many requests took 0-50ms, 50-100ms, etc.

# Gauge - Current value
active_requests.inc()  # Increase by 1
active_requests.dec()  # Decrease by 1
# Result: app_active_requests 5 (5 requests happening right now)
```

Create `app/requirements.txt`:

```txt
Flask==3.0.0
prometheus-client==0.19.0
```

Create `app/Dockerfile`:

```dockerfile
# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
```

### Step 4: Configure Prometheus

Create `prometheus/prometheus.yml`:

```yaml
# Prometheus Configuration

# Global settings
global:
  scrape_interval: 15s      # How often to collect metrics
  evaluation_interval: 15s  # How often to evaluate rules

# Scrape configurations
scrape_configs:
  # Monitor Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Monitor Flask application
  - job_name: 'flask-app'
    scrape_interval: 5s  # Collect every 5 seconds
    static_configs:
      - targets: ['flask-app:5000']  # flask-app is Docker service name
    metrics_path: '/metrics'  # Where to get metrics
```

**What this means:**

```yaml
scrape_interval: 15s
# Prometheus will collect metrics every 15 seconds

job_name: 'flask-app'
# Name for this monitoring job

targets: ['flask-app:5000']
# Where to collect metrics from
# flask-app = Docker service name
# 5000 = Flask app port

metrics_path: '/metrics'
# URL path where metrics are exposed
# Full URL: http://flask-app:5000/metrics
```

### Step 5: Create Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # ============================================
  # Flask Application
  # ============================================
  flask-app:
    build: ./app
    container_name: flask-app
    ports:
      - "5000:5000"  # Access at http://localhost:5000
    networks:
      - monitoring
    restart: unless-stopped

  # ============================================
  # Prometheus (Metrics Collection)
  # ============================================
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"  # Access at http://localhost:9090
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - monitoring
    restart: unless-stopped

  # ============================================
  # Grafana (Dashboards)
  # ============================================
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"  # Access at http://localhost:3000
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin  # Default password
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - prometheus

# ============================================
# Networks
# ============================================
networks:
  monitoring:
    driver: bridge

# ============================================
# Volumes (Persistent Storage)
# ============================================
volumes:
  prometheus-data:
  grafana-data:
```

**What each service does:**

```
flask-app:5000
├─ Your Python application
├─ Exposes metrics at /metrics
└─ Handles user requests

prometheus:9090
├─ Collects metrics from flask-app
├─ Stores time-series data
└─ Provides query interface

grafana:3000
├─ Connects to Prometheus
├─ Creates beautiful dashboards
└─ Shows real-time metrics
```

### Step 6: Start Everything

```bash
# Make sure you're in apm-monitoring-demo directory
cd apm-monitoring-demo

# Start all services
docker-compose up -d

# Check if everything is running
docker-compose ps

# You should see:
# NAME         STATUS    PORTS
# flask-app    Up        0.0.0.0:5000->5000/tcp
# prometheus   Up        0.0.0.0:9090->9090/tcp
# grafana      Up        0.0.0.0:3000->3000/tcp
```

**View logs:**

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f flask-app
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

---

## 🎮 Using the System

### 1. Test Flask Application

**Open browser:**

```
http://localhost:5000
```

**Test endpoints:**

```bash
# Home page
curl http://localhost:5000/

# Fast endpoint
curl http://localhost:5000/api/users

# Slow endpoint (takes 2-5 seconds)
curl http://localhost:5000/api/slow

# Error endpoint (50% chance of error)
curl http://localhost:5000/api/error

# Database query
curl http://localhost:5000/api/database
```

**Generate traffic (run this in terminal):**

```bash
# Install hey (load testing tool)
# Mac:
brew install hey

# Linux:
go install github.com/rakyll/hey@latest

# Generate 1000 requests
hey -n 1000 -c 10 http://localhost:5000/api/users

# Explanation:
# -n 1000: Total 1000 requests
# -c 10: 10 concurrent requests
# Result: Generates realistic traffic for monitoring
```

**Or use this simple bash script:**

```bash
# Create traffic generator
cat > generate_traffic.sh << 'EOF'
#!/bin/bash
echo "Generating traffic..."
while true; do
  curl -s http://localhost:5000/api/users > /dev/null
  curl -s http://localhost:5000/api/slow > /dev/null
  curl -s http://localhost:5000/api/error > /dev/null
  curl -s http://localhost:5000/api/database > /dev/null
  sleep 1
done
EOF

chmod +x generate_traffic.sh
./generate_traffic.sh
```

### 2. View Raw Metrics

**Open browser:**

```
http://localhost:5000/metrics
```

**You'll see:**

```
# HELP app_requests_total Total number of requests
# TYPE app_requests_total counter
app_requests_total{endpoint="/api/users",method="GET",status="200"} 150.0

# HELP app_request_duration_seconds Request duration in seconds
# TYPE app_request_duration_seconds histogram
app_request_duration_seconds_bucket{endpoint="/api/users",method="GET",le="0.005"} 120.0
app_request_duration_seconds_bucket{endpoint="/api/users",method="GET",le="0.01"} 145.0
app_request_duration_seconds_sum{endpoint="/api/users",method="GET"} 7.5
app_request_duration_seconds_count{endpoint="/api/users",method="GET"} 150.0

# HELP app_active_requests Number of active requests
# TYPE app_active_requests gauge
app_active_requests 2.0

# HELP app_errors_total Total number of errors
# TYPE app_errors_total counter
app_errors_total{endpoint="/api/error",error_type="random_error"} 25.0
```

**What this means:**

```
app_requests_total{...} 150.0
→ 150 requests to /api/users endpoint

app_request_duration_seconds_sum 7.5
app_request_duration_seconds_count 150
→ Average response time = 7.5 / 150 = 0.05 seconds (50ms)

app_active_requests 2.0
→ 2 requests being processed right now

app_errors_total 25.0
→ 25 errors occurred
```

### 3. Query Metrics in Prometheus

**Open Prometheus:**

```
http://localhost:9090
```

**Try these queries:**

**1. Request Rate (requests per second):**

```promql
rate(app_requests_total[1m])
```

Shows: How many requests per second in last 1 minute

**2. Average Response Time:**

```promql
rate(app_request_duration_seconds_sum[5m])
/
rate(app_request_duration_seconds_count[5m])
```

Shows: Average response time in last 5 minutes

**3. Error Rate:**

```promql
rate(app_errors_total[5m])
```

Shows: Errors per second

**4. 95th Percentile Response Time:**

```promql
histogram_quantile(0.95,
  rate(app_request_duration_seconds_bucket[5m])
)
```

Shows: 95% of requests complete within this time

**5. Active Requests:**

```promql
app_active_requests
```

Shows: Current number of active requests

**6. Success Rate:**

```promql
sum(rate(app_requests_total{status="200"}[5m]))
/
sum(rate(app_requests_total[5m]))
* 100
```

Shows: Percentage of successful requests

### 4. Create Grafana Dashboard

**Step 1: Login to Grafana**

```
URL: http://localhost:3000
Username: admin
Password: admin
(Change password when prompted)
```

**Step 2: Add Prometheus Data Source**

1. Click ⚙️ (Settings) → Data Sources
2. Click "Add data source"
3. Select "Prometheus"
4. Set URL: `http://prometheus:9090`
5. Click "Save & Test"
6. Should see: ✅ "Data source is working"

**Step 3: Create Dashboard**

1. Click + → Dashboard
2. Click "Add visualization"
3. Select "Prometheus" data source

**Panel 1: Request Rate**

```
Title: Requests per Second
Query: rate(app_requests_total[1m])
Visualization: Time series
Legend: {{endpoint}} - {{method}}
```

**Panel 2: Response Time**

```
Title: Average Response Time
Query: 
  rate(app_request_duration_seconds_sum[5m])
  /
  rate(app_request_duration_seconds_count[5m])
Visualization: Time series
Unit: seconds (s)
```

**Panel 3: Error Rate**

```
Title: Errors per Second
Query: rate(app_errors_total[5m])
Visualization: Time series
Color: Red
```

**Panel 4: Active Requests**

```
Title: Active Requests
Query: app_active_requests
Visualization: Gauge
Min: 0
Max: 100
```

**Panel 5: Success Rate**

```
Title: Success Rate
Query:
  sum(rate(app_requests_total{status="200"}[5m]))
  /
  sum(rate(app_requests_total[5m]))
  * 100
Visualization: Stat
Unit: percent (0-100)
Thresholds: 
  - Red: < 95
  - Yellow: 95-99
  - Green: > 99
```

**Panel 6: Request Distribution by Endpoint**

```
Title: Requests by Endpoint
Query: sum by (endpoint) (rate(app_requests_total[5m]))
Visualization: Pie chart
```

**Save Dashboard:**

1. Click 💾 (Save dashboard)
2. Name: "Flask App Monitoring"
3. Click "Save"

---

## 📊 Understanding the Metrics

### Request Count (Counter)

**What it tracks:**

```
Every time someone visits your app, counter increases

Visit 1: app_requests_total = 1
Visit 2: app_requests_total = 2
Visit 3: app_requests_total = 3
...
```

**Why it's useful:**

- See traffic patterns (busy hours vs quiet hours)
- Detect traffic spikes
- Plan capacity

**Example:**

```
Morning (9 AM): 100 requests/minute
Afternoon (2 PM): 500 requests/minute ← Traffic spike!
Evening (8 PM): 50 requests/minute
```

### Response Time (Histogram)

**What it tracks:**

```
How long each request takes

Request 1: 50ms
Request 2: 100ms
Request 3: 200ms
Request 4: 45ms

Average: (50 + 100 + 200 + 45) / 4 = 98.75ms
P95: 95% of requests complete within 200ms
```

**Why it's useful:**

- Find slow endpoints
- Set SLOs (e.g., "95% of requests < 200ms")
- Detect performance degradation

**Example:**

```
/api/users: Average 50ms ✅ Fast
/api/slow: Average 3000ms ❌ Slow - needs optimization!
```

### Active Requests (Gauge)

**What it tracks:**

```
How many requests are being processed RIGHT NOW

Time 10:00: 5 active requests
Time 10:01: 10 active requests ← Traffic increasing
Time 10:02: 3 active requests ← Traffic decreasing
```

**Why it's useful:**

- Detect if server is overloaded
- See real-time load
- Trigger auto-scaling

**Example:**

```
Normal: 5-10 active requests
Spike: 100 active requests ← Need more servers!
```

### Error Rate (Counter)

**What it tracks:**

```
How many requests fail

Success: 200 OK
Error: 500 Internal Server Error ← Count this!
Success: 200 OK
Error: 404 Not Found ← Count this!

Error rate = 2 errors / 4 requests = 50%
```

**Why it's useful:**

- Detect bugs in production
- Alert when error rate spikes
- Track reliability (SLO: < 0.1% errors)

**Example:**

```
Normal: 0.01% error rate (1 error per 10,000 requests)
Problem: 5% error rate ← Something is broken!
```

---

## 🚨 Setting Up Alerts

### Create Alert Rules in Prometheus

Create `prometheus/alert_rules.yml`:

```yaml
groups:
  - name: flask_app_alerts
    interval: 30s
    rules:
      # Alert: High Error Rate
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(app_errors_total[5m]))
            /
            sum(rate(app_requests_total[5m]))
          ) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}. Threshold is 5%."

      # Alert: Slow Response Time
      - alert: SlowResponseTime
        expr: |
          (
            rate(app_request_duration_seconds_sum[5m])
            /
            rate(app_request_duration_seconds_count[5m])
          ) > 1.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow response time detected"
          description: "Average response time is {{ $value }}s. Threshold is 1s."

      # Alert: High Traffic
      - alert: HighTraffic
        expr: sum(rate(app_requests_total[1m])) > 100
        for: 2m
        labels:
          severity: info
        annotations:
          summary: "High traffic detected"
          description: "Request rate is {{ $value }} req/s. Threshold is 100 req/s."

      # Alert: Service Down
      - alert: ServiceDown
        expr: up{job="flask-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Flask app is down"
          description: "Flask app has been down for more than 1 minute."
```

**Update `prometheus/prometheus.yml`:**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Add alert rules
rule_files:
  - /etc/prometheus/alert_rules.yml

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'flask-app'
    scrape_interval: 5s
    static_configs:
      - targets: ['flask-app:5000']
    metrics_path: '/metrics'
```

**Update `docker-compose.yml` to include alert rules:**

```yaml
prometheus:
  image: prom/prometheus:latest
  container_name: prometheus
  ports:
    - "9090:9090"
  volumes:
    - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    - ./prometheus/alert_rules.yml:/etc/prometheus/alert_rules.yml  # Add this
    - prometheus-data:/prometheus
  command:
    - '--config.file=/etc/prometheus/prometheus.yml'
    - '--storage.tsdb.path=/prometheus'
  networks:
    - monitoring
  restart: unless-stopped
```

**Restart Prometheus:**

```bash
docker-compose restart prometheus
```

**View Alerts:**

```
http://localhost:9090/alerts
```

---

## 🎓 Interview Questions & Answers

### Q1: What is APM and why is it important?

**Answer:**

```
"APM (Application Performance Monitoring) tracks how applications perform in production.

It's important because:
1. Detects issues before users complain
2. Helps find performance bottlenecks
3. Enables data-driven decisions
4. Supports SLO/SLA compliance

For example, if response time suddenly increases from 100ms to 2 seconds,
APM alerts us immediately so we can investigate and fix it."
```

### Q2: What metrics would you monitor for a web application?

**Answer:**

```
"I would monitor these key metrics:

1. Request Rate (throughput)
   - How many requests per second
   - Helps with capacity planning

2. Response Time (latency)
   - Average, P95, P99 response times
   - Ensures good user experience

3. Error Rate
   - Percentage of failed requests
   - Tracks reliability

4. Resource Usage
   - CPU, memory, disk
   - Prevents resource exhaustion

5. Availability
   - Uptime percentage
   - Meets SLA requirements

These are often called 'Golden Signals' or 'RED metrics' 
(Rate, Errors, Duration)."
```

### Q3: Explain Prometheus architecture

**Answer:**

```
"Prometheus uses a pull-based model:

1. Applications expose metrics at /metrics endpoint
2. Prometheus scrapes (pulls) metrics periodically
3. Metrics are stored in time-series database
4. PromQL queries retrieve and analyze data
5. Alertmanager handles alerts

Key components:
- Prometheus Server: Collects and stores metrics
- Exporters: Expose metrics from systems
- Alertmanager: Manages alerts
- Grafana: Visualizes data

Example: Every 15 seconds, Prometheus pulls metrics from 
http://flask-app:5000/metrics and stores them."
```

### Q4: What's the difference between Counter, Gauge, and Histogram?

**Answer:**

```
"These are Prometheus metric types:

Counter:
- Always increases (never decreases)
- Example: Total requests, total errors
- Use case: Count events over time
- Query: rate(counter[5m]) for rate per second

Gauge:
- Can go up or down
- Example: Active requests, memory usage, temperature
- Use case: Current state
- Query: gauge (no rate needed)

Histogram:
- Tracks distribution of values
- Example: Response times
- Use case: Calculate percentiles (P95, P99)
- Query: histogram_quantile(0.95, histogram)

Example:
- request_count (Counter): 1000 total requests
- active_requests (Gauge): 5 requests right now
- request_duration (Histogram): P95 = 200ms"
```

### Q5: How would you troubleshoot high response time?

**Answer:**

```
"I would follow this approach:

1. Check Grafana dashboard
   - Identify which endpoint is slow
   - Check if it's consistent or spike

2. Query Prometheus
   - Compare current vs historical response times
   - Check if specific endpoints are affected

3. Investigate potential causes:
   - High CPU/memory usage
   - Slow database queries
   - External API timeouts
   - Network issues

4. Use APM traces (if available)
   - See where time is spent
   - Identify bottleneck (DB, API, code)

5. Take action:
   - Optimize slow queries
   - Add caching
   - Scale resources
   - Fix inefficient code

6. Monitor improvement
   - Verify response time returns to normal
   - Update runbook for future

Example: If /api/users is slow, I'd check database query time,
add indexes if needed, and implement caching."
```

---

## 🎯 Practice Exercises

### Exercise 1: Add Custom Metric

Add a metric to track database query count:

```python
# In app.py, add this metric
db_queries = Counter(
    'app_database_queries_total',
    'Total database queries',
    ['query_type']
)

# In database_query endpoint
@app.route('/api/database')
def database_query():
    db_queries.labels(query_type='select').inc()  # Add this
    delay = random.uniform(0.1, 1.0)
    time.sleep(delay)
    return jsonify({...})
```

### Exercise 2: Create Alert for High CPU

Add alert rule:

```yaml
- alert: HighCPU
  expr: process_cpu_seconds_total > 0.8
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage"
    description: "CPU usage is {{ $value }}%"
```

### Exercise 3: Build Custom Dashboard

Create dashboard with:

1. Request rate by endpoint
2. Error rate trend
3. Response time heatmap
4. Top 5 slowest endpoints

---

## 🔧 Troubleshooting

### Problem: Prometheus not scraping metrics

**Check:**

```bash
# 1. Is Flask app running?
curl http://localhost:5000/metrics

# 2. Check Prometheus targets
# Open: http://localhost:9090/targets
# Should show flask-app as UP

# 3. Check Prometheus logs
docker-compose logs prometheus

# 4. Verify network connectivity
docker exec prometheus ping flask-app
```

### Problem: Grafana shows "No data"

**Check:**

```bash
# 1. Is Prometheus data source configured?
# Grafana → Settings → Data Sources

# 2. Test query in Prometheus first
# http://localhost:9090

# 3. Check time range in Grafana
# Make sure it's "Last 5 minutes" or "Last 1 hour"

# 4. Verify metrics exist
curl http://localhost:5000/metrics | grep app_requests
```

### Problem: Metrics not updating

**Check:**

```bash
# 1. Generate traffic
curl http://localhost:5000/api/users

# 2. Check if counter increases
curl http://localhost:5000/metrics | grep app_requests_total

# 3. Wait for Prometheus scrape (15 seconds)

# 4. Query in Prometheus
# rate(app_requests_total[1m])
```

---

## 🎉 Congratulations

You've built a complete APM monitoring system! You now know:

✅ What APM is and why it's important
✅ How to instrument Python applications with Prometheus
✅ How to collect and store metrics
✅ How to create Grafana dashboards
✅ How to set up alerts
✅ How to troubleshoot performance issues

**Next Steps:**

1. Add more custom metrics
2. Create more complex dashboards
3. Set up Alertmanager for notifications
4. Try with your own applications
5. Learn about distributed tracing (Jaeger, Zipkin)

**Clean Up:**

```bash
# Stop all services
docker-compose down

# Remove volumes (deletes data)
docker-compose down -v
```

**Keep Learning:**

- Prometheus documentation: prometheus.io
- Grafana tutorials: grafana.com/tutorials
- Practice with real applications

You're now ready to discuss APM in interviews! 🚀
