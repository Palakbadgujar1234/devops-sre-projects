# 🔧 ArgoCD Installation Guide

## 📖 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Method 1: Minikube Installation](#method-1-minikube-installation)
4. [Method 2: Kind Installation](#method-2-kind-installation)
5. [Method 3: Existing Cluster](#method-3-existing-cluster)
6. [Accessing ArgoCD UI](#accessing-argocd-ui)
7. [Initial Configuration](#initial-configuration)
8. [Verification](#verification)
9. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

### Required Software

**1. Kubernetes Cluster**

```bash
# Option A: Minikube (Recommended for beginners)
# Option B: Kind (Kubernetes in Docker)
# Option C: Existing cluster (EKS, GKE, AKS)
```

**2. kubectl**

```bash
# Check if installed
kubectl version --client

# Should show version like:
# Client Version: v1.28.0
```

**3. System Requirements**

```
Minimum:
- 4GB RAM
- 2 CPU cores
- 20GB disk space

Recommended:
- 8GB RAM
- 4 CPU cores
- 50GB disk space
```

### Installation Check

```bash
# Check kubectl
kubectl version --client

# Check Docker (for Minikube/Kind)
docker --version

# Check Minikube (if using)
minikube version

# Check Kind (if using)
kind version
```

---

## 🎯 Installation Methods

### Which Method to Choose?

```
┌─────────────────────────────────────────────────┐
│ Choose Your Installation Method                 │
├─────────────────────────────────────────────────┤
│                                                 │
│ 🟢 Minikube (Recommended for Beginners)        │
│    ✅ Easy to set up                            │
│    ✅ Good for learning                         │
│    ✅ Runs on laptop                            │
│    ⚠️  Single node only                         │
│                                                 │
│ 🔵 Kind (Good for Testing)                     │
│    ✅ Fast startup                              │
│    ✅ Multiple clusters                         │
│    ✅ CI/CD friendly                            │
│    ⚠️  Requires Docker                          │
│                                                 │
│ 🟡 Existing Cluster (Production)               │
│    ✅ Real environment                          │
│    ✅ Multi-node                                │
│    ⚠️  Requires cluster access                  │
│    ⚠️  More complex                             │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 🚀 Method 1: Minikube Installation

### Step 1: Install Minikube

**WHAT:** Minikube runs Kubernetes on your laptop

**WHY:** Perfect for learning and testing

**HOW:**

#### macOS

```bash
# Install using Homebrew
brew install minikube

# Verify installation
minikube version
# Output: minikube version: v1.32.0
```

#### Linux

```bash
# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install it
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

#### Windows

```powershell
# Using Chocolatey
choco install minikube

# Or download installer from:
# https://minikube.sigs.k8s.io/docs/start/

# Verify installation
minikube version
```

### Step 2: Start Minikube

**WHAT:** Start your local Kubernetes cluster

**WHY:** Need running cluster for ArgoCD

**HOW:**

```bash
# Start Minikube with enough resources
minikube start --cpus=4 --memory=8192 --driver=docker

# EXPLANATION:
# --cpus=4         : Use 4 CPU cores (ArgoCD needs resources)
# --memory=8192    : Use 8GB RAM (8192 MB)
# --driver=docker  : Use Docker as the driver

# This will take 2-5 minutes...
# You'll see output like:
# 😄  minikube v1.32.0 on Darwin 14.0
# ✨  Using the docker driver based on user configuration
# 👍  Starting control plane node minikube in cluster minikube
# 🚜  Pulling base image ...
# 🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
# 🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
# 🔎  Verifying Kubernetes components...
# 🌟  Enabled addons: storage-provisioner, default-storageclass
# 🏄  Done! kubectl is now configured to use "minikube" cluster
```

**Verify Minikube is Running:**

```bash
# Check cluster status
minikube status

# Output should show:
# minikube
# type: Control Plane
# host: Running
# kubelet: Running
# apiserver: Running
# kubeconfig: Configured

# Check nodes
kubectl get nodes

# Output:
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   2m    v1.28.3
```

### Step 3: Install ArgoCD

**WHAT:** Install ArgoCD in your Kubernetes cluster

**WHY:** ArgoCD is the GitOps tool we'll use

**HOW:**

```bash
# Create namespace for ArgoCD
kubectl create namespace argocd

# EXPLANATION:
# - Creates a separate namespace called 'argocd'
# - Keeps ArgoCD components isolated
# - Good practice for organization

# Output:
# namespace/argocd created

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# EXPLANATION:
# kubectl apply        : Apply configuration
# -n argocd           : In the argocd namespace
# -f <URL>            : From this manifest file

# This installs:
# - ArgoCD API Server
# - ArgoCD Repository Server
# - ArgoCD Application Controller
# - ArgoCD Redis
# - ArgoCD Dex Server
# - ArgoCD Notifications Controller

# You'll see output like:
# customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
# customresourcedefinition.apiextensions.k8s.io/applicationsets.argoproj.io created
# serviceaccount/argocd-application-controller created
# serviceaccount/argocd-server created
# ... (many more resources)
```

### Step 4: Wait for ArgoCD to be Ready

**WHAT:** Wait for all ArgoCD components to start

**WHY:** Need all pods running before accessing UI

**HOW:**

```bash
# Watch pods starting up
kubectl get pods -n argocd -w

# EXPLANATION:
# get pods           : List all pods
# -n argocd         : In argocd namespace
# -w                : Watch mode (updates in real-time)

# You'll see pods starting:
# NAME                                  READY   STATUS              RESTARTS   AGE
# argocd-application-controller-0       0/1     ContainerCreating   0          10s
# argocd-dex-server-xxx                 0/1     ContainerCreating   0          10s
# argocd-redis-xxx                      0/1     ContainerCreating   0          10s
# argocd-repo-server-xxx                0/1     ContainerCreating   0          10s
# argocd-server-xxx                     0/1     ContainerCreating   0          10s

# Wait until all show READY 1/1 and STATUS Running
# This takes 2-3 minutes

# Press Ctrl+C to stop watching

# Or wait using this command:
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# EXPLANATION:
# wait                    : Wait for condition
# --for=condition=available : Until deployment is available
# --timeout=300s          : Wait up to 5 minutes
# deployment/argocd-server : The ArgoCD server deployment

# Output when ready:
# deployment.apps/argocd-server condition met
```

**Verify All Pods are Running:**

```bash
# Check all pods
kubectl get pods -n argocd

# All should show READY 1/1 and STATUS Running:
# NAME                                  READY   STATUS    RESTARTS   AGE
# argocd-application-controller-0       1/1     Running   0          3m
# argocd-dex-server-xxx                 1/1     Running   0          3m
# argocd-redis-xxx                      1/1     Running   0          3m
# argocd-repo-server-xxx                1/1     Running   0          3m
# argocd-server-xxx                     1/1     Running   0          3m
# argocd-applicationset-controller-xxx  1/1     Running   0          3m
# argocd-notifications-controller-xxx   1/1     Running   0          3m
```

---

## 🐳 Method 2: Kind Installation

### Step 1: Install Kind

**WHAT:** Kind (Kubernetes in Docker) runs K8s in containers

**WHY:** Fast, lightweight, good for testing

**HOW:**

#### macOS/Linux

```bash
# Install using Go
go install sigs.k8s.io/kind@latest

# Or using Homebrew (macOS)
brew install kind

# Verify installation
kind version
# Output: kind v0.20.0 go1.21.0 darwin/amd64
```

#### Windows

```powershell
# Using Chocolatey
choco install kind

# Verify installation
kind version
```

### Step 2: Create Kind Cluster

**WHAT:** Create a Kubernetes cluster using Kind

**WHY:** Need cluster for ArgoCD

**HOW:**

```bash
# Create cluster with custom config
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: argocd-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
EOF

# EXPLANATION:
# kind: Cluster              : Kind cluster configuration
# name: argocd-cluster       : Name of the cluster
# nodes:                     : Node configuration
#   - role: control-plane    : Master node
#   extraPortMappings:       : Expose ports
#     - containerPort: 30080 : Port inside container
#       hostPort: 8080       : Port on your machine
#       protocol: TCP        : TCP protocol

# This creates a cluster and takes 1-2 minutes

# Output:
# Creating cluster "argocd-cluster" ...
# ✓ Ensuring node image (kindest/node:v1.28.0) 🖼
# ✓ Preparing nodes 📦
# ✓ Writing configuration 📜
# ✓ Starting control-plane 🕹️
# ✓ Installing CNI 🔌
# ✓ Installing StorageClass 💾
# Set kubectl context to "kind-argocd-cluster"
```

**Verify Cluster:**

```bash
# Check cluster
kind get clusters
# Output: argocd-cluster

# Check nodes
kubectl get nodes
# Output:
# NAME                           STATUS   ROLES           AGE   VERSION
# argocd-cluster-control-plane   Ready    control-plane   1m    v1.28.0
```

### Step 3: Install ArgoCD on Kind

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Verify
kubectl get pods -n argocd
```

---

## ☁️ Method 3: Existing Cluster

### For AWS EKS

```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --name your-cluster-name --region us-east-1

# Verify connection
kubectl get nodes

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### For Google GKE

```bash
# Configure kubectl for GKE
gcloud container clusters get-credentials your-cluster-name --zone us-central1-a

# Verify connection
kubectl get nodes

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### For Azure AKS

```bash
# Configure kubectl for AKS
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# Verify connection
kubectl get nodes

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

---

## 🌐 Accessing ArgoCD UI

### Method 1: Port Forward (Recommended for Local)

**WHAT:** Forward ArgoCD port to your machine

**WHY:** Easy access without LoadBalancer

**HOW:**

```bash
# Forward port 8080 to ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# EXPLANATION:
# port-forward           : Forward local port to pod/service
# svc/argocd-server     : The ArgoCD server service
# -n argocd             : In argocd namespace
# 8080:443              : Local port 8080 → Service port 443

# Output:
# Forwarding from 127.0.0.1:8080 -> 8080
# Forwarding from [::1]:8080 -> 8080

# Keep this terminal open!
# ArgoCD UI is now available at: https://localhost:8080
```

**Access the UI:**

```bash
# Open in browser
open https://localhost:8080

# Or manually go to: https://localhost:8080

# You'll see a security warning (self-signed certificate)
# Click "Advanced" → "Proceed to localhost"
```

### Method 2: NodePort (For Minikube)

**WHAT:** Expose ArgoCD using NodePort

**WHY:** Persistent access without port-forward

**HOW:**

```bash
# Change service type to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# EXPLANATION:
# patch                : Modify existing resource
# svc argocd-server   : The ArgoCD server service
# -n argocd           : In argocd namespace
# -p '{"spec": ...}'  : Patch with this JSON

# Get the URL (Minikube only)
minikube service argocd-server -n argocd --url

# Output:
# https://192.168.49.2:30443

# Open this URL in browser
```

### Method 3: LoadBalancer (For Cloud)

**WHAT:** Expose ArgoCD using LoadBalancer

**WHY:** Production-ready external access

**HOW:**

```bash
# Change service type to LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Wait for external IP (takes 2-3 minutes)
kubectl get svc argocd-server -n argocd -w

# Output:
# NAME            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)
# argocd-server   LoadBalancer   10.100.200.1    <pending>       80:30080/TCP
# argocd-server   LoadBalancer   10.100.200.1    34.123.45.67    80:30080/TCP

# Access using external IP:
# https://34.123.45.67
```

---

## 🔐 Initial Configuration

### Step 1: Get Admin Password

**WHAT:** Retrieve the initial admin password

**WHY:** Need password to login to ArgoCD

**HOW:**

```bash
# Get the password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# EXPLANATION:
# get secret                        : Get Kubernetes secret
# argocd-initial-admin-secret      : Name of the secret
# -o jsonpath="{.data.password}"   : Extract password field
# | base64 -d                       : Decode from base64

# Output (example):
# mK8fH3jP9qR2sT5v

# Copy this password!
```

**Save the Password:**

```bash
# Save to a file for easy access
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > argocd-password.txt

# View the password
cat argocd-password.txt

# IMPORTANT: Keep this password safe!
```

### Step 2: Login to ArgoCD UI

**WHAT:** Access ArgoCD web interface

**WHY:** Manage applications visually

**HOW:**

```
1. Open browser to: https://localhost:8080
2. You'll see ArgoCD login page
3. Enter credentials:
   Username: admin
   Password: <password from previous step>
4. Click "SIGN IN"
5. You're in! 🎉
```

**What You'll See:**

```
┌─────────────────────────────────────────────────┐
│ ArgoCD Dashboard                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  Applications (0)                               │
│  ┌─────────────────────────────────────────┐   │
│  │  No applications yet                     │   │
│  │  Create your first application!          │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [+ NEW APP]  [Settings]  [User Info]          │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Step 3: Change Admin Password (Recommended)

**WHAT:** Change default password to secure one

**WHY:** Security best practice

**HOW:**

**Option A: Using UI**

```
1. Click "User Info" (top right)
2. Click "Update Password"
3. Enter:
   - Current Password: <initial password>
   - New Password: <your secure password>
   - Confirm Password: <your secure password>
4. Click "Save"
```

**Option B: Using CLI**

```bash
# Install ArgoCD CLI first (see next section)

# Login
argocd login localhost:8080 --username admin --password <initial-password> --insecure

# Change password
argocd account update-password

# You'll be prompted:
# *** Enter current password:
# *** Enter new password:
# *** Confirm new password:
# Password updated
```

### Step 4: Install ArgoCD CLI (Optional but Recommended)

**WHAT:** Command-line tool for ArgoCD

**WHY:** Manage ArgoCD from terminal

**HOW:**

#### macOS

```bash
# Using Homebrew
brew install argocd

# Verify installation
argocd version
```

#### Linux

```bash
# Download latest version
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# Install it
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Remove download
rm argocd-linux-amd64

# Verify installation
argocd version
```

#### Windows

```powershell
# Download from GitHub releases
# https://github.com/argoproj/argo-cd/releases/latest

# Or using Chocolatey
choco install argocd-cli

# Verify installation
argocd version
```

**Login with CLI:**

```bash
# Login to ArgoCD
argocd login localhost:8080 --username admin --password <your-password> --insecure

# EXPLANATION:
# login localhost:8080  : ArgoCD server address
# --username admin      : Username
# --password <pass>     : Password
# --insecure           : Skip TLS verification (for self-signed cert)

# Output:
# 'admin:login' logged in successfully
# Context 'localhost:8080' updated
```

---

## ✅ Verification

### Check Installation

```bash
# 1. Check all pods are running
kubectl get pods -n argocd

# All should show READY 1/1 and STATUS Running

# 2. Check services
kubectl get svc -n argocd

# Should show:
# NAME                    TYPE        CLUSTER-IP       PORT(S)
# argocd-server           ClusterIP   10.96.100.1      80/TCP,443/TCP
# argocd-repo-server      ClusterIP   10.96.100.2      8081/TCP
# argocd-redis            ClusterIP   10.96.100.3      6379/TCP
# argocd-dex-server       ClusterIP   10.96.100.4      5556/TCP,5557/TCP

# 3. Check ArgoCD version
kubectl get deployment argocd-server -n argocd -o jsonpath='{.spec.template.spec.containers[0].image}'

# Output: quay.io/argoproj/argocd:v2.9.0 (or similar)

# 4. Access UI and verify login works
# Open https://localhost:8080
# Login with admin credentials
# Should see ArgoCD dashboard
```

### Test ArgoCD CLI

```bash
# Check CLI version
argocd version

# Output:
# argocd: v2.9.0+unknown
# BuildDate: 2023-11-15T18:30:00Z
# GitCommit: abc123def456
# GoVersion: go1.21.0
# Compiler: gc
# Platform: darwin/amd64
# argocd-server: v2.9.0+unknown

# List applications (should be empty)
argocd app list

# Output:
# NAME  CLUSTER  NAMESPACE  PROJECT  STATUS  HEALTH  SYNCPOLICY  CONDITIONS  REPO  PATH  TARGET
# (empty - no applications yet)
```

---

## 🔧 Troubleshooting

### Problem 1: Pods Not Starting

**Symptom:**

```bash
kubectl get pods -n argocd
# Shows pods in CrashLoopBackOff or Error state
```

**Solution:**

```bash
# Check pod logs
kubectl logs -n argocd deployment/argocd-server

# Check pod events
kubectl describe pod -n argocd <pod-name>

# Common fixes:
# 1. Not enough resources
minikube delete
minikube start --cpus=4 --memory=8192

# 2. Image pull issues
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

### Problem 2: Can't Access UI

**Symptom:**

```
Browser shows "Connection refused" or "Unable to connect"
```

**Solution:**

```bash
# 1. Check port-forward is running
# Make sure you have this running in a terminal:
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 2. Check service is running
kubectl get svc argocd-server -n argocd

# 3. Try different port
kubectl port-forward svc/argocd-server -n argocd 9090:443
# Then access: https://localhost:9090

# 4. Check firewall
# Make sure port 8080 is not blocked
```

### Problem 3: Can't Login

**Symptom:**

```
"Invalid username or password" error
```

**Solution:**

```bash
# 1. Get password again
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 2. Check if secret exists
kubectl get secret -n argocd argocd-initial-admin-secret

# 3. If secret doesn't exist, reset password
kubectl -n argocd delete secret argocd-initial-admin-secret
kubectl -n argocd rollout restart deployment argocd-server
# Wait for restart, then get new password
```

### Problem 4: Certificate Errors

**Symptom:**

```
Browser shows "Your connection is not private"
```

**Solution:**

```
This is normal for self-signed certificates!

1. Click "Advanced"
2. Click "Proceed to localhost" (or similar)
3. Or use --insecure flag with CLI:
   argocd login localhost:8080 --insecure
```

### Problem 5: Minikube Issues

**Symptom:**

```
Minikube won't start or crashes
```

**Solution:**

```bash
# 1. Delete and recreate
minikube delete
minikube start --cpus=4 --memory=8192

# 2. Check Docker is running
docker ps

# 3. Check system resources
# Make sure you have:
# - 8GB RAM available
# - 20GB disk space
# - Docker running

# 4. Try different driver
minikube start --driver=virtualbox
# or
minikube start --driver=hyperkit
```

### Getting Help

```bash
# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server

# Check all resources
kubectl get all -n argocd

# Describe problematic pod
kubectl describe pod -n argocd <pod-name>

# Check events
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

---

## 🎯 Next Steps

Congratulations! ArgoCD is now installed and running! 🎉

**What You've Accomplished:**

- ✅ Installed Kubernetes cluster
- ✅ Installed ArgoCD
- ✅ Accessed ArgoCD UI
- ✅ Configured admin access
- ✅ Verified installation

**Next Guide:** [`03-FIRST-APPLICATION.md`](03-FIRST-APPLICATION.md)

You'll learn:

- Create your first ArgoCD application
- Deploy from Git repository
- See GitOps in action!

---

## 📚 Quick Reference

### Useful Commands

```bash
# Check ArgoCD status
kubectl get pods -n argocd

# Access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Restart ArgoCD
kubectl rollout restart deployment argocd-server -n argocd

# View logs
kubectl logs -n argocd deployment/argocd-server -f

# Delete ArgoCD (if needed)
kubectl delete namespace argocd
```

---

**Remember:** Keep the port-forward terminal open while using ArgoCD UI! 🚀
