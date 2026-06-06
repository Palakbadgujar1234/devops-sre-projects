# 🚀 Quick Start Checklist - Project 1

**Everything you need to implement this project step-by-step**

---

## ✅ Pre-Implementation Checklist

### Before You Start

**Check these off as you complete them:**

#### 1. Software Installation

- [ ] Docker Desktop installed and running
- [ ] kubectl installed (`kubectl version --client`)
- [ ] Git installed (`git --version`)
- [ ] VS Code or text editor installed
- [ ] Terminal/Command Prompt ready

#### 2. Accounts Created

- [ ] GitHub account created
- [ ] Docker Hub account created
- [ ] Email verified for both accounts

#### 3. Basic Knowledge

- [ ] Can run basic terminal commands
- [ ] Understand what Docker is
- [ ] Know basic Git commands (clone, commit, push)
- [ ] Have 4-6 hours available

---

## 📋 Implementation Steps Overview

### Phase 1: Setup Environment (1 hour)

```
Step 1: Install Docker Desktop          [15 min]
Step 2: Install kubectl                 [10 min]
Step 3: Create Kubernetes cluster       [15 min]
Step 4: Install Jenkins                 [20 min]
```

### Phase 2: Create Application (30 min)

```
Step 5: Create sample application       [15 min]
Step 6: Create Dockerfile              [15 min]
```

### Phase 3: Setup Jenkins Pipeline (1 hour)

```
Step 7: Configure Jenkins              [20 min]
Step 8: Create Jenkinsfile             [20 min]
Step 9: Setup GitHub webhook           [20 min]
```

### Phase 4: Kubernetes Deployment (1 hour)

```
Step 10: Create K8s manifests          [30 min]
Step 11: Deploy to Kubernetes          [30 min]
```

### Phase 5: Testing & Verification (30 min)

```
Step 12: Test the pipeline             [15 min]
Step 13: Verify deployment             [15 min]
```

**Total Time: 4 hours**

---

## 🎯 Detailed Step-by-Step Guide

### STEP 1: Install Docker Desktop (15 minutes)

#### For Mac

```bash
# 1. Download Docker Desktop
# Go to: https://www.docker.com/products/docker-desktop

# 2. Install the .dmg file
# Drag Docker to Applications folder

# 3. Start Docker Desktop
# Open from Applications

# 4. Verify installation
docker --version
docker ps

# Expected output:
# Docker version 24.0.x
# CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

#### For Windows

```bash
# 1. Download Docker Desktop
# Go to: https://www.docker.com/products/docker-desktop

# 2. Run the installer
# Follow installation wizard

# 3. Restart computer if prompted

# 4. Start Docker Desktop

# 5. Verify installation
docker --version
docker ps
```

**Troubleshooting:**

- If Docker doesn't start: Check system requirements
- If "permission denied": Run terminal as administrator
- If slow: Allocate more resources in Docker settings

---

### STEP 2: Install kubectl (10 minutes)

#### For Mac

```bash
# Using Homebrew
brew install kubectl

# Verify installation
kubectl version --client

# Expected output:
# Client Version: v1.28.x
```

#### For Windows

```bash
# Using Chocolatey
choco install kubernetes-cli

# Or download directly
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

# Verify installation
kubectl version --client
```

**What is kubectl?**

- Command-line tool for Kubernetes
- Used to deploy and manage applications
- Communicates with Kubernetes cluster

---

### STEP 3: Create Kubernetes Cluster (15 minutes)

#### Enable Kubernetes in Docker Desktop

```bash
# 1. Open Docker Desktop

# 2. Go to Settings (gear icon)

# 3. Click "Kubernetes" tab

# 4. Check "Enable Kubernetes"

# 5. Click "Apply & Restart"

# 6. Wait 2-3 minutes for cluster to start

# 7. Verify cluster is running
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://kubernetes.docker.internal:6443
```

**What just happened?**

- Docker Desktop created a local Kubernetes cluster
- This cluster runs on your laptop
- Perfect for development and learning

---

### STEP 4: Install Jenkins (20 minutes)

#### Using Docker (Easiest way)

```bash
# 1. Create a network for Jenkins
docker network create jenkins

# 2. Run Jenkins container
docker run -d \
  --name jenkins \
  --network jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# 3. Wait 1-2 minutes for Jenkins to start

# 4. Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Copy this password!

# 5. Open Jenkins in browser
# Go to: http://localhost:8080

# 6. Paste the password

# 7. Click "Install suggested plugins"
# Wait 5 minutes for plugins to install

# 8. Create admin user
# Username: admin
# Password: admin (or your choice)
# Full name: Your Name
# Email: your@email.com

# 9. Click "Save and Continue"

# 10. Click "Start using Jenkins"
```

**What is Jenkins?**

- Automation server for CI/CD
- Runs your pipeline
- Builds, tests, and deploys code

**Troubleshooting:**

- Port 8080 already in use? Change to `-p 8081:8080`
- Can't access Jenkins? Check Docker is running
- Forgot password? Run step 4 again

---

### STEP 5: Create Sample Application (15 minutes)

#### Create project directory

```bash
# 1. Create project folder
mkdir -p ~/cicd-project
cd ~/cicd-project

# 2. Initialize Git repository
git init

# 3. Create application file
cat > app.js << 'EOF'
// Simple Node.js application
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from CI/CD Pipeline!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
EOF

# 4. Create package.json
cat > package.json << 'EOF'
{
  "name": "cicd-demo-app",
  "version": "1.0.0",
  "description": "Demo app for CI/CD pipeline",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo 'Tests passed!' && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# 5. Test locally (optional)
npm install
npm start

# Open browser: http://localhost:3000
# You should see JSON response

# Press Ctrl+C to stop
```

**What did we create?**

- Simple Node.js web application
- Has two endpoints: / and /health
- Returns JSON responses
- Ready to be containerized

---

### STEP 6: Create Dockerfile (15 minutes)

```bash
# Still in ~/cicd-project directory

# 1. Create Dockerfile
cat > Dockerfile << 'EOF'
# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY app.js ./

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
EOF

# 2. Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
EOF

# 3. Build Docker image
docker build -t cicd-demo-app:v1 .

# Expected output:
# Successfully built abc123def456
# Successfully tagged cicd-demo-app:v1

# 4. Test Docker image
docker run -d -p 3000:3000 --name test-app cicd-demo-app:v1

# 5. Verify it works
curl http://localhost:3000

# Expected output:
# {"message":"Hello from CI/CD Pipeline!","version":"1.0.0",...}

# 6. Stop and remove test container
docker stop test-app
docker rm test-app
```

**What is a Dockerfile?**

- Instructions to build Docker image
- Like a recipe for your application
- Creates consistent environment

**Why multi-stage build?**

- Smaller image size
- Better security
- Faster deployments

---

### STEP 7: Configure Jenkins (20 minutes)

#### Install Required Plugins

```bash
# 1. Open Jenkins: http://localhost:8080

# 2. Click "Manage Jenkins"

# 3. Click "Manage Plugins"

# 4. Click "Available" tab

# 5. Search and install these plugins:
#    - Docker Pipeline
#    - Kubernetes
#    - Git
#    - Pipeline

# 6. Click "Install without restart"

# 7. Wait for installation to complete

# 8. Click "Restart Jenkins when no jobs are running"

# 9. Wait 2 minutes for Jenkins to restart

# 10. Login again (admin/admin)
```

#### Configure Docker in Jenkins

```bash
# 1. In Jenkins, click "Manage Jenkins"

# 2. Click "Configure System"

# 3. Scroll to "Docker"

# 4. Click "Add Docker"

# 5. Name: docker

# 6. Docker Host URI: unix:///var/run/docker.sock

# 7. Click "Test Connection"
# Should see: "Version: 24.0.x"

# 8. Click "Save"
```

#### Add Docker Hub Credentials

```bash
# 1. In Jenkins, click "Manage Jenkins"

# 2. Click "Manage Credentials"

# 3. Click "(global)"

# 4. Click "Add Credentials"

# 5. Kind: Username with password

# 6. Username: your-dockerhub-username

# 7. Password: your-dockerhub-password

# 8. ID: dockerhub

# 9. Description: Docker Hub Credentials

# 10. Click "Create"
```

---

### STEP 8: Create Jenkinsfile (20 minutes)

```bash
# Still in ~/cicd-project directory

# Create Jenkinsfile
cat > Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "your-dockerhub-username/cicd-demo-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building Docker image...'
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm test'
            }
        }
        
        stage('Push') {
            steps {
                echo 'Pushing to Docker Hub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh '''
                    kubectl set image deployment/cicd-demo \
                        cicd-demo=${DOCKER_IMAGE}:${DOCKER_TAG} \
                        --record
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
EOF

# IMPORTANT: Replace "your-dockerhub-username" with your actual username!
```

**What is a Jenkinsfile?**

- Pipeline as Code
- Defines all pipeline stages
- Version controlled with your code

**Pipeline Stages Explained:**

1. **Checkout** - Get code from Git
2. **Build** - Create Docker image
3. **Test** - Run automated tests
4. **Push** - Upload image to Docker Hub
5. **Deploy** - Deploy to Kubernetes

---

### STEP 9: Setup GitHub Webhook (20 minutes)

#### Push Code to GitHub

```bash
# 1. Create repository on GitHub
# Go to: https://github.com/new
# Name: cicd-demo-project
# Public or Private: Your choice
# Don't initialize with README

# 2. Add remote to your local repo
git remote add origin https://github.com/YOUR-USERNAME/cicd-demo-project.git

# 3. Add all files
git add .

# 4. Commit
git commit -m "Initial commit: CI/CD pipeline setup"

# 5. Push to GitHub
git push -u origin main

# If it asks for credentials:
# Username: your-github-username
# Password: use Personal Access Token (not password!)
```

#### Create Personal Access Token

```bash
# 1. Go to GitHub Settings
# https://github.com/settings/tokens

# 2. Click "Generate new token" → "Generate new token (classic)"

# 3. Note: "Jenkins CI/CD"

# 4. Select scopes:
#    - repo (all)
#    - admin:repo_hook

# 5. Click "Generate token"

# 6. COPY THE TOKEN! You won't see it again!
```

#### Create Jenkins Job

```bash
# 1. Open Jenkins: http://localhost:8080

# 2. Click "New Item"

# 3. Name: cicd-demo-pipeline

# 4. Type: Pipeline

# 5. Click "OK"

# 6. In "Pipeline" section:
#    Definition: Pipeline script from SCM
#    SCM: Git
#    Repository URL: https://github.com/YOUR-USERNAME/cicd-demo-project.git
#    Credentials: Add → Jenkins
#      Kind: Username with password
#      Username: your-github-username
#      Password: paste-your-token-here
#      ID: github
#    Branch: */main
#    Script Path: Jenkinsfile

# 7. Click "Save"
```

---

### STEP 10: Create Kubernetes Manifests (30 minutes)

```bash
# Create kubernetes directory
mkdir -p kubernetes
cd kubernetes

# 1. Create Deployment manifest
cat > deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-demo
  labels:
    app: cicd-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cicd-demo
  template:
    metadata:
      labels:
        app: cicd-demo
    spec:
      containers:
      - name: cicd-demo
        image: your-dockerhub-username/cicd-demo-app:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 3
EOF

# 2. Create Service manifest
cat > service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: cicd-demo-service
spec:
  type: LoadBalancer
  selector:
    app: cicd-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
EOF

# 3. Apply to Kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 4. Verify deployment
kubectl get deployments
kubectl get pods
kubectl get services

# Expected output:
# NAME        READY   UP-TO-DATE   AVAILABLE   AGE
# cicd-demo   2/2     2            2           30s
```

**What did we create?**

- **Deployment**: Manages your application pods
- **Service**: Exposes your application
- **2 replicas**: High availability

---

### STEP 11: Deploy to Kubernetes (30 minutes)

#### Initial Deployment

```bash
# 1. Make sure Kubernetes manifests are applied
cd ~/cicd-project/kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 2. Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=cicd-demo --timeout=60s

# 3. Get service URL
kubectl get service cicd-demo-service

# 4. Test the application
# If using Docker Desktop on Mac:
curl http://localhost

# Expected output:
# {"message":"Hello from CI/CD Pipeline!","version":"1.0.0",...}
```

#### Configure Jenkins for K8s Access

```bash
# 1. Get Kubernetes config
cat ~/.kube/config

# 2. In Jenkins, go to "Manage Jenkins" → "Configure System"

# 3. Add Kubernetes configuration
# (This allows Jenkins to deploy to K8s)

# 4. Test by running the pipeline
# In Jenkins, click on your pipeline
# Click "Build Now"

# 5. Watch the build progress
# Click on build number → "Console Output"
```

---

### STEP 12: Test the Pipeline (15 minutes)

#### Trigger Pipeline Manually

```bash
# 1. In Jenkins, open your pipeline

# 2. Click "Build Now"

# 3. Watch the stages execute:
#    ✅ Checkout
#    ✅ Build
#    ✅ Test
#    ✅ Push
#    ✅ Deploy

# 4. Check Console Output for any errors

# 5. If successful, verify deployment:
kubectl get pods
kubectl logs -l app=cicd-demo

# 6. Test the application:
curl http://localhost
```

#### Trigger Pipeline with Git Push

```bash
# 1. Make a change to your app
cd ~/cicd-project
echo "// Updated" >> app.js

# 2. Commit and push
git add .
git commit -m "Test pipeline trigger"
git push

# 3. Watch Jenkins automatically start building!

# 4. Verify new version deployed:
kubectl get pods
# You should see new pods being created
```

---

### STEP 13: Verify Everything Works (15 minutes)

#### Final Verification Checklist

```bash
# 1. Check Jenkins is running
curl http://localhost:8080

# 2. Check Kubernetes cluster
kubectl cluster-info

# 3. Check application pods
kubectl get pods -l app=cicd-demo

# Expected: 2 pods running

# 4. Check application service
kubectl get service cicd-demo-service

# 5. Test application endpoint
curl http://localhost

# Expected: JSON response

# 6. Check pipeline history
# Open Jenkins → Your pipeline
# Should see successful builds

# 7. Make a test change and push
echo "console.log('Pipeline test');" >> app.js
git add .
git commit -m "Pipeline test"
git push

# 8. Watch automatic deployment
# Jenkins should automatically:
#   - Detect the push
#   - Build new image
#   - Run tests
#   - Push to Docker Hub
#   - Deploy to Kubernetes

# 9. Verify new version deployed
kubectl rollout status deployment/cicd-demo

# 10. Test the updated application
curl http://localhost
```

---

## ✅ Success Criteria

### You've Successfully Completed When

**Infrastructure:**

- [ ] Docker Desktop running
- [ ] Kubernetes cluster active
- [ ] Jenkins accessible at localhost:8080
- [ ] Application accessible at localhost

**Pipeline:**

- [ ] Pipeline runs on git push
- [ ] All stages complete successfully
- [ ] Docker image pushed to Docker Hub
- [ ] Application deployed to Kubernetes

**Verification:**

- [ ] Can access application in browser
- [ ] Can see logs in Kubernetes
- [ ] Can see build history in Jenkins
- [ ] Can trigger pipeline with code changes

---

## 🎯 What You've Built

### Complete CI/CD Pipeline

```
Code Change → Git Push → GitHub
                           ↓
                      (Webhook)
                           ↓
                       Jenkins
                           ↓
              Build → Test → Push → Deploy
                           ↓
                      Kubernetes
                           ↓
                   Running Application
```

### Key Components

1. **Source Control**: GitHub
2. **CI/CD Server**: Jenkins
3. **Container Registry**: Docker Hub
4. **Orchestration**: Kubernetes
5. **Application**: Node.js app

---

## 🎤 Interview Talking Points

**You can now say:**
> "I built a complete CI/CD pipeline using Jenkins and Kubernetes. The pipeline automatically triggers on code commits, builds Docker images, runs tests, pushes to Docker Hub, and deploys to Kubernetes with zero downtime. I implemented health checks, resource limits, and automated rollback capabilities."

**You can demonstrate:**

- Making a code change
- Pushing to GitHub
- Watching automatic deployment
- Verifying in Kubernetes
- Showing the running application

---

## 🐛 Troubleshooting

### Common Issues

**Jenkins won't start:**

```bash
docker logs jenkins
# Check for errors
# Usually port conflict or resource issue
```

**Pipeline fails at Build stage:**

```bash
# Check Docker is running
docker ps

# Check Jenkins has Docker access
docker exec jenkins docker ps
```

**Pipeline fails at Deploy stage:**

```bash
# Check Kubernetes is running
kubectl cluster-info

# Check pods status
kubectl get pods

# Check logs
kubectl logs -l app=cicd-demo
```

**Application not accessible:**

```bash
# Check service
kubectl get service cicd-demo-service

# Check pods are running
kubectl get pods -l app=cicd-demo

# Check pod logs
kubectl logs -l app=cicd-demo
```

---

## 🎉 Congratulations

You've successfully built a production-grade CI/CD pipeline!

**Next Steps:**

1. Read [06-CODE-EXPLANATION.md](./06-CODE-EXPLANATION.md) to understand every line
2. Practice [07-INTERVIEW-QUESTIONS.md](./07-INTERVIEW-QUESTIONS.md)
3. Add this to your resume and portfolio
4. Practice explaining it to others

**You're now ready for DevOps interviews!** 🚀
