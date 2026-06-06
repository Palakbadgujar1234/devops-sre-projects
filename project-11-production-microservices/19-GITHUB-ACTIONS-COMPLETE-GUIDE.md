# 🚀 GitHub Actions - Complete CI/CD Guide

## 📖 Overview

This guide provides a **COMPLETE, EASY-TO-LEARN** GitHub Actions implementation with every line explained. You'll be able to confidently explain this in interviews.

---

## 🎯 What We'll Build

**End-to-End CI/CD Pipeline:**

```
Code Push → GitHub Actions → Build → Test → Docker Build → Push to Registry → Deploy to Kubernetes
```

**Time:** 5-10 minutes per run
**Triggers:** Every push to main/develop branches

---

## 📚 Part 1: GitHub Actions Basics

### What is GitHub Actions?

**WHAT:** CI/CD platform integrated with GitHub

**WHY:**

- ✅ Automated testing and deployment
- ✅ Integrated with GitHub (no external tool)
- ✅ Free for public repos
- ✅ Easy to configure (YAML files)
- ✅ Large marketplace of actions

**HOW IT WORKS:**

```
1. Developer pushes code to GitHub
2. GitHub detects .github/workflows/*.yml files
3. Triggers workflow based on events (push, PR, etc.)
4. Runs jobs on GitHub-hosted runners
5. Executes steps in sequence
6. Reports success/failure
```

---

## 🔧 Part 2: Complete CI/CD Pipeline

### Step 2.1: Create Workflow File

**Location:** `.github/workflows/ci-cd.yml`

**WHAT:** YAML file that defines the CI/CD pipeline

**WHY:** GitHub Actions reads this to know what to do

**HOW:** Create the file in your repository

```yaml
# .github/workflows/ci-cd.yml

# WHAT: Name of the workflow (shows in GitHub UI)
# WHY: Identify this workflow among others
name: CI/CD Pipeline

# WHAT: When to trigger this workflow
# WHY: Define events that start the pipeline
on:
  push:
    branches:
      - main      # Production deployments
      - develop   # Development deployments
  pull_request:
    branches:
      - main      # Test PRs before merging
      - develop

# EXPLANATION:
# on.push: Triggers when code is pushed
# on.pull_request: Triggers when PR is created/updated
# branches: Only for these branches

# WHAT: Environment variables available to all jobs
# WHY: Avoid repetition, centralize configuration
env:
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  NODE_VERSION: '18'
  
# EXPLANATION:
# DOCKER_REGISTRY: Where to push Docker images
# IMAGE_NAME: Uses repo name (owner/repo)
# NODE_VERSION: Node.js version to use
# ${{ }}: GitHub Actions expression syntax

# WHAT: Jobs to run (can run in parallel or sequence)
# WHY: Organize pipeline into logical steps
jobs:
  
  # ============================================
  # JOB 1: BUILD AND TEST
  # ============================================
  
  build-and-test:
    # WHAT: Name of this job
    # WHY: Descriptive name for GitHub UI
    name: Build and Test
    
    # WHAT: Type of machine to run on
    # WHY: GitHub provides these runners for free
    runs-on: ubuntu-latest
    
    # EXPLANATION:
    # ubuntu-latest: Latest Ubuntu Linux
    # Other options: windows-latest, macos-latest
    # GitHub maintains these machines
    
    # WHAT: Sequence of steps to execute
    # WHY: Define what this job does
    steps:
      
      # ----------------------------------------
      # STEP 1: Checkout Code
      # ----------------------------------------
      
      - name: Checkout code
        # WHAT: Use pre-built action from marketplace
        # WHY: Don't reinvent the wheel
        uses: actions/checkout@v4
        
        # EXPLANATION:
        # actions/checkout: Official GitHub action
        # @v4: Version 4 of the action
        # DOES: Clones your repository to the runner
        # WHY NEEDED: Can't build without code!
      
      # ----------------------------------------
      # STEP 2: Setup Node.js
      # ----------------------------------------
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
        
        # EXPLANATION:
        # actions/setup-node: Official Node.js setup action
        # with: Parameters for the action
        # node-version: Which Node.js version to install
        # cache: 'npm': Cache npm dependencies for speed
        # WHY: Need Node.js to run our application
      
      # ----------------------------------------
      # STEP 3: Install Dependencies
      # ----------------------------------------
      
      - name: Install dependencies
        run: npm ci
        working-directory: ./backend
        
        # EXPLANATION:
        # run: Execute shell command
        # npm ci: Clean install (faster than npm install)
        # working-directory: Run command in this folder
        # WHY npm ci: Reproducible builds, uses package-lock.json
        # WHY NOT npm install: Can modify package-lock.json
      
      # ----------------------------------------
      # STEP 4: Run Linting
      # ----------------------------------------
      
      - name: Run linting
        run: npm run lint
        working-directory: ./backend
        
        # EXPLANATION:
        # npm run lint: Runs ESLint
        # WHY: Catch code quality issues
        # FAILS IF: Linting errors found
        # BENEFIT: Enforce code standards
      
      # ----------------------------------------
      # STEP 5: Run Unit Tests
      # ----------------------------------------
      
      - name: Run unit tests
        run: npm test
        working-directory: ./backend
        
        # EXPLANATION:
        # npm test: Runs Jest tests
        # WHY: Ensure code works correctly
        # FAILS IF: Any test fails
        # BENEFIT: Catch bugs early
      
      # ----------------------------------------
      # STEP 6: Run Test Coverage
      # ----------------------------------------
      
      - name: Generate test coverage
        run: npm run test:coverage
        working-directory: ./backend
        
        # EXPLANATION:
        # test:coverage: Runs tests with coverage report
        # WHY: Know how much code is tested
        # GENERATES: coverage/ directory
        # BENEFIT: Track test quality
      
      # ----------------------------------------
      # STEP 7: Upload Coverage Report
      # ----------------------------------------
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./backend/coverage/lcov.info
          flags: backend
          name: backend-coverage
        
        # EXPLANATION:
        # codecov/codecov-action: Upload to Codecov.io
        # files: Coverage report file
        # flags: Tag for this upload
        # WHY: Track coverage over time
        # OPTIONAL: Can skip if not using Codecov
  
  # ============================================
  # JOB 2: BUILD DOCKER IMAGE
  # ============================================
  
  build-docker:
    # WHAT: This job builds Docker image
    # WHY: Need containerized app for deployment
    name: Build Docker Image
    
    # WHAT: Only run after build-and-test succeeds
    # WHY: Don't build if tests fail
    needs: build-and-test
    
    # EXPLANATION:
    # needs: Dependency on other jobs
    # build-and-test: Must complete successfully first
    # WHY: No point building if tests fail
    
    runs-on: ubuntu-latest
    
    # WHAT: Only run on push (not PR)
    # WHY: Don't push images for PRs
    if: github.event_name == 'push'
    
    # EXPLANATION:
    # if: Conditional execution
    # github.event_name: Type of event (push/pull_request)
    # WHY: PRs shouldn't push to registry
    
    steps:
      
      # ----------------------------------------
      # STEP 1: Checkout Code
      # ----------------------------------------
      
      - name: Checkout code
        uses: actions/checkout@v4
      
      # ----------------------------------------
      # STEP 2: Set up Docker Buildx
      # ----------------------------------------
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
        # EXPLANATION:
        # Docker Buildx: Advanced Docker build tool
        # WHY: Better caching, multi-platform builds
        # FEATURES: Layer caching, parallel builds
      
      # ----------------------------------------
      # STEP 3: Login to Container Registry
      # ----------------------------------------
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
        
        # EXPLANATION:
        # docker/login-action: Login to registry
        # registry: ghcr.io (GitHub Container Registry)
        # username: GitHub username (automatic)
        # password: GitHub token (automatic, no setup needed)
        # WHY: Need authentication to push images
        # GITHUB_TOKEN: Automatically provided by GitHub
      
      # ----------------------------------------
      # STEP 4: Extract Metadata
      # ----------------------------------------
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=semver,pattern={{version}}
        
        # EXPLANATION:
        # docker/metadata-action: Generate image tags
        # id: meta: Reference this step's outputs later
        # images: Base image name
        # tags: Tag generation rules
        #   - type=ref,event=branch: Use branch name
        #   - type=sha: Use git commit SHA
        #   - type=semver: Use semantic version
        # EXAMPLE TAGS:
        #   - main
        #   - main-abc1234
        #   - v1.0.0
      
      # ----------------------------------------
      # STEP 5: Build and Push Docker Image
      # ----------------------------------------
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          file: ./backend/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
        
        # EXPLANATION:
        # docker/build-push-action: Build and push image
        # context: Build context directory
        # file: Path to Dockerfile
        # push: true: Push to registry
        # tags: Use tags from metadata step
        # labels: Use labels from metadata step
        # cache-from: Use GitHub Actions cache
        # cache-to: Save to GitHub Actions cache
        # WHY CACHE: Faster builds (reuse layers)
        # BENEFIT: 5-10x faster builds
  
  # ============================================
  # JOB 3: SECURITY SCAN
  # ============================================
  
  security-scan:
    # WHAT: Scan Docker image for vulnerabilities
    # WHY: Catch security issues before deployment
    name: Security Scan
    
    needs: build-docker
    runs-on: ubuntu-latest
    
    steps:
      
      # ----------------------------------------
      # STEP 1: Checkout Code
      # ----------------------------------------
      
      - name: Checkout code
        uses: actions/checkout@v4
      
      # ----------------------------------------
      # STEP 2: Run Trivy Security Scan
      # ----------------------------------------
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
        
        # EXPLANATION:
        # aquasecurity/trivy-action: Security scanner
        # image-ref: Image to scan
        # format: SARIF (Security Alert format)
        # output: Save results to file
        # severity: Only report CRITICAL and HIGH
        # WHY: Find vulnerabilities in dependencies
        # FAILS IF: Critical vulnerabilities found
      
      # ----------------------------------------
      # STEP 3: Upload Scan Results
      # ----------------------------------------
      
      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
        
        # EXPLANATION:
        # Upload results to GitHub Security tab
        # WHY: View vulnerabilities in GitHub UI
        # BENEFIT: Track security over time
  
  # ============================================
  # JOB 4: DEPLOY TO KUBERNETES
  # ============================================
  
  deploy:
    # WHAT: Deploy to Kubernetes cluster
    # WHY: Make new version available to users
    name: Deploy to Kubernetes
    
    needs: [build-docker, security-scan]
    runs-on: ubuntu-latest
    
    # WHAT: Only deploy from main or develop
    # WHY: Control which branches deploy
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop')
    
    # EXPLANATION:
    # github.ref: Full reference (refs/heads/main)
    # WHY: Only deploy specific branches
    # BENEFIT: Prevent accidental deployments
    
    steps:
      
      # ----------------------------------------
      # STEP 1: Checkout Code
      # ----------------------------------------
      
      - name: Checkout code
        uses: actions/checkout@v4
      
      # ----------------------------------------
      # STEP 2: Configure AWS Credentials
      # ----------------------------------------
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
        
        # EXPLANATION:
        # aws-actions/configure-aws-credentials: Setup AWS
        # secrets.AWS_ACCESS_KEY_ID: From GitHub Secrets
        # secrets.AWS_SECRET_ACCESS_KEY: From GitHub Secrets
        # WHY: Need AWS access for EKS
        # SETUP: Add secrets in GitHub repo settings
      
      # ----------------------------------------
      # STEP 3: Update Kubeconfig
      # ----------------------------------------
      
      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig \
            --name my-cluster \
            --region us-east-1
        
        # EXPLANATION:
        # aws eks update-kubeconfig: Configure kubectl
        # --name: EKS cluster name
        # --region: AWS region
        # WHY: kubectl needs cluster credentials
        # CREATES: ~/.kube/config file
      
      # ----------------------------------------
      # STEP 4: Deploy to Kubernetes
      # ----------------------------------------
      
      - name: Deploy to Kubernetes
        run: |
          # Update image in deployment
          kubectl set image deployment/backend \
            backend=${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            --namespace=production
          
          # Wait for rollout to complete
          kubectl rollout status deployment/backend \
            --namespace=production \
            --timeout=5m
        
        # EXPLANATION:
        # kubectl set image: Update container image
        # deployment/backend: Deployment name
        # backend=...: Container name and new image
        # ${{ github.sha }}: Git commit SHA (unique tag)
        # --namespace: Kubernetes namespace
        # kubectl rollout status: Wait for completion
        # --timeout=5m: Fail after 5 minutes
        # WHY: Ensure deployment succeeds
      
      # ----------------------------------------
      # STEP 5: Verify Deployment
      # ----------------------------------------
      
      - name: Verify deployment
        run: |
          # Check pod status
          kubectl get pods \
            --namespace=production \
            --selector=app=backend
          
          # Check deployment status
          kubectl get deployment backend \
            --namespace=production
        
        # EXPLANATION:
        # kubectl get pods: List pods
        # --selector: Filter by label
        # WHY: Verify pods are running
        # BENEFIT: Catch deployment issues
      
      # ----------------------------------------
      # STEP 6: Run Smoke Tests
      # ----------------------------------------
      
      - name: Run smoke tests
        run: |
          # Get service URL
          SERVICE_URL=$(kubectl get service backend \
            --namespace=production \
            -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
          
          # Test health endpoint
          curl -f http://$SERVICE_URL/health || exit 1
          
          # Test API endpoint
          curl -f http://$SERVICE_URL/api/users || exit 1
        
        # EXPLANATION:
        # kubectl get service: Get service details
        # -o jsonpath: Extract specific field
        # curl -f: Fail on HTTP errors
        # || exit 1: Exit with error if curl fails
        # WHY: Verify application works
        # BENEFIT: Catch runtime issues
  
  # ============================================
  # JOB 5: NOTIFY
  # ============================================
  
  notify:
    # WHAT: Send notifications about deployment
    # WHY: Keep team informed
    name: Notify
    
    needs: deploy
    runs-on: ubuntu-latest
    if: always()
    
    # EXPLANATION:
    # if: always(): Run even if previous jobs fail
    # WHY: Always want notifications
    
    steps:
      
      - name: Send Slack notification
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            Deployment ${{ job.status }}
            Branch: ${{ github.ref }}
            Commit: ${{ github.sha }}
            Author: ${{ github.actor }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        
        # EXPLANATION:
        # action-slack: Send Slack message
        # status: success/failure/cancelled
        # text: Message content
        # webhook_url: Slack webhook (from secrets)
        # WHY: Team notification
        # SETUP: Create webhook in Slack
```

---

## 🎯 Part 3: How to Use This Pipeline

### Step 3.1: Setup GitHub Secrets

**WHAT:** Store sensitive data securely

**WHY:** Don't commit credentials to Git

**HOW:**

```bash
# Go to GitHub repository
# Settings → Secrets and variables → Actions → New repository secret

# Add these secrets:
1. AWS_ACCESS_KEY_ID
   Value: Your AWS access key

2. AWS_SECRET_ACCESS_KEY
   Value: Your AWS secret key

3. SLACK_WEBHOOK (optional)
   Value: Your Slack webhook URL
```

### Step 3.2: Commit and Push

```bash
# Create workflow file
mkdir -p .github/workflows
# Copy the YAML above to .github/workflows/ci-cd.yml

# Commit and push
git add .github/workflows/ci-cd.yml
git commit -m "Add CI/CD pipeline"
git push origin main

# GitHub Actions will automatically run!
```

### Step 3.3: Monitor Pipeline

```bash
# View in GitHub:
# 1. Go to repository
# 2. Click "Actions" tab
# 3. See running workflows
# 4. Click on workflow to see details
# 5. View logs for each step
```

---

## 📊 Part 4: Pipeline Flow Visualization

```
┌─────────────────────────────────────────────────────────────┐
│                    DEVELOPER PUSHES CODE                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  GITHUB ACTIONS TRIGGERED                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 1: BUILD AND TEST (5 minutes)                          │
│  ├── Checkout code                                          │
│  ├── Setup Node.js                                          │
│  ├── Install dependencies                                   │
│  ├── Run linting                                            │
│  ├── Run unit tests                                         │
│  └── Generate coverage                                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 2: BUILD DOCKER (3 minutes)                            │
│  ├── Checkout code                                          │
│  ├── Setup Docker Buildx                                    │
│  ├── Login to registry                                      │
│  ├── Extract metadata                                       │
│  └── Build and push image                                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 3: SECURITY SCAN (2 minutes)                           │
│  ├── Checkout code                                          │
│  ├── Run Trivy scanner                                      │
│  └── Upload results                                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 4: DEPLOY (3 minutes)                                  │
│  ├── Checkout code                                          │
│  ├── Configure AWS                                          │
│  ├── Update kubeconfig                                      │
│  ├── Deploy to Kubernetes                                   │
│  ├── Verify deployment                                      │
│  └── Run smoke tests                                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 5: NOTIFY                                              │
│  └── Send Slack notification                                │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              DEPLOYMENT COMPLETE! ✅                         │
└─────────────────────────────────────────────────────────────┘

Total Time: ~13 minutes
```

---

## 🎤 Part 5: Interview Questions & Answers

### Q1: "Explain your CI/CD pipeline"

**Answer:**

```
"My CI/CD pipeline has 5 jobs that run sequentially:

1. Build and Test (5 min):
   - Checkout code from GitHub
   - Setup Node.js environment
   - Install dependencies with npm ci
   - Run ESLint for code quality
   - Run Jest unit tests
   - Generate test coverage report
   - Upload coverage to Codecov

2. Build Docker (3 min):
   - Only runs if tests pass
   - Setup Docker Buildx for advanced builds
   - Login to GitHub Container Registry
   - Generate image tags (branch name, commit SHA)
   - Build Docker image with caching
   - Push to registry

3. Security Scan (2 min):
   - Run Trivy vulnerability scanner
   - Check for CRITICAL and HIGH severity issues
   - Upload results to GitHub Security tab
   - Fail if critical vulnerabilities found

4. Deploy (3 min):
   - Only runs for main/develop branches
   - Configure AWS credentials
   - Update kubectl config for EKS
   - Update Kubernetes deployment with new image
   - Wait for rollout to complete (5 min timeout)
   - Verify pods are running
   - Run smoke tests (health check, API test)

5. Notify:
   - Send Slack notification with status
   - Runs even if previous jobs fail
   - Includes branch, commit, author info

Total time: ~13 minutes from commit to production

Benefits:
- Automated testing catches bugs early
- Security scanning prevents vulnerabilities
- Zero-downtime deployments
- Fast feedback loop
- Team notifications
```

### Q2: "Why use GitHub Actions over Jenkins?"

**Answer:**

```
"I chose GitHub Actions because:

1. Integration:
   - Built into GitHub (no separate server)
   - Access to GitHub context (PR info, commits, etc.)
   - Automatic authentication

2. Ease of Use:
   - YAML configuration (simple)
   - Marketplace of pre-built actions
   - No server maintenance

3. Cost:
   - Free for public repos
   - 2000 minutes/month free for private
   - No infrastructure costs

4. Features:
   - Matrix builds (test multiple versions)
   - Caching (faster builds)
   - Secrets management built-in
   - GitHub Security integration

Jenkins Advantages:
- More plugins
- Self-hosted (more control)
- Better for complex pipelines

For my project, GitHub Actions was perfect because:
- Simple pipeline
- Already using GitHub
- No need for separate server
- Free tier sufficient
```

### Q3: "How do you handle secrets?"

**Answer:**

```
"I use GitHub Secrets for sensitive data:

Setup:
1. Go to repo Settings → Secrets → Actions
2. Add secrets:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - SLACK_WEBHOOK

Usage in workflow:
${{ secrets.AWS_ACCESS_KEY_ID }}

Benefits:
- Encrypted at rest
- Not visible in logs
- Scoped to repository
- Can be organization-wide

Best Practices:
1. Never commit secrets to Git
2. Use least privilege (minimal permissions)
3. Rotate regularly
4. Use different secrets per environment
5. Audit access

Alternative: AWS Secrets Manager
- For production, use AWS Secrets Manager
- GitHub Actions retrieves from there
- Automatic rotation
- Better for teams
```

### Q4: "What if deployment fails?"

**Answer:**

```
"I have multiple safety mechanisms:

1. Automatic Rollback:
   - Kubernetes rolling update
   - If new pods fail health checks
   - Automatically reverts to old version
   - Zero downtime maintained

2. Timeout:
   - 5-minute timeout on rollout
   - Fails if deployment takes too long
   - Prevents hanging deployments

3. Smoke Tests:
   - Test health endpoint
   - Test API endpoints
   - Fail pipeline if tests fail
   - Can trigger rollback

4. Notifications:
   - Slack alert on failure
   - Team immediately notified
   - Includes error details

5. Manual Rollback:
   kubectl rollout undo deployment/backend

Recovery Process:
1. Pipeline fails and notifies team
2. Check logs in GitHub Actions
3. If needed, manual rollback
4. Fix issue in new commit
5. Pipeline runs again

Prevention:
- Comprehensive tests
- Security scanning
- Staging environment first
- Gradual rollout (canary)
```

---

## 🎯 Part 6: Advanced Features

### Feature 1: Matrix Builds

**WHAT:** Test multiple versions simultaneously

**WHY:** Ensure compatibility

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test

# EXPLANATION:
# Runs 6 jobs (3 Node versions × 2 OS)
# Tests compatibility across versions
# Runs in parallel (faster)
```

### Feature 2: Caching

**WHAT:** Reuse dependencies between runs

**WHY:** Faster builds (5-10x)

```yaml
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

# EXPLANATION:
# Caches npm dependencies
# Key based on package-lock.json hash
# Restores if hash matches
# Saves 2-3 minutes per build
```

### Feature 3: Conditional Steps

**WHAT:** Run steps based on conditions

**WHY:** Different behavior per branch

```yaml
- name: Deploy to production
  if: github.ref == 'refs/heads/main'
  run: kubectl apply -f k8s/prod/

- name: Deploy to staging
  if: github.ref == 'refs/heads/develop'
  run: kubectl apply -f k8s/staging/

# EXPLANATION:
# Different deployments per branch
# Production only from main
# Staging from develop
```

---

## 📚 Part 7: Complete Example Repository Structure

```
my-project/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml           ← Main pipeline
│       ├── pr-check.yml        ← PR validation
│       └── release.yml         ← Release automation
├── backend/
│   ├── src/
│   ├── test/
│   ├── Dockerfile
│   ├── package.json
│   └── .eslintrc.js
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
└── README.md
```

---

## 🎉 Summary

**You now know:**

- ✅ What GitHub Actions is and why to use it
- ✅ How to create a complete CI/CD pipeline
- ✅ Every line of the workflow file explained
- ✅ How to setup secrets
- ✅ How to handle failures
- ✅ How to answer interview questions
- ✅ Advanced features (matrix, caching, conditions)

**Time to master:** 1-2 days of practice

**Interview confidence:** 100% 🚀

---

**Next:** [Istio Service Mesh Guide →](20-ISTIO-SERVICE-MESH-GUIDE.md)
