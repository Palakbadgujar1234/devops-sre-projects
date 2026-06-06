# 🚀 Deployment & Branching Strategies

## 📖 Overview

This guide explains the **deployment strategies** and **branching strategies** used in this project, with detailed comparisons and real-world examples.

---

## 🎯 Part 1: Deployment Strategies

### What is a Deployment Strategy?

**WHAT:** A deployment strategy defines how you release new versions of your application to production.

**WHY:** Different strategies offer different trade-offs between:

- Risk (how much can go wrong)
- Speed (how fast you can deploy)
- Cost (resources needed)
- Complexity (how hard to implement)

---

## 🔄 Deployment Strategy Used in This Project

### Rolling Deployment (Our Choice)

**WHAT:** Gradually replace old pods with new pods, one at a time or in small batches.

**WHY WE CHOSE IT:**

1. ✅ Zero downtime
2. ✅ Low risk (gradual rollout)
3. ✅ Easy rollback
4. ✅ Built into Kubernetes
5. ✅ No extra infrastructure needed
6. ✅ Cost-effective

**HOW IT WORKS:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2        # Max 2 extra pods during update
      maxUnavailable: 1  # Max 1 pod can be unavailable
  template:
    spec:
      containers:
      - name: backend
        image: backend:v2.0
```

**Step-by-Step Process:**

```
Initial State (v1.0):
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │
└─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
  6 pods running v1.0

Step 1: Create 2 new pods (maxSurge: 2)
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v2  │ │ v2  │
└─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
  6 old + 2 new = 8 pods total

Step 2: Wait for new pods to be ready
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v2✓ │ │ v2✓ │
└─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
  New pods pass health checks

Step 3: Terminate 1 old pod (maxUnavailable: 1)
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v2✓ │ │ v2✓ │
└─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
  5 old + 2 new = 7 pods

Step 4: Create 1 more new pod
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v1  │ │ v2✓ │ │ v2✓ │ │ v2  │
└─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
  5 old + 3 new = 8 pods

Step 5: Repeat until all pods are v2.0
Final State (v2.0):
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│ v2✓ │ │ v2✓ │ │ v2✓ │ │ v2✓ │ │ v2✓ │ │ v2✓ │
└─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘
  6 pods running v2.0
```

**Configuration Explained:**

```yaml
maxSurge: 2
# WHAT: Maximum number of extra pods during update
# WHY: Allows faster rollout while maintaining capacity
# EXAMPLE: With 6 replicas, can have up to 8 pods (6 + 2)

maxUnavailable: 1
# WHAT: Maximum number of pods that can be unavailable
# WHY: Ensures minimum capacity during update
# EXAMPLE: With 6 replicas, always have at least 5 pods running
```

**Health Checks (Critical for Rolling Updates):**

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3

# EXPLANATION:
# initialDelaySeconds: 10  - Wait 10s before first check
# periodSeconds: 10        - Check every 10s
# failureThreshold: 3      - Mark unhealthy after 3 failures
# WHY: Ensures new pods are healthy before terminating old ones

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3

# EXPLANATION:
# Checks if pod is ready to receive traffic
# WHY: New pods only get traffic when ready
# Prevents sending requests to pods that aren't ready
```

**Rollback Process:**

```bash
# View rollout history
kubectl rollout history deployment/backend

# Output:
# REVISION  CHANGE-CAUSE
# 1         Initial deployment
# 2         Update to v2.0
# 3         Update to v3.0

# Rollback to previous version
kubectl rollout undo deployment/backend

# EXPLANATION:
# Immediately starts rolling back to previous version
# Uses same rolling update process
# Zero downtime during rollback

# Rollback to specific revision
kubectl rollout undo deployment/backend --to-revision=1

# Check rollout status
kubectl rollout status deployment/backend

# Output:
# Waiting for deployment "backend" rollout to finish: 2 out of 6 new replicas have been updated...
# deployment "backend" successfully rolled out
```

---

## 📊 Comparison with Other Deployment Strategies

### 1. Recreate Strategy

**WHAT:** Stop all old pods, then start all new pods.

**Configuration:**

```yaml
strategy:
  type: Recreate
```

**Process:**

```
Step 1: Terminate all old pods
┌─────┐ ┌─────┐ ┌─────┐
│ v1 X│ │ v1 X│ │ v1 X│
└─────┘ └─────┘ └─────┘
  All pods terminated

Step 2: Downtime (no pods running)
[DOWNTIME - Application unavailable]

Step 3: Create all new pods
┌─────┐ ┌─────┐ ┌─────┐
│ v2  │ │ v2  │ │ v2  │
└─────┘ └─────┘ └─────┘
  New pods starting
```

**Pros:**

- ✅ Simple to implement
- ✅ No version mixing
- ✅ No extra resources needed

**Cons:**

- ❌ Downtime during deployment
- ❌ High risk (all or nothing)
- ❌ Slow rollback (need to redeploy)

**When to Use:**

- Development environments
- Maintenance windows acceptable
- Stateful applications that can't run multiple versions

**Why We Didn't Choose It:**

- ❌ Causes downtime (unacceptable for production)
- ❌ Poor user experience
- ❌ Not suitable for 24/7 services

---

### 2. Blue-Green Deployment

**WHAT:** Run two identical environments (Blue and Green). Switch traffic between them.

**Configuration:**

```yaml
# Blue environment (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-blue
spec:
  replicas: 6
  template:
    metadata:
      labels:
        app: backend
        version: blue
    spec:
      containers:
      - name: backend
        image: backend:v1.0

---
# Green environment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-green
spec:
  replicas: 6
  template:
    metadata:
      labels:
        app: backend
        version: green
    spec:
      containers:
      - name: backend
        image: backend:v2.0

---
# Service (switch between blue and green)
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
    version: blue  # Change to 'green' to switch
  ports:
  - port: 80
    targetPort: 3000
```

**Process:**

```
Step 1: Blue is production
┌──────────────────┐
│  Blue (v1.0)     │ ← Production traffic
│  6 pods          │
└──────────────────┘
┌──────────────────┐
│  Green (idle)    │
│  0 pods          │
└──────────────────┘

Step 2: Deploy to Green
┌──────────────────┐
│  Blue (v1.0)     │ ← Production traffic
│  6 pods          │
└──────────────────┘
┌──────────────────┐
│  Green (v2.0)    │ ← Testing
│  6 pods          │
└──────────────────┘

Step 3: Test Green
- Run smoke tests
- Verify functionality
- Check performance

Step 4: Switch traffic to Green
┌──────────────────┐
│  Blue (v1.0)     │ ← Standby
│  6 pods          │
└──────────────────┘
┌──────────────────┐
│  Green (v2.0)    │ ← Production traffic
│  6 pods          │
└──────────────────┘

Step 5: Keep Blue for rollback
- Monitor Green for issues
- If problems, switch back to Blue
- If stable, decommission Blue
```

**Pros:**

- ✅ Zero downtime
- ✅ Instant rollback (just switch back)
- ✅ Full testing before production
- ✅ Easy to understand

**Cons:**

- ❌ Requires 2x resources (expensive)
- ❌ Database migrations complex
- ❌ More infrastructure to manage
- ❌ Need to handle stateful data

**When to Use:**

- Critical applications
- Need instant rollback
- Can afford 2x resources
- Infrequent deployments

**Why We Didn't Choose It:**

- ❌ Too expensive (2x resources)
- ❌ Overkill for our use case
- ❌ Rolling updates sufficient for our needs

---

### 3. Canary Deployment

**WHAT:** Gradually shift traffic from old version to new version.

**Configuration:**

```yaml
# Old version (90% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-stable
spec:
  replicas: 9
  template:
    metadata:
      labels:
        app: backend
        version: stable
    spec:
      containers:
      - name: backend
        image: backend:v1.0

---
# New version (10% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-canary
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: backend
        version: canary
    spec:
      containers:
      - name: backend
        image: backend:v2.0

---
# Service (distributes traffic)
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend  # Matches both stable and canary
  ports:
  - port: 80
    targetPort: 3000
```

**Process:**

```
Step 1: 100% stable version
┌─────────────────────────────────────┐
│  Stable (v1.0) - 100% traffic       │
│  10 pods                            │
└─────────────────────────────────────┘

Step 2: Deploy canary (10% traffic)
┌─────────────────────────────────────┐
│  Stable (v1.0) - 90% traffic        │
│  9 pods                             │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  Canary (v2.0) - 10% traffic        │
│  1 pod                              │
└─────────────────────────────────────┘

Step 3: Monitor canary
- Check error rates
- Monitor latency
- Analyze logs
- User feedback

Step 4: Increase canary (50% traffic)
┌─────────────────────────────────────┐
│  Stable (v1.0) - 50% traffic        │
│  5 pods                             │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  Canary (v2.0) - 50% traffic        │
│  5 pods                             │
└─────────────────────────────────────┘

Step 5: Full rollout (100% canary)
┌─────────────────────────────────────┐
│  Canary (v2.0) - 100% traffic       │
│  10 pods                            │
└─────────────────────────────────────┘
```

**Pros:**

- ✅ Very low risk (gradual rollout)
- ✅ Real user testing
- ✅ Easy to rollback
- ✅ Detect issues early

**Cons:**

- ❌ Complex to implement
- ❌ Requires traffic splitting
- ❌ Need advanced monitoring
- ❌ Longer deployment time

**When to Use:**

- High-risk changes
- Large user base
- Need real user feedback
- Can afford complexity

**Why We Didn't Choose It:**

- ❌ Too complex for initial project
- ❌ Requires service mesh (Istio)
- ❌ Rolling updates sufficient
- ✅ Can add later as enhancement

---

### 4. A/B Testing Deployment

**WHAT:** Run multiple versions simultaneously, route users based on criteria.

**Configuration:**

```yaml
# Version A (control)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-a
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: backend
        version: a
    spec:
      containers:
      - name: backend
        image: backend:v1.0

---
# Version B (experiment)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-b
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: backend
        version: b
    spec:
      containers:
      - name: backend
        image: backend:v2.0

---
# Ingress with routing rules
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "X-Version"
    nginx.ingress.kubernetes.io/canary-by-header-value: "b"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-a  # Default
            port:
              number: 80
```

**Routing Logic:**

```
User Request → Ingress Controller
                    ↓
        ┌───────────┴───────────┐
        │                       │
    Header: X-Version=b?    No header
        │                       │
        ↓                       ↓
   Version B              Version A
   (New feature)         (Current)
```

**Pros:**

- ✅ Test features with specific users
- ✅ Measure feature impact
- ✅ Data-driven decisions
- ✅ Both versions stable

**Cons:**

- ❌ Very complex
- ❌ Need analytics integration
- ❌ Requires feature flags
- ❌ Database schema challenges

**When to Use:**

- Testing new features
- Need user feedback
- Measuring business impact
- Product experiments

**Why We Didn't Choose It:**

- ❌ Not for deployment, for feature testing
- ❌ Different use case
- ❌ Requires extensive infrastructure

---

## 📊 Deployment Strategy Comparison Table

| Strategy | Downtime | Risk | Complexity | Cost | Rollback Speed | Best For |
|----------|----------|------|------------|------|----------------|----------|
| **Rolling** ✅ | None | Low | Low | Low | Fast | Most applications |
| Recreate | Yes | High | Very Low | Very Low | Slow | Dev environments |
| Blue-Green | None | Very Low | Medium | High | Instant | Critical apps |
| Canary | None | Very Low | High | Medium | Fast | High-risk changes |
| A/B Testing | None | Low | Very High | High | Fast | Feature testing |

**Our Choice: Rolling Deployment**

- ✅ Perfect balance of all factors
- ✅ Built into Kubernetes
- ✅ Zero downtime
- ✅ Low cost
- ✅ Easy to implement
- ✅ Fast rollback

---

## 🌿 Part 2: Branching Strategies

### What is a Branching Strategy?

**WHAT:** A branching strategy defines how your team organizes code in Git.

**WHY:** Enables:

- Parallel development
- Code review process
- Release management
- Hotfix handling
- Feature isolation

---

## 🔀 Branching Strategy Used in This Project

### GitFlow (Our Choice)

**WHAT:** A branching model with specific branch types for different purposes.

**WHY WE CHOSE IT:**

1. ✅ Clear separation of concerns
2. ✅ Supports multiple environments
3. ✅ Easy hotfix process
4. ✅ Parallel feature development
5. ✅ Industry standard
6. ✅ Well-documented

**Branch Structure:**

```
main (production)
  ↑
  │ merge
  │
develop (integration)
  ↑
  │ merge
  │
feature/* (new features)
release/* (release preparation)
hotfix/* (production fixes)
```

**Detailed Branch Explanation:**

### 1. Main Branch

```bash
# WHAT: Production-ready code
# WHY: Always deployable, stable
# WHO: Only release and hotfix branches merge here

# Protected branch rules:
- Require pull request reviews
- Require status checks to pass
- Require branches to be up to date
- No direct commits allowed
```

**Characteristics:**

- Always stable
- Tagged with version numbers
- Deployed to production
- Never commit directly

### 2. Develop Branch

```bash
# WHAT: Integration branch for features
# WHY: Latest development changes
# WHO: Feature branches merge here

# Protected branch rules:
- Require pull request reviews
- Require CI/CD to pass
- No direct commits (except small fixes)
```

**Characteristics:**

- Latest features
- May be unstable
- Deployed to dev environment
- Base for feature branches

### 3. Feature Branches

```bash
# WHAT: Individual feature development
# WHY: Isolate feature work
# WHO: Developers create from develop

# Naming convention:
feature/user-authentication
feature/payment-integration
feature/dashboard-redesign

# Lifecycle:
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication

# ... work on feature ...

git add .
git commit -m "Add user authentication"
git push origin feature/user-authentication

# Create pull request to develop
# After review and approval, merge to develop
# Delete feature branch
```

**Characteristics:**

- Short-lived (days to weeks)
- One feature per branch
- Merged via pull request
- Deleted after merge

### 4. Release Branches

```bash
# WHAT: Prepare for production release
# WHY: Final testing and bug fixes
# WHO: Created from develop when ready

# Naming convention:
release/v1.0.0
release/v2.0.0

# Lifecycle:
git checkout develop
git checkout -b release/v1.0.0

# ... final testing, bug fixes ...
# ... update version numbers ...
# ... update changelog ...

# Merge to main
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"

# Merge back to develop
git checkout develop
git merge release/v1.0.0

# Delete release branch
git branch -d release/v1.0.0
```

**Characteristics:**

- Short-lived (days)
- Only bug fixes allowed
- No new features
- Merged to both main and develop

### 5. Hotfix Branches

```bash
# WHAT: Emergency production fixes
# WHY: Fix critical bugs in production
# WHO: Created from main

# Naming convention:
hotfix/critical-security-fix
hotfix/payment-bug

# Lifecycle:
git checkout main
git checkout -b hotfix/critical-security-fix

# ... fix the bug ...

git add .
git commit -m "Fix critical security vulnerability"

# Merge to main
git checkout main
git merge hotfix/critical-security-fix
git tag -a v1.0.1 -m "Hotfix: Security vulnerability"

# Merge to develop
git checkout develop
git merge hotfix/critical-security-fix

# Delete hotfix branch
git branch -d hotfix/critical-security-fix
```

**Characteristics:**

- Very short-lived (hours)
- Critical fixes only
- Merged to both main and develop
- Creates new version tag

---

## 📊 Complete GitFlow Workflow

```
Time →

main:      v1.0.0 ────────────────────────── v1.1.0 ─── v1.1.1
             │                                  │         │
             │                                  │         │
develop:     │ ─── feature1 ─── feature2 ──────┤         │
             │        │            │            │         │
             │        │            │            │         │
feature/A:   │        └────────────┘            │         │
             │                                  │         │
release:     │                      └─────────┐ │         │
             │                                │ │         │
hotfix:      │                                │ │    └────┘
             │                                │ │
             └────────────────────────────────┴─┴──────────→
```

**Step-by-Step Example:**

```bash
# 1. Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/user-profile

# 2. Work on feature
# ... make changes ...
git add .
git commit -m "Add user profile page"
git push origin feature/user-profile

# 3. Create pull request
# - Review code
# - Run CI/CD tests
# - Get approval

# 4. Merge to develop
git checkout develop
git merge feature/user-profile
git push origin develop
git branch -d feature/user-profile

# 5. Prepare release
git checkout develop
git checkout -b release/v1.1.0

# 6. Final testing and fixes
# ... test in staging ...
# ... fix bugs ...
git commit -m "Fix bug in user profile"

# 7. Merge to main
git checkout main
git merge release/v1.1.0
git tag -a v1.1.0 -m "Release 1.1.0"
git push origin main --tags

# 8. Merge back to develop
git checkout develop
git merge release/v1.1.0
git push origin develop

# 9. Delete release branch
git branch -d release/v1.1.0

# 10. Deploy to production
# CI/CD automatically deploys main branch
```

---

## 🔄 Comparison with Other Branching Strategies

### 1. GitHub Flow

**WHAT:** Simplified flow with only main and feature branches.

**Structure:**

```
main (production)
  ↑
  │ merge via PR
  │
feature/* (all work)
```

**Workflow:**

```bash
# 1. Create feature branch from main
git checkout main
git checkout -b feature/new-feature

# 2. Work and commit
git commit -m "Add feature"

# 3. Push and create PR
git push origin feature/new-feature

# 4. Review, test, merge to main
# 5. Deploy main to production
```

**Pros:**

- ✅ Very simple
- ✅ Fast deployment
- ✅ Good for continuous deployment
- ✅ Less overhead

**Cons:**

- ❌ No release preparation
- ❌ Hard to maintain multiple versions
- ❌ No hotfix process
- ❌ Main must always be deployable

**When to Use:**

- Small teams
- Continuous deployment
- Single production version
- Simple projects

**Why We Didn't Choose It:**

- ❌ Need release preparation
- ❌ Need hotfix process
- ❌ Need staging environment

---

### 2. Trunk-Based Development

**WHAT:** Everyone commits to main (trunk), use feature flags for incomplete features.

**Structure:**

```
main (trunk)
  ↑
  │ direct commits or very short-lived branches
  │
short-lived branches (< 1 day)
```

**Workflow:**

```bash
# 1. Create very short branch (optional)
git checkout -b feature-x

# 2. Work for few hours
git commit -m "Add feature (behind flag)"

# 3. Merge same day
git checkout main
git merge feature-x

# 4. Feature hidden behind flag
if (featureFlags.newFeature) {
  // new code
} else {
  // old code
}
```

**Pros:**

- ✅ Very fast integration
- ✅ Reduces merge conflicts
- ✅ Encourages small changes
- ✅ Good for CI/CD

**Cons:**

- ❌ Requires feature flags
- ❌ Need strong testing
- ❌ Main can be unstable
- ❌ Complex flag management

**When to Use:**

- Mature teams
- Strong CI/CD
- Feature flag system
- High deployment frequency

**Why We Didn't Choose It:**

- ❌ Too advanced for learning
- ❌ Requires feature flag infrastructure
- ❌ Higher risk

---

### 3. GitLab Flow

**WHAT:** Environment-based branches (main, staging, production).

**Structure:**

```
main (development)
  ↓ merge
staging (staging environment)
  ↓ merge
production (production environment)
```

**Workflow:**

```bash
# 1. Work on main
git checkout main
git commit -m "Add feature"

# 2. Merge to staging
git checkout staging
git merge main
# Deploy to staging environment

# 3. Test in staging
# ... run tests ...

# 4. Merge to production
git checkout production
git merge staging
# Deploy to production
```

**Pros:**

- ✅ Clear environment mapping
- ✅ Simple to understand
- ✅ Good for multiple environments
- ✅ Easy deployment

**Cons:**

- ❌ Can have merge conflicts
- ❌ No release preparation
- ❌ Hotfixes complex

**When to Use:**

- Multiple environments
- Simple deployment process
- Small to medium teams

**Why We Didn't Choose It:**

- ❌ Less flexible than GitFlow
- ❌ No release branch concept
- ❌ GitFlow more industry standard

---

## 📊 Branching Strategy Comparison Table

| Strategy | Complexity | Flexibility | Release Control | Hotfix Support | Best For |
|----------|------------|-------------|-----------------|----------------|----------|
| **GitFlow** ✅ | High | High | Excellent | Excellent | Enterprise apps |
| GitHub Flow | Low | Low | Poor | Poor | Continuous deployment |
| Trunk-Based | Medium | Medium | Good | Good | Mature teams |
| GitLab Flow | Medium | Medium | Good | Medium | Multiple environments |

**Our Choice: GitFlow**

- ✅ Best for learning all concepts
- ✅ Industry standard
- ✅ Supports all scenarios
- ✅ Clear process for everything
- ✅ Good for interviews

---

## 🎯 Integration: Deployment + Branching

### How They Work Together

```
Git Branch          →  Environment  →  Deployment Strategy
─────────────────────────────────────────────────────────
feature/*           →  Dev          →  Recreate (fast)
develop             →  Dev          →  Rolling Update
release/*           →  Staging      →  Rolling Update
main                →  Production   →  Rolling Update
hotfix/*            →  Production   →  Rolling Update (fast)
```

**CI/CD Pipeline Integration:**

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches:
      - develop      # Deploy to dev
      - main         # Deploy to production
  pull_request:
    branches:
      - develop      # Test feature branches

jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Dev
        run: |
          kubectl set image deployment/backend \
            backend=backend:${{ github.sha }} \
            --namespace=dev
          # Uses Rolling Update strategy

  deploy-staging:
    if: startsWith(github.ref, 'refs/heads/release/')
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Staging
        run: |
          kubectl set image deployment/backend \
            backend=backend:${{ github.sha }} \
            --namespace=staging
          # Uses Rolling Update strategy

  deploy-production:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: |
          kubectl set image deployment/backend \
            backend=backend:${{ github.sha }} \
            --namespace=production
          # Uses Rolling Update strategy
          # With stricter health checks
```

---

## 💡 Best Practices

### Deployment Best Practices

1. **Always Use Health Checks**

   ```yaml
   livenessProbe:
     httpGet:
       path: /health
   readinessProbe:
     httpGet:
       path: /ready
   ```

2. **Implement Graceful Shutdown**

   ```javascript
   process.on('SIGTERM', () => {
     server.close(() => {
       db.close();
       process.exit(0);
     });
   });
   ```

3. **Use Pod Disruption Budgets**

   ```yaml
   apiVersion: policy/v1
   kind: PodDisruptionBudget
   spec:
     minAvailable: 2
   ```

4. **Monitor Deployments**
   - Watch error rates
   - Monitor latency
   - Check resource usage
   - Set up alerts

### Branching Best Practices

1. **Keep Branches Short-Lived**
   - Feature branches: < 2 weeks
   - Release branches: < 1 week
   - Hotfix branches: < 1 day

2. **Use Descriptive Names**

   ```bash
   # Good
   feature/user-authentication
   hotfix/payment-bug
   
   # Bad
   feature/fix
   test-branch
   ```

3. **Write Good Commit Messages**

   ```bash
   # Good
   git commit -m "Add user authentication with JWT"
   
   # Bad
   git commit -m "fix"
   ```

4. **Always Use Pull Requests**
   - Code review required
   - CI/CD must pass
   - At least one approval

---

## 🎓 Interview Tips

### How to Explain Your Strategy

**Question:** "What deployment strategy did you use and why?"

**Answer:**

```
"I used Rolling Deployment strategy because:

1. Zero Downtime: Gradually replaces pods, always maintaining capacity
2. Low Risk: Issues detected early, easy to rollback
3. Cost-Effective: No extra infrastructure needed
4. Built-in: Native Kubernetes feature, no additional tools

Configuration:
- maxSurge: 2 (allows faster rollout)
- maxUnavailable: 1 (maintains capacity)
- Health checks ensure new pods are ready
- Automatic rollback on failure

I considered Blue-Green but it requires 2x resources, which wasn't 
cost-effective for our use case. Canary deployment was too complex 
for initial implementation but could be added later.

For branching, I used GitFlow because it provides clear separation 
between development, staging, and production, supports hotfixes, 
and is industry standard."
```

---

## 🚀 Summary

### Deployment Strategy: Rolling Update

- ✅ Zero downtime
- ✅ Low risk
- ✅ Easy rollback
- ✅ Cost-effective
- ✅ Built into Kubernetes

### Branching Strategy: GitFlow

- ✅ Clear process
- ✅ Supports all scenarios
- ✅ Industry standard
- ✅ Good for teams
- ✅ Excellent for learning

### Together They Provide

- Complete development workflow
- Safe deployment process
- Easy collaboration
- Production-ready practices
- Interview-ready knowledge

---

**You're now ready to explain both strategies confidently in interviews! 🎉**
