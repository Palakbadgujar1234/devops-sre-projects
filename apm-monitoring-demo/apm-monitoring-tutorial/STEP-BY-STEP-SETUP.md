# 🎯 Complete Step-by-Step Setup Guide for Beginners

**Welcome!** This guide will walk you through EVERY step to set up the APM monitoring system on your laptop. No VM needed, everything runs locally!

**Time Required:** 30-45 minutes
**What You Need:** Just your laptop and internet connection

---

## 📋 What We'll Do Today

```
Step 1: Install Docker Desktop (10 min)
    ↓
Step 2: Verify Installation (2 min)
    ↓
Step 3: Create Project Files (5 min)
    ↓
Step 4: Start the System (5 min)
    ↓
Step 5: Test Everything Works (10 min)
    ↓
Step 6: Create Your First Dashboard (10 min)
    ↓
🎉 Success! You have a working monitoring system!
```

---

## 🚀 STEP 1: Install Docker Desktop

### What is Docker?

Docker lets you run applications in containers (like lightweight virtual machines). We need it to run Prometheus, Grafana, and our Flask app.

### For Windows

**Step 1.1: Download Docker Desktop**

1. Open your web browser
2. Go to: <https://www.docker.com/products/docker-desktop>
3. Click "Download for Windows"
4. Wait for download to complete (about 500MB)

**Step 1.2: Install Docker Desktop**

1. Find the downloaded file (usually in Downloads folder)
2. Double-click `Docker Desktop Installer.exe`
3. Click "OK" when asked about WSL 2
4. Wait for installation (5-10 minutes)
5. Click "Close and restart" when done
6. Your computer will restart

**Step 1.3: Start Docker Desktop**

1. After restart, Docker Desktop should start automatically
2. If not, search for "Docker Desktop" in Start menu and open it
3. Accept the terms and conditions
4. Wait for Docker to start (you'll see a whale icon in system tray)
5. When whale icon stops animating, Docker is ready!

### For Mac

**Step 1.1: Download Docker Desktop**

1. Open Safari or Chrome
2. Go to: <https://www.docker.com/products/docker-desktop>
3. Click "Download for Mac"
4. Choose:
   - "Mac with Intel chip" (older Macs)
   - "Mac with Apple chip" (M1/M2/M3 Macs)
5. Wait for download (about 500MB)

**Step 1.2: Install Docker Desktop**

1. Open Downloads folder
2. Double-click `Docker.dmg`
3. Drag Docker icon to Applications folder
4. Open Applications folder
5. Double-click Docker
6. Click "Open" when asked
7. Enter your Mac password when prompted
8. Wait for Docker to start

**Step 1.3: Verify Docker is Running**

1. Look for whale icon in menu bar (top right)
2. Click whale icon
3. Should say "Docker Desktop is running"

### For Linux (Ubuntu/Debian)

**Step 1.1: Open Terminal**

1. Press `Ctrl + Alt + T`
2. Terminal window opens

**Step 1.2: Install Docker**
Copy and paste these commands one by one:

```bash
# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Add your user to docker group (so you don't need sudo)
sudo usermod -aG docker $USER

# Log out and log back in for group changes to take effect
echo "Please log out and log back in, then continue to Step 2"
```

---

## ✅ STEP 2: Verify Docker Installation

Let's make sure Docker is working!

### Open Terminal/Command Prompt

**Windows:**

1. Press `Windows key + R`
2. Type `cmd` and press Enter
3. Black window opens (Command Prompt)

**Mac:**

1. Press `Cmd + Space`
2. Type `terminal` and press Enter
3. Terminal window opens

**Linux:**

1. Press `Ctrl + Alt + T`
2. Terminal opens

### Test Docker

**Type this command and press Enter:**

```bash
docker --version
```

**You should see something like:**

```
Docker version 24.0.7, build afdd53b
```

**If you see this, Docker is installed! ✅**

**If you see "command not found":**

- Windows: Restart your computer and try again
- Mac: Make sure Docker Desktop is running (whale icon in menu bar)
- Linux: Log out and log back in

### Test Docker Compose

**Type this command:**

```bash
docker compose version
```

**You should see:**

```
Docker Compose version v2.23.0
```

**Great! Docker is ready! ✅**

---

## 📁 STEP 3: Create Project Files

Now let's create all the files we need!

### Step 3.1: Create Project Folder

**Windows (Command Prompt):**

```cmd
cd Desktop
mkdir apm-monitoring-demo
cd apm-monitoring-demo
```

**Mac/Linux (Terminal):**

```bash
cd ~/Desktop
mkdir apm-monitoring-demo
cd apm-monitoring-demo
```

**What this does:**

- `cd Desktop` - Go to Desktop folder
- `mkdir apm-monitoring-demo` - Create new folder
- `cd apm-monitoring-demo` - Go into that folder

### Step 3.2: Create Folder Structure

**Type these commands:**

**Windows:**

```cmd
mkdir app
mkdir prometheus
mkdir grafana
```

**Mac/Linux:**

```bash
mkdir app prometheus grafana
```

**Your folder structure now looks like:**

```
Desktop/
└── apm-monitoring-demo/
    ├── app/
    ├── prometheus/
    └── grafana/
```

### Step 3.3: Create Flask Application

**Create app.py file:**

**Windows:**

```cmd
notepad app\app.py
```

When Notepad opens, click "Yes" to create new file.

**Mac:**

```bash
nano app/app.py
```

**Linux:**

```bash
nano app/app.py
```

**Copy and paste this code:**

```python
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
    print("🚀 Starting Flask app...")
    print("📊 Metrics: http://localhost:5000/metrics")
    print("🏠 Home: http://localhost:5000/")
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**Save the file:**

- **Windows Notepad:** Click File → Save, then close Notepad
- **Mac/Linux nano:** Press `Ctrl + X`, then `Y`, then `Enter`

### Step 3.4: Create requirements.txt

**Windows:**

```cmd
notepad app\requirements.txt
```

**Mac/Linux:**

```bash
nano app/requirements.txt
```

**Type this:**

```
Flask==3.0.0
prometheus-client==0.19.0
```

**Save and close** (same as before)

### Step 3.5: Create Dockerfile

**Windows:**

```cmd
notepad app\Dockerfile
```

**Mac/Linux:**

```bash
nano app/Dockerfile
```

**Type this:**

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

**Save and close**

### Step 3.6: Create Prometheus Configuration

**Windows:**

```cmd
notepad prometheus\prometheus.yml
```

**Mac/Linux:**

```bash
nano prometheus/prometheus.yml
```

**Type this:**

```yaml
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
    metrics_path: '/metrics'
```

**Save and close**

### Step 3.7: Create docker-compose.yml

**Windows:**

```cmd
notepad docker-compose.yml
```

**Mac/Linux:**

```bash
nano docker-compose.yml
```

**Type this:**

```yaml
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
```

**Save and close**

**✅ All files created!**

---

## 🎬 STEP 4: Start the System

Now let's start everything!

### Step 4.1: Make Sure You're in the Right Folder

**Type this to check:**

**Windows:**

```cmd
cd
```

**Mac/Linux:**

```bash
pwd
```

**You should see:**

```
C:\Users\YourName\Desktop\apm-monitoring-demo    (Windows)
/Users/YourName/Desktop/apm-monitoring-demo      (Mac)
/home/YourName/Desktop/apm-monitoring-demo       (Linux)
```

**If not, go back to the folder:**

```bash
cd ~/Desktop/apm-monitoring-demo    # Mac/Linux
cd Desktop\apm-monitoring-demo      # Windows
```

### Step 4.2: Start Docker Containers

**Type this command:**

```bash
docker compose up -d
```

**What you'll see:**

```
[+] Building 45.2s (10/10) FINISHED
[+] Running 4/4
 ✔ Network apm-monitoring-demo_monitoring    Created
 ✔ Container flask-app                       Started
 ✔ Container prometheus                      Started
 ✔ Container grafana                         Started
```

**This will take 2-5 minutes the first time** (downloading images)

**What `-d` means:**

- `-d` = "detached mode" (runs in background)
- Without `-d`, terminal would be blocked

### Step 4.3: Check if Everything is Running

**Type this:**

```bash
docker compose ps
```

**You should see:**

```
NAME         IMAGE                    STATUS    PORTS
flask-app    apm-monitoring-demo...   Up        0.0.0.0:5000->5000/tcp
prometheus   prom/prometheus:latest   Up        0.0.0.0:9090->9090/tcp
grafana      grafana/grafana:latest   Up        0.0.0.0:3000->3000/tcp
```

**All should say "Up"! ✅**

**If any say "Exited" or "Restarting":**

```bash
# View logs to see what's wrong
docker compose logs flask-app
docker compose logs prometheus
docker compose logs grafana
```

---

## 🧪 STEP 5: Test Everything Works

Let's test each component!

### Test 1: Flask Application

**Open your web browser** (Chrome, Firefox, Safari, Edge)

**Go to:** `http://localhost:5000`

**You should see:**

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

**✅ Flask is working!**

### Test 2: Test Different Endpoints

**In browser, try these URLs:**

1. **<http://localhost:5000/api/users>**
   - Should show list of users instantly

2. **<http://localhost:5000/api/slow>**
   - Takes 2-5 seconds (simulates slow operation)
   - Shows how long it took

3. **<http://localhost:5000/api/error>**
   - 50% chance of error
   - Try multiple times, you'll see both success and error

4. **<http://localhost:5000/metrics>**
   - Shows raw Prometheus metrics
   - Lots of numbers and text

**All working? Great! ✅**

### Test 3: Prometheus

**Go to:** `http://localhost:9090`

**You should see:** Prometheus web interface

**Try a query:**

1. In the search box, type: `app_requests_total`
2. Click "Execute"
3. Click "Graph" tab
4. You should see a graph!

**✅ Prometheus is working!**

### Test 4: Grafana

**Go to:** `http://localhost:3000`

**You should see:** Grafana login page

**Login:**

- Username: `admin`
- Password: `admin`

**First time login:**

- It will ask you to change password
- You can skip this (click "Skip")

**✅ Grafana is working!**

---

## 📊 STEP 6: Create Your First Dashboard

Let's create a beautiful dashboard!

### Step 6.1: Add Prometheus Data Source

1. **In Grafana, click** ⚙️ (gear icon) on left sidebar
2. **Click** "Data sources"
3. **Click** "Add data source"
4. **Click** "Prometheus"
5. **In URL field, type:** `http://prometheus:9090`
6. **Scroll down and click** "Save & test"
7. **You should see:** ✅ "Data source is working"

**✅ Data source added!**

### Step 6.2: Create Dashboard

1. **Click** + (plus icon) on left sidebar
2. **Click** "Dashboard"
3. **Click** "Add visualization"
4. **Select** "Prometheus" data source

### Step 6.3: Create First Panel - Request Rate

**In the query box at bottom:**

1. **Click** "Code" button (top right of query box)
2. **Type this query:**

   ```
   rate(app_requests_total[1m])
   ```

3. **Press** "Run queries" button
4. **You should see a graph!**

**Configure the panel:**

1. **On right side, find "Title"**
2. **Change to:** "Requests per Second"
3. **Click** "Apply" (top right)

**✅ First panel created!**

### Step 6.4: Add More Panels

**Click** "Add" → "Visualization"

**Panel 2: Average Response Time**

- Query: `rate(app_request_duration_seconds_sum[5m]) / rate(app_request_duration_seconds_count[5m])`
- Title: "Average Response Time"
- Unit: seconds (s)

**Panel 3: Active Requests**

- Query: `app_active_requests`
- Title: "Active Requests"
- Visualization: Gauge

**Panel 4: Error Rate**

- Query: `rate(app_errors_total[5m])`
- Title: "Errors per Second"

### Step 6.5: Save Dashboard

1. **Click** 💾 (save icon) at top
2. **Name:** "Flask App Monitoring"
3. **Click** "Save"

**✅ Dashboard created!**

---

## 🚦 STEP 7: Generate Traffic

Let's generate some traffic to see metrics!

### Option 1: Manual Testing (Easy)

**Open browser and visit these URLs multiple times:**

- <http://localhost:5000/api/users>
- <http://localhost:5000/api/slow>
- <http://localhost:5000/api/error>
- <http://localhost:5000/api/database>

**Refresh each URL 10-20 times**

**Go back to Grafana dashboard** - You'll see metrics changing!

### Option 2: Automated Traffic (Better)

**Open a NEW terminal/command prompt** (keep the first one open)

**Windows (PowerShell):**

```powershell
while($true) {
  Invoke-WebRequest -Uri http://localhost:5000/api/users -UseBasicParsing | Out-Null
  Start-Sleep -Seconds 1
  Invoke-WebRequest -Uri http://localhost:5000/api/database -UseBasicParsing | Out-Null
  Start-Sleep -Seconds 1
}
```

**Mac/Linux:**

```bash
while true; do
  curl -s http://localhost:5000/api/users > /dev/null
  sleep 1
  curl -s http://localhost:5000/api/database > /dev/null
  sleep 1
  curl -s http://localhost:5000/api/error > /dev/null
  sleep 1
done
```

**This will generate traffic continuously!**

**To stop:** Press `Ctrl + C`

**Watch your Grafana dashboard** - Metrics are updating in real-time! 📊

---

## 🎉 SUCCESS! What You've Accomplished

### You Now Have

✅ Docker running on your laptop
✅ Flask application with Prometheus metrics
✅ Prometheus collecting metrics every 5 seconds
✅ Grafana dashboard showing real-time data
✅ Complete monitoring system running locally!

### You Can Now

✅ Monitor application performance
✅ See request rates and response times
✅ Track errors in real-time
✅ Create custom dashboards
✅ Understand how APM works

---

## 🛠️ Useful Commands

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f flask-app
docker compose logs -f prometheus
docker compose logs -f grafana
```

### Stop Everything

```bash
docker compose down
```

### Start Again

```bash
docker compose up -d
```

### Restart a Service

```bash
docker compose restart flask-app
```

### Remove Everything (including data)

```bash
docker compose down -v
```

---

## 🐛 Troubleshooting

### Problem: "docker: command not found"

**Solution:**

- Make sure Docker Desktop is running
- Restart your computer
- Reinstall Docker Desktop

### Problem: "Port 5000 is already in use"

**Solution:**

```bash
# Stop whatever is using port 5000
# Windows:
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux:
lsof -i :5000
kill -9 <PID>
```

### Problem: Container keeps restarting

**Solution:**

```bash
# Check logs
docker compose logs flask-app

# Common issues:
# - Syntax error in code
# - Missing file
# - Port already in use
```

### Problem: Can't access <http://localhost:5000>

**Solution:**

1. Check if container is running: `docker compose ps`
2. Check logs: `docker compose logs flask-app`
3. Try: `http://127.0.0.1:5000`
4. Restart: `docker compose restart flask-app`

### Problem: Grafana shows "No data"

**Solution:**

1. Generate traffic first (visit Flask URLs)
2. Wait 30 seconds for metrics to collect
3. Check time range in Grafana (top right)
4. Verify Prometheus data source is working

---

## 📚 What to Do Next

### Today

1. ✅ Explore the Grafana dashboard
2. ✅ Try different Prometheus queries
3. ✅ Generate traffic and watch metrics
4. ✅ Take screenshots for your portfolio

### Tomorrow

1. Read [CODE-EXPLAINED.md](./CODE-EXPLAINED.md) to understand every line
2. Modify the code (add new endpoints)
3. Create more dashboard panels
4. Experiment with different metrics

### This Week

1. Add this project to your GitHub
2. Write a blog post about what you learned
3. Practice explaining it (for interviews)
4. Try applying it to your own projects

---

## 🎓 You Did It

**Congratulations!** 🎉 You've successfully set up a complete APM monitoring system on your laptop!

**You now have:**

- Hands-on experience with Docker
- Working knowledge of Prometheus and Grafana
- A real project for your portfolio
- Confidence to tackle more DevOps tools

**Keep learning and building!** 🚀

---

## 💬 Need Help?

If you get stuck:

1. Check the troubleshooting section above
2. Read the error messages carefully
3. Google the error message
4. Check Docker Desktop logs
5. Try restarting Docker Desktop

**Remember:** Every expert was once a beginner. You're doing great! 💪
