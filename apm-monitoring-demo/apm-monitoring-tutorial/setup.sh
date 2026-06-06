#!/bin/bash

# APM Monitoring Setup Script
# This script creates all necessary files for the monitoring tutorial

set -e  # Exit on error

echo "🚀 Setting up APM Monitoring Tutorial..."
echo ""

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p app prometheus grafana/dashboards

# Create Flask application
echo "🐍 Creating Flask application..."
cat > app/app.py << 'EOF'
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import time
import random

app = Flask(__name__)

# Prometheus Metrics
request_count = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
request_duration = Histogram('app_request_duration_seconds', 'Request duration', ['method', 'endpoint'])
active_requests = Gauge('app_active_requests', 'Active requests')
error_count = Counter('app_errors_total', 'Total errors', ['endpoint', 'error_type'])

@app.before_request
def before_request():
    request.start_time = time.time()
    active_requests.inc()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    request_count.labels(method=request.method, endpoint=request.endpoint or 'unknown', status=response.status_code).inc()
    request_duration.labels(method=request.method, endpoint=request.endpoint or 'unknown').observe(duration)
    active_requests.dec()
    return response

@app.route('/')
def home():
    return jsonify({
        'message': 'Welcome to APM Monitoring Demo!',
        'endpoints': {
            '/': 'Home page',
            '/api/users': 'Get users (fast)',
            '/api/slow': 'Slow endpoint (2-5 seconds)',
            '/api/error': 'Error endpoint (50% chance)',
            '/api/database': 'Database query simulation',
            '/metrics': 'Prometheus metrics',
            '/health': 'Health check'
        }
    })

@app.route('/api/users')
def get_users():
    users = [
        {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
        {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'}
    ]
    return jsonify(users)

@app.route('/api/slow')
def slow_endpoint():
    delay = random.uniform(2, 5)
    time.sleep(delay)
    return jsonify({'message': f'This took {delay:.2f} seconds', 'data': 'Heavy computation result'})

@app.route('/api/error')
def error_endpoint():
    if random.random() < 0.5:
        error_count.labels(endpoint='/api/error', error_type='random_error').inc()
        return jsonify({'error': 'Random error occurred!'}), 500
    return jsonify({'message': 'Success!'})

@app.route('/api/database')
def database_query():
    delay = random.uniform(0.1, 1.0)
    time.sleep(delay)
    return jsonify({'query': 'SELECT * FROM users', 'rows': 100, 'duration_ms': delay * 1000})

@app.route('/metrics')
def metrics():
    return generate_latest()

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    print("🚀 Starting Flask app with Prometheus metrics...")
    print("📊 Metrics: http://localhost:5000/metrics")
    print("🏠 Home: http://localhost:5000/")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

# Create requirements.txt
echo "📦 Creating requirements.txt..."
cat > app/requirements.txt << 'EOF'
Flask==3.0.0
prometheus-client==0.19.0
EOF

# Create Dockerfile
echo "🐳 Creating Dockerfile..."
cat > app/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF

# Create Prometheus configuration
echo "📊 Creating Prometheus configuration..."
cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

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
EOF

# Create alert rules
echo "🚨 Creating alert rules..."
cat > prometheus/alert_rules.yml << 'EOF'
groups:
  - name: flask_app_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: |
          (sum(rate(app_errors_total[5m])) / sum(rate(app_requests_total[5m]))) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: SlowResponseTime
        expr: |
          (rate(app_request_duration_seconds_sum[5m]) / rate(app_request_duration_seconds_count[5m])) > 1.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow response time"
          description: "Average response time is {{ $value }}s"

      - alert: ServiceDown
        expr: up{job="flask-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Flask app is down"
          description: "Flask app has been down for more than 1 minute"
EOF

# Create docker-compose.yml
echo "🐳 Creating docker-compose.yml..."
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
    restart: unless-stopped

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

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus-data:
  grafana-data:
EOF

# Create traffic generator script
echo "🚦 Creating traffic generator..."
cat > generate_traffic.sh << 'EOF'
#!/bin/bash
echo "🚦 Generating traffic to Flask app..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
  curl -s http://localhost:5000/api/users > /dev/null && echo "✅ /api/users"
  sleep 0.5
  curl -s http://localhost:5000/api/database > /dev/null && echo "✅ /api/database"
  sleep 0.5
  curl -s http://localhost:5000/api/error > /dev/null && echo "✅ /api/error"
  sleep 0.5
  curl -s http://localhost:5000/api/slow > /dev/null && echo "✅ /api/slow"
  sleep 1
done
EOF

chmod +x generate_traffic.sh

# Create README with quick start
echo "📝 Creating quick start guide..."
cat > QUICKSTART.md << 'EOF'
# 🚀 Quick Start Guide

## Start the System

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

## Access the Services

- **Flask App:** http://localhost:5000
- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3000 (admin/admin)

## Generate Traffic

```bash
# In a new terminal
./generate_traffic.sh
```

## View Metrics

1. **Raw Metrics:** http://localhost:5000/metrics
2. **Prometheus Queries:** http://localhost:9090/graph
3. **Grafana Dashboards:** http://localhost:3000

## Useful Commands

```bash
# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart a service
docker-compose restart flask-app

# Remove everything including data
docker-compose down -v
```

## Sample Prometheus Queries

```promql
# Request rate
rate(app_requests_total[1m])

# Average response time
rate(app_request_duration_seconds_sum[5m]) / rate(app_request_duration_seconds_count[5m])

# Error rate
rate(app_errors_total[5m])

# Active requests
app_active_requests
```

## Grafana Setup

1. Login: http://localhost:3000 (admin/admin)
2. Add Data Source:
   - Settings → Data Sources → Add Prometheus
   - URL: http://prometheus:9090
   - Save & Test
3. Create Dashboard:
   - + → Dashboard → Add visualization
   - Use the queries above

## Troubleshooting

```bash
# Check if services are running
docker-compose ps

# View service logs
docker-compose logs flask-app
docker-compose logs prometheus
docker-compose logs grafana

# Test Flask app
curl http://localhost:5000/health

# Test Prometheus
curl http://localhost:9090/-/healthy
```
EOF

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "1. Read README.md for detailed tutorial"
echo "2. Read QUICKSTART.md for quick commands"
echo "3. Run: docker-compose up -d"
echo "4. Open: http://localhost:5000"
echo ""
echo "🎉 Happy monitoring!"

# Made with Bob
