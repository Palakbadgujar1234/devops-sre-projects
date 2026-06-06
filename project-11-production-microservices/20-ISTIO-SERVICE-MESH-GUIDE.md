# 🕸️ Istio Service Mesh - Complete Sidecar Implementation

## 📖 Overview

This guide provides a **COMPLETE, EASY-TO-LEARN** Istio Service Mesh implementation with sidecar pattern. Every concept explained with WHAT-WHY-HOW format.

---

## 🎯 What We'll Build

**Complete Service Mesh with Istio:**

```
Application Pods with Istio Sidecars
├── Traffic Management (routing, load balancing)
├── Security (mTLS, authentication)
├── Observability (metrics, tracing, logging)
└── Resilience (retries, timeouts, circuit breakers)
```

---

## 📚 Part 1: Service Mesh Basics

### What is a Service Mesh?

**WHAT:** Infrastructure layer for service-to-service communication

**WHY:**

- ✅ Traffic management (routing, load balancing)
- ✅ Security (mTLS encryption)
- ✅ Observability (metrics, tracing)
- ✅ Resilience (retries, circuit breakers)
- ✅ Without changing application code

**HOW IT WORKS:**

```
Without Service Mesh:
App A → App B
(App handles: routing, retries, security, metrics)

With Service Mesh:
App A → Sidecar A → Sidecar B → App B
(Sidecar handles: routing, retries, security, metrics)
```

### What is Istio?

**WHAT:** Open-source service mesh platform

**WHY:**

- ✅ Most popular service mesh
- ✅ Feature-rich
- ✅ Cloud-native
- ✅ Large community

**COMPONENTS:**

```
Istio Architecture:
├── Control Plane (istiod)
│   ├── Pilot: Traffic management
│   ├── Citadel: Security (certificates)
│   └── Galley: Configuration
└── Data Plane (Envoy sidecars)
    └── Proxy: Handles all traffic
```

### What is a Sidecar?

**WHAT:** Additional container in the same pod as your application

**WHY:**

- ✅ Intercepts all network traffic
- ✅ Applies policies
- ✅ Collects metrics
- ✅ No app code changes

**HOW IT WORKS:**

```
Pod without Sidecar:
┌─────────────────┐
│  Pod            │
│  ┌───────────┐  │
│  │    App    │  │
│  └───────────┘  │
└─────────────────┘

Pod with Sidecar:
┌─────────────────────────┐
│  Pod                    │
│  ┌───────────┐          │
│  │    App    │          │
│  └─────┬─────┘          │
│        │                │
│  ┌─────▼──────────────┐ │
│  │  Envoy Sidecar     │ │
│  │  (Istio Proxy)     │ │
│  └────────────────────┘ │
└─────────────────────────┘

Traffic Flow:
External → Sidecar → App
App → Sidecar → External
```

---

## 🔧 Part 2: Install Istio

### Step 2.1: Prerequisites

```bash
# Verify Kubernetes cluster
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://...

# Check cluster version (1.24+ recommended)
kubectl version --short

# Verify nodes
kubectl get nodes

# Expected: At least 2 nodes running
```

### Step 2.2: Download Istio

```bash
# Download Istio (latest version)
curl -L https://istio.io/downloadIstio | sh -

# EXPLANATION:
# Downloads Istio CLI and manifests
# Creates istio-1.x.x directory

# Move to Istio directory
cd istio-1.20.0

# EXPLANATION:
# Version number may vary
# Contains: bin/, samples/, manifests/

# Add istioctl to PATH
export PATH=$PWD/bin:$PATH

# EXPLANATION:
# istioctl: Istio command-line tool
# Used to install and manage Istio

# Verify installation
istioctl version

# Expected output:
# client version: 1.20.0
# control plane version: (not installed yet)
```

### Step 2.3: Install Istio

```bash
# Install Istio with demo profile
istioctl install --set profile=demo -y

# EXPLANATION:
# --set profile=demo: Demo configuration
# -y: Auto-confirm installation

# PROFILES:
# - default: Production (minimal resources)
# - demo: Testing (all features enabled)
# - minimal: Bare minimum
# - production: Production-ready

# WHY demo profile:
# - All features enabled
# - Good for learning
# - Includes ingress/egress gateways

# Installation takes 2-3 minutes

# Expected output:
# ✔ Istio core installed
# ✔ Istiod installed
# ✔ Ingress gateways installed
# ✔ Egress gateways installed
# ✔ Installation complete

# Verify installation
kubectl get pods -n istio-system

# Expected output:
# NAME                                    READY   STATUS
# istio-egressgateway-xxx                 1/1     Running
# istio-ingressgateway-xxx                1/1     Running
# istiod-xxx                              1/1     Running

# EXPLANATION:
# istio-system: Istio namespace
# istiod: Control plane
# ingress/egress gateways: Traffic entry/exit points
```

### Step 2.4: Enable Sidecar Injection

```bash
# Label namespace for automatic sidecar injection
kubectl label namespace default istio-injection=enabled

# EXPLANATION:
# istio-injection=enabled: Auto-inject sidecars
# default: Namespace name
# WHY: Automatically adds Envoy sidecar to new pods

# Verify label
kubectl get namespace default --show-labels

# Expected output:
# NAME      STATUS   AGE   LABELS
# default   Active   10d   istio-injection=enabled

# EXPLANATION:
# Any pod created in this namespace will automatically
# get an Istio sidecar injected
```

---

## 🚀 Part 3: Deploy Application with Sidecars

### Step 3.1: Deploy Sample Application

```bash
# Create deployment YAML
cat > app-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
      version: v1
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      containers:
      - name: backend
        image: your-backend:latest
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: VERSION
          value: "v1"
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
spec:
  ports:
  - port: 3000
    name: http
  selector:
    app: backend
EOF

# EXPLANATION:
# Standard Kubernetes deployment
# No Istio-specific configuration needed
# Sidecar will be injected automatically

# Deploy application
kubectl apply -f app-deployment.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=backend --timeout=60s

# Check pods
kubectl get pods -l app=backend

# Expected output:
# NAME                       READY   STATUS    RESTARTS   AGE
# backend-xxx                2/2     Running   0          30s
# backend-yyy                2/2     Running   0          30s
# backend-zzz                2/2     Running   0          30s

# EXPLANATION:
# READY: 2/2 (not 1/1)
# 2 containers: app + sidecar
# WHY: Istio automatically injected Envoy sidecar
```

### Step 3.2: Verify Sidecar Injection

```bash
# Describe pod to see containers
kubectl describe pod -l app=backend | grep -A 5 "Containers:"

# Expected output:
# Containers:
#   backend:
#     Image: your-backend:latest
#   istio-proxy:
#     Image: docker.io/istio/proxyv2:1.20.0

# EXPLANATION:
# Two containers in pod:
# 1. backend: Your application
# 2. istio-proxy: Envoy sidecar

# Check sidecar logs
kubectl logs -l app=backend -c istio-proxy --tail=10

# Expected output:
# [Envoy] starting main dispatch loop
# [Envoy] all clusters initialized
# [Envoy] starting workers

# EXPLANATION:
# -c istio-proxy: Sidecar container
# Shows Envoy proxy logs
# Confirms sidecar is running
```

---

## 🎯 Part 4: Traffic Management

### Feature 1: Traffic Routing

**WHAT:** Route traffic based on rules

**WHY:** A/B testing, canary deployments

**HOW:**

```bash
# Deploy v2 of application
cat > app-v2-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-v2
  labels:
    app: backend
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v2
  template:
    metadata:
      labels:
        app: backend
        version: v2
    spec:
      containers:
      - name: backend
        image: your-backend:v2
        ports:
        - containerPort: 3000
        env:
        - name: VERSION
          value: "v2"
EOF

kubectl apply -f app-v2-deployment.yaml

# EXPLANATION:
# Now we have:
# - 3 pods running v1
# - 1 pod running v2
# By default, traffic is distributed evenly

# Create VirtualService for traffic routing
cat > virtual-service.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend
spec:
  hosts:
  - backend
  http:
  - match:
    - headers:
        user-type:
          exact: beta
    route:
    - destination:
        host: backend
        subset: v2
  - route:
    - destination:
        host: backend
        subset: v1
      weight: 90
    - destination:
        host: backend
        subset: v2
      weight: 10
EOF

# EXPLANATION:
# VirtualService: Istio traffic routing rules
# hosts: Service name
# match: Conditional routing
#   - If header "user-type: beta" → v2
# route: Default routing
#   - 90% traffic → v1
#   - 10% traffic → v2 (canary)

# Create DestinationRule (defines subsets)
cat > destination-rule.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend
spec:
  host: backend
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
EOF

# EXPLANATION:
# DestinationRule: Defines service subsets
# subsets: Groups of pods
#   - v1: Pods with label version=v1
#   - v2: Pods with label version=v2

# Apply routing rules
kubectl apply -f virtual-service.yaml
kubectl apply -f destination-rule.yaml

# Test routing
# Normal request (90% v1, 10% v2)
kubectl exec -it deploy/backend -c backend -- curl backend:3000

# Beta user request (100% v2)
kubectl exec -it deploy/backend -c backend -- \
  curl -H "user-type: beta" backend:3000
```

### Feature 2: Load Balancing

**WHAT:** Distribute traffic across pods

**WHY:** Better performance, high availability

```bash
# Update DestinationRule with load balancing
cat > destination-rule-lb.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend
spec:
  host: backend
  trafficPolicy:
    loadBalancer:
      simple: LEAST_REQUEST
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
EOF

# EXPLANATION:
# trafficPolicy: Traffic behavior
# loadBalancer: Load balancing algorithm
# LEAST_REQUEST: Send to pod with fewest active requests

# ALGORITHMS:
# - ROUND_ROBIN: Rotate through pods
# - LEAST_REQUEST: Fewest active requests
# - RANDOM: Random selection
# - PASSTHROUGH: No load balancing

kubectl apply -f destination-rule-lb.yaml
```

### Feature 3: Circuit Breaking

**WHAT:** Stop sending traffic to failing pods

**WHY:** Prevent cascade failures

```bash
# Add circuit breaker to DestinationRule
cat > destination-rule-cb.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend
spec:
  host: backend
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
EOF

# EXPLANATION:
# connectionPool: Connection limits
#   - maxConnections: Max TCP connections
#   - http1MaxPendingRequests: Max queued requests
#   - http2MaxRequests: Max HTTP/2 requests

# outlierDetection: Circuit breaker
#   - consecutiveErrors: 5 errors → eject pod
#   - interval: Check every 30s
#   - baseEjectionTime: Eject for 30s
#   - maxEjectionPercent: Max 50% of pods ejected

# WHY:
# If pod fails 5 times in 30s:
# - Stop sending traffic for 30s
# - Prevents overloading failing pod
# - Gives pod time to recover

kubectl apply -f destination-rule-cb.yaml
```

### Feature 4: Retries and Timeouts

**WHAT:** Automatically retry failed requests

**WHY:** Handle transient failures

```bash
# Add retries to VirtualService
cat > virtual-service-retry.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend
spec:
  hosts:
  - backend
  http:
  - route:
    - destination:
        host: backend
    timeout: 10s
    retries:
      attempts: 3
      perTryTimeout: 2s
      retryOn: 5xx,reset,connect-failure
EOF

# EXPLANATION:
# timeout: 10s: Total request timeout
# retries:
#   - attempts: 3: Try up to 3 times
#   - perTryTimeout: 2s: Each attempt timeout
#   - retryOn: When to retry
#     * 5xx: Server errors
#     * reset: Connection reset
#     * connect-failure: Can't connect

# EXAMPLE:
# Request fails with 503 → Retry
# Retry fails with 503 → Retry again
# Second retry fails → Return error
# Total time: 6s (3 attempts × 2s)

kubectl apply -f virtual-service-retry.yaml
```

---

## 🔐 Part 5: Security (mTLS)

### What is mTLS?

**WHAT:** Mutual TLS - both client and server authenticate

**WHY:**

- ✅ Encrypted communication
- ✅ Mutual authentication
- ✅ Zero-trust security

**HOW IT WORKS:**

```
Without mTLS:
App A → (plain text) → App B
❌ No encryption
❌ No authentication

With mTLS:
App A → Sidecar A → (encrypted) → Sidecar B → App B
✅ Encrypted
✅ Authenticated
✅ Automatic (no app changes)
```

### Enable mTLS

```bash
# Enable strict mTLS for namespace
cat > peer-authentication.yaml << 'EOF'
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: STRICT
EOF

# EXPLANATION:
# PeerAuthentication: mTLS policy
# mode: STRICT: Require mTLS
# MODES:
#   - PERMISSIVE: Allow both mTLS and plain
#   - STRICT: Only mTLS
#   - DISABLE: No mTLS

kubectl apply -f peer-authentication.yaml

# Verify mTLS
istioctl authn tls-check deploy/backend backend

# Expected output:
# HOST:PORT                STATUS     SERVER     CLIENT
# backend.default.svc...   OK         mTLS       mTLS

# EXPLANATION:
# OK: mTLS working
# SERVER: Server accepts mTLS
# CLIENT: Client uses mTLS
```

---

## 📊 Part 6: Observability

### Feature 1: Metrics (Prometheus)

**WHAT:** Automatic metrics collection

**WHY:** Monitor service health

```bash
# Istio automatically exports metrics to Prometheus

# View metrics
kubectl port-forward -n istio-system svc/prometheus 9090:9090

# Open browser: http://localhost:9090

# Example queries:
# Request rate:
istio_requests_total

# Request duration:
istio_request_duration_milliseconds

# Success rate:
sum(rate(istio_requests_total{response_code!~"5.*"}[5m])) /
sum(rate(istio_requests_total[5m]))

# EXPLANATION:
# Istio sidecars automatically collect:
# - Request count
# - Request duration
# - Response codes
# - Source/destination services
```

### Feature 2: Distributed Tracing (Jaeger)

**WHAT:** Track requests across services

**WHY:** Debug latency issues

```bash
# Install Jaeger
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# Wait for Jaeger to be ready
kubectl wait --for=condition=available --timeout=60s \
  deployment/jaeger -n istio-system

# Access Jaeger UI
kubectl port-forward -n istio-system svc/jaeger 16686:16686

# Open browser: http://localhost:16686

# EXPLANATION:
# Jaeger shows:
# - Request path through services
# - Time spent in each service
# - Errors and retries
# - Complete request timeline

# Example trace:
# frontend → backend → database
#   100ms     50ms      30ms
# Total: 180ms
```

### Feature 3: Service Graph (Kiali)

**WHAT:** Visualize service mesh

**WHY:** Understand service dependencies

```bash
# Install Kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Wait for Kiali
kubectl wait --for=condition=available --timeout=60s \
  deployment/kiali -n istio-system

# Access Kiali UI
kubectl port-forward -n istio-system svc/kiali 20001:20001

# Open browser: http://localhost:20001

# EXPLANATION:
# Kiali shows:
# - Service topology
# - Traffic flow
# - Health status
# - Configuration
# - Metrics

# Features:
# - Graph view (visual)
# - Traffic animation
# - Error highlighting
# - Configuration validation
```

---

## 🎤 Part 7: Interview Questions & Answers

### Q1: "What is a service mesh and why use it?"

**Answer:**

```
"A service mesh is an infrastructure layer that handles service-to-service 
communication. I use Istio because:

1. Traffic Management:
   - Intelligent routing (A/B testing, canary)
   - Load balancing (least request, round robin)
   - Circuit breaking (prevent cascade failures)
   - Retries and timeouts (handle transient failures)

2. Security:
   - Automatic mTLS (encrypted communication)
   - Authentication (verify service identity)
   - Authorization (control access)
   - No code changes needed

3. Observability:
   - Automatic metrics (Prometheus)
   - Distributed tracing (Jaeger)
   - Service graph (Kiali)
   - Complete visibility

4. Resilience:
   - Circuit breakers
   - Retries
   - Timeouts
   - Fault injection (testing)

In my project:
- 90/10 traffic split for canary deployments
- Automatic mTLS between all services
- Circuit breaker after 5 consecutive errors
- 3 retries with 2s timeout each
- Complete observability with Prometheus/Grafana
```

### Q2: "Explain the sidecar pattern"

**Answer:**

```
"The sidecar pattern adds a helper container to each application pod:

Architecture:
┌─────────────────────────┐
│  Pod                    │
│  ┌───────────┐          │
│  │    App    │          │
│  └─────┬─────┘          │
│        │                │
│  ┌─────▼──────────────┐ │
│  │  Envoy Sidecar     │ │
│  └────────────────────┘ │
└─────────────────────────┘

How it works:
1. All traffic goes through sidecar
2. Sidecar applies policies
3. Sidecar collects metrics
4. App doesn't know sidecar exists

Benefits:
- No app code changes
- Consistent policies across services
- Language-agnostic
- Centralized configuration

In my project:
- Istio automatically injects Envoy sidecar
- Sidecar handles all network traffic
- App just makes normal HTTP calls
- Sidecar adds mTLS, retries, metrics

Example:
App makes: curl http://backend:3000
Sidecar:
1. Intercepts request
2. Adds mTLS encryption
3. Applies retry policy
4. Collects metrics
5. Forwards to destination sidecar
6. Destination sidecar decrypts
7. Forwards to destination app
```

### Q3: "How does Istio provide mTLS without code changes?"

**Answer:**

```
"Istio uses sidecar proxies to handle mTLS automatically:

Process:
1. App makes plain HTTP request
2. Sidecar intercepts traffic (iptables rules)
3. Sidecar encrypts with TLS
4. Sends to destination sidecar
5. Destination sidecar decrypts
6. Forwards plain HTTP to app

Certificate Management:
- Istio CA (Citadel) generates certificates
- Automatically rotates every 24 hours
- Each service gets unique identity
- Certificates stored in Kubernetes secrets

Configuration:
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT

Benefits:
- Zero code changes
- Automatic encryption
- Automatic rotation
- Mutual authentication

In my project:
- All service-to-service traffic encrypted
- Certificates auto-rotated
- No performance impact (hardware acceleration)
- Complete zero-trust security
```

### Q4: "What's the difference between Istio and Kubernetes Service?"

**Answer:**

```
"Kubernetes Service provides basic networking, Istio adds advanced features:

Kubernetes Service:
- Basic load balancing (round robin)
- Service discovery (DNS)
- Simple routing
- No security
- No observability

Istio (with Service):
- Advanced load balancing (least request, consistent hash)
- Intelligent routing (header-based, weight-based)
- Circuit breaking
- Retries and timeouts
- mTLS encryption
- Automatic metrics
- Distributed tracing

Example:

Kubernetes Service:
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
  - port: 3000

Istio VirtualService:
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend
spec:
  hosts:
  - backend
  http:
  - match:
    - headers:
        user-type:
          exact: beta
    route:
    - destination:
        host: backend
        subset: v2
  - route:
    - destination:
        host: backend
        subset: v1
      weight: 90
    - destination:
        host: backend
        subset: v2
      weight: 10

Istio adds:
- Header-based routing (beta users → v2)
- Weight-based routing (90% v1, 10% v2)
- Retries, timeouts, circuit breaking
- mTLS, metrics, tracing

Both work together:
- Service: Basic connectivity
- Istio: Advanced features
```

### Q5: "How do you troubleshoot Istio issues?"

**Answer:**

```
"I use multiple tools to troubleshoot:

1. Check Sidecar Injection:
kubectl get pods -l app=backend
# Should show 2/2 (app + sidecar)

kubectl describe pod <pod-name>
# Check for istio-proxy container

2. Check Istio Configuration:
istioctl analyze
# Validates configuration
# Shows errors and warnings

3. Check Proxy Status:
istioctl proxy-status
# Shows all proxies
# Sync status with control plane

4. Check Proxy Config:
istioctl proxy-config routes <pod-name>
# Shows routing rules
# Verify traffic routing

5. Check Logs:
kubectl logs <pod-name> -c istio-proxy
# Sidecar logs
# Shows traffic, errors

kubectl logs -n istio-system deploy/istiod
# Control plane logs
# Shows configuration issues

6. Use Kiali:
# Visual service graph
# Shows traffic flow
# Highlights errors

Common Issues:

Issue: Sidecar not injected
Solution: Check namespace label
kubectl label namespace default istio-injection=enabled

Issue: mTLS errors
Solution: Check PeerAuthentication
kubectl get peerauthentication

Issue: Traffic not routing
Solution: Check VirtualService
istioctl analyze

Issue: High latency
Solution: Check Jaeger traces
# Identify slow services
```

---

## 🎯 Part 8: Real-World Scenario

### Scenario: Canary Deployment with Istio

**Goal:** Deploy new version to 10% of users, monitor, then increase

```bash
# Step 1: Deploy v2 (1 replica)
kubectl apply -f backend-v2-deployment.yaml

# Step 2: Route 10% traffic to v2
cat > canary-10.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend
spec:
  hosts:
  - backend
  http:
  - route:
    - destination:
        host: backend
        subset: v1
      weight: 90
    - destination:
        host: backend
        subset: v2
      weight: 10
EOF

kubectl apply -f canary-10.yaml

# Step 3: Monitor metrics
# Check error rate, latency in Grafana
# If good, increase to 50%

# Step 4: Increase to 50%
cat > canary-50.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend
spec:
  hosts:
  - backend
  http:
  - route:
    - destination:
        host: backend
        subset: v1
      weight: 50
    - destination:
        host: backend
        subset: v2
      weight: 50
EOF

kubectl apply -f canary-50.yaml

# Step 5: Monitor again
# If still good, go to 100%

# Step 6: Full rollout
cat > canary-100.yaml << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend
spec:
  hosts:
  - backend
  http:
  - route:
    - destination:
        host: backend
        subset: v2
      weight: 100
EOF

kubectl apply -f canary-100.yaml

# Step 7: Scale down v1
kubectl scale deployment backend --replicas=0

# Benefits:
# - Gradual rollout
# - Monitor at each step
# - Easy rollback (change weights)
# - No downtime
# - User-based routing possible
```

---

## 📚 Part 9: Summary

**You now know:**

- ✅ What service mesh is and why to use it
- ✅ What Istio is and its components
- ✅ What sidecar pattern is and how it works
- ✅ How to install Istio
- ✅ How to enable sidecar injection
- ✅ Traffic management (routing, load balancing, circuit breaking)
- ✅ Security (mTLS)
- ✅ Observability (metrics, tracing, service graph)
- ✅ How to troubleshoot issues
- ✅ Real-world canary deployment scenario
- ✅ How to answer interview questions

**Time to master:** 2-3 days of practice

**Interview confidence:** 100% 🚀

---

## 🎉 Complete

**You can now confidently explain:**

- Service mesh concepts
- Istio architecture
- Sidecar pattern
- Traffic management
- mTLS security
- Observability features
- Real-world use cases

**Next:** Practice deploying and experimenting with Istio features!
