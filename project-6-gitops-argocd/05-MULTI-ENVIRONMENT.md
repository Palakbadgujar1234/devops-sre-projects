# 🌍 Multi-Environment Management with GitOps

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [Environment Strategies](#environment-strategies)
3. [Promotion Workflows](#promotion-workflows)
4. [Branch-Based Environments](#branch-based-environments)
5. [Kustomize Patterns](#kustomize-patterns)
6. [Environment-Specific Secrets](#environment-specific-secrets)
7. [Testing Strategies](#testing-strategies)
8. [Best Practices](#best-practices)

---

## 🎯 Introduction

### WHAT is Multi-Environment Management?

Managing **multiple deployment environments** (dev, staging, production) with different configurations using GitOps.

### WHY Multiple Environments?

```
Development → Staging → Production

Dev:
- Test new features
- Rapid iteration
- Minimal resources
- Can break

Staging:
- Pre-production testing
- Performance testing
- Integration testing
- Production-like

Production:
- Live users
- High availability
- Maximum resources
- Must be stable
```

### HOW We Manage Them

Using **Kustomize overlays** and **ArgoCD applications** to maintain environment-specific configurations while sharing common base configurations.

---

## 🏗️ Environment Strategies

### Strategy 1: Overlay-Based (What We Use)

**WHAT:** Base configuration + environment overlays

**Structure:**

```
apps/frontend/
├── base/              ← Common config
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/           ← Dev-specific
    ├── staging/       ← Staging-specific
    └── prod/          ← Prod-specific
```

**Pros:**

- ✅ DRY (Don't Repeat Yourself)
- ✅ Easy to maintain
- ✅ Clear differences
- ✅ Kustomize native

**Cons:**

- ⚠️ Changes to base affect all environments
- ⚠️ Need careful testing

**When to Use:**

- Most common use case
- Environments are similar
- Want to share common config

### Strategy 2: Branch-Based

**WHAT:** Different Git branches for each environment

**Structure:**

```
main branch        → Production
staging branch     → Staging
develop branch     → Development
```

**Pros:**

- ✅ Complete isolation
- ✅ Easy rollback (branch revert)
- ✅ Clear promotion path

**Cons:**

- ⚠️ More complex Git workflow
- ⚠️ Merge conflicts
- ⚠️ Code duplication

**When to Use:**

- Need complete isolation
- Different teams per environment
- Strict change control

### Strategy 3: Repository-Based

**WHAT:** Separate Git repositories per environment

**Structure:**

```
app-dev-repo       → Development
app-staging-repo   → Staging
app-prod-repo      → Production
```

**Pros:**

- ✅ Maximum isolation
- ✅ Different access controls
- ✅ Independent versioning

**Cons:**

- ⚠️ Most complex
- ⚠️ Difficult to sync changes
- ⚠️ Maintenance overhead

**When to Use:**

- Enterprise with strict separation
- Different teams own environments
- Compliance requirements

---

## 🔄 Promotion Workflows

### Workflow 1: Manual Promotion

**WHAT:** Manually promote changes between environments

**Process:**

```
1. Develop in dev environment
2. Test in dev
3. Manually update staging
4. Test in staging
5. Manually update production
6. Monitor production
```

**Implementation:**

```bash
# Step 1: Deploy to dev
git checkout main
# Make changes to apps/frontend/overlays/dev/
git commit -m "Add feature X to dev"
git push

# Step 2: Test in dev
# ... testing ...

# Step 3: Promote to staging
# Copy changes to staging overlay
cp apps/frontend/overlays/dev/feature.yaml apps/frontend/overlays/staging/
git commit -m "Promote feature X to staging"
git push

# Step 4: Test in staging
# ... testing ...

# Step 5: Promote to production
cp apps/frontend/overlays/staging/feature.yaml apps/frontend/overlays/prod/
git commit -m "Promote feature X to production"
git push
```

**Pros:**

- ✅ Full control
- ✅ Explicit approval
- ✅ Easy to understand

**Cons:**

- ⚠️ Manual work
- ⚠️ Prone to errors
- ⚠️ Slow

### Workflow 2: Automated Promotion

**WHAT:** Automatically promote after tests pass

**Process:**

```
1. Commit to dev
2. Auto-deploy to dev
3. Run automated tests
4. If tests pass → auto-promote to staging
5. Run staging tests
6. If tests pass → auto-promote to production
```

**Implementation with GitHub Actions:**

```yaml
# .github/workflows/promote.yml
name: Promote to Staging

on:
  push:
    branches:
      - main
    paths:
      - 'apps/**/overlays/dev/**'

jobs:
  test-and-promote:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          # Run your tests here
          ./run-tests.sh dev
      
      - name: Promote to staging
        if: success()
        run: |
          # Copy dev changes to staging
          rsync -av apps/frontend/overlays/dev/ apps/frontend/overlays/staging/
          
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add apps/frontend/overlays/staging/
          git commit -m "Auto-promote to staging"
          git push
```

**Pros:**

- ✅ Fast
- ✅ Consistent
- ✅ Reduces human error

**Cons:**

- ⚠️ Need good tests
- ⚠️ Can auto-deploy bugs
- ⚠️ Complex setup

### Workflow 3: Pull Request Based

**WHAT:** Use PRs for promotion

**Process:**

```
1. Develop in feature branch
2. PR to dev branch → auto-deploy to dev
3. Test in dev
4. PR from dev to staging → auto-deploy to staging
5. Test in staging
6. PR from staging to main → auto-deploy to production
```

**Implementation:**

```bash
# Step 1: Create feature branch
git checkout -b feature/new-feature

# Make changes
vim apps/frontend/overlays/dev/deployment.yaml
git commit -m "Add new feature"
git push origin feature/new-feature

# Step 2: Create PR to dev branch
# On GitHub: Create PR feature/new-feature → dev
# ArgoCD watches dev branch, auto-deploys

# Step 3: After testing, promote to staging
git checkout staging
git merge dev
git push origin staging
# ArgoCD watches staging branch, auto-deploys

# Step 4: After testing, promote to production
git checkout main
git merge staging
git push origin main
# ArgoCD watches main branch, auto-deploys
```

**Pros:**

- ✅ Code review process
- ✅ Clear approval trail
- ✅ Git-native workflow

**Cons:**

- ⚠️ More Git complexity
- ⚠️ Merge conflicts
- ⚠️ Slower than automated

---

## 🌿 Branch-Based Environments

### Setup Branch-Based Strategy

**Step 1: Create Branches**

```bash
# Create staging branch
git checkout -b staging
git push origin staging

# Create production branch
git checkout -b production
git push origin production

# Back to main (dev)
git checkout main
```

**Step 2: Configure ArgoCD for Branches**

```yaml
# Dev environment (main branch)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-dev
spec:
  source:
    repoURL: https://github.com/YOUR-USERNAME/my-first-gitops-app
    targetRevision: main  # ← Dev branch
    path: apps/frontend/base
  destination:
    namespace: dev

---
# Staging environment (staging branch)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-staging
spec:
  source:
    repoURL: https://github.com/YOUR-USERNAME/my-first-gitops-app
    targetRevision: staging  # ← Staging branch
    path: apps/frontend/base
  destination:
    namespace: staging

---
# Production environment (production branch)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-prod
spec:
  source:
    repoURL: https://github.com/YOUR-USERNAME/my-first-gitops-app
    targetRevision: production  # ← Production branch
    path: apps/frontend/base
  destination:
    namespace: production
```

**Step 3: Promotion Process**

```bash
# Develop on main
git checkout main
# ... make changes ...
git commit -m "New feature"
git push origin main
# Auto-deploys to dev

# Promote to staging
git checkout staging
git merge main
git push origin staging
# Auto-deploys to staging

# Promote to production
git checkout production
git merge staging
git push origin production
# Auto-deploys to production
```

---

## 🎨 Kustomize Patterns

### Pattern 1: Strategic Merge Patch

**WHAT:** Merge changes into base configuration

**Example:**

```yaml
# Base deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: frontend
        image: nginx:1.25

---
# Overlay patch (strategic merge)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3  # ← Overrides base
  template:
    spec:
      containers:
      - name: frontend
        resources:  # ← Adds to base
          requests:
            memory: "256Mi"
```

**Result:** Replicas changed to 3, resources added, everything else from base.

### Pattern 2: JSON Patch

**WHAT:** Precise modifications using JSON Patch (RFC 6902)

**Example:**

```yaml
# kustomization.yaml
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 5
    - op: add
      path: /spec/template/spec/containers/0/env
      value:
      - name: ENVIRONMENT
        value: production
  target:
    kind: Deployment
    name: frontend
```

**Operations:**

- `add`: Add new field
- `remove`: Delete field
- `replace`: Change value
- `move`: Move field
- `copy`: Copy field
- `test`: Test value (validation)

### Pattern 3: ConfigMap Generator

**WHAT:** Generate ConfigMaps from files or literals

**Example:**

```yaml
# kustomization.yaml
configMapGenerator:
- name: app-config
  literals:
  - ENVIRONMENT=production
  - LOG_LEVEL=info
  - API_URL=https://api.example.com
  files:
  - config.json
  - settings.yaml
```

**Result:** ConfigMap created with hash suffix for versioning.

### Pattern 4: Secret Generator

**WHAT:** Generate Secrets (use with caution!)

**Example:**

```yaml
# kustomization.yaml
secretGenerator:
- name: db-credentials
  literals:
  - username=admin
  - password=changeme  # ← Don't commit real passwords!
  files:
  - tls.crt
  - tls.key
```

**⚠️ WARNING:** Never commit real secrets to Git! Use sealed secrets or external secret management.

---

## 🔐 Environment-Specific Secrets

### Problem: Secrets in Git

```
❌ DON'T DO THIS:
apiVersion: v1
kind: Secret
metadata:
  name: db-password
data:
  password: cGFzc3dvcmQxMjM=  # ← Base64 is NOT encryption!

Anyone can decode: echo "cGFzc3dvcmQxMjM=" | base64 -d
Output: password123
```

### Solution 1: Sealed Secrets

**WHAT:** Encrypt secrets that can only be decrypted in cluster

**Setup:**

```bash
# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Install kubeseal CLI
brew install kubeseal  # macOS
# or download from GitHub releases

# Create regular secret
kubectl create secret generic db-password \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml > secret.yaml

# Seal it
kubeseal -f secret.yaml -w sealed-secret.yaml

# sealed-secret.yaml is safe to commit!
cat sealed-secret.yaml
```

**Result:**

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: db-password
spec:
  encryptedData:
    password: AgBx7V8... # ← Encrypted, safe to commit!
```

**Commit to Git:**

```bash
git add sealed-secret.yaml
git commit -m "Add sealed secret"
git push

# ArgoCD deploys sealed secret
# Controller decrypts it in cluster
# App uses regular secret
```

### Solution 2: External Secrets Operator

**WHAT:** Sync secrets from external vault (AWS Secrets Manager, HashiCorp Vault, etc.)

**Setup:**

```bash
# Install External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace
```

**Usage:**

```yaml
# ExternalSecret resource
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-password
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: db-password
  data:
  - secretKey: password
    remoteRef:
      key: prod/db/password
```

**Benefits:**

- ✅ Secrets never in Git
- ✅ Centralized secret management
- ✅ Automatic rotation
- ✅ Audit trail

### Solution 3: Environment Variables (Not Recommended)

**WHAT:** Pass secrets as environment variables to ArgoCD

**Setup:**

```yaml
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-prod
spec:
  source:
    helm:
      parameters:
      - name: database.password
        value: $DB_PASSWORD  # ← From environment
```

**Cons:**

- ⚠️ Not GitOps (not in Git)
- ⚠️ Hard to manage
- ⚠️ No audit trail

---

## 🧪 Testing Strategies

### Strategy 1: Smoke Tests

**WHAT:** Quick tests after deployment

**Example:**

```bash
#!/bin/bash
# smoke-test.sh

NAMESPACE=$1
APP=$2

echo "Running smoke tests for $APP in $NAMESPACE..."

# Check pods are running
PODS=$(kubectl get pods -n $NAMESPACE -l app=$APP -o jsonpath='{.items[*].status.phase}')
if [[ "$PODS" != *"Running"* ]]; then
  echo "❌ Pods not running"
  exit 1
fi

# Check service exists
kubectl get svc -n $NAMESPACE $APP > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Service not found"
  exit 1
fi

# Check endpoint responds
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- \
  curl -f http://$APP.$NAMESPACE.svc.cluster.local
if [ $? -ne 0 ]; then
  echo "❌ Endpoint not responding"
  exit 1
fi

echo "✅ Smoke tests passed"
```

**Usage:**

```bash
# After deployment
./smoke-test.sh dev frontend
./smoke-test.sh staging frontend
./smoke-test.sh production frontend
```

### Strategy 2: Integration Tests

**WHAT:** Test interactions between services

**Example:**

```bash
#!/bin/bash
# integration-test.sh

NAMESPACE=$1

echo "Running integration tests in $NAMESPACE..."

# Test frontend → backend
RESPONSE=$(kubectl run -it --rm test --image=curlimages/curl --restart=Never -- \
  curl -s http://frontend.$NAMESPACE.svc.cluster.local/api)

if [[ "$RESPONSE" != *"Backend API"* ]]; then
  echo "❌ Frontend-Backend integration failed"
  exit 1
fi

# Test backend → database
kubectl exec -n $NAMESPACE deployment/backend -- \
  psql -h postgres.$NAMESPACE.svc.cluster.local -U admin -d myapp -c "SELECT 1"

if [ $? -ne 0 ]; then
  echo "❌ Backend-Database integration failed"
  exit 1
fi

echo "✅ Integration tests passed"
```

### Strategy 3: Automated Testing Pipeline

**WHAT:** Run tests automatically on deployment

**GitHub Actions Example:**

```yaml
# .github/workflows/test-deployment.yml
name: Test Deployment

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
      
      - name: Wait for deployment
        run: |
          kubectl wait --for=condition=available --timeout=300s \
            deployment/dev-frontend -n dev
      
      - name: Run smoke tests
        run: ./smoke-test.sh dev frontend
      
      - name: Run integration tests
        run: ./integration-test.sh dev
      
      - name: Notify on failure
        if: failure()
        run: |
          # Send Slack notification
          curl -X POST $SLACK_WEBHOOK \
            -d '{"text":"Deployment tests failed!"}'
```

---

## 📋 Best Practices

### 1. Environment Parity

**WHAT:** Keep environments as similar as possible

**Why:** Catch issues before production

**How:**

```yaml
# Use same base configuration
apps/frontend/base/  ← Shared by all

# Only differ in:
- Replica count
- Resource limits
- Domain names
- External integrations
```

### 2. Progressive Rollout

**WHAT:** Deploy to environments sequentially

**Process:**

```
Dev → Staging → Production

Each stage:
1. Deploy
2. Test
3. Monitor
4. Approve
5. Next stage
```

### 3. Rollback Strategy

**WHAT:** Always have a rollback plan

**Methods:**

```bash
# Method 1: Git revert
git revert HEAD
git push

# Method 2: ArgoCD rollback
argocd app rollback frontend-prod

# Method 3: Previous Git commit
argocd app sync frontend-prod --revision <previous-commit>
```

### 4. Monitoring Per Environment

**WHAT:** Monitor each environment separately

**Setup:**

```yaml
# Prometheus labels
environment: dev
environment: staging
environment: production

# Grafana dashboards
- Dev Dashboard
- Staging Dashboard
- Production Dashboard

# Alerts
- Dev: Low priority
- Staging: Medium priority
- Production: High priority
```

### 5. Documentation

**WHAT:** Document environment differences

**Example:**

```markdown
# Environment Differences

## Development
- Purpose: Feature development
- Replicas: 1
- Resources: Minimal
- Data: Fake/test data
- Uptime: Best effort
- Access: All developers

## Staging
- Purpose: Pre-production testing
- Replicas: 2
- Resources: Moderate
- Data: Anonymized production data
- Uptime: 95%
- Access: QA team + developers

## Production
- Purpose: Live users
- Replicas: 3+
- Resources: Full
- Data: Real user data
- Uptime: 99.9%
- Access: Ops team only
```

---

## 🎯 Summary

### Key Concepts

1. **Multiple Environments**: Dev, Staging, Production
2. **Kustomize Overlays**: Share base, customize per environment
3. **Promotion Workflows**: Manual, automated, or PR-based
4. **Secret Management**: Never commit secrets to Git
5. **Testing**: Smoke tests, integration tests, automated pipelines

### What You Learned

- ✅ How to structure multi-environment applications
- ✅ Different promotion strategies
- ✅ Kustomize patterns for environment management
- ✅ Secret management best practices
- ✅ Testing strategies for each environment

---

## 🚀 Next Steps

**Next Guide:** [`06-BEST-PRACTICES.md`](06-BEST-PRACTICES.md)

Learn:

- Production-ready patterns
- Security best practices
- Monitoring and alerting
- Disaster recovery

---

**Remember:** Environments should be similar enough to catch issues, but different enough to match their purpose! 🌍
