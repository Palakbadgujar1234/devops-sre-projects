# 🎯 Interview Questions & Answers

## 📚 Complete Guide for Interview Preparation

This document contains **50+ interview questions** based on this CI/CD project, with detailed answers that demonstrate your understanding.

---

## 🎯 Table of Contents

1. [General CI/CD Questions](#general-cicd-questions)
2. [Docker Questions](#docker-questions)
3. [Kubernetes Questions](#kubernetes-questions)
4. [Jenkins Questions](#jenkins-questions)
5. [Troubleshooting Questions](#troubleshooting-questions)
6. [Architecture & Design Questions](#architecture--design-questions)
7. [Scenario-Based Questions](#scenario-based-questions)
8. [Best Practices Questions](#best-practices-questions)

---

## 🔄 General CI/CD Questions

### Q1: What is CI/CD and why is it important?

**Answer:**
CI/CD stands for Continuous Integration and Continuous Deployment/Delivery.

**Continuous Integration (CI):**

- Developers frequently merge code to main branch
- Automated builds and tests run on each commit
- Catches bugs early
- Reduces integration problems

**Continuous Deployment (CD):**

- Automatically deploys code to production
- After passing all tests
- Fast delivery to users
- Reduces manual errors

**Why Important:**

1. **Faster Time to Market**: Deploy multiple times per day
2. **Better Quality**: Automated testing catches bugs early
3. **Reduced Risk**: Small, frequent changes are safer
4. **Developer Productivity**: Less time on manual tasks
5. **Customer Satisfaction**: Faster bug fixes and features

**Example from my project:**

```
Developer pushes code → GitHub webhook → Jenkins pipeline
→ Build → Test → Docker image → Deploy to Kubernetes
→ Live in production (5-10 minutes total)
```

---

### Q2: Walk me through your CI/CD pipeline

**Answer:**
My pipeline has 6 main stages:

**1. Checkout (5 seconds)**

- Jenkins pulls latest code from GitHub
- Triggered by webhook on git push

**2. Build (10-30 seconds)**

- Install dependencies with `npm ci`
- Faster and more reliable than `npm install`

**3. Test (5-10 seconds)**

- Run unit tests with Jest
- Generate coverage report
- Pipeline fails if tests fail

**4. Docker Build (20-60 seconds)**

- Build Docker image from Dockerfile
- Tag with build number for versioning
- Also tag as 'latest'

**5. Push to Registry (10-30 seconds)**

- Push image to Docker Hub
- Uses credentials stored in Jenkins
- Both tags pushed (build number and latest)

**6. Deploy to Kubernetes (20-40 seconds)**

- Apply deployment and service YAML
- Kubernetes pulls new image
- Rolling update with zero downtime
- Health checks ensure pods are ready

**Total Time:** 2-5 minutes from code push to production

**Key Features:**

- Fully automated (no manual steps)
- Fails fast (stops on first error)
- Rollback capability (previous images available)
- Zero downtime deployment

---

### Q3: How do you ensure zero-downtime deployments?

**Answer:**
I use Kubernetes Rolling Update strategy:

**Configuration:**

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Max 1 extra pod during update
    maxUnavailable: 1  # Max 1 pod down during update
```

**How it works:**

1. **Start with 3 pods** running version 1.0
2. **Create 1 new pod** with version 2.0 (now 4 pods total)
3. **Wait for new pod** to pass health checks
4. **Terminate 1 old pod** (back to 3 pods)
5. **Repeat** until all pods are version 2.0

**Why Zero Downtime:**

- Always have pods serving traffic
- New pods must be healthy before old ones terminate
- Service load balances across all healthy pods
- If new version fails health checks, rollout stops

**Additional Safety:**

- Readiness probes ensure pod is ready
- Liveness probes detect unhealthy pods
- Can rollback with `kubectl rollout undo`

---

## 🐳 Docker Questions

### Q4: Explain your Dockerfile and why you structured it that way

**Answer:**

```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

**Why this structure:**

**1. Base Image (node:16-alpine)**

- Alpine Linux is small (5MB vs 900MB)
- Reduces image size and attack surface
- Faster to pull and deploy

**2. WORKDIR /app**

- Sets working directory
- All commands run in /app
- Cleaner than using cd

**3. COPY package*.json first**

- Enables Docker layer caching
- If package.json unchanged, npm install is cached
- Saves time on rebuilds

**4. RUN npm ci --only=production**

- npm ci is faster and more reliable
- --only=production excludes dev dependencies
- Smaller image size

**5. COPY . . last**

- Application code changes frequently
- Copying last maximizes cache usage
- Only rebuilds from this point if code changes

**6. EXPOSE 3000**

- Documents which port app uses
- Doesn't actually publish port

**7. CMD ["node", "app.js"]**

- Command to run when container starts
- JSON array format is preferred

**Result:**

- Image size: ~150MB (vs 900MB without optimization)
- Build time: 30 seconds (vs 2 minutes)
- Cache hit rate: 80%+

---

### Q5: How would you optimize a Docker image that's too large?

**Answer:**
Multiple strategies:

**1. Use Alpine Base Images**

```dockerfile
# Before: 900MB
FROM node:16

# After: 150MB
FROM node:16-alpine
```

**2. Multi-Stage Builds**

```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/app.js"]
```

**3. Exclude Unnecessary Files**

```
# .dockerignore
node_modules/
test/
.git/
README.md
```

**4. Remove Dev Dependencies**

```dockerfile
RUN npm ci --only=production
```

**5. Minimize Layers**

```dockerfile
# Bad: 3 layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# Good: 1 layer
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean
```

**6. Use .dockerignore**

- Prevents copying unnecessary files
- Reduces build context size
- Faster builds

**Real Example:**

- Original: 3GB
- After optimization: 300MB
- 10x reduction!

---

### Q6: What's the difference between CMD and ENTRYPOINT?

**Answer:**

**CMD:**

- Default command to run
- Can be overridden
- Used for default arguments

**ENTRYPOINT:**

- Main command to run
- Not easily overridden
- Used for executable containers

**Examples:**

**Using CMD:**

```dockerfile
CMD ["node", "app.js"]
```

```bash
# Runs: node app.js
docker run myapp

# Runs: /bin/bash (CMD overridden)
docker run myapp /bin/bash
```

**Using ENTRYPOINT:**

```dockerfile
ENTRYPOINT ["node"]
CMD ["app.js"]
```

```bash
# Runs: node app.js
docker run myapp

# Runs: node server.js (CMD overridden)
docker run myapp server.js

# Still runs node (ENTRYPOINT not overridden)
```

**Best Practice:**

- Use ENTRYPOINT for main executable
- Use CMD for default arguments
- Combine both for flexibility

**My Choice:**
I use CMD because:

- Simpler for this use case
- Easy to override for debugging
- Standard for Node.js apps

---

## ☸️ Kubernetes Questions

### Q7: Explain the difference between a Pod, Deployment, and Service

**Answer:**

**Pod:**

- Smallest deployable unit
- Wraps one or more containers
- Shares network and storage
- Ephemeral (can be deleted/recreated)

**Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
  - name: myapp
    image: myapp:1.0
```

**Deployment:**

- Manages multiple identical Pods
- Ensures desired number of Pods running
- Handles updates and rollbacks
- Self-healing (replaces failed Pods)

**Example:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
```

**Service:**

- Provides stable network endpoint
- Load balances traffic across Pods
- Pods can die/restart (new IPs)
- Service IP stays constant

**Example:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 3000
```

**Analogy:**

- **Pod** = Individual server
- **Deployment** = Server manager (ensures 3 servers always running)
- **Service** = Load balancer (routes traffic to servers)

---

### Q8: What are liveness and readiness probes? Why are they important?

**Answer:**

**Liveness Probe:**

- Checks if container is alive
- If fails → Kubernetes restarts container
- Detects hung or crashed applications

**Example:**

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3
```

**Readiness Probe:**

- Checks if container is ready for traffic
- If fails → Removes from Service endpoints
- Prevents sending traffic to unready pods

**Example:**

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 3
```

**Key Differences:**

| Aspect | Liveness | Readiness |
|--------|----------|-----------|
| **Purpose** | Is it alive? | Ready for traffic? |
| **Failure Action** | Restart container | Remove from service |
| **Use Case** | Detect deadlocks | Detect slow startup |

**Why Important:**

**1. Self-Healing:**

- Automatically restart unhealthy containers
- No manual intervention needed

**2. Zero Downtime:**

- Don't send traffic to unready pods
- Smooth deployments

**3. Better Reliability:**

- Detect issues early
- Prevent cascading failures

**Real Example:**

```
Scenario: Database connection lost

Without probes:
- Container keeps running
- Returns 500 errors to users
- Manual restart needed

With probes:
- Liveness probe fails
- Kubernetes restarts container
- Container reconnects to database
- Automatic recovery
```

---

### Q9: How does Kubernetes handle scaling?

**Answer:**

**Two Types of Scaling:**

**1. Horizontal Scaling (Add more Pods)**

**Manual:**

```bash
kubectl scale deployment myapp --replicas=5
```

**Automatic (HPA):**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**How HPA Works:**

1. Monitor CPU usage every 15 seconds
2. If CPU > 70%:
   - Calculate needed replicas
   - Scale up gradually
3. If CPU < 70%:
   - Wait 5 minutes (cooldown)
   - Scale down gradually

**2. Vertical Scaling (Bigger Pods)**

```yaml
resources:
  requests:
    memory: "256Mi"  # Increased from 128Mi
    cpu: "200m"      # Increased from 100m
  limits:
    memory: "512Mi"
    cpu: "400m"
```

**When to Use Each:**

**Horizontal Scaling:**

- ✅ Stateless applications
- ✅ Need high availability
- ✅ Variable load
- ❌ Stateful applications

**Vertical Scaling:**

- ✅ Memory-intensive apps
- ✅ Single-instance apps
- ❌ Limited by node size

**My Project:**

- Uses horizontal scaling
- 3 replicas minimum
- Can scale to 10 based on CPU
- Handles traffic spikes automatically

---

### Q10: What happens when a node fails in Kubernetes?

**Answer:**

**Failure Detection:**

1. Kubelet stops sending heartbeats
2. After 40 seconds → Node marked NotReady
3. After 5 minutes → Pods evicted

**Recovery Process:**

**Step 1: Mark Node NotReady**

```bash
$ kubectl get nodes
NAME     STATUS     AGE
node-1   Ready      10d
node-2   NotReady   10d  ← Failed node
node-3   Ready      10d
```

**Step 2: Evict Pods**

- Kubernetes evicts pods from failed node
- Respects PodDisruptionBudgets
- Graceful termination (30 seconds default)

**Step 3: Reschedule Pods**

- Scheduler assigns pods to healthy nodes
- Considers resource availability
- Respects affinity/anti-affinity rules

**Step 4: Start New Pods**

- Kubelet on healthy nodes starts pods
- Pulls images if needed
- Runs health checks

**Timeline:**

```
0:00 - Node fails
0:40 - Marked NotReady
5:00 - Pods evicted
5:30 - New pods scheduled
6:00 - New pods running
```

**Impact on My Application:**

```
Before failure:
Node 1: Pod 1 ✓
Node 2: Pod 2 ✓  ← Node fails
Node 3: Pod 3 ✓

After recovery:
Node 1: Pod 1, Pod 2 (new) ✓
Node 2: OFFLINE ✗
Node 3: Pod 3 ✓
```

**Minimizing Impact:**

1. **Multiple Replicas**: Always have backup pods
2. **Pod Anti-Affinity**: Spread pods across nodes
3. **Resource Requests**: Ensure capacity for rescheduling
4. **Health Checks**: Detect issues quickly

---

## 🔧 Jenkins Questions

### Q11: Explain your Jenkins pipeline stages

**Answer:**

My pipeline has 6 stages:

**1. Checkout**

```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

- Pulls code from GitHub
- Triggered by webhook
- Shows commit info

**2. Build**

```groovy
stage('Build') {
    steps {
        sh 'npm ci'
    }
}
```

- Installs dependencies
- Uses npm ci (faster, reliable)
- Fails if dependencies missing

**3. Test**

```groovy
stage('Test') {
    steps {
        sh 'npm test'
    }
}
```

- Runs unit tests
- Generates coverage report
- Fails pipeline if tests fail

**4. Docker Build**

```groovy
stage('Docker Build') {
    steps {
        script {
            docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
        }
    }
}
```

- Builds Docker image
- Tags with build number
- Also tags as 'latest'

**5. Push to Registry**

```groovy
stage('Push') {
    steps {
        script {
            docker.withRegistry('https://docker.io', 'credentials') {
                docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}").push()
            }
        }
    }
}
```

- Pushes to Docker Hub
- Uses stored credentials
- Pushes both tags

**6. Deploy**

```groovy
stage('Deploy') {
    steps {
        sh 'kubectl apply -f k8s/'
        sh 'kubectl rollout status deployment/myapp'
    }
}
```

- Deploys to Kubernetes
- Waits for rollout completion
- Fails if deployment fails

**Why This Order:**

- Fail fast (tests before build)
- Build once, deploy anywhere
- Automated and repeatable

---

### Q12: How do you handle secrets in Jenkins?

**Answer:**

**Never Hardcode Secrets:**

```groovy
// ❌ BAD
sh 'docker login -u myuser -p mypassword123'

// ✅ GOOD
withCredentials([usernamePassword(...)]) {
    sh 'docker login -u $USER -p $PASS'
}
```

**Storing Secrets:**

**1. Jenkins Credentials**

- Navigate to: Manage Jenkins → Credentials
- Add credentials (username/password, secret text, etc.)
- Give it an ID (e.g., 'docker-hub-credentials')

**2. Using in Pipeline**

```groovy
environment {
    DOCKER_CREDS = credentials('docker-hub-credentials')
}

stages {
    stage('Push') {
        steps {
            sh 'docker login -u $DOCKER_CREDS_USR -p $DOCKER_CREDS_PSW'
        }
    }
}
```

**3. Using withCredentials**

```groovy
withCredentials([
    usernamePassword(
        credentialsId: 'docker-hub-credentials',
        usernameVariable: 'USER',
        passwordVariable: 'PASS'
    )
]) {
    sh 'docker login -u $USER -p $PASS'
}
```

**Best Practices:**

1. **Never commit secrets** to Git
2. **Use credential IDs** not actual values
3. **Rotate secrets** regularly
4. **Limit access** to credentials
5. **Audit usage** of secrets

**Additional Security:**

- Use HashiCorp Vault for secrets
- Enable audit logging
- Use least privilege principle
- Encrypt Jenkins home directory

---

### Q13: How do you handle pipeline failures?

**Answer:**

**Detection:**

```groovy
post {
    failure {
        echo 'Pipeline failed!'
        // Send notification
    }
}
```

**Notification:**

```groovy
post {
    failure {
        emailext(
            subject: "Build #${BUILD_NUMBER} failed",
            body: "Check console output",
            to: 'team@example.com'
        )
        
        // Or Slack
        slackSend(
            color: 'danger',
            message: "Build failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

**Debugging:**

1. **Check Console Output**
   - View full build log
   - Look for error messages

2. **Check Stage**
   - Which stage failed?
   - What was the error?

3. **Reproduce Locally**

   ```bash
   # Run same commands locally
   npm ci
   npm test
   docker build -t myapp .
   ```

**Common Failures:**

**1. Test Failures**

```
Solution:
- Fix failing tests
- Update test expectations
- Check test environment
```

**2. Docker Build Failures**

```
Solution:
- Check Dockerfile syntax
- Verify base image exists
- Check network connectivity
```

**3. Deployment Failures**

```
Solution:
- Check Kubernetes cluster status
- Verify image exists in registry
- Check resource availability
```

**Recovery:**

```groovy
post {
    failure {
        // Rollback deployment
        sh 'kubectl rollout undo deployment/myapp'
    }
}
```

---

## 🔍 Troubleshooting Questions

### Q14: A pod is in CrashLoopBackOff. How do you troubleshoot?

**Answer:**

**Step 1: Check Pod Status**

```bash
kubectl get pods
# NAME                    READY   STATUS             RESTARTS   AGE
# myapp-xxx               0/1     CrashLoopBackOff   5          5m
```

**Step 2: View Logs**

```bash
# Current logs
kubectl logs myapp-xxx

# Previous logs (if pod restarted)
kubectl logs --previous myapp-xxx

# Follow logs
kubectl logs -f myapp-xxx
```

**Step 3: Describe Pod**

```bash
kubectl describe pod myapp-xxx
```

Look for:

- Events section (errors, warnings)
- Container state
- Exit code

**Step 4: Check Events**

```bash
kubectl get events --sort-by='.lastTimestamp'
```

**Common Causes:**

**1. Application Error**

```
Logs show:
Error: Cannot find module 'express'

Solution:
- Missing dependency
- Rebuild Docker image with npm install
```

**2. Wrong Command**

```
Logs show:
/bin/sh: app.js: not found

Solution:
- Check CMD in Dockerfile
- Verify file exists in image
```

**3. Port Already in Use**

```
Logs show:
Error: listen EADDRINUSE: address already in use :::3000

Solution:
- Change port in app
- Check for port conflicts
```

**4. Missing Environment Variables**

```
Logs show:
Error: DATABASE_URL is not defined

Solution:
- Add env vars to deployment
- Check ConfigMap/Secret
```

**5. Health Check Failing**

```
Events show:
Liveness probe failed: HTTP probe failed

Solution:
- Check /health endpoint
- Increase initialDelaySeconds
- Fix application health check
```

**Step 5: Debug Interactively**

```bash
# Get shell in container
kubectl exec -it myapp-xxx -- /bin/sh

# Check files
ls -la

# Check processes
ps aux

# Check network
netstat -tulpn
```

---

### Q15: Application is slow. How do you investigate?

**Answer:**

**Step 1: Check Resource Usage**

```bash
# Pod resource usage
kubectl top pods

# Node resource usage
kubectl top nodes
```

**Step 2: Check Pod Status**

```bash
kubectl get pods
kubectl describe pod myapp-xxx
```

Look for:

- CPU/Memory limits reached
- Throttling
- OOMKilled events

**Step 3: Check Application Logs**

```bash
kubectl logs myapp-xxx | grep -i error
kubectl logs myapp-xxx | grep -i slow
kubectl logs myapp-xxx | grep -i timeout
```

**Step 4: Check Network**

```bash
# Service endpoints
kubectl get endpoints myapp-service

# Network policies
kubectl get networkpolicies

# Test connectivity
kubectl exec -it myapp-xxx -- curl http://myapp-service
```

**Common Causes:**

**1. Resource Limits Too Low**

```yaml
# Problem
resources:
  limits:
    cpu: "100m"     # Too low!
    memory: "128Mi"

# Solution
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
```

**2. Too Few Replicas**

```bash
# Check current replicas
kubectl get deployment myapp

# Scale up
kubectl scale deployment myapp --replicas=5
```

**3. Database Connection Issues**

```
Logs show:
Connection timeout to database

Solution:
- Check database status
- Verify connection string
- Check network policies
- Increase connection pool
```

**4. External API Slow**

```
Solution:
- Add caching
- Implement timeouts
- Use circuit breaker
- Add retry logic
```

**5. Memory Leak**

```bash
# Monitor memory over time
kubectl top pod myapp-xxx --watch

Solution:
- Profile application
- Fix memory leaks
- Restart pods regularly
```

**Step 5: Performance Testing**

```bash
# Load test
ab -n 1000 -c 10 http://myapp-service/

# Monitor during test
kubectl top pods --watch
```

---

## 🏗️ Architecture & Design Questions

### Q16: How would you design this for production?

**Answer:**

**Current Setup (Development):**

- Single cluster (Minikube)
- 3 replicas
- NodePort service
- No monitoring
- No logging aggregation

**Production Setup:**

**1. High Availability**

```yaml
# Multiple replicas across zones
replicas: 6

# Pod anti-affinity
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - myapp
      topologyKey: topology.kubernetes.io/zone
```

**2. Load Balancing**

```yaml
# Use LoadBalancer instead of NodePort
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: LoadBalancer  # Cloud load balancer
  ports:
  - port: 80
    targetPort: 3000
```

**3. Auto-Scaling**

```yaml
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  minReplicas: 6
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```

**4. Monitoring**

```yaml
# Prometheus + Grafana
- Metrics collection
- Dashboards
- Alerting

# Key metrics:
- Request rate
- Error rate
- Response time
- Resource usage
```

**5. Logging**

```yaml
# ELK Stack or Loki
- Centralized logging
- Log aggregation
- Search and analysis
- Retention policies
```

**6. Security**

```yaml
# Network Policies
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 3000
```

**7. Secrets Management**

```yaml
# Use external secrets manager
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault

# Not in Git
# Encrypted at rest
# Rotated regularly
```

**8. Disaster Recovery**

```yaml
# Multi-region deployment
- Primary region: us-east-1
- Secondary region: us-west-2
- Database replication
- Automated failover

# Backup strategy
- Daily backups
- Point-in-time recovery
- Tested restore procedures
```

**9. CI/CD Improvements**

```yaml
# Multiple environments
- Development
- Staging
- Production

# Deployment strategy
- Blue-green deployment
- Canary releases
- Feature flags

# Quality gates
- Code coverage > 80%
- Security scanning
- Performance testing
```

**10. Cost Optimization**

```yaml
# Resource optimization
- Right-size pods
- Use spot instances
- Auto-scale down during off-hours
- Reserved instances for base load
```

---

### Q17: How would you implement blue-green deployment?

**Answer:**

**Concept:**

- Two identical environments (blue and green)
- Blue = current production
- Green = new version
- Switch traffic instantly
- Easy rollback

**Implementation:**

**Step 1: Deploy Green Environment**

```yaml
# green-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: myapp
        image: myapp:2.0  # New version
```

**Step 2: Test Green Environment**

```bash
# Create test service
kubectl apply -f green-service.yaml

# Get service URL
kubectl get service myapp-green-service

# Run tests
curl http://myapp-green-service/health
ab -n 1000 -c 10 http://myapp-green-service/
```

**Step 3: Switch Traffic**

```yaml
# Update main service selector
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    version: green  # Changed from blue to green
  ports:
  - port: 80
    targetPort: 3000
```

**Step 4: Monitor**

```bash
# Watch metrics
kubectl top pods
kubectl logs -f -l version=green

# Check error rates
# Monitor response times
```

**Step 5: Rollback if Needed**

```yaml
# Switch back to blue
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    version: blue  # Rollback
```

**Step 6: Cleanup**

```bash
# After successful deployment
kubectl delete deployment myapp-blue
```

**Advantages:**

- Instant switchover
- Easy rollback
- Zero downtime
- Full testing before switch

**Disadvantages:**

- Double resources during deployment
- Database migrations tricky
- More complex setup

**When to Use:**

- Critical applications
- Need instant rollback
- Can afford double resources
- Infrequent deployments

---

## 🎬 Scenario-Based Questions

### Q18: Production is down. Walk me through your response

**Answer:**

**Immediate Response (0-5 minutes):**

**1. Acknowledge and Assess**

```bash
# Check if it's really down
curl https://myapp.com/health

# Check monitoring
# - Grafana dashboards
# - Error rates
# - Response times
```

**2. Check Recent Changes**

```bash
# Recent deployments
kubectl rollout history deployment/myapp

# Recent commits
git log --oneline -10
```

**3. Quick Rollback**

```bash
# If recent deployment caused it
kubectl rollout undo deployment/myapp

# Verify
kubectl rollout status deployment/myapp
curl https://myapp.com/health
```

**Investigation (5-30 minutes):**

**4. Check Pods**

```bash
# Pod status
kubectl get pods

# Pod logs
kubectl logs -l app=myapp --tail=100

# Pod events
kubectl describe pods -l app=myapp
```

**5. Check Resources**

```bash
# Resource usage
kubectl top pods
kubectl top nodes

# Check for OOMKilled
kubectl get pods -o json | jq '.items[] | select(.status.containerStatuses[].lastState.terminated.reason=="OOMKilled")'
```

**6. Check Dependencies**

```bash
# Database
kubectl get pods -l app=database

# External services
curl https://api.external.com/health

# Network
kubectl get networkpolicies
```

**Root Cause Analysis (30+ minutes):**

**7. Analyze Logs**

```bash
# Application logs
kubectl logs -l app=myapp --since=1h | grep ERROR

# System logs
journalctl -u kubelet --since "1 hour ago"
```

**8. Check Metrics**

```
# Grafana dashboards
- Request rate dropped?
- Error rate spiked?
- Response time increased?
- Resource usage?
```

**9. Reproduce Issue**

```bash
# Try to reproduce locally
docker run -p 3000:3000 myapp:latest

# Check specific endpoint
curl -v https://myapp.com/api/endpoint
```

**Communication:**

**10. Status Updates**

```
Every 15 minutes:
- What happened
- Current status
- ETA for fix
- Workarounds

Channels:
- Slack incident channel
- Status page
- Email to stakeholders
```

**Post-Incident:**

**11. Post-Mortem**

```
Document:
- Timeline of events
- Root cause
- Impact (users affected, duration)
- Actions taken
- Lessons learned
- Action items to prevent recurrence
```

**12. Implement Improvements**

```
- Add monitoring
- Improve alerts
- Update runbooks
- Add tests
- Improve deployment process
```

---

### Q19: How would you handle a sudden traffic spike?

**Answer:**

**Immediate Actions:**

**1. Check Current State**

```bash
# Pod count
kubectl get pods -l app=myapp

# Resource usage
kubectl top pods
kubectl top nodes

# HPA status
kubectl get hpa
```

**2. Manual Scale if Needed**

```bash
# If HPA not keeping up
kubectl scale deployment myapp --replicas=20

# Verify
kubectl get pods -w
```

**3. Monitor**

```bash
# Watch scaling
kubectl get hpa -w

# Watch pods
kubectl get pods -w

# Check metrics
kubectl top pods --watch
```

**Automated Response:**

**4. Horizontal Pod Autoscaler**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    kind: Deployment
    name: myapp
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
```

**5. Cluster Autoscaler**

```yaml
# Automatically add nodes if needed
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-autoscaler
data:
  min-nodes: "3"
  max-nodes: "20"
```

**Optimization:**

**6. Caching**

```javascript
// Add Redis caching
const redis = require('redis');
const client = redis.createClient();

app.get('/api/data', async (req, res) => {
    // Check cache first
    const cached = await client.get('data');
    if (cached) {
        return res.json(JSON.parse(cached));
    }
    
    // Fetch from database
    const data = await database.query('SELECT * FROM data');
    
    // Cache for 5 minutes
    await client.setex('data', 300, JSON.stringify(data));
    
    res.json(data);
});
```

**7. CDN**

```
# Use CDN for static assets
- Images
- CSS
- JavaScript
- Reduces load on application
```

**8. Rate Limiting**

```javascript
// Prevent abuse
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

**Prevention:**

**9. Load Testing**

```bash
# Regular load tests
ab -n 10000 -c 100 http://myapp.com/

# Identify bottlenecks
# Optimize before traffic spike
```

**10. Capacity Planning**

```
# Monitor trends
- Peak traffic times
- Growth rate
- Seasonal patterns

# Plan capacity
- Ensure enough resources
- Set appropriate HPA limits
- Have buffer capacity
```

---

## 💡 Best Practices Questions

### Q20: What are your CI/CD best practices?

**Answer:**

**1. Version Everything**

```
✅ Code in Git
✅ Infrastructure as Code (Terraform)
✅ Configuration as Code (Kubernetes YAML)
✅ Pipeline as Code (Jenkinsfile)
```

**2. Automate Everything**

```
✅ Automated builds
✅ Automated tests
✅ Automated deployments
✅ Automated rollbacks
```

**3. Test Early and Often**

```
✅ Unit tests (every commit)
✅ Integration tests (every merge)
✅ End-to-end tests (before production)
✅ Performance tests (weekly)
```

**4. Fail Fast**

```groovy
pipeline {
    stages {
        stage('Test') {
            steps {
                sh 'npm test'
            }
            // Fail here if tests fail
            // Don't waste time building/deploying
        }
        stage('Build') {
            // Only runs if tests pass
        }
    }
}
```

**5. Build Once, Deploy Anywhere**

```
✅ Build Docker image once
✅ Tag with version
✅ Deploy same image to dev/staging/prod
✅ No rebuilding between environments
```

**6. Immutable Infrastructure**

```
✅ Never modify running containers
✅ Always deploy new version
✅ Old version stays available for rollback
```

**7. Security**

```
✅ Scan images for vulnerabilities
✅ Never commit secrets
✅ Use least privilege
✅ Audit all changes
```

**8. Monitoring and Logging**

```
✅ Monitor all deployments
✅ Centralized logging
✅ Alert on failures
✅ Track metrics
```

**9. Rollback Strategy**

```
✅ Keep previous versions
✅ Automated rollback on failure
✅ Test rollback procedure
✅ Document rollback steps
```

**10. Documentation**

```
✅ README for each project
✅ Architecture diagrams
✅ Runbooks for common issues
✅ Post-mortems for incidents
```

---

## 🎯 Summary

### Key Takeaways for Interviews

**1. Understand the Why**

- Don't just memorize commands
- Explain why you made choices
- Understand trade-offs

**2. Real-World Experience**

- Talk about your project
- Mention challenges faced
- Explain how you solved them

**3. Best Practices**

- Show you know industry standards
- Mention security considerations
- Discuss scalability

**4. Problem-Solving**

- Walk through troubleshooting steps
- Show systematic approach
- Mention tools you'd use

**5. Communication**

- Explain clearly
- Use analogies
- Check if interviewer understands

---

## 📚 Additional Resources

**Practice:**

1. Build this project
2. Break it intentionally
3. Fix the issues
4. Document your learnings

**Study:**

1. Official documentation
2. Real-world case studies
3. Blog posts from companies
4. Conference talks

**Prepare:**

1. Practice explaining out loud
2. Draw diagrams
3. Time yourself
4. Get feedback

**Remember:** Interviewers want to see:

- Technical knowledge ✅
- Problem-solving ability ✅
- Communication skills ✅
- Real-world experience ✅

**You've got this!** 🚀
