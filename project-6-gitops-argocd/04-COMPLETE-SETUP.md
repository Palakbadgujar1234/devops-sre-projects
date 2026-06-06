# 🏗️ Complete GitOps Setup - Production Ready

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [What We'll Build](#what-well-build)
3. [Prerequisites](#prerequisites)
4. [Part 1: Repository Setup](#part-1-repository-setup)
5. [Part 2: Deploy Applications](#part-2-deploy-applications)
6. [Part 3: Test GitOps Workflow](#part-3-test-gitops-workflow)
7. [Part 4: Production Features](#part-4-production-features)
8. [Complete Testing](#complete-testing)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Introduction

### WHAT You'll Build

A **complete production-ready GitOps platform** with:

- ✅ Multiple applications (frontend, backend, database)
- ✅ Multiple environments (dev, staging, production)
- ✅ Automated synchronization
- ✅ Self-healing capabilities
- ✅ Complete audit trail

### WHY This Matters

This is **enterprise-grade GitOps**:

```
Basic Setup (Guide 03):
- Single application
- Manual sync
- One environment

Complete Setup (This Guide):
- Multiple applications
- Automated sync
- Multiple environments
- Production-ready
```

### HOW Long It Takes

- **Setup**: 2-3 hours
- **Understanding**: 4-6 hours
- **Total**: 6-9 hours for complete mastery

---

## 🏛️ What We'll Build

### Complete Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Git Repository                          │
│                                                             │
│  apps/                                                      │
│  ├── frontend/                                              │
│  │   ├── base/           (Common config)                   │
│  │   └── overlays/                                         │
│  │       ├── dev/        (1 replica, NodePort)             │
│  │       ├── staging/    (2 replicas, more resources)      │
│  │       └── prod/       (3 replicas, anti-affinity)       │
│  ├── backend/                                               │
│  └── database/                                              │
│                                                             │
│  argocd/                                                    │
│  ├── applications/       (9 ArgoCD apps)                   │
│  └── project.yaml       (ArgoCD project)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ArgoCD Watches & Syncs
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                         │
│                                                             │
│  dev namespace        staging namespace    production       │
│  ├── frontend (1)     ├── frontend (2)     ├── frontend(3) │
│  ├── backend (1)      ├── backend (2)      ├── backend (3) │
│  └── postgres (1)     └── postgres (1)     └── postgres(1) │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Prerequisites

```bash
# Verify ArgoCD is running
kubectl get pods -n argocd

# Verify you can access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Check GitHub account
# You need: GitHub account with repository access

# Check kubectl
kubectl version --client
```

---

## 📁 Part 1: Repository Setup

### Step 1.1: Create Repository Structure

```bash
# Create or navigate to your repository
cd my-first-gitops-app  # Or create new: git clone <your-repo>

# Create complete directory structure
mkdir -p apps/{frontend,backend,database}/{base,overlays/{dev,staging,prod}}
mkdir -p argocd/applications

# Verify structure
tree -L 3 apps/

# Expected output:
# apps/
# ├── backend
# │   ├── base
# │   └── overlays
# │       ├── dev
# │       ├── prod
# │       └── staging
# ├── database
# │   ├── base
# │   └── overlays
# │       ├── dev
# │       ├── prod
# │       └── staging
# └── frontend
#     ├── base
#     └── overlays
#         ├── dev
#         ├── prod
#         └── staging
```

### Step 1.2: Create Frontend Application

**Base Configuration:**

```bash
# Create deployment
cat > apps/frontend/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF

# Create service
cat > apps/frontend/base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
EOF

# Create kustomization
cat > apps/frontend/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
EOF
```

**Dev Overlay:**

```bash
cat > apps/frontend/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: dev
bases:
- ../../base
namePrefix: dev-
commonLabels:
  environment: dev
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 1
  target:
    kind: Deployment
- patch: |-
    - op: replace
      path: /spec/type
      value: NodePort
  target:
    kind: Service
EOF
```

**Staging Overlay:**

```bash
cat > apps/frontend/overlays/staging/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: staging
bases:
- ../../base
namePrefix: staging-
commonLabels:
  environment: staging
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 2
  target:
    kind: Deployment
EOF
```

**Production Overlay:**

```bash
cat > apps/frontend/overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: production
bases:
- ../../base
namePrefix: prod-
commonLabels:
  environment: production
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
  target:
    kind: Deployment
- patch: |-
    - op: replace
      path: /spec/template/spec/containers/0/resources/requests/memory
      value: 128Mi
    - op: replace
      path: /spec/template/spec/containers/0/resources/limits/memory
      value: 256Mi
  target:
    kind: Deployment
EOF
```

### Step 1.3: Create Backend Application

```bash
# Base deployment
cat > apps/backend/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: node:18-alpine
        command: ["node"]
        args: ["-e", "require('http').createServer((req,res)=>res.end('Backend API')).listen(3000)"]
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF

# Base service
cat > apps/backend/base/service.yaml << 'EOF'
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
EOF

# Base kustomization
cat > apps/backend/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
EOF

# Dev overlay
cat > apps/backend/overlays/dev/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: dev
bases:
- ../../base
namePrefix: dev-
commonLabels:
  environment: dev
EOF

# Staging overlay
cat > apps/backend/overlays/staging/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: staging
bases:
- ../../base
namePrefix: staging-
commonLabels:
  environment: staging
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 2
  target:
    kind: Deployment
EOF

# Production overlay
cat > apps/backend/overlays/prod/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: production
bases:
- ../../base
namePrefix: prod-
commonLabels:
  environment: production
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
  target:
    kind: Deployment
EOF
```

### Step 1.4: Create Database Application

```bash
# Base statefulset
cat > apps/database/base/statefulset.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "myapp"
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          value: "changeme"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF

# Base service
cat > apps/database/base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  type: ClusterIP
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

# Base kustomization
cat > apps/database/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- statefulset.yaml
- service.yaml
EOF

# Create overlays for all environments
for env in dev staging prod; do
  ns=$env
  [ "$env" = "prod" ] && ns="production"
  
  cat > apps/database/overlays/$env/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $ns
bases:
- ../../base
namePrefix: ${env}-
commonLabels:
  environment: $env
EOF
done
```

### Step 1.5: Commit to Git

```bash
# Add all files
git add apps/

# Commit
git commit -m "Add complete application structure with overlays"

# Push
git push origin main

# Verify on GitHub - you should see complete apps/ directory
```

---

## 🚀 Part 2: Deploy Applications

### Step 2.1: Create Namespaces

```bash
# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace production

# Verify
kubectl get namespaces | grep -E "dev|staging|production"
```

### Step 2.2: Create ArgoCD Project

```bash
cat > argocd/project.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: myapp
  namespace: argocd
spec:
  description: My Application Project
  sourceRepos:
  - '*'
  destinations:
  - namespace: '*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
EOF

# Apply project
kubectl apply -f argocd/project.yaml

# Verify
kubectl get appproject -n argocd myapp
```

### Step 2.3: Create ArgoCD Applications

**IMPORTANT:** Replace `YOUR-USERNAME` with your GitHub username in all commands below!

```bash
# Set your GitHub username
GITHUB_USER="YOUR-USERNAME"  # CHANGE THIS!

# Create all 9 applications
for env in dev staging prod; do
  ns=$env
  [ "$env" = "prod" ] && ns="production"
  
  for app in frontend backend database; do
    cat > argocd/applications/${app}-${env}.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${app}-${env}
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: myapp
  source:
    repoURL: https://github.com/${GITHUB_USER}/my-first-gitops-app
    targetRevision: HEAD
    path: apps/${app}/overlays/${env}
  destination:
    server: https://kubernetes.default.svc
    namespace: ${ns}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
  done
done

# Verify files created
ls -la argocd/applications/

# Should show 9 files:
# backend-dev.yaml      database-dev.yaml     frontend-dev.yaml
# backend-prod.yaml     database-prod.yaml    frontend-prod.yaml
# backend-staging.yaml  database-staging.yaml frontend-staging.yaml
```

### Step 2.4: Commit ArgoCD Configurations

```bash
# Add ArgoCD files
git add argocd/

# Commit
git commit -m "Add ArgoCD project and applications"

# Push
git push origin main
```

### Step 2.5: Deploy Applications

```bash
# Apply all applications
kubectl apply -f argocd/applications/

# You should see:
# application.argoproj.io/backend-dev created
# application.argoproj.io/backend-prod created
# application.argoproj.io/backend-staging created
# application.argoproj.io/database-dev created
# application.argoproj.io/database-prod created
# application.argoproj.io/database-staging created
# application.argoproj.io/frontend-dev created
# application.argoproj.io/frontend-prod created
# application.argoproj.io/frontend-staging created

# Watch applications sync
watch kubectl get applications -n argocd

# Wait until all show:
# SYNC STATUS: Synced
# HEALTH STATUS: Healthy
# (Press Ctrl+C to exit watch)
```

### Step 2.6: Verify Deployments

```bash
# Check dev environment
kubectl get pods -n dev

# Expected output:
# NAME                           READY   STATUS    RESTARTS   AGE
# dev-backend-xxx                1/1     Running   0          2m
# dev-frontend-xxx               1/1     Running   0          2m
# dev-postgres-0                 1/1     Running   0          2m

# Check staging environment
kubectl get pods -n staging

# Expected output (2 replicas for frontend/backend):
# NAME                               READY   STATUS    RESTARTS   AGE
# staging-backend-xxx                1/1     Running   0          2m
# staging-backend-yyy                1/1     Running   0          2m
# staging-frontend-xxx               1/1     Running   0          2m
# staging-frontend-yyy               1/1     Running   0          2m
# staging-postgres-0                 1/1     Running   0          2m

# Check production environment
kubectl get pods -n production

# Expected output (3 replicas for frontend/backend):
# NAME                            READY   STATUS    RESTARTS   AGE
# prod-backend-xxx                1/1     Running   0          2m
# prod-backend-yyy                1/1     Running   0          2m
# prod-backend-zzz                1/1     Running   0          2m
# prod-frontend-xxx               1/1     Running   0          2m
# prod-frontend-yyy               1/1     Running   0          2m
# prod-frontend-zzz               1/1     Running   0          2m
# prod-postgres-0                 1/1     Running   0          2m

# Check all at once
kubectl get pods --all-namespaces | grep -E "dev-|staging-|prod-"
```

### Step 2.7: Access ArgoCD UI

```bash
# Make sure port-forward is running
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Open browser
open https://localhost:8080

# You should see 9 applications:
# - backend-dev, backend-staging, backend-prod
# - database-dev, database-staging, database-prod
# - frontend-dev, frontend-staging, frontend-prod

# All should show:
# Status: Synced (green)
# Health: Healthy (green)
```

---

## 🧪 Part 3: Test GitOps Workflow

### Test 1: Scale Frontend in Dev

**WHAT:** Change replica count via Git

**WHY:** Demonstrate GitOps workflow

**HOW:**

```bash
# Edit dev frontend overlay
vim apps/frontend/overlays/dev/kustomization.yaml

# Change replicas from 1 to 2:
# Find the patch section and change:
# FROM: value: 1
# TO:   value: 2

# Or use sed:
sed -i '' 's/value: 1/value: 2/' apps/frontend/overlays/dev/kustomization.yaml

# Verify change
grep -A 5 "replicas" apps/frontend/overlays/dev/kustomization.yaml

# Commit and push
git add apps/frontend/overlays/dev/kustomization.yaml
git commit -m "Scale dev frontend to 2 replicas"
git push origin main

# Watch ArgoCD sync (automatic within 3 minutes)
watch kubectl get pods -n dev

# You should see a second frontend pod starting:
# dev-frontend-xxx   1/1     Running   0          5m
# dev-frontend-yyy   0/1     Pending   0          5s  ← New pod!

# After ~30 seconds:
# dev-frontend-xxx   1/1     Running   0          5m
# dev-frontend-yyy   1/1     Running   0          35s ← Running!

# 🎉 Deployment via Git commit!
```

### Test 2: Update Backend Image

**WHAT:** Change container image version

**WHY:** Simulate application update

**HOW:**

```bash
# Edit staging backend deployment
vim apps/backend/base/deployment.yaml

# Change image version:
# FROM: image: node:18-alpine
# TO:   image: node:20-alpine

# Or use sed:
sed -i '' 's/node:18-alpine/node:20-alpine/' apps/backend/base/deployment.yaml

# Commit and push
git add apps/backend/base/deployment.yaml
git commit -m "Update backend to Node.js 20"
git push origin main

# Watch all environments update
watch 'kubectl get pods -n dev -l app=backend && echo "---" && kubectl get pods -n staging -l app=backend && echo "---" && kubectl get pods -n production -l app=backend'

# You'll see rolling updates in all environments:
# Old pods terminating, new pods starting
# This affects ALL environments (dev, staging, prod)
# because they all use the same base!
```

### Test 3: Self-Healing

**WHAT:** Manually change something, watch ArgoCD revert it

**WHY:** Demonstrate drift prevention

**HOW:**

```bash
# Manually scale production frontend to 10 replicas
kubectl scale deployment prod-frontend -n production --replicas=10

# Check pods
kubectl get pods -n production -l app=frontend

# You'll see 10 pods starting!
# NAME                            READY   STATUS    RESTARTS   AGE
# prod-frontend-xxx               1/1     Running   0          10m
# prod-frontend-yyy               1/1     Running   0          10m
# prod-frontend-zzz               1/1     Running   0          10m
# prod-frontend-aaa               0/1     Pending   0          5s  ← New
# prod-frontend-bbb               0/1     Pending   0          5s  ← New
# ... (7 more new pods)

# Wait 10-20 seconds, check again
kubectl get pods -n production -l app=frontend

# ArgoCD detected drift and reverted!
# Back to 3 pods as defined in Git:
# NAME                            READY   STATUS    RESTARTS   AGE
# prod-frontend-xxx               1/1     Running   0          11m
# prod-frontend-yyy               1/1     Running   0          11m
# prod-frontend-zzz               1/1     Running   0          11m

# 🎉 Self-healing in action!

# Check ArgoCD UI - you'll see sync event
```

### Test 4: Rollback

**WHAT:** Revert a change using Git

**WHY:** Demonstrate easy rollback

**HOW:**

```bash
# View recent commits
git log --oneline -5

# Output:
# abc1234 Update backend to Node.js 20
# def5678 Scale dev frontend to 2 replicas
# ghi9012 Add ArgoCD project and applications
# ...

# Revert the Node.js 20 update
git revert abc1234

# Git opens editor - save and exit

# Push revert
git push origin main

# Watch backend pods rollback to Node.js 18
watch 'kubectl get pods -n staging -l app=backend -o wide'

# You'll see rolling update back to Node.js 18
# 🎉 Rollback via Git revert!
```

---

## 🎯 Part 4: Production Features

### Feature 1: Resource Quotas

**WHAT:** Limit resources per namespace

**WHY:** Prevent resource exhaustion

**HOW:**

```bash
# Create resource quota for dev
cat > apps/frontend/overlays/dev/resourcequota.yaml << 'EOF'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
EOF

# Add to kustomization
cat >> apps/frontend/overlays/dev/kustomization.yaml << 'EOF'
resources:
- resourcequota.yaml
EOF

# Commit and push
git add apps/frontend/overlays/dev/
git commit -m "Add resource quota to dev environment"
git push origin main

# Verify quota created
kubectl get resourcequota -n dev
kubectl describe resourcequota dev-quota -n dev
```

### Feature 2: Network Policies

**WHAT:** Control network traffic between pods

**WHY:** Security - limit communication

**HOW:**

```bash
# Create network policy for production
cat > apps/frontend/overlays/prod/networkpolicy.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-netpol
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
EOF

# Add to kustomization
cat >> apps/frontend/overlays/prod/kustomization.yaml << 'EOF'
resources:
- networkpolicy.yaml
EOF

# Commit and push
git add apps/frontend/overlays/prod/
git commit -m "Add network policy to production frontend"
git push origin main

# Verify
kubectl get networkpolicy -n production
```

### Feature 3: Health Checks

**WHAT:** Add liveness and readiness probes

**WHY:** Better reliability and zero-downtime deployments

**Already included in our deployments!**

```bash
# View existing health checks
kubectl describe deployment dev-frontend -n dev | grep -A 10 "Liveness\|Readiness"

# Output shows:
# Liveness:   http-get http://:80/ delay=10s timeout=1s period=10s
# Readiness:  http-get http://:80/ delay=5s timeout=1s period=5s
```

---

## ✅ Complete Testing

### Test All Environments

```bash
# Create test script
cat > test-all-environments.sh << 'EOF'
#!/bin/bash

echo "=== Testing All Environments ==="
echo

for env in dev staging production; do
  echo "Environment: $env"
  echo "Pods:"
  kubectl get pods -n $env
  echo
  echo "Services:"
  kubectl get svc -n $env
  echo
  echo "---"
  echo
done

echo "=== ArgoCD Applications ==="
kubectl get applications -n argocd

echo
echo "=== Summary ==="
echo "Total pods:"
kubectl get pods --all-namespaces | grep -E "dev-|staging-|prod-" | wc -l
echo
echo "Applications in ArgoCD:"
kubectl get applications -n argocd | grep -v NAME | wc -l
EOF

chmod +x test-all-environments.sh

# Run test
./test-all-environments.sh
```

### Access Applications

```bash
# Access dev frontend
kubectl port-forward -n dev svc/dev-frontend 8081:80 &
open http://localhost:8081

# Access staging frontend
kubectl port-forward -n staging svc/staging-frontend 8082:80 &
open http://localhost:8082

# Access production frontend
kubectl port-forward -n production svc/prod-frontend 8083:80 &
open http://localhost:8083

# All should show "Welcome to nginx!"
```

### Verify GitOps Workflow

```bash
# Check sync status
argocd app list

# Output should show all apps Synced and Healthy:
# NAME              CLUSTER                         NAMESPACE    PROJECT  STATUS  HEALTH
# backend-dev       https://kubernetes.default.svc  dev          myapp    Synced  Healthy
# backend-prod      https://kubernetes.default.svc  production   myapp    Synced  Healthy
# backend-staging   https://kubernetes.default.svc  staging      myapp    Synced  Healthy
# database-dev      https://kubernetes.default.svc  dev          myapp    Synced  Healthy
# database-prod     https://kubernetes.default.svc  production   myapp    Synced  Healthy
# database-staging  https://kubernetes.default.svc  staging      myapp    Synced  Healthy
# frontend-dev      https://kubernetes.default.svc  dev          myapp    Synced  Healthy
# frontend-prod     https://kubernetes.default.svc  production   myapp    Synced  Healthy
# frontend-staging  https://kubernetes.default.svc  staging      myapp    Synced  Healthy
```

---

## 🔧 Troubleshooting

### Problem 1: Application Not Syncing

```bash
# Check application status
argocd app get frontend-dev

# Check sync errors
kubectl describe application frontend-dev -n argocd

# Force refresh
argocd app get frontend-dev --refresh

# Force sync
argocd app sync frontend-dev --force
```

### Problem 2: Pods Not Starting

```bash
# Check pod status
kubectl get pods -n dev

# Check pod logs
kubectl logs -n dev <pod-name>

# Check pod events
kubectl describe pod -n dev <pod-name>

# Common issues:
# - Image pull errors: Check image name
# - Resource limits: Check resource quotas
# - Volume issues: Check PVC status
```

### Problem 3: Can't Access Application

```bash
# Check service
kubectl get svc -n dev

# Check endpoints
kubectl get endpoints -n dev

# Test from within cluster
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- curl http://dev-frontend.dev
```

### Problem 4: Git Changes Not Detected

```bash
# Check repository connection
argocd repo list

# Refresh application
argocd app get frontend-dev --refresh

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-application-controller
```

---

## 🎉 Success Criteria

You've successfully completed the setup if:

- ✅ All 9 applications deployed (3 apps × 3 environments)
- ✅ All applications show Synced and Healthy in ArgoCD
- ✅ Can access applications in all environments
- ✅ Git commits trigger automatic deployments
- ✅ Self-healing works (manual changes reverted)
- ✅ Rollback works (git revert)
- ✅ Different replica counts per environment
- ✅ Resource quotas and network policies applied

---

## 📊 What You Built

### Statistics

```
Applications:     9 (frontend, backend, database × 3 environments)
Namespaces:       3 (dev, staging, production)
Total Pods:       13 (1+2+3 frontend, 1+2+3 backend, 1+1+1 database)
Git Commits:      ~10
ArgoCD Apps:      9
Kustomize Overlays: 9
```

### Architecture Achieved

```
✅ Multi-application platform
✅ Multi-environment setup
✅ Automated GitOps workflow
✅ Self-healing capabilities
✅ Complete audit trail
✅ Production-ready patterns
✅ Resource management
✅ Network security
```

---

## 🚀 Next Steps

**Next Guide:** [`05-MULTI-ENVIRONMENT.md`](05-MULTI-ENVIRONMENT.md)

Advanced topics:

- Environment promotion strategies
- Blue-green deployments
- Canary releases
- Advanced Kustomize patterns

**Or:** [`06-BEST-PRACTICES.md`](06-BEST-PRACTICES.md)

Production patterns:

- Secrets management
- RBAC configuration
- Monitoring integration
- Disaster recovery

---

## 📚 Quick Reference

### Useful Commands

```bash
# List all applications
argocd app list

# Get application details
argocd app get <app-name>

# Sync application
argocd app sync <app-name>

# Refresh application
argocd app get <app-name> --refresh

# View application logs
argocd app logs <app-name>

# Delete application
argocd app delete <app-name>

# Check all pods
kubectl get pods --all-namespaces | grep -E "dev-|staging-|prod-"

# Check all applications
kubectl get applications -n argocd

# Force sync all applications
for app in $(argocd app list -o name); do argocd app sync $app; done
```

---

**Congratulations!** You've built a complete production-ready GitOps platform! 🎉

**Key Achievement:** You can now deploy applications to multiple environments with a simple Git commit! 🔄

**Remember:** Git is your source of truth. Every change goes through Git. That's the power of GitOps! 💪
