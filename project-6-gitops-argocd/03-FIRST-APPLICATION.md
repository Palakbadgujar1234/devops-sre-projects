# 🚀 Your First ArgoCD Application

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [What We'll Build](#what-well-build)
3. [Prerequisites](#prerequisites)
4. [Step 1: Prepare Git Repository](#step-1-prepare-git-repository)
5. [Step 2: Create Kubernetes Manifests](#step-2-create-kubernetes-manifests)
6. [Step 3: Create ArgoCD Application](#step-3-create-argocd-application)
7. [Step 4: Watch the Magic](#step-4-watch-the-magic)
8. [Step 5: Make Changes](#step-5-make-changes)
9. [Step 6: Rollback](#step-6-rollback)
10. [Understanding What Happened](#understanding-what-happened)
11. [Troubleshooting](#troubleshooting)

---

## 🎯 Introduction

### WHAT You'll Do

Deploy your first application using GitOps! You'll:

1. Create a Git repository with Kubernetes manifests
2. Tell ArgoCD to watch that repository
3. See ArgoCD automatically deploy your app
4. Make changes and see automatic updates
5. Perform a rollback

### WHY This Matters

This is the **"Aha!" moment** of GitOps:

```
Traditional:
You → kubectl apply → Kubernetes

GitOps:
You → Git commit → ArgoCD → Kubernetes

The magic: Git commit = Deployment! 🎉
```

### HOW Long It Takes

- **Quick version**: 15 minutes
- **With understanding**: 30 minutes
- **With experimentation**: 1 hour

---

## 🎨 What We'll Build

### Simple Web Application

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Git Repository (GitHub)                        │
│  └── k8s/                                       │
│      ├── deployment.yaml  (Nginx app)           │
│      └── service.yaml     (Expose app)          │
│                                                 │
│                    ↓                            │
│              ArgoCD watches                     │
│                    ↓                            │
│                                                 │
│  Kubernetes Cluster                             │
│  └── Namespace: demo                            │
│      ├── Deployment: nginx-app (3 replicas)     │
│      └── Service: nginx-service (NodePort)      │
│                                                 │
└─────────────────────────────────────────────────┘
```

### What You'll See

1. **Create Git repo** with Kubernetes files
2. **Create ArgoCD app** pointing to repo
3. **ArgoCD deploys** automatically
4. **Change replica count** in Git
5. **ArgoCD updates** automatically
6. **Rollback** by reverting Git commit

---

## ✅ Prerequisites

### Required

- ✅ ArgoCD installed and running
- ✅ kubectl configured
- ✅ GitHub account (or GitLab/Bitbucket)
- ✅ Git installed locally

### Verify Setup

```bash
# Check ArgoCD is running
kubectl get pods -n argocd

# Check you can access ArgoCD UI
# https://localhost:8080

# Check Git is installed
git --version

# Check kubectl works
kubectl get nodes
```

---

## 📁 Step 1: Prepare Git Repository

### Option A: Use Our Demo Repository (Easiest)

**WHAT:** Fork our ready-made demo repository

**WHY:** Fastest way to get started

**HOW:**

```bash
# 1. Go to GitHub and fork this repository:
# https://github.com/argoproj/argocd-example-apps

# 2. Clone YOUR fork
git clone https://github.com/YOUR-USERNAME/argocd-example-apps.git
cd argocd-example-apps

# 3. Explore the guestbook example
ls guestbook/

# You'll see:
# guestbook-ui-deployment.yaml
# guestbook-ui-svc.yaml
```

### Option B: Create Your Own Repository (Recommended for Learning)

**WHAT:** Create a new Git repository with Kubernetes manifests

**WHY:** Better understanding of the process

**HOW:**

#### Step 1.1: Create GitHub Repository

```
1. Go to GitHub.com
2. Click "+" → "New repository"
3. Name: "my-first-gitops-app"
4. Description: "Learning GitOps with ArgoCD"
5. Public repository
6. Initialize with README
7. Click "Create repository"
```

#### Step 1.2: Clone Repository Locally

```bash
# Clone your new repository
git clone https://github.com/YOUR-USERNAME/my-first-gitops-app.git

# EXPLANATION:
# Replace YOUR-USERNAME with your GitHub username

# Enter the directory
cd my-first-gitops-app

# Verify you're in the right place
pwd
# Output: /path/to/my-first-gitops-app
```

#### Step 1.3: Create Directory Structure

```bash
# Create directory for Kubernetes manifests
mkdir -p k8s

# EXPLANATION:
# mkdir        : Make directory
# -p           : Create parent directories if needed
# k8s          : Directory name (common convention)

# Verify
ls -la
# Output:
# drwxr-xr-x  3 user  staff   96 Dec  1 10:00 .
# drwxr-xr-x  5 user  staff  160 Dec  1 10:00 ..
# drwxr-xr-x  8 user  staff  256 Dec  1 10:00 .git
# -rw-r--r--  1 user  staff   50 Dec  1 10:00 README.md
# drwxr-xr-x  2 user  staff   64 Dec  1 10:00 k8s
```

---

## 📝 Step 2: Create Kubernetes Manifests

### Step 2.1: Create Deployment

**WHAT:** Define how to run your application

**WHY:** Tells Kubernetes what container to run and how many replicas

**HOW:**

```bash
# Create deployment file
cat > k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
spec:
  replicas: 2
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
        image: nginx:1.25
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
```

**LINE-BY-LINE EXPLANATION:**

```yaml
apiVersion: apps/v1
# WHAT: Kubernetes API version for Deployments
# WHY: Tells Kubernetes which API to use

kind: Deployment
# WHAT: Type of Kubernetes resource
# WHY: We're creating a Deployment (manages Pods)

metadata:
  name: nginx-app
  # WHAT: Name of this deployment
  # WHY: Used to identify and manage this deployment
  
  labels:
    app: nginx
  # WHAT: Labels to organize resources
  # WHY: Used for grouping and selecting resources

spec:
  replicas: 2
  # WHAT: Number of pod copies to run
  # WHY: For high availability and load distribution
  # RESULT: Kubernetes will maintain exactly 2 pods
  
  selector:
    matchLabels:
      app: nginx
  # WHAT: How to find pods managed by this deployment
  # WHY: Deployment needs to know which pods it controls
  # MUST MATCH: template.metadata.labels below
  
  template:
    # WHAT: Template for creating pods
    # WHY: Defines what each pod should look like
    
    metadata:
      labels:
        app: nginx
      # WHAT: Labels for the pods
      # WHY: Must match selector above
    
    spec:
      # WHAT: Pod specification
      # WHY: Defines what runs inside the pod
      
      containers:
      - name: nginx
        # WHAT: Container name
        # WHY: Identifies this container in the pod
        
        image: nginx:1.25
        # WHAT: Docker image to use
        # WHY: nginx:1.25 is a stable web server
        # FORMAT: image:tag
        
        ports:
        - containerPort: 80
          # WHAT: Port the container listens on
          # WHY: Nginx serves HTTP on port 80
        
        resources:
          # WHAT: Resource limits and requests
          # WHY: Prevents one pod from using all resources
          
          requests:
            memory: "64Mi"
            # WHAT: Minimum memory needed
            # WHY: Kubernetes reserves this much
            
            cpu: "100m"
            # WHAT: Minimum CPU needed (100 millicores = 0.1 CPU)
            # WHY: Kubernetes reserves this much
          
          limits:
            memory: "128Mi"
            # WHAT: Maximum memory allowed
            # WHY: Pod killed if it exceeds this
            
            cpu: "200m"
            # WHAT: Maximum CPU allowed (0.2 CPU)
            # WHY: Prevents CPU hogging
```

### Step 2.2: Create Service

**WHAT:** Expose your application to network traffic

**WHY:** Makes your app accessible from outside the pod

**HOW:**

```bash
# Create service file
cat > k8s/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
    name: http
EOF
```

**LINE-BY-LINE EXPLANATION:**

```yaml
apiVersion: v1
# WHAT: Kubernetes API version for Services
# WHY: Services use v1 API (older, stable)

kind: Service
# WHAT: Type of resource
# WHY: We're creating a Service (network access)

metadata:
  name: nginx-service
  # WHAT: Name of this service
  # WHY: Used to access the service (DNS name)
  
  labels:
    app: nginx
  # WHAT: Labels for organization
  # WHY: Helps group related resources

spec:
  type: NodePort
  # WHAT: Type of service
  # WHY: NodePort exposes service on each node's IP
  # OPTIONS:
  #   - ClusterIP: Internal only (default)
  #   - NodePort: Accessible from outside (we use this)
  #   - LoadBalancer: Cloud load balancer
  
  selector:
    app: nginx
  # WHAT: Which pods to send traffic to
  # WHY: Matches pods with label "app: nginx"
  # MUST MATCH: deployment.yaml pod labels
  
  ports:
  - port: 80
    # WHAT: Port the service listens on
    # WHY: Other services connect to this port
    
    targetPort: 80
    # WHAT: Port on the pod to forward to
    # WHY: Must match containerPort in deployment
    
    nodePort: 30080
    # WHAT: Port on the node (30000-32767 range)
    # WHY: Access app at <node-ip>:30080
    # OPTIONAL: Kubernetes assigns random if not specified
    
    protocol: TCP
    # WHAT: Network protocol
    # WHY: HTTP uses TCP
    
    name: http
    # WHAT: Name for this port
    # WHY: Useful when service has multiple ports
```

### Step 2.3: Verify Files

```bash
# Check files were created
ls -la k8s/

# Output:
# -rw-r--r--  1 user  staff  450 Dec  1 10:00 deployment.yaml
# -rw-r--r--  1 user  staff  250 Dec  1 10:00 service.yaml

# View deployment file
cat k8s/deployment.yaml

# View service file
cat k8s/service.yaml
```

### Step 2.4: Commit to Git

**WHAT:** Save files to Git repository

**WHY:** ArgoCD will read from Git

**HOW:**

```bash
# Add files to Git
git add k8s/

# EXPLANATION:
# git add    : Stage files for commit
# k8s/       : Add all files in k8s directory

# Commit with message
git commit -m "Add Kubernetes manifests for nginx app"

# EXPLANATION:
# git commit : Save staged changes
# -m         : Commit message
# "Add..."   : Descriptive message of what changed

# Push to GitHub
git push origin main

# EXPLANATION:
# git push   : Upload commits to remote
# origin     : Remote repository name (GitHub)
# main       : Branch name

# Output:
# Enumerating objects: 5, done.
# Counting objects: 100% (5/5), done.
# Delta compression using up to 8 threads
# Compressing objects: 100% (3/3), done.
# Writing objects: 100% (4/4), 450 bytes | 450.00 KiB/s, done.
# Total 4 (delta 0), reused 0 (delta 0)
# To https://github.com/YOUR-USERNAME/my-first-gitops-app.git
#    abc1234..def5678  main -> main
```

**Verify on GitHub:**

```
1. Go to your GitHub repository
2. You should see:
   - k8s/deployment.yaml
   - k8s/service.yaml
3. Click on files to view content
```

---

## 🎯 Step 3: Create ArgoCD Application

### Method A: Using ArgoCD UI (Easiest)

**WHAT:** Create application through web interface

**WHY:** Visual and beginner-friendly

**HOW:**

#### Step 3.1: Access ArgoCD UI

```bash
# Make sure port-forward is running
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser
open https://localhost:8080

# Login with admin credentials
```

#### Step 3.2: Create New Application

```
1. Click "+ NEW APP" button (top left)

2. Fill in GENERAL section:
   Application Name: nginx-app
   Project: default
   Sync Policy: Manual (we'll change to automatic later)

3. Fill in SOURCE section:
   Repository URL: https://github.com/YOUR-USERNAME/my-first-gitops-app
   Revision: HEAD
   Path: k8s

4. Fill in DESTINATION section:
   Cluster URL: https://kubernetes.default.svc
   Namespace: default

5. Click "CREATE" at the top
```

**What Each Field Means:**

```yaml
Application Name: nginx-app
# WHAT: Name for this ArgoCD application
# WHY: Identifies this app in ArgoCD

Project: default
# WHAT: ArgoCD project (logical grouping)
# WHY: Organizes applications

Sync Policy: Manual
# WHAT: How ArgoCD syncs changes
# WHY: Manual = you click sync, Automatic = auto-sync
# OPTIONS:
#   - Manual: You control when to sync
#   - Automatic: ArgoCD syncs automatically

Repository URL: https://github.com/YOUR-USERNAME/my-first-gitops-app
# WHAT: Git repository location
# WHY: Where ArgoCD reads manifests from

Revision: HEAD
# WHAT: Git branch/tag/commit
# WHY: HEAD = latest commit on default branch
# OPTIONS:
#   - HEAD: Latest commit
#   - main: Main branch
#   - v1.0.0: Specific tag
#   - abc123: Specific commit

Path: k8s
# WHAT: Directory in repo with manifests
# WHY: ArgoCD looks here for YAML files

Cluster URL: https://kubernetes.default.svc
# WHAT: Kubernetes cluster to deploy to
# WHY: This is the local cluster
# NOTE: Can deploy to different clusters

Namespace: default
# WHAT: Kubernetes namespace for deployment
# WHY: Isolates resources
```

### Method B: Using ArgoCD CLI

**WHAT:** Create application using command line

**WHY:** Faster, scriptable, repeatable

**HOW:**

```bash
# Create application
argocd app create nginx-app \
  --repo https://github.com/YOUR-USERNAME/my-first-gitops-app \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# EXPLANATION:
# argocd app create    : Create new application
# nginx-app            : Application name
# --repo               : Git repository URL
# --path k8s           : Directory with manifests
# --dest-server        : Kubernetes cluster
# --dest-namespace     : Target namespace

# Output:
# application 'nginx-app' created
```

### Method C: Using Kubernetes Manifest (Most GitOps Way!)

**WHAT:** Define ArgoCD application as Kubernetes resource

**WHY:** Everything in Git, including ArgoCD config!

**HOW:**

```bash
# Create ArgoCD application manifest
cat > argocd-app.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR-USERNAME/my-first-gitops-app
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Apply it
kubectl apply -f argocd-app.yaml

# EXPLANATION:
# kubectl apply    : Create/update resource
# -f               : From file
# argocd-app.yaml  : Our application definition

# Output:
# application.argoproj.io/nginx-app created
```

**LINE-BY-LINE EXPLANATION:**

```yaml
apiVersion: argoproj.io/v1alpha1
# WHAT: ArgoCD API version
# WHY: ArgoCD uses custom Kubernetes resources

kind: Application
# WHAT: ArgoCD Application resource
# WHY: Defines an application to deploy

metadata:
  name: nginx-app
  # WHAT: Application name
  # WHY: Identifies this application
  
  namespace: argocd
  # WHAT: Namespace for ArgoCD application resource
  # WHY: ArgoCD applications live in argocd namespace

spec:
  project: default
  # WHAT: ArgoCD project
  # WHY: Logical grouping of applications
  
  source:
    # WHAT: Where to get manifests from
    # WHY: Defines the Git source
    
    repoURL: https://github.com/YOUR-USERNAME/my-first-gitops-app
    # WHAT: Git repository URL
    # WHY: Where manifests are stored
    
    targetRevision: HEAD
    # WHAT: Git branch/tag/commit
    # WHY: Which version to deploy
    
    path: k8s
    # WHAT: Directory in repo
    # WHY: Where to find YAML files
  
  destination:
    # WHAT: Where to deploy to
    # WHY: Defines target cluster and namespace
    
    server: https://kubernetes.default.svc
    # WHAT: Kubernetes API server
    # WHY: Which cluster to deploy to
    
    namespace: default
    # WHAT: Target namespace
    # WHY: Where to create resources
  
  syncPolicy:
    # WHAT: How to sync changes
    # WHY: Defines automation behavior
    
    automated:
      # WHAT: Enable automatic sync
      # WHY: ArgoCD syncs without manual intervention
      
      prune: true
      # WHAT: Delete resources not in Git
      # WHY: Keeps cluster matching Git exactly
      
      selfHeal: true
      # WHAT: Revert manual changes
      # WHY: Prevents configuration drift
```

---

## 🎬 Step 4: Watch the Magic

### Step 4.1: View Application in UI

```
1. Go to ArgoCD UI: https://localhost:8080
2. You'll see your application: nginx-app
3. Status will show: "OutOfSync" (yellow)
4. This means: Git has resources, but they're not in Kubernetes yet
```

**What You'll See:**

```
┌─────────────────────────────────────────────────┐
│ nginx-app                                        │
├─────────────────────────────────────────────────┤
│ Status: OutOfSync                               │
│ Health: Missing                                 │
│ Sync: Manual                                    │
│                                                 │
│ Resources:                                      │
│ ├─ Deployment/nginx-app (OutOfSync)            │
│ └─ Service/nginx-service (OutOfSync)           │
└─────────────────────────────────────────────────┘
```

### Step 4.2: Sync the Application

**WHAT:** Deploy the application to Kubernetes

**WHY:** Make Kubernetes match Git

**HOW:**

**Using UI:**

```
1. Click on "nginx-app" application
2. Click "SYNC" button (top)
3. Click "SYNCHRONIZE" in the popup
4. Watch the magic happen! ✨
```

**Using CLI:**

```bash
# Sync the application
argocd app sync nginx-app

# EXPLANATION:
# argocd app sync  : Synchronize application
# nginx-app        : Application name

# You'll see output like:
# TIMESTAMP           GROUP        KIND         NAMESPACE  NAME            STATUS    HEALTH        HOOK  MESSAGE
# 2024-12-01T10:00:00Z              Service      default    nginx-service   Synced    Healthy             service/nginx-service created
# 2024-12-01T10:00:01Z apps         Deployment   default    nginx-app       Synced    Progressing         deployment.apps/nginx-app created

# Wait for sync to complete
argocd app wait nginx-app

# Output:
# Name:               nginx-app
# Project:            default
# Server:             https://kubernetes.default.svc
# Namespace:          default
# URL:                https://localhost:8080/applications/nginx-app
# Repo:               https://github.com/YOUR-USERNAME/my-first-gitops-app
# Target:             HEAD
# Path:               k8s
# SyncWindow:         Sync Allowed
# Sync Policy:        Manual
# Sync Status:        Synced to HEAD (abc1234)
# Health Status:      Healthy
```

### Step 4.3: Verify Deployment

```bash
# Check pods are running
kubectl get pods

# Output:
# NAME                         READY   STATUS    RESTARTS   AGE
# nginx-app-7d8f6b9c5d-abc12   1/1     Running   0          1m
# nginx-app-7d8f6b9c5d-def34   1/1     Running   0          1m

# Check deployment
kubectl get deployment nginx-app

# Output:
# NAME        READY   UP-TO-DATE   AVAILABLE   AGE
# nginx-app   2/2     2            2           1m

# Check service
kubectl get service nginx-service

# Output:
# NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# nginx-service   NodePort   10.96.100.123   <none>        80:30080/TCP   1m
```

### Step 4.4: Access the Application

**Using Minikube:**

```bash
# Get the URL
minikube service nginx-service --url

# Output:
# http://192.168.49.2:30080

# Open in browser
open http://192.168.49.2:30080

# You should see: "Welcome to nginx!"
```

**Using Port Forward:**

```bash
# Forward port
kubectl port-forward service/nginx-service 8081:80

# Open browser
open http://localhost:8081

# You should see: "Welcome to nginx!"
```

**Using kubectl:**

```bash
# Test with curl
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- curl http://nginx-service

# Output:
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# ...
```

---

## 🔄 Step 5: Make Changes (See GitOps in Action!)

### Step 5.1: Change Replica Count

**WHAT:** Increase replicas from 2 to 4

**WHY:** See automatic sync in action

**HOW:**

```bash
# Edit deployment file
vim k8s/deployment.yaml

# Change this line:
# FROM: replicas: 2
# TO:   replicas: 4

# Or use sed:
sed -i '' 's/replicas: 2/replicas: 4/' k8s/deployment.yaml

# Verify change
grep replicas k8s/deployment.yaml
# Output: replicas: 4
```

### Step 5.2: Commit and Push

```bash
# Add changes
git add k8s/deployment.yaml

# Commit
git commit -m "Scale nginx app to 4 replicas"

# Push
git push origin main

# Output:
# To https://github.com/YOUR-USERNAME/my-first-gitops-app.git
#    def5678..ghi9012  main -> main
```

### Step 5.3: Watch ArgoCD Detect Change

**If Manual Sync:**

```
1. Go to ArgoCD UI
2. nginx-app will show "OutOfSync" (yellow)
3. Click "SYNC" button
4. Click "SYNCHRONIZE"
5. Watch replicas increase to 4!
```

**If Automatic Sync:**

```
1. Wait 3 minutes (default sync interval)
2. ArgoCD automatically detects change
3. ArgoCD automatically syncs
4. Replicas increase to 4!
```

**Using CLI:**

```bash
# Check sync status
argocd app get nginx-app

# If manual, sync it
argocd app sync nginx-app

# Watch the sync
argocd app wait nginx-app
```

### Step 5.4: Verify Scaling

```bash
# Check pods (should now be 4)
kubectl get pods

# Output:
# NAME                         READY   STATUS    RESTARTS   AGE
# nginx-app-7d8f6b9c5d-abc12   1/1     Running   0          5m
# nginx-app-7d8f6b9c5d-def34   1/1     Running   0          5m
# nginx-app-7d8f6b9c5d-ghi56   1/1     Running   0          30s  ← New!
# nginx-app-7d8f6b9c5d-jkl78   1/1     Running   0          30s  ← New!

# Check deployment
kubectl get deployment nginx-app

# Output:
# NAME        READY   UP-TO-DATE   AVAILABLE   AGE
# nginx-app   4/4     4            4           5m

# 🎉 You just deployed by committing to Git!
```

---

## ⏮️ Step 6: Rollback

### Scenario: Oops, 4 replicas is too many

**WHAT:** Revert to previous version

**WHY:** Easy rollback is a key GitOps benefit

**HOW:**

### Step 6.1: Revert Git Commit

```bash
# View commit history
git log --oneline

# Output:
# ghi9012 Scale nginx app to 4 replicas  ← Current (bad)
# def5678 Add Kubernetes manifests        ← Previous (good)

# Revert the last commit
git revert HEAD

# EXPLANATION:
# git revert  : Create new commit that undoes changes
# HEAD        : Latest commit

# Git will open editor for commit message
# Default message is fine, save and exit

# Or do it in one command:
git revert HEAD --no-edit

# Output:
# [main jkl0123] Revert "Scale nginx app to 4 replicas"
#  1 file changed, 1 insertion(+), 1 deletion(-)
```

### Step 6.2: Push Revert

```bash
# Push the revert
git push origin main

# Output:
# To https://github.com/YOUR-USERNAME/my-first-gitops-app.git
#    ghi9012..jkl0123  main -> main
```

### Step 6.3: Watch ArgoCD Rollback

```bash
# ArgoCD detects the revert
# Syncs automatically (if auto-sync enabled)
# Or click SYNC in UI

# Watch pods scale down
kubectl get pods -w

# You'll see 2 pods terminating:
# nginx-app-7d8f6b9c5d-ghi56   1/1     Terminating   0          2m
# nginx-app-7d8f6b9c5d-jkl78   1/1     Terminating   0          2m

# Final state: 2 pods running
# NAME                         READY   STATUS    RESTARTS   AGE
# nginx-app-7d8f6b9c5d-abc12   1/1     Running   0          10m
# nginx-app-7d8f6b9c5d-def34   1/1     Running   0          10m

# 🎉 Rolled back by reverting Git commit!
```

---

## 🧠 Understanding What Happened

### The GitOps Flow

```
┌─────────────────────────────────────────────────┐
│ 1. You Changed Git                              │
│    └─ Edited deployment.yaml                    │
│    └─ Changed replicas: 2 → 4                   │
│    └─ Committed and pushed                      │
│                                                 │
│ 2. ArgoCD Detected Change                       │
│    └─ Polls Git every 3 minutes                 │
│    └─ Compares Git vs Kubernetes                │
│    └─ Found difference: replicas                │
│                                                 │
│ 3. ArgoCD Synced                                │
│    └─ Applied changes to Kubernetes             │
│    └─ Scaled deployment to 4 replicas           │
│    └─ Kubernetes created 2 new pods             │
│                                                 │
│ 4. You Reverted Git                             │
│    └─ Ran git revert                            │
│    └─ Changed replicas: 4 → 2                   │
│    └─ Pushed revert                             │
│                                                 │
│ 5. ArgoCD Rolled Back                           │
│    └─ Detected revert in Git                    │
│    └─ Synced to previous state                  │
│    └─ Kubernetes terminated 2 pods              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Key Concepts

**1. Git as Source of Truth**

```
Question: "How many replicas should be running?"
Answer: "Check Git!"

Git says: replicas: 2
Kubernetes has: 2 pods
Status: ✅ Synced
```

**2. Declarative Configuration**

```
You don't say: "Add 2 more pods"
You say: "I want 4 pods total"
Kubernetes figures out: "Need to add 2 pods"
```

**3. Continuous Reconciliation**

```
ArgoCD checks every 3 minutes:
- What does Git say?
- What does Kubernetes have?
- Are they the same?
- If not, sync them!
```

**4. Self-Healing**

```
Someone manually runs: kubectl scale deployment nginx-app --replicas=10

ArgoCD: "Wait, Git says 2, but K8s has 10!"
ArgoCD: "Let me fix that..."
ArgoCD: *Scales back to 2*

Result: Configuration drift prevented!
```

---

## 🔧 Troubleshooting

### Problem 1: Application Shows "OutOfSync"

**Symptom:**

```
ArgoCD UI shows yellow "OutOfSync" status
```

**Cause:**

```
Git and Kubernetes don't match
```

**Solution:**

```bash
# Check what's different
argocd app diff nginx-app

# Sync the application
argocd app sync nginx-app

# Or click SYNC in UI
```

### Problem 2: Sync Fails

**Symptom:**

```
Sync operation fails with error
```

**Common Causes & Solutions:**

```bash
# 1. Invalid YAML
# Check YAML syntax
kubectl apply --dry-run=client -f k8s/deployment.yaml

# 2. Resource already exists
# Delete existing resource
kubectl delete deployment nginx-app

# Then sync again
argocd app sync nginx-app

# 3. Insufficient permissions
# Check ArgoCD has permissions
kubectl auth can-i create deployments --as=system:serviceaccount:argocd:argocd-application-controller
```

### Problem 3: Can't Access Application

**Symptom:**

```
Can't access nginx at http://localhost:8081
```

**Solution:**

```bash
# 1. Check pods are running
kubectl get pods

# 2. Check service exists
kubectl get service nginx-service

# 3. Check port-forward is running
kubectl port-forward service/nginx-service 8081:80

# 4. Test with curl
curl http://localhost:8081
```

### Problem 4: ArgoCD Not Detecting Changes

**Symptom:**

```
Pushed to Git but ArgoCD doesn't see changes
```

**Solution:**

```bash
# 1. Check repository URL is correct
argocd app get nginx-app | grep Repo

# 2. Manually refresh
argocd app get nginx-app --refresh

# 3. Check ArgoCD can access Git
argocd repo list

# 4. Force sync
argocd app sync nginx-app --force
```

---

## 🎯 What You Learned

### Key Achievements

✅ Created Git repository with Kubernetes manifests
✅ Created ArgoCD application
✅ Deployed application using GitOps
✅ Made changes via Git commit
✅ Saw automatic synchronization
✅ Performed rollback via Git revert

### The GitOps Magic

```
Traditional Deployment:
1. Write code
2. Build image
3. SSH to server
4. Run kubectl commands
5. Hope it works
6. Hard to rollback

GitOps Deployment:
1. Write code
2. Commit to Git
3. Push
4. Done! ArgoCD handles rest
5. Easy rollback (git revert)
```

---

## 🚀 Next Steps

**Next Guide:** [`04-COMPLETE-SETUP.md`](04-COMPLETE-SETUP.md)

You'll learn:

- Complete multi-application setup
- Environment management (dev/staging/prod)
- Advanced ArgoCD features
- Production best practices

---

## 📚 Quick Reference

### Useful Commands

```bash
# Create application
argocd app create APP_NAME --repo REPO_URL --path PATH --dest-server SERVER --dest-namespace NAMESPACE

# List applications
argocd app list

# Get application details
argocd app get APP_NAME

# Sync application
argocd app sync APP_NAME

# Delete application
argocd app delete APP_NAME

# Watch sync status
argocd app wait APP_NAME

# View application logs
argocd app logs APP_NAME

# Rollback to previous version
argocd app rollback APP_NAME
```

---

**Congratulations!** You've experienced the magic of GitOps! 🎉

**Remember:** Git commit = Deployment. That's the power of GitOps! 🔄
