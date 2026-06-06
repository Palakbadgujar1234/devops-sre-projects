# 📖 Complete Code Explanation - Line by Line

This guide explains EVERY line of code in the APM monitoring tutorial. Perfect for complete beginners!

---

## 📄 File 1: app.py (Flask Application)

### Import Statements

```python
from flask import Flask, jsonify, request
```

**Explanation:**

- `from flask import` - Get tools from Flask library
- `Flask` - Main Flask class to create web application
- `jsonify` - Converts Python data to JSON format (for API responses)
- `request` - Access information about incoming HTTP requests

**Example:**

```python
# Without jsonify:
return {'name': 'Alice'}  # Returns Python dict

# With jsonify:
return jsonify({'name': 'Alice'})  # Returns proper JSON response
```

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest
```

**Explanation:**

- `prometheus_client` - Library to create Prometheus metrics
- `Counter` - Metric that only increases (like odometer in car)
- `Histogram` - Metric that tracks distribution (like speed ranges)
- `Gauge` - Metric that can go up or down (like fuel gauge)
- `generate_latest` - Function to export metrics in Prometheus format

```python
import time
```

**Explanation:**

- `time` - Python's built-in time library
- Used to measure how long things take
- Used to add delays (simulate slow operations)

```python
import random
```

**Explanation:**

- `random` - Python's built-in random number library
- Used to simulate unpredictable behavior (random delays, random errors)

### Create Flask Application

```python
app = Flask(__name__)
```

**Explanation:**

- `Flask(__name__)` - Creates a new Flask web application
- `__name__` - Special Python variable (name of current file)
- `app` - Variable that holds our web application

**Think of it as:**

```
Flask(__name__) = "Create a new restaurant"
app = "Your restaurant object"
```

### Define Prometheus Metrics

```python
request_count = Counter(
    'app_requests_total',
    'Total number of requests',
    ['method', 'endpoint', 'status']
)
```

**Explanation Line by Line:**

- `request_count =` - Variable name (we'll use this in code)
- `Counter(` - Create a Counter metric (always increases)
- `'app_requests_total'` - Metric name (shown in Prometheus)
- `'Total number of requests'` - Description (helps others understand)
- `['method', 'endpoint', 'status']` - Labels (categories for grouping)

**Labels Explained:**

```python
# Without labels:
request_count = 150  # Just a number

# With labels:
request_count{method="GET", endpoint="/api/users", status="200"} = 100
request_count{method="POST", endpoint="/api/users", status="201"} = 50
# Now we can see breakdown by method, endpoint, and status!
```

```python
request_duration = Histogram(
    'app_request_duration_seconds',
    'Request duration in seconds',
    ['method', 'endpoint']
)
```

**Explanation:**

- `Histogram` - Tracks distribution of values
- `'app_request_duration_seconds'` - Metric name
- `'Request duration in seconds'` - Description
- `['method', 'endpoint']` - Labels to categorize

**What Histogram Does:**

```
Tracks how many requests took:
- 0-10ms: 50 requests
- 10-50ms: 80 requests
- 50-100ms: 15 requests
- 100-500ms: 5 requests
- >500ms: 0 requests

This helps find slow requests!
```

```python
active_requests = Gauge(
    'app_active_requests',
    'Number of active requests'
)
```

**Explanation:**

- `Gauge` - Can increase or decrease (current value)
- `'app_active_requests'` - Metric name
- No labels needed (just tracks total active requests)

**How Gauge Works:**

```
Request 1 starts: active_requests = 1
Request 2 starts: active_requests = 2
Request 1 ends:   active_requests = 1
Request 2 ends:   active_requests = 0
```

```python
error_count = Counter(
    'app_errors_total',
    'Total number of errors',
    ['endpoint', 'error_type']
)
```

**Explanation:**

- Another Counter (for tracking errors)
- Labels: `endpoint` (which URL) and `error_type` (what kind of error)

### Middleware Functions

```python
@app.before_request
def before_request():
```

**Explanation:**

- `@app.before_request` - Decorator (runs before EVERY request)
- `def before_request():` - Function definition
- This function runs automatically before handling any URL

**Flow:**

```
User visits /api/users
    ↓
before_request() runs first  ← We are here
    ↓
/api/users handler runs
    ↓
after_request() runs last
    ↓
Response sent to user
```

```python
    request.start_time = time.time()
```

**Explanation:**

- `time.time()` - Gets current time in seconds (e.g., 1704067200.123)
- `request.start_time =` - Saves this time to request object
- We'll use this later to calculate how long request took

**Example:**

```python
# When request starts:
request.start_time = 1704067200.123

# When request ends (2 seconds later):
current_time = 1704067202.123
duration = current_time - request.start_time
# duration = 2.0 seconds
```

```python
    active_requests.inc()
```

**Explanation:**

- `active_requests` - Our Gauge metric
- `.inc()` - Increase by 1
- Tracks that one more request is being processed

**Example:**

```python
# Before: active_requests = 5
active_requests.inc()
# After: active_requests = 6
```

```python
@app.after_request
def after_request(response):
```

**Explanation:**

- `@app.after_request` - Runs after EVERY request
- `def after_request(response):` - Function that receives response object
- `response` - The response we're about to send to user

```python
    duration = time.time() - request.start_time
```

**Explanation:**

- `time.time()` - Current time
- `request.start_time` - Time when request started (saved earlier)
- `duration` - How long request took (in seconds)

**Example:**

```python
# Request started at: 1704067200.123
# Request ending at:  1704067200.173
duration = 1704067200.173 - 1704067200.123
# duration = 0.05 seconds (50 milliseconds)
```

```python
    request_count.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
```

**Explanation Line by Line:**

- `request_count` - Our Counter metric
- `.labels(` - Set label values
- `method=request.method` - HTTP method (GET, POST, etc.)
- `endpoint=request.endpoint or 'unknown'` - URL endpoint (or 'unknown' if None)
- `status=response.status_code` - HTTP status (200, 404, 500, etc.)
- `.inc()` - Increase counter by 1

**What `or 'unknown'` means:**

```python
# If endpoint exists:
endpoint = '/api/users' or 'unknown'  # Result: '/api/users'

# If endpoint is None:
endpoint = None or 'unknown'  # Result: 'unknown'
```

**Result in Prometheus:**

```
app_requests_total{method="GET", endpoint="/api/users", status="200"} 1
```

```python
    request_duration.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).observe(duration)
```

**Explanation:**

- `request_duration` - Our Histogram metric
- `.labels(...)` - Set label values
- `.observe(duration)` - Record this duration value

**What `.observe()` does:**

```python
# Records each request duration:
request_duration.observe(0.05)  # 50ms
request_duration.observe(0.12)  # 120ms
request_duration.observe(0.03)  # 30ms

# Prometheus creates buckets:
# 0-50ms: 2 requests
# 50-100ms: 0 requests
# 100-200ms: 1 request
```

```python
    active_requests.dec()
```

**Explanation:**

- `.dec()` - Decrease by 1
- Request is finished, so reduce active count

**Example:**

```python
# Before: active_requests = 6
active_requests.dec()
# After: active_requests = 5
```

```python
    return response
```

**Explanation:**

- `return response` - Send response back to user
- Must return response in `after_request` function

### Application Endpoints

```python
@app.route('/')
def home():
```

**Explanation:**

- `@app.route('/')` - This function handles requests to homepage (/)
- `def home():` - Function name
- When user visits <http://localhost:5000/>, this function runs

**How Routes Work:**

```python
@app.route('/')          → http://localhost:5000/
@app.route('/api/users') → http://localhost:5000/api/users
@app.route('/health')    → http://localhost:5000/health
```

```python
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
```

**Explanation:**

- `jsonify({...})` - Convert Python dictionary to JSON
- `'message': '...'` - Welcome message
- `'endpoints': {...}` - Dictionary of available URLs

**What User Sees:**

```json
{
  "message": "Welcome to APM Monitoring Demo!",
  "endpoints": {
    "/": "Home page",
    "/api/users": "Get users (fast)",
    ...
  }
}
```

```python
@app.route('/api/users')
def get_users():
```

**Explanation:**

- Handles requests to `/api/users`
- Returns list of users

```python
    users = [
        {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
        {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'}
    ]
```

**Explanation:**

- `users = [...]` - Create a list
- Each `{...}` is a dictionary representing one user
- In real app, this would come from database

```python
    return jsonify(users)
```

**Explanation:**

- Convert list to JSON and return
- User receives JSON array of users

```python
@app.route('/api/slow')
def slow_endpoint():
```

**Explanation:**

- Simulates a slow operation (like heavy database query)

```python
    delay = random.uniform(2, 5)
```

**Explanation:**

- `random.uniform(2, 5)` - Random number between 2 and 5
- `delay` - How many seconds to wait

**Example:**

```python
delay = random.uniform(2, 5)
# Could be: 2.3, 3.7, 4.1, 2.9, etc.
```

```python
    time.sleep(delay)
```

**Explanation:**

- `time.sleep(delay)` - Pause execution for `delay` seconds
- Simulates slow operation (database query, API call, etc.)

**What Happens:**

```
User makes request
    ↓
delay = 3.5 seconds
    ↓
time.sleep(3.5)  ← Program pauses here for 3.5 seconds
    ↓
Return response (after 3.5 seconds)
```

```python
    return jsonify({
        'message': f'This took {delay:.2f} seconds',
        'data': 'Some heavy computation result'
    })
```

**Explanation:**

- `f'...'` - f-string (formatted string)
- `{delay:.2f}` - Insert delay value with 2 decimal places
- `.2f` means "2 decimal places" (e.g., 3.50)

**Example:**

```python
delay = 3.456789
f'This took {delay:.2f} seconds'
# Result: "This took 3.46 seconds"
```

```python
@app.route('/api/error')
def error_endpoint():
```

**Explanation:**

- Simulates random errors (50% chance)

```python
    if random.random() < 0.5:
```

**Explanation:**

- `random.random()` - Random number between 0 and 1
- `< 0.5` - If less than 0.5 (50% chance)

**How It Works:**

```python
random.random() = 0.3  → 0.3 < 0.5 → True → Error!
random.random() = 0.7  → 0.7 < 0.5 → False → Success!
random.random() = 0.1  → 0.1 < 0.5 → True → Error!
random.random() = 0.9  → 0.9 < 0.5 → False → Success!
```

```python
        error_count.labels(
            endpoint='/api/error',
            error_type='random_error'
        ).inc()
```

**Explanation:**

- Increase error counter
- Label it with endpoint and error type

```python
        return jsonify({'error': 'Random error occurred!'}), 500
```

**Explanation:**

- `jsonify({...})` - JSON response
- `, 500` - HTTP status code 500 (Internal Server Error)

**HTTP Status Codes:**

```
200 = Success
404 = Not Found
500 = Server Error
```

```python
    return jsonify({'message': 'Success!'})
```

**Explanation:**

- If no error (50% chance), return success
- Default status code is 200 (success)

```python
@app.route('/api/database')
def database_query():
```

**Explanation:**

- Simulates database query with variable response time

```python
    delay = random.uniform(0.1, 1.0)
```

**Explanation:**

- Random delay between 0.1 and 1.0 seconds
- Simulates database query time

```python
    time.sleep(delay)
```

**Explanation:**

- Pause for `delay` seconds

```python
    return jsonify({
        'query': 'SELECT * FROM users',
        'rows': 100,
        'duration_ms': delay * 1000
    })
```

**Explanation:**

- `'query': '...'` - SQL query (fake, for demo)
- `'rows': 100` - Number of rows returned (fake)
- `delay * 1000` - Convert seconds to milliseconds

**Example:**

```python
delay = 0.5 seconds
delay * 1000 = 500 milliseconds
```

```python
@app.route('/metrics')
def metrics():
```

**Explanation:**

- Special endpoint for Prometheus
- Returns all metrics in Prometheus format

```python
    return generate_latest()
```

**Explanation:**

- `generate_latest()` - Function from prometheus_client
- Generates metrics in Prometheus text format

**What It Returns:**

```
# HELP app_requests_total Total number of requests
# TYPE app_requests_total counter
app_requests_total{method="GET",endpoint="/api/users",status="200"} 150.0
...
```

```python
@app.route('/health')
def health():
```

**Explanation:**

- Health check endpoint
- Used by load balancers to check if app is alive

```python
    return jsonify({'status': 'healthy'})
```

**Explanation:**

- Simple response indicating app is running

```python
if __name__ == '__main__':
```

**Explanation:**

- `if __name__ == '__main__':` - Only run if script is executed directly
- Not run if imported as module

**When This Runs:**

```bash
python app.py  ← Runs this block
```

**When This Doesn't Run:**

```python
import app  ← Doesn't run this block
```

```python
    print("🚀 Starting Flask app with Prometheus metrics...")
    print("📊 Metrics available at: http://localhost:5000/metrics")
    print("🏠 Home page at: http://localhost:5000/")
```

**Explanation:**

- `print()` - Display messages in terminal
- Helpful information for user

```python
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**Explanation:**

- `app.run()` - Start the Flask web server
- `host='0.0.0.0'` - Listen on all network interfaces
- `port=5000` - Use port 5000
- `debug=True` - Enable debug mode (auto-reload, detailed errors)

**What Each Parameter Means:**

```python
host='0.0.0.0'
# Means: Accept connections from anywhere
# localhost (127.0.0.1) ✅
# Your computer's IP (192.168.1.100) ✅
# Docker container ✅

host='127.0.0.1'
# Means: Only accept connections from localhost
# localhost ✅
# Other computers ❌

port=5000
# Means: Listen on port 5000
# Access at: http://localhost:5000

debug=True
# Means:
# - Auto-reload when code changes
# - Show detailed error messages
# - Don't use in production!
```

---

## 📄 File 2: requirements.txt

```txt
Flask==3.0.0
prometheus-client==0.19.0
```

**Explanation:**

- `Flask==3.0.0` - Install Flask version 3.0.0
- `prometheus-client==0.19.0` - Install prometheus-client version 0.19.0
- `==` means "exact version"

**Why Specify Versions:**

```
Without version:
Flask  ← Could install any version (might break!)

With version:
Flask==3.0.0  ← Always installs 3.0.0 (consistent!)
```

**How to Install:**

```bash
pip install -r requirements.txt
```

---

## 📄 File 3: Dockerfile

```dockerfile
FROM python:3.11-slim
```

**Explanation:**

- `FROM` - Start with this base image
- `python:3.11-slim` - Python 3.11 minimal image
- `slim` = Smaller size (no unnecessary packages)

**Image Sizes:**

```
python:3.11        → 1GB (full OS + Python)
python:3.11-slim   → 150MB (minimal OS + Python)
python:3.11-alpine → 50MB (very minimal)
```

```dockerfile
WORKDIR /app
```

**Explanation:**

- `WORKDIR` - Set working directory
- `/app` - All commands run in /app directory
- Creates directory if it doesn't exist

**What This Does:**

```bash
# Without WORKDIR:
RUN ls  # Lists files in /

# With WORKDIR /app:
RUN ls  # Lists files in /app
```

```dockerfile
COPY requirements.txt .
```

**Explanation:**

- `COPY` - Copy file from host to container
- `requirements.txt` - Source file (on your computer)
- `.` - Destination (current directory = /app)

**Full Path:**

```
From: /your/computer/app/requirements.txt
To:   /app/requirements.txt (in container)
```

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

**Explanation:**

- `RUN` - Execute command during build
- `pip install` - Install Python packages
- `--no-cache-dir` - Don't save cache (smaller image)
- `-r requirements.txt` - Install from requirements file

**What `--no-cache-dir` Does:**

```
With cache:
Image size: 200MB (includes pip cache)

Without cache:
Image size: 150MB (no cache saved)
```

```dockerfile
COPY app.py .
```

**Explanation:**

- Copy app.py from host to container
- Destination: /app/app.py

```dockerfile
EXPOSE 5000
```

**Explanation:**

- `EXPOSE` - Document that container uses port 5000
- Doesn't actually open port (just documentation)
- Actual port mapping done in docker-compose.yml

**Note:**

```dockerfile
EXPOSE 5000  ← Just documentation

# Actual port opening:
docker run -p 5000:5000 myapp  ← This opens port
```

```dockerfile
CMD ["python", "app.py"]
```

**Explanation:**

- `CMD` - Command to run when container starts
- `["python", "app.py"]` - Run: python app.py
- Array format (preferred over string)

**Array vs String:**

```dockerfile
# Array format (preferred):
CMD ["python", "app.py"]

# String format:
CMD python app.py

# Why array is better:
# - No shell interpretation
# - Signals handled correctly
# - More predictable
```

---

## 📄 File 4: prometheus.yml

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
```

**Explanation:**

- `global:` - Global settings for Prometheus
- `scrape_interval: 15s` - Collect metrics every 15 seconds
- `evaluation_interval: 15s` - Evaluate alert rules every 15 seconds

**What This Means:**

```
Time 0s:  Collect metrics from all targets
Time 15s: Collect metrics again
Time 30s: Collect metrics again
...

Every 15 seconds:
1. Scrape metrics from targets
2. Evaluate alert rules
3. Store data
```

```yaml
rule_files:
  - /etc/prometheus/alert_rules.yml
```

**Explanation:**

- `rule_files:` - List of alert rule files
- `/etc/prometheus/alert_rules.yml` - Path to rules file

```yaml
scrape_configs:
```

**Explanation:**

- `scrape_configs:` - List of targets to monitor
- Each target is a "job"

```yaml
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

**Explanation:**

- `job_name: 'prometheus'` - Name for this monitoring job
- `static_configs:` - Static list of targets (not auto-discovered)
- `targets: ['localhost:9090']` - Monitor Prometheus itself

**What This Does:**

```
Every 15 seconds:
1. Connect to localhost:9090
2. GET http://localhost:9090/metrics
3. Parse metrics
4. Store in database
```

```yaml
  - job_name: 'flask-app'
    scrape_interval: 5s
    static_configs:
      - targets: ['flask-app:5000']
    metrics_path: '/metrics'
```

**Explanation:**

- `job_name: 'flask-app'` - Name for Flask app monitoring
- `scrape_interval: 5s` - Override global (collect every 5 seconds)
- `targets: ['flask-app:5000']` - Flask app location
- `metrics_path: '/metrics'` - URL path for metrics

**Why `flask-app` not `localhost`:**

```
In Docker:
- flask-app = Docker service name (DNS resolves to container)
- localhost = Prometheus container itself (wrong!)

Outside Docker:
- localhost:5000 = Flask app (correct)
```

**Full URL:**

```
http://flask-app:5000/metrics
```

---

## 📄 File 5: alert_rules.yml

```yaml
groups:
  - name: flask_app_alerts
    interval: 30s
    rules:
```

**Explanation:**

- `groups:` - List of alert rule groups
- `name: flask_app_alerts` - Group name
- `interval: 30s` - Evaluate these rules every 30 seconds
- `rules:` - List of alert rules

```yaml
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
          description: "Error rate is {{ $value | humanizePercentage }}"
```

**Explanation Line by Line:**

```yaml
- alert: HighErrorRate
```

- `alert:` - Name of this alert
- `HighErrorRate` - Alert name (shown in Prometheus)

```yaml
expr: |
```

- `expr:` - PromQL expression (query)
- `|` - Multi-line string

```yaml
(
  sum(rate(app_errors_total[5m]))
  /
  sum(rate(app_requests_total[5m]))
) > 0.05
```

**Breaking Down the Query:**

```promql
rate(app_errors_total[5m])
```

- `app_errors_total` - Error counter metric
- `[5m]` - Look at last 5 minutes
- `rate()` - Calculate rate per second

**Example:**

```
Errors in last 5 minutes: 15
Time period: 300 seconds
Rate: 15 / 300 = 0.05 errors/second
```

```promql
sum(rate(app_errors_total[5m]))
```

- `sum()` - Add up all values
- Combines all endpoints into one number

```promql
sum(rate(app_errors_total[5m]))
/
sum(rate(app_requests_total[5m]))
```

- Divide errors by total requests
- Result: Error rate (percentage)

**Example:**

```
Errors per second: 0.05
Requests per second: 1.0
Error rate: 0.05 / 1.0 = 0.05 (5%)
```

```promql
> 0.05
```

- Alert if error rate > 5%

```yaml
for: 2m
```

- `for: 2m` - Must be true for 2 minutes before alerting
- Prevents false alarms from temporary spikes

**How It Works:**

```
Time 0:00 - Error rate 6% (above threshold)
Time 0:30 - Error rate 6% (still above)
Time 1:00 - Error rate 6% (still above)
Time 1:30 - Error rate 6% (still above)
Time 2:00 - Error rate 6% (2 minutes passed) → ALERT! 🚨
```

```yaml
labels:
  severity: critical
```

- `labels:` - Add labels to alert
- `severity: critical` - Mark as critical priority

**Severity Levels:**

```
critical → Page on-call engineer immediately
warning  → Send notification, investigate soon
info     → Just log it, no immediate action
```

```yaml
annotations:
  summary: "High error rate detected"
  description: "Error rate is {{ $value | humanizePercentage }}"
```

- `annotations:` - Human-readable information
- `summary:` - Short description
- `description:` - Detailed description
- `{{ $value }}` - Insert actual value
- `| humanizePercentage` - Format as percentage

**Example Alert:**

```
Summary: High error rate detected
Description: Error rate is 7.5%
```

---

## 📄 File 6: docker-compose.yml

```yaml
version: '3.8'
```

**Explanation:**

- `version: '3.8'` - Docker Compose file format version
- Use features from version 3.8

```yaml
services:
```

**Explanation:**

- `services:` - List of containers to run
- Each service = one container

```yaml
  flask-app:
    build: ./app
    container_name: flask-app
    ports:
      - "5000:5000"
    networks:
      - monitoring
    restart: unless-stopped
```

**Explanation Line by Line:**

```yaml
flask-app:
```

- Service name (used for DNS in Docker network)

```yaml
build: ./app
```

- `build:` - Build image from Dockerfile
- `./app` - Directory containing Dockerfile

**What This Does:**

```bash
# Equivalent to:
cd ./app
docker build -t flask-app .
```

```yaml
container_name: flask-app
```

- `container_name:` - Name for the container
- `flask-app` - Container name (shown in `docker ps`)

```yaml
ports:
  - "5000:5000"
```

- `ports:` - Port mapping
- `"5000:5000"` - Map host port 5000 to container port 5000

**Port Mapping Format:**

```yaml
"HOST:CONTAINER"
"5000:5000"  → localhost:5000 → container:5000
"8080:5000"  → localhost:8080 → container:5000
```

```yaml
networks:
  - monitoring
```

- `networks:` - Connect to these networks
- `monitoring` - Network name (defined at bottom)

**Why Networks:**

```
Without network:
flask-app → Can't reach prometheus

With network:
flask-app → Can reach prometheus by name
```

```yaml
restart: unless-stopped
```

- `restart:` - Restart policy
- `unless-stopped` - Always restart unless manually stopped

**Restart Policies:**

```
no              → Never restart
always          → Always restart (even after reboot)
on-failure      → Restart only if crashed
unless-stopped  → Restart unless manually stopped
```

```yaml
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/alert_rules.yml:/etc/prometheus/alert_rules.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - monitoring
    restart: unless-stopped
```

**Explanation:**

```yaml
image: prom/prometheus:latest
```

- `image:` - Use pre-built image (don't build)
- `prom/prometheus:latest` - Official Prometheus image, latest version

```yaml
volumes:
  - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
```

- `volumes:` - Mount files/directories
- `HOST:CONTAINER` format
- `./prometheus/prometheus.yml` - File on your computer
- `/etc/prometheus/prometheus.yml` - File in container

**What This Does:**

```
Your computer:          Container:
prometheus.yml    →     /etc/prometheus/prometheus.yml
                        (Prometheus reads this file)
```

```yaml
- prometheus-data:/prometheus
```

- `prometheus-data` - Named volume (persistent storage)
- `/prometheus` - Mount point in container

**Why Named Volume:**

```
Without volume:
Container deleted → Data lost! ❌

With volume:
Container deleted → Data preserved! ✅
```

```yaml
command:
  - '--config.file=/etc/prometheus/prometheus.yml'
  - '--storage.tsdb.path=/prometheus'
```

- `command:` - Override default command
- `--config.file=...` - Config file location
- `--storage.tsdb.path=...` - Where to store data

**Equivalent to:**

```bash
prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus
```

```yaml
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - prometheus
```

**Explanation:**

```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=admin
  - GF_USERS_ALLOW_SIGN_UP=false
```

- `environment:` - Environment variables
- `GF_SECURITY_ADMIN_PASSWORD=admin` - Set admin password
- `GF_USERS_ALLOW_SIGN_UP=false` - Disable user registration

**Environment Variables:**

```
Inside container:
echo $GF_SECURITY_ADMIN_PASSWORD
# Output: admin

Grafana reads these variables on startup
```

```yaml
depends_on:
  - prometheus
```

- `depends_on:` - Start order
- `prometheus` - Start Prometheus before Grafana

**Start Order:**

```
1. Start prometheus
2. Wait for prometheus to be ready
3. Start grafana
```

```yaml
networks:
  monitoring:
    driver: bridge
```

**Explanation:**

- `networks:` - Define networks
- `monitoring:` - Network name
- `driver: bridge` - Network type

**What Bridge Network Does:**

```
Creates virtual network where containers can talk:

flask-app:5000  ←→  prometheus:9090  ←→  grafana:3000
     ↓                    ↓                    ↓
All connected via "monitoring" network
```

```yaml
volumes:
  prometheus-data:
  grafana-data:
```

**Explanation:**

- `volumes:` - Define named volumes
- `prometheus-data:` - Volume for Prometheus data
- `grafana-data:` - Volume for Grafana data

**Where Data is Stored:**

```
Docker manages these volumes:
/var/lib/docker/volumes/prometheus-data
/var/lib/docker/volumes/grafana-data

You don't need to know exact path!
Docker handles it automatically.
```

---

## 🎓 Summary

### Key Concepts Explained

**1. Flask Application**

- Creates web server
- Handles HTTP requests
- Returns JSON responses

**2. Prometheus Metrics**

- Counter: Always increases (requests, errors)
- Gauge: Can go up/down (active requests)
- Histogram: Tracks distribution (response times)

**3. Docker**

- Dockerfile: Instructions to build image
- docker-compose.yml: Run multiple containers together
- Volumes: Persistent storage
- Networks: Container communication

**4. Prometheus**

- Scrapes metrics from /metrics endpoint
- Stores time-series data
- Evaluates alert rules

**5. Grafana**

- Connects to Prometheus
- Creates dashboards
- Visualizes metrics

### How Everything Works Together

```
1. Flask app exposes metrics at /metrics
2. Prometheus scrapes metrics every 5 seconds
3. Prometheus stores metrics in database
4. Prometheus evaluates alert rules
5. Grafana queries Prometheus
6. Grafana displays dashboards
7. You see beautiful graphs! 📊
```

### Common Patterns

**Error Handling:**

```python
try:
    # Do something
except Exception as e:
    error_count.inc()
    return error_response
```

**Timing Operations:**

```python
start = time.time()
# Do something
duration = time.time() - start
request_duration.observe(duration)
```

**Conditional Logic:**

```python
if condition:
    # Do this
else:
    # Do that
```

---

## 🎯 Next Steps

Now that you understand every line:

1. **Run the code** - See it in action
2. **Modify it** - Change values, add features
3. **Break it** - Learn by fixing errors
4. **Extend it** - Add your own metrics

**Remember:** The best way to learn is by doing! 🚀
