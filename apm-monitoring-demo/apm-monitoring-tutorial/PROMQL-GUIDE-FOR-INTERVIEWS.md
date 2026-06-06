# 📊 PromQL Guide for DevOps Interviews

Complete guide to understanding, writing, and explaining Prometheus queries. No need to memorize - learn the patterns!

---

## 🎯 Do You Need to Memorize Queries?

### ❌ NO! You Don't Need to Memorize

**What you need instead:**

- ✅ Understand the **patterns**
- ✅ Know the **building blocks**
- ✅ Learn the **logic**
- ✅ Practice the **common use cases**

**Think of it like SQL:**

- You don't memorize every SQL query
- You understand SELECT, WHERE, JOIN, GROUP BY
- You combine them based on what you need

**Same with PromQL:**

- You don't memorize every query
- You understand metric types, functions, operators
- You combine them based on what you want to measure

---

## 🧱 Building Blocks of PromQL

### 1. Metric Names (The Foundation)

**What they are:**

```
app_requests_total
app_request_duration_seconds
app_active_requests
app_errors_total
```

**How to find them:**

```bash
# In Prometheus UI (http://localhost:9091)
# Start typing in the query box
# Autocomplete will show available metrics
```

**Naming convention:**

```
<application>_<what_it_measures>_<unit>

Examples:
http_requests_total          # Total HTTP requests
http_request_duration_seconds # Request duration in seconds
node_cpu_seconds_total       # CPU time in seconds
mysql_queries_total          # Total MySQL queries
```

---

### 2. Labels (The Filters)

**What they are:**

```
Labels are key-value pairs that add dimensions to metrics

app_requests_total{endpoint="home", method="GET", status="200"}
                   └─────────────────────────────────────────┘
                              These are labels
```

**Common labels:**

```
endpoint="/api/users"    # Which API endpoint
method="GET"             # HTTP method
status="200"             # HTTP status code
instance="flask-app"     # Which server/container
job="flask-app"          # Which application
```

**How to use them:**

```promql
# Get all requests
app_requests_total

# Get only GET requests
app_requests_total{method="GET"}

# Get only /api/users endpoint
app_requests_total{endpoint="get_users"}

# Get only successful requests (200 status)
app_requests_total{status="200"}

# Combine multiple labels
app_requests_total{method="GET", status="200"}
```

---

### 3. Metric Types (The Categories)

#### Counter (Always Goes Up)

**What it is:**

- Starts at 0
- Only increases
- Resets to 0 on restart

**Examples:**

```
app_requests_total        # Total requests (never decreases)
app_errors_total          # Total errors (never decreases)
http_requests_total       # Total HTTP requests
```

**How to use:**

```promql
# ❌ Don't use raw counter (not useful)
app_requests_total

# ✅ Use rate() to get per-second rate
rate(app_requests_total[1m])
```

**Why rate()?**

```
Time    Counter Value    rate() Result
10:00   100             -
10:01   160             1 req/sec (60 requests in 60 seconds)
10:02   220             1 req/sec (60 requests in 60 seconds)
10:03   340             2 req/sec (120 requests in 60 seconds)
```

#### Gauge (Goes Up and Down)

**What it is:**

- Can increase or decrease
- Represents current value
- Like a thermometer

**Examples:**

```
app_active_requests       # Current active requests
node_memory_usage_bytes   # Current memory usage
temperature_celsius       # Current temperature
```

**How to use:**

```promql
# ✅ Use directly (no rate needed)
app_active_requests

# Can also use functions
avg_over_time(app_active_requests[5m])  # Average over 5 minutes
max_over_time(app_active_requests[1h])  # Maximum in last hour
```

#### Histogram (Distribution)

**What it is:**

- Tracks distribution of values
- Automatically creates buckets
- Used for response times, sizes, etc.

**Examples:**

```
app_request_duration_seconds_bucket  # Response time buckets
app_request_duration_seconds_sum     # Sum of all response times
app_request_duration_seconds_count   # Count of requests
```

**How to use:**

```promql
# Average response time
rate(app_request_duration_seconds_sum[1m]) / 
rate(app_request_duration_seconds_count[1m])

# 95th percentile (95% of requests faster than this)
histogram_quantile(0.95, 
  rate(app_request_duration_seconds_bucket[1m])
)
```

---

## 🔧 Essential PromQL Functions

### 1. rate() - Most Important

**What it does:**

- Calculates per-second rate
- Only for counters
- Smooths out spikes

**Syntax:**

```promql
rate(metric_name[time_range])
```

**Examples:**

```promql
# Requests per second (1 minute average)
rate(app_requests_total[1m])

# Errors per second (5 minute average)
rate(app_errors_total[5m])

# CPU usage rate
rate(node_cpu_seconds_total[2m])
```

**Time ranges explained:**

```
[1m]  = Last 1 minute
[5m]  = Last 5 minutes
[1h]  = Last 1 hour
[1d]  = Last 1 day
```

**Interview tip:**
> "I use rate() to convert cumulative counters into per-second rates, which gives a more meaningful view of current activity. The time range parameter smooths out short-term spikes."

---

### 2. sum() - Add Things Up

**What it does:**

- Adds values together
- Can group by labels

**Examples:**

```promql
# Total requests across all endpoints
sum(app_requests_total)

# Total requests per endpoint
sum by(endpoint) (app_requests_total)

# Total requests per method
sum by(method) (app_requests_total)

# Total requests per endpoint and method
sum by(endpoint, method) (app_requests_total)
```

**Visual example:**

```
Before sum():
app_requests_total{endpoint="home"} = 100
app_requests_total{endpoint="users"} = 200
app_requests_total{endpoint="api"} = 300

After sum():
600

After sum by(endpoint):
{endpoint="home"} = 100
{endpoint="users"} = 200
{endpoint="api"} = 300
```

---

### 3. avg() - Average Values

**What it does:**

- Calculates average
- Can group by labels

**Examples:**

```promql
# Average active requests
avg(app_active_requests)

# Average active requests per instance
avg by(instance) (app_active_requests)

# Average response time
avg(app_request_duration_seconds)
```

---

### 4. max() and min() - Find Extremes

**Examples:**

```promql
# Maximum active requests
max(app_active_requests)

# Minimum response time
min(app_request_duration_seconds)

# Maximum memory usage per pod
max by(pod) (container_memory_usage_bytes)
```

---

### 5. histogram_quantile() - Percentiles

**What it does:**

- Calculates percentiles from histogram
- Shows "X% of requests are faster than this"

**Examples:**

```promql
# 50th percentile (median) - half of requests faster
histogram_quantile(0.50, 
  rate(app_request_duration_seconds_bucket[1m])
)

# 95th percentile - 95% of requests faster
histogram_quantile(0.95, 
  rate(app_request_duration_seconds_bucket[1m])
)

# 99th percentile - 99% of requests faster
histogram_quantile(0.99, 
  rate(app_request_duration_seconds_bucket[1m])
)
```

**Why percentiles matter:**

```
Average response time: 100ms
95th percentile: 500ms

This means:
- Most requests are fast (100ms average)
- But 5% of users experience 500ms+
- Average hides the bad experience!
```

---

## 📝 Common Query Patterns (Learn These!)

### Pattern 1: Request Rate

**Goal:** How many requests per second?

**Query:**

```promql
rate(app_requests_total[1m])
```

**Breakdown:**

- `app_requests_total` = counter of total requests
- `rate()` = convert to per-second rate
- `[1m]` = average over last 1 minute

**Variations:**

```promql
# Per endpoint
rate(app_requests_total{endpoint="users"}[1m])

# Per method
rate(app_requests_total{method="GET"}[1m])

# Total across all labels
sum(rate(app_requests_total[1m]))

# Per endpoint (grouped)
sum by(endpoint) (rate(app_requests_total[1m]))
```

---

### Pattern 2: Error Rate

**Goal:** How many errors per second?

**Query:**

```promql
rate(app_errors_total[5m])
```

**Better - Error Percentage:**

```promql
# Errors as percentage of total requests
(
  rate(app_errors_total[5m])
  /
  rate(app_requests_total[5m])
) * 100
```

**Example result:**

```
2.5  (means 2.5% of requests are errors)
```

---

### Pattern 3: Average Response Time

**Goal:** How long do requests take?

**Query:**

```promql
rate(app_request_duration_seconds_sum[1m])
/
rate(app_request_duration_seconds_count[1m])
```

**Breakdown:**

- `_sum` = total time spent on all requests
- `_count` = number of requests
- `sum / count` = average time per request

**Why two metrics?**

```
Time    Requests    Total Time    Average
10:00   10          5 seconds     0.5s per request
10:01   20          8 seconds     0.4s per request
10:02   5           10 seconds    2.0s per request (slow!)
```

---

### Pattern 4: 95th Percentile Response Time

**Goal:** What response time do 95% of users experience?

**Query:**

```promql
histogram_quantile(0.95,
  rate(app_request_duration_seconds_bucket[1m])
)
```

**Breakdown:**

- `0.95` = 95th percentile
- `_bucket` = histogram buckets
- `rate()` = per-second rate of each bucket

**Other percentiles:**

```promql
# 50th percentile (median)
histogram_quantile(0.50, rate(app_request_duration_seconds_bucket[1m]))

# 90th percentile
histogram_quantile(0.90, rate(app_request_duration_seconds_bucket[1m]))

# 99th percentile (worst case)
histogram_quantile(0.99, rate(app_request_duration_seconds_bucket[1m]))
```

---

### Pattern 5: Current Active Connections

**Goal:** How many requests are being processed right now?

**Query:**

```promql
app_active_requests
```

**That's it!** Gauges don't need rate().

**Variations:**

```promql
# Maximum in last 5 minutes
max_over_time(app_active_requests[5m])

# Average in last 5 minutes
avg_over_time(app_active_requests[5m])

# Per instance
sum by(instance) (app_active_requests)
```

---

### Pattern 6: Traffic Growth

**Goal:** Is traffic increasing or decreasing?

**Query:**

```promql
# Current rate
rate(app_requests_total[5m])

# Rate 1 hour ago
rate(app_requests_total[5m] offset 1h)

# Percentage change
(
  rate(app_requests_total[5m])
  -
  rate(app_requests_total[5m] offset 1h)
)
/
rate(app_requests_total[5m] offset 1h)
* 100
```

**Example result:**

```
25  (means traffic increased by 25%)
-10 (means traffic decreased by 10%)
```

---

### Pattern 7: Success Rate

**Goal:** What percentage of requests succeed?

**Query:**

```promql
(
  sum(rate(app_requests_total{status=~"2.."}[5m]))
  /
  sum(rate(app_requests_total[5m]))
) * 100
```

**Breakdown:**

- `status=~"2.."` = regex for 200-299 (success)
- First sum = successful requests per second
- Second sum = all requests per second
- Result = percentage of successful requests

---

## 🎓 Interview Questions & Answers

### Q1: "Write a query to show requests per second"

**Your Answer:**

```promql
rate(app_requests_total[1m])
```

**Explanation:**
> "I use rate() to convert the cumulative counter into a per-second rate. The [1m] time range provides a 1-minute moving average, which smooths out short-term spikes and gives a more stable view of current traffic."

---

### Q2: "How would you calculate error rate?"

**Your Answer:**

```promql
rate(app_errors_total[5m])
```

**Better Answer (as percentage):**

```promql
(rate(app_errors_total[5m]) / rate(app_requests_total[5m])) * 100
```

**Explanation:**
> "I calculate error rate as a percentage of total requests. This is more meaningful than absolute numbers because 10 errors per second is fine if you have 10,000 requests per second (0.1% error rate), but terrible if you only have 100 requests per second (10% error rate)."

---

### Q3: "What's the difference between average and 95th percentile response time?"

**Your Answer:**

**Average:**

```promql
rate(app_request_duration_seconds_sum[1m]) / 
rate(app_request_duration_seconds_count[1m])
```

**95th Percentile:**

```promql
histogram_quantile(0.95, 
  rate(app_request_duration_seconds_bucket[1m])
)
```

**Explanation:**
> "Average can hide problems. If 95% of requests take 100ms but 5% take 10 seconds, the average might be 500ms, which looks okay. But 5% of users are having a terrible experience!
>
> The 95th percentile shows what 95% of users actually experience. It's better for understanding real user experience and setting SLOs. For example, 'P95 response time < 500ms' is a common SLO."

---

### Q4: "How would you detect if an application is down?"

**Your Answer:**

```promql
up{job="flask-app"}
```

**Or check request rate:**

```promql
rate(app_requests_total[5m]) == 0
```

**Explanation:**
> "I would use the 'up' metric which Prometheus automatically generates. It's 1 when the target is reachable and 0 when it's down.
>
> Alternatively, I can check if the request rate drops to zero, which indicates no traffic is being processed. I'd set an alert: 'if up == 0 for 1 minute, page on-call engineer'."

---

### Q5: "How do you calculate CPU usage percentage?"

**Your Answer:**

```promql
100 - (avg by(instance) (
  rate(node_cpu_seconds_total{mode="idle"}[5m])
) * 100)
```

**Explanation:**
> "CPU metrics are counters that track time spent in different modes (idle, user, system, etc.). I calculate idle time rate and subtract from 100 to get usage percentage.
>
> The rate() function converts cumulative seconds into per-second rate, and I group by instance to see per-server CPU usage."

---

### Q6: "Write a query to show memory usage percentage"

**Your Answer:**

```promql
(
  node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes
)
/
node_memory_MemTotal_bytes
* 100
```

**Explanation:**
> "I calculate used memory (Total - Available) divided by total memory, then multiply by 100 for percentage. This gives a clear view of memory pressure on each node."

---

## 🎯 How to Learn PromQL (Not Memorize!)

### Step 1: Understand Your Metrics

**In Prometheus UI:**

1. Go to <http://localhost:9091>
2. Click "Graph"
3. Start typing in the query box
4. See what metrics are available
5. Click on a metric to see its labels

**Example exploration:**

```
Type: app_
See: app_requests_total, app_errors_total, app_active_requests

Click on app_requests_total
See labels: {endpoint="home", method="GET", status="200"}
```

---

### Step 2: Start Simple

**Begin with basic queries:**

```promql
# 1. Just the metric name
app_requests_total

# 2. Add a label filter
app_requests_total{method="GET"}

# 3. Add rate()
rate(app_requests_total[1m])

# 4. Add sum()
sum(rate(app_requests_total[1m]))
```

---

### Step 3: Build Up Complexity

**Layer by layer:**

```promql
# Start: Raw counter
app_requests_total

# Add: Rate calculation
rate(app_requests_total[1m])

# Add: Group by endpoint
sum by(endpoint) (rate(app_requests_total[1m]))

# Add: Filter for errors only
sum by(endpoint) (rate(app_requests_total{status=~"5.."}[1m]))
```

---

### Step 4: Use the Metrics Browser

**In Prometheus UI:**

1. Click "Metrics browser" button
2. Browse available metrics
3. See example queries
4. Copy and modify

---

### Step 5: Practice Common Patterns

**Create a cheat sheet:**

```promql
# Request rate
rate(requests_total[1m])

# Error rate
rate(errors_total[5m])

# Average response time
rate(duration_sum[1m]) / rate(duration_count[1m])

# 95th percentile
histogram_quantile(0.95, rate(duration_bucket[1m]))

# Current value (gauge)
active_connections

# Sum across instances
sum(metric_name)

# Group by label
sum by(label_name) (metric_name)
```

---

## 📚 PromQL Cheat Sheet for Interviews

### Basic Selectors

```promql
metric_name                          # All series
metric_name{label="value"}           # Filter by label
metric_name{label=~"regex"}          # Regex match
metric_name{label!="value"}          # Not equal
metric_name{label=~"value1|value2"}  # OR condition
```

### Time Ranges

```promql
metric_name[5m]   # Last 5 minutes
metric_name[1h]   # Last 1 hour
metric_name[1d]   # Last 1 day
```

### Rate Functions

```promql
rate(counter[5m])        # Per-second rate
irate(counter[5m])       # Instant rate (more sensitive)
increase(counter[5m])    # Total increase
```

### Aggregation

```promql
sum(metric)              # Sum all
avg(metric)              # Average
max(metric)              # Maximum
min(metric)              # Minimum
count(metric)            # Count series
```

### Grouping

```promql
sum by(label) (metric)       # Group by label
sum without(label) (metric)  # Group by all except label
```

### Math Operations

```promql
metric1 + metric2        # Addition
metric1 - metric2        # Subtraction
metric1 * metric2        # Multiplication
metric1 / metric2        # Division
metric1 % metric2        # Modulo
```

### Comparison

```promql
metric > 100             # Greater than
metric < 50              # Less than
metric == 0              # Equal to
metric != 0              # Not equal to
```

### Time Functions

```promql
metric offset 1h         # Value 1 hour ago
avg_over_time(metric[5m])  # Average over time
max_over_time(metric[5m])  # Maximum over time
min_over_time(metric[5m])  # Minimum over time
```

---

## 🎯 Real Interview Scenarios

### Scenario 1: "Our API is slow. Write queries to investigate."

**Your Response:**

```promql
# 1. Check current response time
rate(http_request_duration_seconds_sum[5m]) / 
rate(http_request_duration_seconds_count[5m])

# 2. Check 95th percentile
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket[5m])
)

# 3. Break down by endpoint
sum by(endpoint) (
  rate(http_request_duration_seconds_sum[5m]) / 
  rate(http_request_duration_seconds_count[5m])
)

# 4. Check if traffic increased
rate(http_requests_total[5m])

# 5. Check error rate
rate(http_requests_total{status=~"5.."}[5m])
```

**Explanation:**
> "I would start by checking average and P95 response times to confirm the slowness. Then I'd break it down by endpoint to identify which specific API is slow. I'd also check if traffic increased (causing overload) or if error rates are high (indicating failures)."

---

### Scenario 2: "Set up an alert for high error rate"

**Your Response:**

```promql
# Alert when error rate > 5% for 5 minutes
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
) * 100 > 5
```

**Explanation:**
> "I calculate error rate as a percentage of total requests. The alert fires when more than 5% of requests fail for 5 consecutive minutes. This avoids false alarms from brief spikes while catching sustained issues."

---

### Scenario 3: "How would you monitor database performance?"

**Your Response:**

```promql
# Query duration
rate(mysql_query_duration_seconds_sum[5m]) / 
rate(mysql_query_duration_seconds_count[5m])

# Slow queries (>1s)
rate(mysql_slow_queries_total[5m])

# Connection pool usage
mysql_connections_active / mysql_connections_max * 100

# Query rate
rate(mysql_queries_total[5m])
```

**Explanation:**
> "I would track query duration to detect slowdowns, monitor slow queries to identify problematic SQL, check connection pool usage to detect connection exhaustion, and track query rate to understand load patterns."

---

## 🎓 Pro Tips for Interviews

### 1. Always Explain Your Thinking

**Don't just write the query, explain:**

- Why you chose this metric
- Why you used rate() or not
- Why this time range
- What the result means

### 2. Start Simple, Then Refine

**Show your process:**

```promql
# First attempt
app_requests_total

# Better - add rate
rate(app_requests_total[1m])

# Even better - group by endpoint
sum by(endpoint) (rate(app_requests_total[1m]))

# Best - filter for errors only
sum by(endpoint) (rate(app_requests_total{status=~"5.."}[1m]))
```

### 3. Mention Trade-offs

**Example:**
> "I use [1m] for real-time monitoring because it's responsive, but for alerting I'd use [5m] to avoid false alarms from brief spikes."

### 4. Connect to Business Impact

**Example:**
> "This query shows P95 response time, which directly impacts user experience. If P95 exceeds 500ms, users will perceive the app as slow, potentially leading to abandonment."

---

## 📖 Learning Resources

### Practice in Prometheus UI

1. Go to <http://localhost:9091>
2. Try queries
3. See results immediately
4. Experiment!

### Official Documentation

- <https://prometheus.io/docs/prometheus/latest/querying/basics/>
- <https://prometheus.io/docs/prometheus/latest/querying/functions/>

### Practice Queries

```promql
# Try these in your Prometheus:
rate(app_requests_total[1m])
sum(rate(app_requests_total[1m]))
sum by(endpoint) (rate(app_requests_total[1m]))
histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[1m]))
```

---

## 🎉 Summary

### You Don't Need to Memorize ✅

**Instead, remember:**

1. **Patterns** - Request rate, error rate, response time
2. **Functions** - rate(), sum(), avg(), histogram_quantile()
3. **Logic** - Why you use each function
4. **Practice** - Try queries in Prometheus UI

### Key Takeaways

- ✅ Counters need rate()
- ✅ Gauges don't need rate()
- ✅ Use [1m] for real-time, [5m] for alerts
- ✅ Group with sum by(label)
- ✅ Percentiles > averages for user experience
- ✅ Always explain your thinking in interviews

### Interview Success Formula

```
Understanding + Practice + Explanation = Success

NOT

Memorization = Failure (you'll forget under pressure!)
```

**You've got this!** 🚀
