# 🏗️ Architecture Deep Dive

## 📖 Overview

This guide provides a **detailed explanation** of the microservices platform architecture, covering every component, design decision, and how everything works together.

---

## 🎯 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Route 53 (DNS)                            │
│              api.example.com → ALB IP                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              Application Load Balancer (ALB)                     │
│  - SSL/TLS Termination                                          │
│  - Health Checks                                                │
│  - Path-based Routing                                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.0.0/16)                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Public Subnets (10.0.1.0/24)                │  │
│  │  - NAT Gateway                                           │  │
│  │  - Load Balancer                                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │             Private Subnets (10.0.10.0/24)               │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │         EKS Cluster (Kubernetes)                   │  │  │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │  │  │
│  │  │  │  Frontend    │  │   Backend    │  │PostgreSQL│ │  │  │
│  │  │  │  Deployment  │  │  Deployment  │  │StatefulSet│ │  │  │
│  │  │  │  3 Replicas  │  │  3 Replicas  │  │ 1 Replica│ │  │  │
│  │  │  └──────────────┘  └──────────────┘  └──────────┘ │  │  │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │  │  │
│  │  │  │ Prometheus   │  │   Grafana    │  │   EFK    │ │  │  │
│  │  │  │  Monitoring  │  │  Dashboard   │  │ Logging  │ │  │  │
│  │  │  └──────────────┘  └──────────────┘  └──────────┘ │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    External Services                             │
│  - AWS ECR (Container Registry)                                 │
│  - AWS S3 (Backups, Logs)                                       │
│  - AWS Secrets Manager                                          │
│  - AWS CloudWatch                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔍 Component Deep Dive

### 1. Frontend Layer (React Application)

**WHAT:** User-facing web application

**WHY:** Provides intuitive interface for users

**TECHNOLOGY:** React + Nginx

**Architecture:**

```
┌─────────────────────────────────────────┐
│         Frontend Deployment             │
│  ┌───────────────────────────────────┐  │
│  │  Pod 1: frontend-abc123           │  │
│  │  ┌─────────────┐  ┌─────────────┐ │  │
│  │  │   Nginx     │  │ React Build │ │  │
│  │  │   (Port 80) │→ │ Static Files│ │  │
│  │  └─────────────┘  └─────────────┘ │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Pod 2: frontend-def456           │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Pod 3: frontend-ghi789           │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Key Features:**

- **Static File Serving:** Nginx serves pre-built React files
- **Client-Side Routing:** React Router handles navigation
- **API Communication:** Axios for HTTP requests to backend
- **Responsive Design:** Works on desktop and mobile
- **Health Checks:** `/health` endpoint for Kubernetes

**Resource Configuration:**

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
  limits:
    memory: "128Mi"
    cpu: "200m"
```

**Scaling Strategy:**

- Horizontal Pod Autoscaler (HPA)
- Scale based on CPU usage
- Min: 3 replicas, Max: 10 replicas
- Target: 70% CPU utilization

---

### 2. Backend Layer (Node.js API)

**WHAT:** RESTful API server

**WHY:** Business logic and data processing

**TECHNOLOGY:** Node.js + Express + PostgreSQL

**Architecture:**

```
┌─────────────────────────────────────────┐
│          Backend Deployment             │
│  ┌───────────────────────────────────┐  │
│  │  Pod 1: backend-abc123            │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  Express Server (Port 3000) │  │  │
│  │  │  ┌─────────────────────────┐│  │  │
│  │  │  │ Routes:                 ││  │  │
│  │  │  │ - GET  /health          ││  │  │
│  │  │  │ - GET  /ready           ││  │  │
│  │  │  │ - GET  /metrics         ││  │  │
│  │  │  │ - GET  /api/users       ││  │  │
│  │  │  │ - POST /api/users       ││  │  │
│  │  │  │ - DELETE /api/users/:id ││  │  │
│  │  │  └─────────────────────────┘│  │  │
│  │  │  ┌─────────────────────────┐│  │  │
│  │  │  │ Connection Pool         ││  │  │
│  │  │  │ - Max: 20 connections   ││  │  │
│  │  │  │ - Idle timeout: 30s     ││  │  │
│  │  │  └─────────────────────────┘│  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Pod 2: backend-def456            │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Pod 3: backend-ghi789            │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**API Endpoints:**

1. **Health Check (`GET /health`)**
   - Purpose: Kubernetes liveness probe
   - Checks: Database connectivity
   - Response: 200 (healthy) or 503 (unhealthy)

2. **Readiness Check (`GET /ready`)**
   - Purpose: Kubernetes readiness probe
   - Checks: Application ready to serve traffic
   - Response: 200 (ready) or 503 (not ready)

3. **Metrics (`GET /metrics`)**
   - Purpose: Prometheus monitoring
   - Returns: CPU, memory, uptime
   - Format: JSON

4. **Get Users (`GET /api/users`)**
   - Purpose: Fetch all users
   - Response: Array of user objects
   - Pagination: Future enhancement

5. **Create User (`POST /api/users`)**
   - Purpose: Create new user
   - Body: `{ name, email }`
   - Validation: Required fields, email format

6. **Delete User (`DELETE /api/users/:id`)**
   - Purpose: Delete user by ID
   - Response: Success or 404

**Resource Configuration:**

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "200m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

**Scaling Strategy:**

- HPA based on CPU and memory
- Min: 3 replicas, Max: 20 replicas
- Target: 70% CPU, 80% memory

---

### 3. Database Layer (PostgreSQL)

**WHAT:** Relational database for data persistence

**WHY:** ACID compliance, reliability, SQL support

**TECHNOLOGY:** PostgreSQL 15

**Architecture:**

```
┌─────────────────────────────────────────┐
│       PostgreSQL StatefulSet            │
│  ┌───────────────────────────────────┐  │
│  │  Pod: postgres-0                  │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  PostgreSQL Server          │  │  │
│  │  │  (Port 5432)                │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │ Database: myapp       │  │  │  │
│  │  │  │ Tables:               │  │  │  │
│  │  │  │ - users               │  │  │  │
│  │  │  │   - id (PK)           │  │  │  │
│  │  │  │   - name              │  │  │  │
│  │  │  │   - email (UNIQUE)    │  │  │  │
│  │  │  │   - created_at        │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  PersistentVolume           │  │  │
│  │  │  - Size: 10Gi               │  │  │
│  │  │  - Type: EBS                │  │  │
│  │  │  - Backup: Daily to S3      │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Why StatefulSet?**

- Stable network identity (postgres-0)
- Persistent storage per pod
- Ordered deployment and scaling
- Required for databases

**Schema Design:**

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

**Backup Strategy:**

- Automated daily backups to S3
- Point-in-time recovery
- Retention: 30 days
- Tested restore procedures

---

### 4. Networking Layer

**WHAT:** Network communication between components

**WHY:** Secure, reliable communication

**Components:**

#### A. Services (Kubernetes)

**Frontend Service:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
```

- **Type:** LoadBalancer (creates AWS ALB)
- **Purpose:** Expose frontend to internet
- **Port:** 80 (HTTP)

**Backend Service:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 3000
```

- **Type:** ClusterIP (internal only)
- **Purpose:** Frontend → Backend communication
- **Port:** 3000

**Database Service:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  type: ClusterIP
  clusterIP: None  # Headless service
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

- **Type:** Headless (for StatefulSet)
- **Purpose:** Backend → Database communication
- **Port:** 5432

#### B. Network Policies

**Backend Network Policy:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
```

**Purpose:**

- Restrict traffic to backend
- Only frontend can access backend
- Backend can only access database
- Security through network isolation

---

### 5. Monitoring Layer (Prometheus + Grafana)

**WHAT:** Metrics collection and visualization

**WHY:** Observability, alerting, troubleshooting

**Architecture:**

```
┌─────────────────────────────────────────┐
│         Monitoring Stack                │
│  ┌───────────────────────────────────┐  │
│  │  Prometheus                       │  │
│  │  - Scrapes metrics every 15s      │  │
│  │  - Stores time-series data        │  │
│  │  - Evaluates alert rules          │  │
│  │  - Retention: 15 days             │  │
│  └───────────────────────────────────┘  │
│              ↓                           │
│  ┌───────────────────────────────────┐  │
│  │  Grafana                          │  │
│  │  - Visualizes metrics             │  │
│  │  - Custom dashboards              │  │
│  │  - Alert notifications            │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
         ↑           ↑           ↑
         │           │           │
    Frontend     Backend     Database
    (metrics)   (metrics)   (metrics)
```

**Metrics Collected:**

1. **Application Metrics:**
   - Request rate
   - Response time (p50, p95, p99)
   - Error rate
   - Active connections

2. **Infrastructure Metrics:**
   - CPU usage
   - Memory usage
   - Disk I/O
   - Network traffic

3. **Business Metrics:**
   - User signups
   - API calls per endpoint
   - Database queries

**Dashboards:**

1. Application Overview
2. Infrastructure Health
3. SLO Compliance
4. Error Budget Tracking
5. Database Performance

---

### 6. Logging Layer (EFK Stack)

**WHAT:** Centralized log aggregation

**WHY:** Debugging, auditing, compliance

**Architecture:**

```
┌─────────────────────────────────────────┐
│            Logging Stack                │
│  ┌───────────────────────────────────┐  │
│  │  Fluentd (DaemonSet)              │  │
│  │  - Runs on every node             │  │
│  │  - Collects container logs        │  │
│  │  - Parses and enriches            │  │
│  └───────────────────────────────────┘  │
│              ↓                           │
│  ┌───────────────────────────────────┐  │
│  │  Elasticsearch                    │  │
│  │  - Stores logs                    │  │
│  │  - Indexes for search             │  │
│  │  - Retention: 30 days             │  │
│  └───────────────────────────────────┘  │
│              ↓                           │
│  ┌───────────────────────────────────┐  │
│  │  Kibana                           │  │
│  │  - Search logs                    │  │
│  │  - Visualize patterns             │  │
│  │  - Create alerts                  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Log Format:**

```json
{
  "timestamp": "2024-01-15T10:00:00Z",
  "level": "INFO",
  "service": "backend",
  "pod": "backend-abc123",
  "message": "User created successfully",
  "userId": "123",
  "duration": "45ms"
}
```

---

### 7. CI/CD Pipeline (GitHub Actions)

**WHAT:** Automated build and deployment

**WHY:** Fast, reliable releases

**Pipeline Flow:**

```
Code Push → GitHub
     ↓
GitHub Actions Triggered
     ↓
┌─────────────────────┐
│  Build Stage        │
│  - Checkout code    │
│  - Run linting      │
│  - Run tests        │
│  - Build Docker     │
│  - Scan image       │
└─────────────────────┘
     ↓
┌─────────────────────┐
│  Push Stage         │
│  - Tag image        │
│  - Push to ECR      │
│  - Update manifests │
└─────────────────────┘
     ↓
┌─────────────────────┐
│  Deploy Stage       │
│  - ArgoCD detects   │
│  - Rolling update   │
│  - Health checks    │
│  - Monitor          │
└─────────────────────┘
     ↓
Production Deployed ✅
```

---

## 🔐 Security Architecture

### 1. Network Security

**VPC Design:**

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24)
│   ├── NAT Gateway
│   └── Load Balancer
└── Private Subnets (10.0.10.0/24)
    ├── EKS Worker Nodes
    ├── Application Pods
    └── Database
```

**Security Groups:**

- ALB: Allow 80/443 from internet
- Worker Nodes: Allow traffic from ALB
- Database: Allow 5432 from worker nodes only

### 2. Application Security

**Authentication & Authorization:**

- JWT tokens for API authentication
- RBAC in Kubernetes
- IAM roles for AWS resources

**Secrets Management:**

- Kubernetes Secrets for sensitive data
- AWS Secrets Manager for rotation
- No secrets in code or images

### 3. Container Security

**Image Security:**

- Multi-stage builds (smaller attack surface)
- Non-root user
- Vulnerability scanning with Trivy
- Signed images

**Runtime Security:**

- Read-only root filesystem
- Drop all capabilities
- Resource limits
- Network policies

---

## 📈 Scalability Architecture

### Horizontal Scaling

**Application Layer:**

```
Load: Low (100 req/s)
Frontend: 3 pods
Backend: 3 pods

Load: Medium (1000 req/s)
Frontend: 6 pods
Backend: 10 pods

Load: High (10000 req/s)
Frontend: 10 pods
Backend: 20 pods
```

**Auto-Scaling Configuration:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Vertical Scaling

**Cluster Auto-Scaler:**

- Automatically adds nodes when pods pending
- Removes nodes when underutilized
- Cost optimization

---

## 🎯 Design Decisions & Trade-offs

### 1. Why Kubernetes over ECS?

**Chosen:** Kubernetes (EKS)

**Reasons:**

- ✅ Industry standard
- ✅ Portable across clouds
- ✅ Rich ecosystem
- ✅ Better for learning

**Trade-off:**

- ❌ More complex than ECS
- ❌ Steeper learning curve

### 2. Why PostgreSQL over NoSQL?

**Chosen:** PostgreSQL

**Reasons:**

- ✅ ACID compliance
- ✅ Relational data model
- ✅ Strong consistency
- ✅ SQL support

**Trade-off:**

- ❌ Harder to scale horizontally
- ❌ Schema changes require migrations

### 3. Why Rolling Deployment?

**Chosen:** Rolling Update

**Reasons:**

- ✅ Zero downtime
- ✅ Built into Kubernetes
- ✅ No extra cost
- ✅ Easy rollback

**Trade-off:**

- ❌ Slower than Blue-Green
- ❌ Version mixing during update

---

## 🚀 Performance Characteristics

### Expected Performance

**Throughput:**

- Frontend: 10,000 requests/second
- Backend: 5,000 requests/second
- Database: 1,000 queries/second

**Latency:**

- Frontend: p95 < 100ms
- Backend: p95 < 200ms
- Database: p95 < 50ms

**Availability:**

- Target: 99.9% (3 nines)
- Downtime: 43 minutes/month
- Achieved through redundancy

---

## 📚 Summary

This architecture provides:

- ✅ High availability (multiple replicas)
- ✅ Scalability (auto-scaling)
- ✅ Security (network policies, secrets)
- ✅ Observability (monitoring, logging)
- ✅ Reliability (health checks, rollback)
- ✅ Performance (optimized resources)

**Next:** [Prerequisites Setup →](02-PREREQUISITES.md)
