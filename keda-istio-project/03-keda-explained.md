# KEDA - Complete Beginner's Guide

## 🎯 What is KEDA?

### Simple Explanation

Imagine a restaurant:

- **Traditional Autoscaling**: Add waiters when kitchen is busy (CPU/memory based)
- **KEDA**: Add waiters when there are customers waiting (event-driven)

**KEDA** = **K**ubernetes **E**vent-**D**riven **A**utoscaling

It scales your applications based on **real events** (messages, requests, metrics) not just CPU/memory!

### Technical Definition

**KEDA** is a Kubernetes-based event-driven autoscaler that:

- 📊 Scales based on external metrics (queues, databases, custom metrics)
- 🔄 Scales to zero when no events
- 🚀 Scales up instantly when events arrive
- 🔌 Works with 50+ event sources (RabbitMQ, Kafka, Azure Queue, AWS SQS, etc.)

---

## 🤔 Why Do We Need KEDA?

### Problem With Traditional Autoscaling

```
Kubernetes HPA (Horizontal Pod Autoscaler):

Scenario: Message processing service

┌─────────────────────────────────────────┐
│  RabbitMQ Queue: 1000 messages waiting  │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  Worker Pods: 2 pods (CPU at 30%)      │
│  HPA says: "CPU is low, don't scale"   │
└─────────────────────────────────────────┘

Problem: Messages pile up! 😱
- CPU is low because pods are waiting for messages
- HPA doesn't know about queue depth
- Messages take hours to process
```

### Solution With KEDA

```
KEDA Autoscaling:

Scenario: Same message processing service

┌─────────────────────────────────────────┐
│  RabbitMQ Queue: 1000 messages waiting  │
└─────────────────────────────────────────┘
              ↓
         KEDA watches queue
              ↓
┌─────────────────────────────────────────┐
│  Worker Pods: Scales to 20 pods!       │
│  KEDA says: "Queue is full, scale up!" │
└─────────────────────────────────────────┘

Solution: Messages processed quickly! ✅
- KEDA monitors queue depth
- Scales based on actual work
- Processes 1000 messages in minutes
```

---

## 🏗️ KEDA Architecture

### High-Level View

```
┌─────────────────────────────────────────────────────────┐
│                    KEDA Architecture                     │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │         KEDA Operator (Control Plane)          │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐   │    │
│  │  │  Metrics │  │  Scaler  │  │  Webhook │   │    │
│  │  │  Server  │  │  Manager │  │  Server  │   │    │
│  │  └──────────┘  └──────────┘  └──────────┘   │    │
│  └────────────────────────────────────────────────┘    │
│                         │                               │
│                         ↓                               │
│  ┌─────────────────────────────────────────────────┐  │
│  │            External Event Sources                │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐     │  │
│  │  │RabbitMQ  │  │  Kafka   │  │   AWS    │     │  │
│  │  │  Queue   │  │  Topic   │  │   SQS    │     │  │
│  │  └──────────┘  └──────────┘  └──────────┘     │  │
│  └─────────────────────────────────────────────────┘  │
│                         │                               │
│                         ↓                               │
│  ┌─────────────────────────────────────────────────┐  │
│  │         Your Application Pods                    │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐        │  │
│  │  │  Pod 1  │  │  Pod 2  │  │  Pod N  │        │  │
│  │  │ Worker  │  │ Worker  │  │ Worker  │        │  │
│  │  └─────────┘  └─────────┘  └─────────┘        │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Components Explained

#### 1. **KEDA Operator**

- Watches ScaledObject resources
- Queries external event sources
- Tells Kubernetes to scale

#### 2. **Metrics Server**

- Exposes metrics to Kubernetes HPA
- Converts external metrics to HPA format

#### 3. **Scalers**

- Connectors to external systems
- 50+ built-in scalers
- Custom scalers possible

---

## 🔑 Core KEDA Concepts

### 1. ScaledObject

**What**: Main KEDA resource that defines scaling behavior

```yaml
# ScaledObject Example
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: rabbitmq-scaledobject
spec:
  scaleTargetRef:
    name: message-processor  # Deployment to scale
  minReplicaCount: 0         # Can scale to zero!
  maxReplicaCount: 30        # Maximum pods
  pollingInterval: 30        # Check every 30 seconds
  cooldownPeriod: 300        # Wait 5 min before scaling down
  triggers:
  - type: rabbitmq
    metadata:
      queueName: orders
      queueLength: "5"       # 1 pod per 5 messages
      host: amqp://rabbitmq:5672
```

**What This Does**:

```
1. Monitors RabbitMQ queue "orders"
2. Scales deployment "message-processor"
3. Creates 1 pod for every 5 messages
4. Scales to 0 when queue is empty
5. Maximum 30 pods
6. Checks every 30 seconds
7. Waits 5 minutes before scaling down
```

---

### 2. Triggers (Event Sources)

**What**: Defines what to monitor and when to scale

#### Popular Triggers

##### A. RabbitMQ Trigger

```yaml
triggers:
- type: rabbitmq
  metadata:
    queueName: orders
    queueLength: "10"
    host: amqp://user:pass@rabbitmq:5672
```

**Use Case**: Process messages from queue

```
Queue has 100 messages
queueLength = 10
Result: Scale to 10 pods (100 / 10)
```

##### B. Kafka Trigger

```yaml
triggers:
- type: kafka
  metadata:
    bootstrapServers: kafka:9092
    consumerGroup: my-group
    topic: events
    lagThreshold: "50"
```

**Use Case**: Process Kafka events

```
Consumer lag = 500 messages
lagThreshold = 50
Result: Scale to 10 pods (500 / 50)
```

##### C. Azure Queue Trigger

```yaml
triggers:
- type: azure-queue
  metadata:
    queueName: myqueue
    queueLength: "5"
    connectionFromEnv: AZURE_STORAGE_CONNECTION
```

##### D. AWS SQS Trigger

```yaml
triggers:
- type: aws-sqs-queue
  metadata:
    queueURL: https://sqs.us-east-1.amazonaws.com/123/myqueue
    queueLength: "5"
    awsRegion: us-east-1
```

##### E. Prometheus Trigger

```yaml
triggers:
- type: prometheus
  metadata:
    serverAddress: http://prometheus:9090
    metricName: http_requests_total
    threshold: "100"
    query: sum(rate(http_requests_total[1m]))
```

**Use Case**: Scale based on custom metrics

```
If requests per second > 100
Scale up to handle load
```

##### F. Cron Trigger

```yaml
triggers:
- type: cron
  metadata:
    timezone: America/New_York
    start: 0 8 * * *    # 8 AM
    end: 0 18 * * *     # 6 PM
    desiredReplicas: "10"
```

**Use Case**: Predictable scaling

```
8 AM - 6 PM: Scale to 10 pods (business hours)
6 PM - 8 AM: Scale to 0 (off hours)
```

---

### 3. ScaledJob

**What**: For one-time jobs instead of long-running deployments

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: batch-processor
spec:
  jobTargetRef:
    template:
      spec:
        containers:
        - name: processor
          image: batch-processor:latest
  pollingInterval: 30
  maxReplicaCount: 10
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  triggers:
  - type: rabbitmq
    metadata:
      queueName: batch-jobs
      queueLength: "1"
```

**Difference from ScaledObject**:

```
ScaledObject:
- Long-running pods
- Processes continuously
- Example: Web server, API

ScaledJob:
- Creates Kubernetes Jobs
- One job per message/event
- Job completes and terminates
- Example: Batch processing, ETL
```

---

## 🎯 How KEDA Works

### Scaling Flow

```
Step 1: Event occurs
┌─────────────────────────────────┐
│  RabbitMQ: 50 messages arrive   │
└─────────────────────────────────┘
              ↓
Step 2: KEDA detects
┌─────────────────────────────────┐
│  KEDA Scaler queries RabbitMQ   │
│  Sees: 50 messages in queue     │
└─────────────────────────────────┘
              ↓
Step 3: KEDA calculates
┌─────────────────────────────────┐
│  queueLength = 5                │
│  Desired pods = 50 / 5 = 10     │
└─────────────────────────────────┘
              ↓
Step 4: KEDA scales
┌─────────────────────────────────┐
│  Current: 2 pods                │
│  Desired: 10 pods               │
│  Action: Create 8 more pods     │
└─────────────────────────────────┘
              ↓
Step 5: Pods process messages
┌─────────────────────────────────┐
│  10 pods process 50 messages    │
│  Queue becomes empty            │
└─────────────────────────────────┘
              ↓
Step 6: KEDA scales down
┌─────────────────────────────────┐
│  No messages for 5 minutes      │
│  Scale down to 0 pods           │
│  Save resources! 💰             │
└─────────────────────────────────┘
```

---

## 🎯 Real-World Use Cases

### Use Case 1: E-commerce Order Processing

**Scenario**: Process orders from queue

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: order-processor
spec:
  scaleTargetRef:
    name: order-processor-deployment
  minReplicaCount: 1
  maxReplicaCount: 50
  triggers:
  - type: rabbitmq
    metadata:
      queueName: orders
      queueLength: "10"
```

**How It Works**:

```
Normal Day:
- 100 orders/hour
- KEDA maintains 2-3 pods

Black Friday:
- 10,000 orders/hour
- KEDA scales to 50 pods
- All orders processed quickly

After Sale:
- Orders drop to normal
- KEDA scales back to 2-3 pods
- Cost optimized! 💰
```

---

### Use Case 2: Image Processing

**Scenario**: Resize images uploaded by users

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: image-processor
spec:
  jobTargetRef:
    template:
      spec:
        containers:
        - name: processor
          image: image-resizer:latest
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.us-east-1.amazonaws.com/123/images
      queueLength: "1"
      awsRegion: us-east-1
```

**How It Works**:

```
User uploads 100 images
↓
100 messages in SQS queue
↓
KEDA creates 100 jobs
↓
Each job processes 1 image
↓
Jobs complete and terminate
↓
No ongoing cost! 💰
```

---

### Use Case 3: Scheduled Batch Processing

**Scenario**: Run reports every night

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: report-generator
spec:
  scaleTargetRef:
    name: report-generator
  minReplicaCount: 0
  maxReplicaCount: 10
  triggers:
  - type: cron
    metadata:
      timezone: America/New_York
      start: 0 2 * * *     # 2 AM
      end: 0 6 * * *       # 6 AM
      desiredReplicas: "10"
```

**How It Works**:

```
2 AM: KEDA scales to 10 pods
      Generate reports for all customers
      
6 AM: Reports complete
      KEDA scales to 0 pods
      
Rest of day: 0 pods running
             No cost! 💰
```

---

### Use Case 4: API Rate Limiting

**Scenario**: Scale based on API request rate

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: api-server
spec:
  scaleTargetRef:
    name: api-server
  minReplicaCount: 2
  maxReplicaCount: 20
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: http_requests_per_second
      threshold: "100"
      query: sum(rate(http_requests_total{job="api-server"}[1m]))
```

**How It Works**:

```
Low traffic (50 req/s):
- 2 pods handle load

Medium traffic (500 req/s):
- KEDA scales to 5 pods

High traffic (2000 req/s):
- KEDA scales to 20 pods

Traffic drops:
- KEDA scales back to 2 pods
```

---

## 📊 KEDA vs Traditional HPA

| Feature | Traditional HPA | KEDA |
|---------|----------------|------|
| **Metrics** | CPU, Memory only | 50+ event sources |
| **Scale to Zero** | No (min 1 pod) | Yes (0 pods) |
| **External Metrics** | Complex setup | Built-in |
| **Event-Driven** | No | Yes |
| **Queue-Based** | Not supported | Native support |
| **Custom Metrics** | Difficult | Easy |
| **Cost Savings** | Limited | Significant |

### Example Comparison

```
Scenario: Process 1000 messages, then idle for 23 hours

Traditional HPA:
- Minimum 1 pod always running
- 24 hours × 1 pod = 24 pod-hours
- Cost: $24/day

KEDA:
- Scales to 10 pods for 1 hour
- Scales to 0 for 23 hours
- 1 hour × 10 pods = 10 pod-hours
- Cost: $10/day
- Savings: 58%! 💰
```

---

## 🔧 KEDA Configuration Best Practices

### 1. Choosing minReplicaCount

```yaml
# Option 1: Scale to zero (maximum savings)
minReplicaCount: 0
# Use when: Can tolerate cold start delay

# Option 2: Keep minimum pods (faster response)
minReplicaCount: 2
# Use when: Need instant response
```

### 2. Setting maxReplicaCount

```yaml
# Calculate based on:
# - Maximum expected load
# - Resource limits
# - Cost constraints

maxReplicaCount: 50

# Example calculation:
# Peak load: 5000 messages/minute
# Processing rate: 100 messages/minute per pod
# Required: 5000 / 100 = 50 pods
```

### 3. Tuning pollingInterval

```yaml
# Fast polling (more responsive, more API calls)
pollingInterval: 10  # Check every 10 seconds

# Slow polling (less responsive, fewer API calls)
pollingInterval: 60  # Check every 60 seconds

# Recommended: 30 seconds (good balance)
pollingInterval: 30
```

### 4. Setting cooldownPeriod

```yaml
# Short cooldown (scales down quickly)
cooldownPeriod: 60  # 1 minute

# Long cooldown (prevents flapping)
cooldownPeriod: 300  # 5 minutes

# Recommended: 5 minutes
cooldownPeriod: 300
```

---

## 🎓 Key Takeaways

### What You Learned

- ✅ KEDA scales based on events, not just CPU/memory
- ✅ Can scale to zero for cost savings
- ✅ Supports 50+ event sources
- ✅ ScaledObject for deployments
- ✅ ScaledJob for batch processing
- ✅ Triggers define scaling behavior
- ✅ Much more cost-effective than traditional HPA

### Why It Matters

- ✅ Significant cost savings (scale to zero)
- ✅ Better resource utilization
- ✅ Faster response to events
- ✅ Simpler than custom solutions
- ✅ Production-ready and battle-tested

---

## 🚀 Next Steps

Now that you understand KEDA, learn:

**Next**: [Why Use Istio + KEDA Together?](./04-why-istio-keda.md)

Discover how Istio and KEDA complement each other for a complete production-ready architecture!

---

## 📝 Quick Reference

### Common KEDA Commands

```bash
# Install KEDA
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.12.0/keda-2.12.0.yaml

# Check KEDA installation
kubectl get pods -n keda

# Create ScaledObject
kubectl apply -f scaledobject.yaml

# Check ScaledObject status
kubectl get scaledobject

# Describe ScaledObject
kubectl describe scaledobject <name>

# View HPA created by KEDA
kubectl get hpa

# Check scaling events
kubectl get events --sort-by='.lastTimestamp'

# Delete ScaledObject
kubectl delete scaledobject <name>
```

### Debugging KEDA

```bash
# Check KEDA operator logs
kubectl logs -n keda deployment/keda-operator

# Check metrics server logs
kubectl logs -n keda deployment/keda-metrics-apiserver

# Test scaler connection
kubectl logs -n keda deployment/keda-operator | grep "scaler"

# View current metrics
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1
```

**Congratulations!** You now understand KEDA event-driven autoscaling! 🎉
