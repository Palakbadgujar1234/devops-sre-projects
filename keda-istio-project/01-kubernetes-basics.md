# Kubernetes Basics - Complete Beginner's Guide

## 🎯 What is Kubernetes?

### Simple Explanation

Imagine you have a restaurant:

- **Without Kubernetes**: You manually assign waiters to tables, manage kitchen staff, handle busy/slow times
- **With Kubernetes**: An automated manager handles all this - assigns staff, scales up during rush hours, replaces sick employees

**Kubernetes** is like that automated manager, but for your applications!

### Technical Definition

Kubernetes (K8s) is an **open-source container orchestration platform** that automates:

- Deployment
- Scaling
- Management
- Networking

of containerized applications.

---

## 🤔 Why Do We Need Kubernetes?

### Problem Without Kubernetes

```
Scenario: You have a web application

Manual Approach:
1. Deploy app on Server 1
2. Server 1 crashes → App is down! 😱
3. Traffic increases → Need to manually add Server 2, 3, 4
4. Update app → Manually update each server
5. One server has issues → Hard to detect and fix
```

### Solution With Kubernetes

```
Kubernetes Approach:
1. Tell K8s: "Run 3 copies of my app"
2. One crashes → K8s automatically starts a new one ✅
3. Traffic increases → K8s automatically adds more copies
4. Update app → K8s does rolling update (zero downtime)
5. Issues detected → K8s provides logs, metrics, health checks
```

---

## 🏗️ Kubernetes Architecture

### High-Level View

```
┌─────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                      │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │         Control Plane (Master Node)            │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐   │    │
│  │  │   API    │  │Scheduler │  │Controller│   │    │
│  │  │  Server  │  │          │  │ Manager  │   │    │
│  │  └──────────┘  └──────────┘  └──────────┘   │    │
│  └────────────────────────────────────────────────┘    │
│                         │                               │
│                         ↓                               │
│  ┌─────────────────────────────────────────────────┐  │
│  │              Worker Nodes                        │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐        │  │
│  │  │  Node 1 │  │  Node 2 │  │  Node 3 │        │  │
│  │  │  Pods   │  │  Pods   │  │  Pods   │        │  │
│  │  └─────────┘  └─────────┘  └─────────┘        │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Components Explained

#### 1. **Control Plane (Brain)**

- **API Server**: Front door to Kubernetes (all commands go here)
- **Scheduler**: Decides which worker node runs your app
- **Controller Manager**: Ensures desired state matches actual state
- **etcd**: Database storing all cluster data

#### 2. **Worker Nodes (Muscles)**

- **Kubelet**: Agent running on each node, manages containers
- **Container Runtime**: Docker/containerd - runs containers
- **Kube-proxy**: Handles networking

---

## 📦 Core Kubernetes Concepts

### 1. Pod (Smallest Unit)

**What**: A pod is the smallest deployable unit in Kubernetes
**Think**: A pod is like a house where containers live

```yaml
# Simple Pod Example
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
spec:
  containers:
  - name: my-app
    image: nginx:latest
    ports:
    - containerPort: 80
```

**Real-World Analogy**:

```
Pod = House
Container = Person living in the house
Usually 1 person per house (1 container per pod)
Sometimes roommates (multiple containers in one pod)
```

**Key Points**:

- ✅ Pods are ephemeral (temporary)
- ✅ Each pod gets its own IP address
- ✅ Containers in a pod share network and storage
- ✅ If a pod dies, Kubernetes creates a new one

---

### 2. Deployment (Manages Pods)

**What**: Manages multiple identical pods
**Think**: A deployment is like a factory that produces identical products

```yaml
# Deployment Example
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 3  # Run 3 copies
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

**What This Does**:

```
1. Creates 3 identical pods
2. If one pod dies → Creates a new one
3. Can scale up/down easily
4. Handles rolling updates
```

**Real-World Scenario**:

```
E-commerce Website:
- Deployment: "web-frontend"
- Replicas: 5 pods
- One pod crashes → Deployment creates new one
- Black Friday → Scale to 20 pods
- After sale → Scale back to 5 pods
```

---

### 3. Service (Networking)

**What**: Provides stable network endpoint for pods
**Think**: Like a phone number that stays same even if you change phones

```yaml
# Service Example
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

**Why Needed**:

```
Problem: Pods have changing IP addresses
- Pod 1: 10.0.0.1 (dies)
- Pod 2: 10.0.0.2 (new IP!)

Solution: Service provides stable IP
- Service: 10.0.1.100 (never changes)
- Routes traffic to healthy pods
```

**Service Types**:

1. **ClusterIP** (Default)
   - Internal only
   - Use: Communication between services inside cluster

2. **NodePort**
   - Exposes on each node's IP
   - Use: Development/testing

3. **LoadBalancer**
   - Creates external load balancer
   - Use: Production (exposes to internet)

---

### 4. ConfigMap (Configuration)

**What**: Stores configuration data
**Think**: Like a settings file

```yaml
# ConfigMap Example
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://db:5432"
  api_key: "dev-key-123"
  log_level: "info"
```

**Usage in Pod**:

```yaml
spec:
  containers:
  - name: my-app
    image: my-app:latest
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
```

**Why Use ConfigMap**:

- ✅ Separate config from code
- ✅ Easy to update without rebuilding image
- ✅ Different configs for dev/staging/prod

---

### 5. Secret (Sensitive Data)

**What**: Like ConfigMap but for sensitive data
**Think**: Like a password manager

```yaml
# Secret Example
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  db-password: cGFzc3dvcmQxMjM=  # base64 encoded
  api-token: dG9rZW4tYWJjMTIz
```

**Usage**:

```yaml
spec:
  containers:
  - name: my-app
    image: my-app:latest
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: db-password
```

**Key Differences from ConfigMap**:

- ✅ Base64 encoded
- ✅ Can be encrypted at rest
- ✅ More access controls
- ✅ Not shown in logs

---

### 6. Namespace (Isolation)

**What**: Virtual clusters within a cluster
**Think**: Like folders on your computer

```yaml
# Namespace Example
apiVersion: v1
kind: Namespace
metadata:
  name: development
```

**Common Namespaces**:

```
default          → Default namespace
kube-system      → Kubernetes system components
kube-public      → Public resources
development      → Dev environment
staging          → Staging environment
production       → Production environment
```

**Why Use Namespaces**:

- ✅ Organize resources
- ✅ Separate environments
- ✅ Apply different policies
- ✅ Resource quotas per namespace

---

## 🔄 How Kubernetes Works

### Example: Deploying an Application

```
Step 1: You create a Deployment
↓
Step 2: API Server receives request
↓
Step 3: Scheduler assigns pods to nodes
↓
Step 4: Kubelet on nodes starts containers
↓
Step 5: Controller Manager monitors health
↓
Step 6: If pod dies, Controller creates new one
```

### Self-Healing Example

```
Scenario: Pod crashes

1. Pod crashes on Node 1
2. Kubelet detects crash
3. Reports to API Server
4. Controller Manager sees mismatch:
   - Desired: 3 pods
   - Actual: 2 pods
5. Controller creates new pod
6. Scheduler assigns to Node 2
7. Kubelet starts new pod
8. Back to 3 pods! ✅
```

---

## 🎯 Real-World Use Cases

### Use Case 1: E-commerce Website

```yaml
# Frontend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 5
  template:
    spec:
      containers:
      - name: web
        image: ecommerce-frontend:v1
---
# Backend API Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  replicas: 10
  template:
    spec:
      containers:
      - name: api
        image: ecommerce-api:v1
---
# Database (StatefulSet for persistence)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: postgres
        image: postgres:13
```

**Benefits**:

- ✅ Auto-scaling during sales
- ✅ Zero-downtime updates
- ✅ Self-healing if crashes
- ✅ Easy rollback if issues

---

### Use Case 2: Microservices Architecture

```
┌─────────────────────────────────────────┐
│         Kubernetes Cluster              │
│                                         │
│  ┌──────────┐  ┌──────────┐           │
│  │  User    │  │  Order   │           │
│  │ Service  │→ │ Service  │           │
│  └──────────┘  └──────────┘           │
│       ↓              ↓                 │
│  ┌──────────┐  ┌──────────┐           │
│  │ Payment  │  │Inventory │           │
│  │ Service  │  │ Service  │           │
│  └──────────┘  └──────────┘           │
│                                         │
│  Each service:                          │
│  - Independent deployment               │
│  - Own database                         │
│  - Can scale independently              │
└─────────────────────────────────────────┘
```

---

## 🛠️ Basic kubectl Commands

### Viewing Resources

```bash
# Get all pods
kubectl get pods

# Get all deployments
kubectl get deployments

# Get all services
kubectl get services

# Get everything
kubectl get all

# Detailed info about a pod
kubectl describe pod <pod-name>

# Watch pods in real-time
kubectl get pods --watch
```

### Creating Resources

```bash
# Create from YAML file
kubectl apply -f deployment.yaml

# Create from directory
kubectl apply -f ./k8s/

# Create namespace
kubectl create namespace dev
```

### Debugging

```bash
# View logs
kubectl logs <pod-name>

# Follow logs (like tail -f)
kubectl logs -f <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward to local machine
kubectl port-forward <pod-name> 8080:80
```

### Scaling

```bash
# Scale deployment
kubectl scale deployment my-app --replicas=5

# Auto-scale based on CPU
kubectl autoscale deployment my-app --min=2 --max=10 --cpu-percent=80
```

### Deleting

```bash
# Delete pod
kubectl delete pod <pod-name>

# Delete deployment
kubectl delete deployment <deployment-name>

# Delete from file
kubectl delete -f deployment.yaml

# Delete everything in namespace
kubectl delete all --all -n <namespace>
```

---

## 📊 Kubernetes vs Traditional Deployment

| Feature | Traditional | Kubernetes |
|---------|------------|------------|
| **Deployment** | Manual SSH to servers | Declarative YAML |
| **Scaling** | Manual server addition | Automatic scaling |
| **Updates** | Downtime required | Rolling updates |
| **Recovery** | Manual restart | Self-healing |
| **Load Balancing** | External LB setup | Built-in Service |
| **Monitoring** | Separate tools | Integrated metrics |
| **Networking** | Manual configuration | Automatic DNS |

---

## 🎓 Key Takeaways

### What You Learned

- ✅ Kubernetes automates container management
- ✅ Pods are the smallest unit
- ✅ Deployments manage multiple pods
- ✅ Services provide stable networking
- ✅ ConfigMaps and Secrets store configuration
- ✅ Namespaces organize resources
- ✅ Kubernetes is self-healing

### Why It Matters

- ✅ Reduces manual work
- ✅ Increases reliability
- ✅ Enables auto-scaling
- ✅ Simplifies updates
- ✅ Industry standard

---

## 🚀 Next Steps

Now that you understand Kubernetes basics, you're ready to learn about:

**Next**: [What is Istio Service Mesh?](./02-istio-explained.md)

This will build on your Kubernetes knowledge and show you how to add advanced networking, security, and observability to your applications!

---

## 📝 Practice Exercise

Try creating this simple deployment:

```yaml
# Save as nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

```bash
# Deploy it
kubectl apply -f nginx-deployment.yaml

# Check status
kubectl get pods
kubectl get services

# Access it
kubectl port-forward service/nginx-service 8080:80
# Open browser: http://localhost:8080

# Clean up
kubectl delete -f nginx-deployment.yaml
```

**Congratulations!** You now understand Kubernetes fundamentals! 🎉
