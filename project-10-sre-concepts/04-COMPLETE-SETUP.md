# 📊 Complete SRE Setup - SLO/SLI Implementation

## 📖 Complete Implementation Guide

This guide provides a **complete, production-ready SRE implementation** with SLIs, SLOs, error budgets, monitoring, and alerting - all with step-by-step instructions and line-by-line explanations.

---

## 🎯 What We'll Build

```
Complete SRE Platform:
├── Service Definition
├── SLI Metrics (Prometheus)
│   ├── Availability
│   ├── Latency
│   └── Error Rate
├── SLO Targets
│   ├── 99.9% availability
│   ├── p95 latency < 200ms
│   └── Error rate < 0.1%
├── Error Budget Tracking
├── Grafana Dashboards
├── Alert Rules
└── Incident Response Process
```

---

## 📋 Prerequisites

```bash
# Required
- Kubernetes cluster (Minikube or cloud)
- kubectl installed
- Helm installed
- Basic Prometheus/Grafana knowledge

# Verify
kubectl version --client
helm version
```

---

## 🚀 Part 1: Deploy Sample Application

### Step 1.1: Create Demo Application

**WHAT:** Deploy a sample web application to monitor

**WHY:** Need a real service to measure SLIs

**HOW:**

```bash
# Create namespace
kubectl create namespace sre-demo

# Create deployment
cat > app-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
  namespace: sre-demo
  labels:
    app: demo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: app
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# EXPLANATION:
# replicas: 3                    : High availability
# prometheus.io/scrape: "true"   : Enable Prometheus scraping
# livenessProbe                  : Health check for restarts
# readinessProbe                 : Health check for traffic

kubectl apply -f app-deployment.yaml

# Create service
cat > app-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: demo-app
  namespace: sre-demo
  labels:
    app: demo-app
spec:
  type: LoadBalancer
  selector:
    app: demo-app
  ports:
  - port: 80
    targetPort: 80
    name: http
EOF

kubectl apply -f app-service.yaml

# Verify
kubectl get pods -n sre-demo
kubectl get svc -n sre-demo
```

---

## 📊 Part 2: Install Monitoring Stack

### Step 2.1: Install Prometheus

**WHAT:** Metrics collection and storage

**WHY:** Track SLI metrics

**HOW:**

```bash
# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# EXPLANATION:
# kube-prometheus-stack          : Complete monitoring stack
# --namespace monitoring         : Dedicated namespace
# serviceMonitorSelectorNilUsesHelmValues=false : Monitor all namespaces

# Wait for pods
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=prometheus \
  -n monitoring \
  --timeout=300s

# Verify
kubectl get pods -n monitoring

# Access Prometheus UI
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &

# Open: http://localhost:9090
```

### Step 2.2: Install Grafana

**WHAT:** Visualization and dashboards

**WHY:** Display SLI/SLO metrics

**HOW:**

```bash
# Grafana is included in kube-prometheus-stack

# Get Grafana password
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d

# Save password
echo "Grafana password: $(kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d)"

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &

# Open: http://localhost:3000
# Login: admin / <password from above>
```

---

## 📈 Part 3: Define SLIs

### Step 3.1: Availability SLI

**WHAT:** Percentage of successful requests

**WHY:** Users care if service is available

**HOW:**

```yaml
# Create ServiceMonitor for our app
cat > servicemonitor.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: demo-app
  namespace: sre-demo
  labels:
    app: demo-app
spec:
  selector:
    matchLabels:
      app: demo-app
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
EOF

kubectl apply -f servicemonitor.yaml

# Availability Query (PromQL)
# Good events / Total events

# Good events: HTTP 2xx, 3xx responses
sum(rate(http_requests_total{status=~"2..|3.."}[5m]))

# Total events: All HTTP responses
sum(rate(http_requests_total[5m]))

# Availability SLI:
sum(rate(http_requests_total{status=~"2..|3.."}[5m]))
/
sum(rate(http_requests_total[5m]))
* 100

# EXPLANATION:
# rate(...[5m])           : Per-second rate over 5 minutes
# status=~"2..|3.."       : Regex for 2xx and 3xx status codes
# sum()                   : Aggregate across all instances
# * 100                   : Convert to percentage
```

### Step 3.2: Latency SLI

**WHAT:** Request response time

**WHY:** Users care about speed

**HOW:**

```promql
# P95 Latency (95th percentile)
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# EXPLANATION:
# histogram_quantile(0.95, ...)  : 95th percentile
# http_request_duration_seconds  : Histogram metric
# rate(...[5m])                  : Rate over 5 minutes
# sum(...) by (le)               : Aggregate by bucket

# P99 Latency (99th percentile)
histogram_quantile(0.99,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# Average Latency
rate(http_request_duration_seconds_sum[5m])
/
rate(http_request_duration_seconds_count[5m])
```

### Step 3.3: Error Rate SLI

**WHAT:** Percentage of failed requests

**WHY:** Users care about reliability

**HOW:**

```promql
# Error Rate
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
* 100

# EXPLANATION:
# status=~"5.."  : 5xx server errors
# Divide by total requests
# Multiply by 100 for percentage
```

---

## 🎯 Part 4: Define SLOs

### Step 4.1: Set SLO Targets

**WHAT:** Define reliability targets

**WHY:** Clear goals for the team

**HOW:**

```yaml
# Create SLO ConfigMap
cat > slo-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: slo-config
  namespace: sre-demo
data:
  slo.yaml: |
    # Service Level Objectives
    service: demo-app
    
    slos:
      # Availability SLO
      - name: availability
        description: "Percentage of successful requests"
        sli_query: |
          sum(rate(http_requests_total{status=~"2..|3.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))
          * 100
        target: 99.9
        unit: percent
        window: 30d
        
      # Latency SLO
      - name: latency_p95
        description: "95th percentile latency"
        sli_query: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
          )
        target: 0.2
        unit: seconds
        window: 30d
        
      # Error Rate SLO
      - name: error_rate
        description: "Percentage of failed requests"
        sli_query: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))
          * 100
        target: 0.1
        unit: percent
        window: 30d
EOF

kubectl apply -f slo-config.yaml

# EXPLANATION:
# target: 99.9        : 99.9% availability target
# target: 0.2         : 200ms latency target
# target: 0.1         : 0.1% error rate target
# window: 30d         : 30-day rolling window
```

---

## 💰 Part 5: Calculate Error Budget

### Step 5.1: Error Budget Formula

**WHAT:** Allowed failure rate

**WHY:** Balance reliability and velocity

**HOW:**

```yaml
# Error Budget Calculation
cat > error-budget.yaml << 'EOF'
# Error Budget = 100% - SLO

# Availability SLO: 99.9%
# Error Budget: 100% - 99.9% = 0.1%

# For 30 days:
# Total minutes: 30 * 24 * 60 = 43,200 minutes
# Error Budget: 43,200 * 0.001 = 43.2 minutes
# Can have 43.2 minutes of downtime per month

# For requests:
# If 1M requests/month
# Error Budget: 1,000,000 * 0.001 = 1,000 requests
# Can have 1,000 failed requests per month

# Error Budget Remaining Query:
(
  1 - (
    sum(rate(http_requests_total{status=~"5.."}[30d]))
    /
    sum(rate(http_requests_total[30d]))
  )
  - 0.999  # SLO target
)
/
(1 - 0.999)  # Error budget
* 100

# EXPLANATION:
# Actual error rate - SLO target = budget used
# Divide by total budget
# Multiply by 100 for percentage
# Result: % of error budget remaining
EOF

# Create Prometheus recording rule
cat > error-budget-rule.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: slo-rules
  namespace: monitoring
spec:
  groups:
  - name: slo
    interval: 30s
    rules:
    # Availability SLI
    - record: sli:availability:ratio
      expr: |
        sum(rate(http_requests_total{status=~"2..|3.."}[5m]))
        /
        sum(rate(http_requests_total[5m]))
    
    # Error Budget Remaining
    - record: slo:error_budget:remaining
      expr: |
        (
          1 - (
            sum(rate(http_requests_total{status=~"5.."}[30d]))
            /
            sum(rate(http_requests_total[30d]))
          )
          - 0.999
        )
        /
        (1 - 0.999)
        * 100
    
    # SLO Compliance
    - record: slo:availability:compliance
      expr: |
        sli:availability:ratio >= 0.999
EOF

kubectl apply -f error-budget-rule.yaml
```

---

## 🚨 Part 6: Configure Alerts

### Step 6.1: SLO Violation Alerts

**WHAT:** Alert when SLO is violated

**WHY:** Proactive incident response

**HOW:**

```yaml
# Create alert rules
cat > slo-alerts.yaml << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: slo-alerts
  namespace: monitoring
spec:
  groups:
  - name: slo-alerts
    interval: 30s
    rules:
    # Availability SLO violation
    - alert: AvailabilitySLOViolation
      expr: |
        sli:availability:ratio < 0.999
      for: 5m
      labels:
        severity: critical
        slo: availability
      annotations:
        summary: "Availability SLO violated"
        description: "Availability is {{ $value | humanizePercentage }}, below 99.9% target"
    
    # Latency SLO violation
    - alert: LatencySLOViolation
      expr: |
        histogram_quantile(0.95,
          sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
        ) > 0.2
      for: 5m
      labels:
        severity: warning
        slo: latency
      annotations:
        summary: "Latency SLO violated"
        description: "P95 latency is {{ $value }}s, above 200ms target"
    
    # Error Budget exhausted
    - alert: ErrorBudgetExhausted
      expr: |
        slo:error_budget:remaining < 0
      for: 5m
      labels:
        severity: critical
        slo: error_budget
      annotations:
        summary: "Error budget exhausted"
        description: "Error budget is {{ $value }}%, stop deployments!"
    
    # Error Budget low
    - alert: ErrorBudgetLow
      expr: |
        slo:error_budget:remaining < 25
      for: 5m
      labels:
        severity: warning
        slo: error_budget
      annotations:
        summary: "Error budget low"
        description: "Error budget is {{ $value }}%, be careful with deployments"
EOF

kubectl apply -f slo-alerts.yaml

# EXPLANATION:
# expr: sli:availability:ratio < 0.999  : Trigger when below SLO
# for: 5m                               : Must be true for 5 minutes
# severity: critical                    : Alert severity
# annotations                           : Alert details
```

---

## 📊 Part 7: Create Grafana Dashboards

### Step 7.1: SLO Dashboard

**WHAT:** Visualize SLIs and SLOs

**WHY:** Team visibility

**HOW:**

```json
# Create dashboard JSON
cat > slo-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "SLO Dashboard",
    "panels": [
      {
        "title": "Availability SLI",
        "targets": [
          {
            "expr": "sli:availability:ratio * 100"
          }
        ],
        "type": "graph",
        "thresholds": [
          {
            "value": 99.9,
            "color": "green"
          }
        ]
      },
      {
        "title": "Error Budget Remaining",
        "targets": [
          {
            "expr": "slo:error_budget:remaining"
          }
        ],
        "type": "gauge",
        "thresholds": [
          {
            "value": 0,
            "color": "red"
          },
          {
            "value": 25,
            "color": "yellow"
          },
          {
            "value": 50,
            "color": "green"
          }
        ]
      },
      {
        "title": "P95 Latency",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) * 1000"
          }
        ],
        "type": "graph",
        "thresholds": [
          {
            "value": 200,
            "color": "green"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100"
          }
        ],
        "type": "graph",
        "thresholds": [
          {
            "value": 0.1,
            "color": "green"
          }
        ]
      }
    ]
  }
}
EOF

# Import to Grafana
# 1. Open Grafana (http://localhost:3000)
# 2. Click "+" → "Import"
# 3. Paste JSON or upload file
# 4. Click "Load"
```

---

## 🎯 Part 8: Error Budget Policy

### Step 8.1: Define Policy

**WHAT:** Rules for using error budget

**WHY:** Balance reliability and velocity

**HOW:**

```yaml
# Create error budget policy
cat > error-budget-policy.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: error-budget-policy
  namespace: sre-demo
data:
  policy.yaml: |
    # Error Budget Policy
    
    # When Error Budget > 50%:
    actions:
      - Deploy new features freely
      - Take calculated risks
      - Innovate quickly
      - Focus on velocity
    
    # When Error Budget 25-50%:
    actions:
      - Review deployments carefully
      - Increase testing
      - Monitor closely
      - Balance velocity and reliability
    
    # When Error Budget < 25%:
    actions:
      - Slow down deployments
      - Focus on reliability
      - Fix existing issues
      - Improve monitoring
    
    # When Error Budget Exhausted (< 0%):
    actions:
      - STOP all deployments
      - Emergency fixes only
      - Root cause analysis
      - Improve reliability
      - Postmortem required
    
    # Exceptions:
    exceptions:
      - Security patches (always allowed)
      - Critical bug fixes (always allowed)
      - Rollbacks (always allowed)
EOF

kubectl apply -f error-budget-policy.yaml
```

---

## ✅ Part 9: Testing the Setup

### Step 9.1: Generate Traffic

```bash
# Install load generator
kubectl run load-generator \
  --image=busybox \
  --restart=Never \
  -- /bin/sh -c "while true; do wget -q -O- http://demo-app.sre-demo; done"

# Generate some errors (simulate failures)
kubectl run error-generator \
  --image=busybox \
  --restart=Never \
  -- /bin/sh -c "while true; do wget -q -O- http://demo-app.sre-demo/nonexistent; sleep 10; done"

# Wait 5 minutes for metrics to populate
sleep 300
```

### Step 9.2: Verify Metrics

```bash
# Check Prometheus
# Open: http://localhost:9090
# Query: sli:availability:ratio
# Should see value close to 1.0 (100%)

# Check error budget
# Query: slo:error_budget:remaining
# Should see positive value

# Check Grafana dashboard
# Open: http://localhost:3000
# Navigate to SLO Dashboard
# Should see all metrics
```

### Step 9.3: Simulate SLO Violation

```bash
# Scale down to cause availability issues
kubectl scale deployment demo-app -n sre-demo --replicas=0

# Wait 5 minutes
sleep 300

# Check alerts
kubectl get prometheusrules -n monitoring

# Should see AvailabilitySLOViolation firing

# Restore service
kubectl scale deployment demo-app -n sre-demo --replicas=3
```

---

## 📋 Part 10: SLO Report

### Step 10.1: Generate Report

```bash
# Create report script
cat > generate-slo-report.sh << 'EOF'
#!/bin/bash

echo "=== SLO Report ==="
echo "Generated: $(date)"
echo

# Availability
AVAILABILITY=$(kubectl exec -n monitoring prometheus-kube-prometheus-prometheus-0 -- \
  promtool query instant http://localhost:9090 \
  'sli:availability:ratio * 100' | grep -oP '\d+\.\d+' | head -1)

echo "Availability SLI: ${AVAILABILITY}%"
echo "Availability SLO: 99.9%"
echo "Status: $([ $(echo "$AVAILABILITY >= 99.9" | bc) -eq 1 ] && echo "✅ PASS" || echo "❌ FAIL")"
echo

# Error Budget
ERROR_BUDGET=$(kubectl exec -n monitoring prometheus-kube-prometheus-prometheus-0 -- \
  promtool query instant http://localhost:9090 \
  'slo:error_budget:remaining' | grep -oP '\d+\.\d+' | head -1)

echo "Error Budget Remaining: ${ERROR_BUDGET}%"
echo "Status: $([ $(echo "$ERROR_BUDGET > 0" | bc) -eq 1 ] && echo "✅ Available" || echo "❌ Exhausted")"
echo

# Recommendation
if [ $(echo "$ERROR_BUDGET > 50" | bc) -eq 1 ]; then
  echo "Recommendation: ✅ Safe to deploy new features"
elif [ $(echo "$ERROR_BUDGET > 25" | bc) -eq 1 ]; then
  echo "Recommendation: ⚠️  Deploy carefully, monitor closely"
elif [ $(echo "$ERROR_BUDGET > 0" | bc) -eq 1 ]; then
  echo "Recommendation: ⚠️  Slow down, focus on reliability"
else
  echo "Recommendation: ❌ STOP deployments, fix issues!"
fi
EOF

chmod +x generate-slo-report.sh

# Run report
./generate-slo-report.sh
```

---

## 🎉 Success

You've built a complete SRE platform with:

- ✅ SLI metrics defined and tracked
- ✅ SLO targets set
- ✅ Error budgets calculated
- ✅ Monitoring with Prometheus
- ✅ Dashboards in Grafana
- ✅ Automated alerting
- ✅ Error budget policy
- ✅ SLO reporting

---

## 🎯 Key Takeaways

### SLI Selection

```
Good SLIs:
✅ User-facing
✅ Measurable
✅ Actionable
✅ Simple

Bad SLIs:
❌ Internal metrics
❌ Hard to measure
❌ Not actionable
❌ Too complex
```

### SLO Setting

```
Good SLOs:
✅ Achievable (99.9%, not 100%)
✅ Based on user needs
✅ Measurable
✅ Documented

Bad SLOs:
❌ Unrealistic (100%)
❌ Arbitrary numbers
❌ Unmeasurable
❌ Undocumented
```

### Error Budget Usage

```
High Budget (>50%):
→ Deploy freely
→ Innovate
→ Take risks

Low Budget (<25%):
→ Slow down
→ Fix issues
→ Improve reliability

Exhausted (<0%):
→ STOP deployments
→ Emergency only
→ Postmortem
```

---

## 📚 Next Steps

**Next Guide:** [`05-MONITORING-ALERTING.md`](05-MONITORING-ALERTING.md)

Advanced monitoring patterns and alert tuning.

---

**Remember:** SRE is about balance - not just reliability, but enabling fast, safe innovation! 📊

**Pro Tip:** Start with 3-5 SLIs. You can always add more later! 🎯
