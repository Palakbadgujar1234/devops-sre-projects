# 🔧 Grafana Troubleshooting Guide

Complete guide to fixing common Grafana issues when setting up monitoring with Prometheus.

---

## 🚨 Issue 1: "Connection Refused" Error

### Error Message

```
Post "http://localhost:9091/api/v1/query": dial tcp [::1]:9091: connect: connection refused
There was an error returned querying the Prometheus API.
```

### Root Cause

Grafana is trying to connect to `localhost:9091`, but inside Docker, `localhost` refers to the Grafana container itself, not your Mac or other containers!

### ✅ Solution

**Change the Prometheus URL from:**

```
http://localhost:9091  ❌ WRONG
```

**To:**

```
http://prometheus:9090  ✅ CORRECT
```

**Steps:**

1. In Grafana, go to **Configuration** → **Data Sources**
2. Click on your Prometheus data source
3. Find the **"URL"** field
4. Change it to: `http://prometheus:9090`
5. Scroll down and click **"Save & test"**
6. You should see: ✅ **"Data source is working"**

### Why This Works

**Docker Networking Explained:**

When containers are in the same Docker network:

- ✅ Use **container names** as hostnames
- ✅ Use **internal ports** (not mapped ports)
- ❌ Cannot use `localhost` to reach other containers

**Your Setup:**

```
Mac (your computer)
  ↓
  localhost:9091 → Prometheus (external access)
  localhost:3000 → Grafana (external access)
  localhost:5000 → Flask (external access)

Inside Docker Network:
  prometheus:9090 → Prometheus (internal)
  grafana:3000 → Grafana (internal)
  flask-app:5000 → Flask (internal)
```

**From your Mac browser:**

- ✅ `http://localhost:9091` → Reaches Prometheus
- ✅ `http://localhost:3000` → Reaches Grafana

**From inside Grafana container:**

- ❌ `http://localhost:9091` → Tries to reach Grafana itself (fails!)
- ✅ `http://prometheus:9090` → Reaches Prometheus container

---

## 🚨 Issue 2: "No Data" in Panels

### Symptoms

- Dashboard loads successfully
- Panels show "No data"
- Queries return empty results

### Possible Causes & Solutions

#### Cause 1: No Traffic Generated

**Problem:** Flask app has no requests yet, so no metrics exist.

**Solution:**

```bash
# Generate some traffic
for i in {1..20}; do
  curl -s http://localhost:5000/api/users > /dev/null
  echo "✅ Request $i"
  sleep 0.5
done

# Wait for Prometheus to scrape
sleep 10
```

#### Cause 2: Wrong Time Range

**Problem:** Looking at wrong time period.

**Solution:**

1. Click time range selector (top right)
2. Select **"Last 5 minutes"** or **"Last 15 minutes"**
3. Click **"Apply"**

#### Cause 3: Wrong Query

**Problem:** Query syntax error or metric doesn't exist.

**Solution:**

1. Go to Prometheus UI: `http://localhost:9091`
2. Test your query there first
3. If it works in Prometheus, copy to Grafana
4. If it doesn't work, check metric name

**Common queries:**

```promql
# Request rate
rate(app_requests_total[1m])

# Active requests
app_active_requests

# Error rate
rate(app_errors_total[5m])

# Average response time
rate(app_request_duration_seconds_sum[1m]) / rate(app_request_duration_seconds_count[1m])
```

#### Cause 4: Prometheus Not Scraping

**Problem:** Prometheus target is DOWN.

**Solution:**

1. Check Prometheus targets: `http://localhost:9091/targets`
2. If flask-app is DOWN, see "Prometheus Target DOWN" section below

---

## 🚨 Issue 3: Prometheus Target DOWN

### Error in Prometheus Targets Page

```
flask-app: DOWN
Error: received unsupported Content-Type "text/html; charset=utf-8"
```

### Root Cause

Flask app is returning HTML instead of Prometheus metrics format.

### ✅ Solution

**Check Flask /metrics endpoint:**

```bash
# Test from your Mac
curl -I http://localhost:5000/metrics

# Should see:
# Content-Type: text/plain; version=0.0.4; charset=utf-8
```

**If you see `Content-Type: text/html`, fix the Flask app:**

```python
# app.py - Make sure you have this:
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}
```

**Rebuild and restart:**

```bash
cd ~/Desktop/apm-monitoring-demo
docker compose up -d --build flask-app
sleep 10
curl -I http://localhost:5000/metrics
```

---

## 🚨 Issue 4: Can't Login to Grafana

### Default Credentials

**Username:** `admin`  
**Password:** `admin`

### If Password Was Changed

**Reset it:**

```bash
# Stop Grafana
docker stop grafana

# Remove Grafana data volume
docker volume rm apm-monitoring-demo_grafana-data

# Restart
docker compose up -d grafana

# Login with admin/admin again
```

---

## 🚨 Issue 5: Dashboard Not Updating

### Symptoms

- Dashboard shows old data
- Metrics not refreshing

### Solutions

#### Enable Auto-Refresh

1. Click **refresh icon** dropdown (top right)
2. Select **"5s"** or **"10s"**
3. Dashboard will auto-refresh

#### Check Time Range

1. Click time range selector (top right)
2. Make sure it's set to recent time (e.g., "Last 5 minutes")
3. Click **"Refresh"** icon

#### Generate New Traffic

```bash
# Generate continuous traffic
while true; do
  curl -s http://localhost:5000/api/users > /dev/null
  echo "✅ $(date +%H:%M:%S)"
  sleep 2
done
```

---

## 🚨 Issue 6: "Bad Gateway" or "502" Error

### Root Cause

Grafana container is not running or crashed.

### Solution

```bash
# Check if Grafana is running
docker ps | grep grafana

# If not running, check logs
docker logs grafana

# Restart Grafana
docker restart grafana

# Or restart everything
docker compose restart
```

---

## 🚨 Issue 7: Panels Show "Error" or "Bad Request"

### Cause 1: Invalid PromQL Query

**Solution:**

1. Test query in Prometheus first: `http://localhost:9091`
2. Fix syntax errors
3. Copy working query to Grafana

**Common mistakes:**

```promql
# ❌ Wrong
rate(app_requests_total)  # Missing time range

# ✅ Correct
rate(app_requests_total[1m])  # Has time range
```

### Cause 2: Metric Doesn't Exist

**Solution:**

1. Go to Prometheus: `http://localhost:9091`
2. Click **"Graph"**
3. Start typing metric name
4. Use autocomplete to find correct name

---

## 🚨 Issue 8: Can't Add Data Source

### Error: "Data source with the same name already exists"

**Solution:**

1. Go to **Configuration** → **Data Sources**
2. Find existing Prometheus data source
3. Either:
   - **Option A:** Edit the existing one
   - **Option B:** Delete it and create new one

---

## 🚨 Issue 9: Grafana Shows "Unauthorized"

### Root Cause

Data source authentication issue.

### Solution

**For Prometheus (no auth needed):**

1. Edit data source
2. Scroll to **"Auth"** section
3. Make sure **all auth options are OFF**:
   - ❌ Basic auth
   - ❌ TLS Client Auth
   - ❌ Skip TLS Verify
   - ❌ Forward OAuth Identity
4. Click **"Save & test"**

---

## 🚨 Issue 10: Port Already in Use

### Error When Starting Grafana

```
Error: bind: address already in use
```

### Solution

**Check what's using port 3000:**

```bash
lsof -i :3000
```

**Option A: Stop the other service**

```bash
# If it's another Docker container
docker stop <container-name>
```

**Option B: Change Grafana port**

```yaml
# docker-compose.yml
services:
  grafana:
    ports:
      - "3001:3000"  # Use port 3001 instead
```

Then access Grafana at: `http://localhost:3001`

---

## 🔍 Diagnostic Commands

### Check All Containers

```bash
docker ps
```

**Expected output:**

```
flask-app    Up    0.0.0.0:5000->5000/tcp
prometheus   Up    0.0.0.0:9091->9090/tcp
grafana      Up    0.0.0.0:3000->3000/tcp
```

### Check Grafana Logs

```bash
docker logs grafana --tail 50
```

### Check Prometheus Connection from Grafana

```bash
# Test from inside Grafana container
docker exec grafana wget -O- http://prometheus:9090/api/v1/query?query=up
```

### Check Network

```bash
# List networks
docker network ls

# Inspect monitoring network
docker network inspect apm-monitoring-demo_monitoring
```

### Test Prometheus API

```bash
# From your Mac
curl "http://localhost:9091/api/v1/query?query=up"

# Should return JSON with results
```

---

## 🎯 Quick Fixes Checklist

When Grafana isn't working, check these in order:

- [ ] Is Grafana container running? (`docker ps`)
- [ ] Can you access Grafana UI? (`http://localhost:3000`)
- [ ] Can you login? (admin/admin)
- [ ] Is Prometheus URL correct? (`http://prometheus:9090`)
- [ ] Is Prometheus target UP? (`http://localhost:9091/targets`)
- [ ] Does Flask return metrics? (`curl http://localhost:5000/metrics`)
- [ ] Have you generated traffic? (curl Flask endpoints)
- [ ] Is time range correct? (Last 5-15 minutes)
- [ ] Is auto-refresh enabled? (5s or 10s)
- [ ] Are queries valid? (Test in Prometheus first)

---

## 🎓 Understanding Docker Networking (Interview Gold!)

### Port Mapping Explained

**docker-compose.yml:**

```yaml
services:
  prometheus:
    ports:
      - "9091:9090"
```

**What this means:**

- **9091** = External port (from your Mac)
- **9090** = Internal port (inside container)

**Access patterns:**

```
From Mac browser:
  http://localhost:9091 → Prometheus

From Grafana container:
  http://prometheus:9090 → Prometheus

From Prometheus container:
  http://flask-app:5000 → Flask
```

### Container Name Resolution

**Docker provides built-in DNS:**

- Service name in docker-compose.yml becomes hostname
- All containers on same network can resolve these names
- No need for IP addresses!

**Example:**

```yaml
services:
  prometheus:    # Hostname: prometheus
  grafana:       # Hostname: grafana
  flask-app:     # Hostname: flask-app
```

---

## 🎤 Interview Answers

### "Why use prometheus:9090 instead of localhost:9091?"

> "In Docker, each container has its own network namespace. When Grafana tries to connect to 'localhost', it's referring to itself, not other containers.
>
> Docker provides built-in DNS for container-to-container communication. When containers are on the same network, they can reach each other using service names as hostnames.
>
> The port mapping '9091:9090' only affects external access from the host. Internal communication uses the internal port (9090) directly.
>
> So from my Mac, I use localhost:9091, but from Grafana container, I use prometheus:9090."

### "How would you troubleshoot Grafana showing no data?"

> "I would follow a systematic approach:
>
> 1. **Verify data source connection** - Check if Prometheus data source shows 'working' status
> 2. **Test in Prometheus first** - Go to Prometheus UI and test the query there
> 3. **Check time range** - Ensure I'm looking at the right time period
> 4. **Verify metrics exist** - Confirm the application has generated metrics
> 5. **Check Prometheus targets** - Ensure Prometheus is successfully scraping the application
> 6. **Review query syntax** - Validate PromQL syntax is correct
> 7. **Check logs** - Review Grafana and Prometheus logs for errors
>
> This methodical approach helps isolate whether the issue is with data collection, storage, or visualization."

---

## 📚 Additional Resources

- **[README.md](README.md)** - Complete tutorial
- **[STEP-BY-STEP-SETUP.md](STEP-BY-STEP-SETUP.md)** - Setup guide
- **[CODE-EXPLAINED.md](CODE-EXPLAINED.md)** - Code explanation
- **[QUICK-FIX.md](QUICK-FIX.md)** - Prometheus fixes
- **[FINAL-FIX.md](FINAL-FIX.md)** - Advanced troubleshooting

---

## 🆘 Still Having Issues?

**Run this diagnostic script:**

```bash
#!/bin/bash
echo "🔍 Grafana Diagnostics"
echo "===================="
echo ""

echo "1️⃣ Container Status"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "2️⃣ Grafana Logs (last 10 lines)"
docker logs grafana --tail 10
echo ""

echo "3️⃣ Test Prometheus from Grafana"
docker exec grafana wget -O- http://prometheus:9090/api/v1/query?query=up 2>&1 | head -5
echo ""

echo "4️⃣ Test Flask Metrics"
curl -I http://localhost:5000/metrics | grep -i content-type
echo ""

echo "5️⃣ Prometheus Targets"
echo "Check: http://localhost:9091/targets"
echo ""

echo "✅ Diagnostics complete!"
```

**Save as `diagnose-grafana.sh`, make executable, and run:**

```bash
chmod +x diagnose-grafana.sh
./diagnose-grafana.sh
```

---

## 🎉 Success Checklist

Once everything is working, you should have:

- ✅ Grafana accessible at `http://localhost:3000`
- ✅ Login with admin/admin works
- ✅ Prometheus data source shows "working"
- ✅ Can create dashboards
- ✅ Panels show live data
- ✅ Auto-refresh updates every 5-10 seconds
- ✅ Queries return results
- ✅ Time range selector works
- ✅ Can customize visualizations

**Congratulations! Your monitoring system is fully operational!** 🚀
