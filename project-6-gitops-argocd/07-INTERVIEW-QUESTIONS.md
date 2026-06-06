# 🎯 GitOps & ArgoCD Interview Questions

## 📖 Table of Contents

1. [Fundamental Concepts](#fundamental-concepts)
2. [ArgoCD Specific](#argocd-specific)
3. [Scenario-Based Questions](#scenario-based-questions)
4. [Troubleshooting Questions](#troubleshooting-questions)
5. [Best Practices Questions](#best-practices-questions)
6. [Advanced Topics](#advanced-topics)

---

## 🎓 Fundamental Concepts

### Q1: What is GitOps?

**Answer:**
GitOps is an operational framework that uses Git as the single source of truth for declarative infrastructure and applications. The key principles are:

1. **Declarative**: System state described declaratively
2. **Versioned**: All changes tracked in Git
3. **Immutable**: Git commits are immutable
4. **Pulled**: Changes pulled from Git, not pushed
5. **Continuously Reconciled**: System continuously matches Git state

**Example:**

```
Traditional: kubectl apply -f deployment.yaml
GitOps: git commit → ArgoCD syncs → Kubernetes updated
```

---

### Q2: What are the benefits of GitOps over traditional CD?

**Answer:**

**GitOps Benefits:**

1. **Single Source of Truth**: Git contains everything
2. **Audit Trail**: Every change tracked in Git history
3. **Easy Rollback**: `git revert` to rollback
4. **Declarative**: Describe desired state, not steps
5. **Self-Healing**: Automatic drift correction
6. **Security**: No cluster credentials in CI/CD
7. **Collaboration**: Pull requests for changes

**Traditional CD Issues:**

- Manual kubectl commands
- No audit trail
- Hard to rollback
- Configuration drift
- Credentials everywhere

---

### Q3: Explain the difference between push-based and pull-based deployment

**Answer:**

**Push-Based (Traditional CI/CD):**

```
CI/CD Pipeline → kubectl apply → Kubernetes

Problems:
- CI/CD needs cluster credentials
- No continuous reconciliation
- Configuration drift possible
- Security risk
```

**Pull-Based (GitOps):**

```
Git Repository ← ArgoCD (in cluster) → Kubernetes

Benefits:
- No external cluster access needed
- Continuous reconciliation
- Drift prevention
- More secure
```

**Real-World Example:**

```
Push: Jenkins pushes to production
Pull: ArgoCD pulls from Git and applies
```

---

### Q4: What is declarative configuration?

**Answer:**

**Declarative (What you want):**

```yaml
spec:
  replicas: 3
  image: nginx:1.25
```

"I want 3 replicas of nginx:1.25"

**Imperative (How to do it):**

```bash
kubectl create deployment nginx --image=nginx:1.24
kubectl scale deployment nginx --replicas=2
kubectl set image deployment/nginx nginx=nginx:1.25
kubectl scale deployment nginx --replicas=3
```

"Do these steps in order"

**Why Declarative is Better:**

- Idempotent (safe to apply multiple times)
- Self-healing (system maintains desired state)
- Clear (easy to understand what you want)
- Predictable (same result every time)

---

## 🔧 ArgoCD Specific

### Q5: What is ArgoCD and how does it work?

**Answer:**

**What:** Kubernetes-native GitOps continuous delivery tool

**Architecture:**

```
┌─────────────────────────────────────┐
│ ArgoCD Components                   │
├─────────────────────────────────────┤
│ 1. API Server                       │
│    - Web UI                         │
│    - CLI interface                  │
│    - Webhook receiver               │
│                                     │
│ 2. Repository Server                │
│    - Clones Git repos               │
│    - Generates manifests            │
│    - Caches repo data               │
│                                     │
│ 3. Application Controller           │
│    - Monitors applications          │
│    - Compares Git vs Cluster        │
│    - Syncs differences              │
│    - Detects drift                  │
│                                     │
│ 4. Redis                            │
│    - Caching                        │
│    - Session storage                │
│                                     │
│ 5. Dex (Optional)                   │
│    - SSO/OIDC                       │
│    - User authentication            │
└─────────────────────────────────────┘
```

**How It Works:**

1. Application Controller polls Git every 3 minutes
2. Compares Git state with cluster state
3. If different, marks as "OutOfSync"
4. If auto-sync enabled, applies changes
5. Monitors health of deployed resources

---

### Q6: Explain ArgoCD Application, Project, and Repository

**Answer:**

**Application:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo
    path: k8s/
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

- Represents a deployed application
- Links Git repo to Kubernetes cluster
- Defines sync policy

**Project:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-frontend
spec:
  sourceRepos:
  - 'https://github.com/org/frontend-*'
  destinations:
  - namespace: 'frontend-*'
    server: https://kubernetes.default.svc
```

- Logical grouping of applications
- Access control (RBAC)
- Restricts what can be deployed where

**Repository:**

- Git repository containing manifests
- Registered in ArgoCD
- Can be public or private
- Credentials stored as secrets

---

### Q7: What is the difference between sync and refresh in ArgoCD?

**Answer:**

**Refresh:**

```bash
argocd app get my-app --refresh
```

- Fetches latest from Git
- Compares with cluster
- Updates sync status
- **Does NOT apply changes**
- Fast operation

**Sync:**

```bash
argocd app sync my-app
```

- Applies changes to cluster
- Makes cluster match Git
- **Actually deploys**
- Slower operation

**Auto-Refresh:**

- Happens every 3 minutes by default
- Can be configured

**Auto-Sync:**

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

- Automatically syncs when OutOfSync
- No manual intervention needed

---

### Q8: Explain ArgoCD sync waves and hooks

**Answer:**

**Sync Waves:**
Control order of resource deployment using annotations:

```yaml
# Deploy first (wave 0)
apiVersion: v1
kind: Namespace
metadata:
  name: my-app
  annotations:
    argocd.argoproj.io/sync-wave: "0"

---
# Deploy second (wave 1)
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  annotations:
    argocd.argoproj.io/sync-wave: "1"

---
# Deploy third (wave 2)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  annotations:
    argocd.argoproj.io/sync-wave: "2"
```

**Use Cases:**

- Create namespace before resources
- Create ConfigMap before Deployment
- Database before application

**Hooks:**
Run jobs at specific points in sync:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate-tool
        command: ["./migrate.sh"]
      restartPolicy: Never
```

**Hook Types:**

- `PreSync`: Before sync
- `Sync`: During sync
- `PostSync`: After sync
- `SyncFail`: On sync failure
- `Skip`: Skip resource

---

## 🎬 Scenario-Based Questions

### Q9: How would you implement blue-green deployment with GitOps?

**Answer:**

**Strategy:**

```
1. Deploy new version (green) alongside old (blue)
2. Test green version
3. Switch traffic to green
4. Keep blue for rollback
5. Remove blue after verification
```

**Implementation:**

```yaml
# Blue deployment (current)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  labels:
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0

---
# Green deployment (new)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  labels:
    version: green
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
      - name: app
        image: myapp:v2.0

---
# Service (switch by changing selector)
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue  # Change to 'green' to switch
  ports:
  - port: 80
```

**Process:**

```bash
# 1. Deploy green
git add app-green-deployment.yaml
git commit -m "Deploy green version"
git push

# 2. Test green
kubectl port-forward svc/app-green 8080:80
# ... testing ...

# 3. Switch traffic
# Edit service.yaml: version: blue → version: green
git commit -m "Switch to green"
git push

# 4. Monitor
# ... monitoring ...

# 5. Remove blue (or keep for rollback)
git rm app-blue-deployment.yaml
git commit -m "Remove blue version"
git push
```

---

### Q10: How do you handle secrets in GitOps?

**Answer:**

**Problem:** Can't commit secrets to Git

**Solutions:**

**1. Sealed Secrets (Recommended):**

```bash
# Create secret
kubectl create secret generic db-pass \
  --from-literal=password=secret123 \
  --dry-run=client -o yaml | \
  kubeseal -o yaml > sealed-secret.yaml

# Commit sealed secret
git add sealed-secret.yaml
git commit -m "Add sealed database password"
git push

# ArgoCD deploys sealed secret
# Controller decrypts it in cluster
# App uses regular secret
```

**2. External Secrets Operator:**

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-password
spec:
  secretStoreRef:
    name: aws-secrets-manager
  target:
    name: db-password
  data:
  - secretKey: password
    remoteRef:
      key: prod/db/password
```

**3. Helm Secrets:**

```bash
# Encrypt values
helm secrets enc values-prod.yaml

# Commit encrypted file
git add values-prod.yaml
git commit -m "Add encrypted values"
```

**4. SOPS (Mozilla):**

```bash
# Encrypt file
sops -e secret.yaml > secret.enc.yaml

# Commit encrypted file
git add secret.enc.yaml
```

**Best Practice:**

- Never commit plain secrets
- Use sealed secrets for simplicity
- Use external secrets for enterprise
- Rotate secrets regularly

---

### Q11: Application is OutOfSync but you want to keep manual changes. How?

**Answer:**

**Scenario:** HPA scaled deployment, but Git says 3 replicas

**Solution 1: Ignore Differences**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas  # Ignore replica count
```

**Solution 2: Update Git**

```bash
# Update Git to match reality
vim deployment.yaml
# Change replicas: 3 → replicas: 5
git commit -m "Update replicas to match HPA"
git push
```

**Solution 3: Disable Auto-Sync**

```yaml
syncPolicy:
  automated: null  # Disable auto-sync
```

**Solution 4: Use HPA Properly**

```yaml
# Remove replicas from deployment
# Let HPA manage it
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 3
  maxReplicas: 10
```

**Best Practice:** Use ignoreDifferences for HPA-managed fields

---

### Q12: How do you promote changes from dev to staging to production?

**Answer:**

**Strategy 1: Overlay-Based**

```bash
# 1. Test in dev
git checkout main
vim apps/myapp/overlays/dev/config.yaml
git commit -m "Update dev config"
git push
# ArgoCD syncs to dev

# 2. Promote to staging
cp apps/myapp/overlays/dev/config.yaml \
   apps/myapp/overlays/staging/config.yaml
git commit -m "Promote to staging"
git push
# ArgoCD syncs to staging

# 3. Promote to production
cp apps/myapp/overlays/staging/config.yaml \
   apps/myapp/overlays/prod/config.yaml
git commit -m "Promote to production"
git push
# ArgoCD syncs to production
```

**Strategy 2: Branch-Based**

```bash
# 1. Develop on main (dev)
git checkout main
# ... changes ...
git push
# ArgoCD syncs to dev

# 2. Promote to staging
git checkout staging
git merge main
git push
# ArgoCD syncs to staging

# 3. Promote to production
git checkout production
git merge staging
git push
# ArgoCD syncs to production
```

**Strategy 3: Tag-Based**

```bash
# 1. Deploy to dev
git tag dev-v1.2.3
git push --tags
# ArgoCD (targetRevision: dev-*) syncs

# 2. Promote to staging
git tag staging-v1.2.3
git push --tags
# ArgoCD (targetRevision: staging-*) syncs

# 3. Promote to production
git tag prod-v1.2.3
git push --tags
# ArgoCD (targetRevision: prod-*) syncs
```

---

## 🔍 Troubleshooting Questions

### Q13: Application shows "OutOfSync" but you don't see any differences. Why?

**Answer:**

**Common Causes:**

**1. Resource Hooks:**

```yaml
# Job with hook annotation
apiVersion: batch/v1
kind: Job
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
```

- Hooks don't count as "in sync"
- Solution: Check for hook annotations

**2. Ignored Resources:**

```yaml
# Resource with ignore annotation
metadata:
  annotations:
    argocd.argoproj.io/compare-options: IgnoreExtraneous
```

**3. Cluster-Generated Fields:**

```yaml
# Kubernetes adds these
status:
  conditions: [...]
metadata:
  managedFields: [...]
```

- ArgoCD ignores these by default
- Check `resource.customizations`

**4. Whitespace Differences:**

```yaml
# Git has:
replicas: 3

# Cluster has:
replicas:  3  # Extra space
```

- Normalize YAML formatting

**5. Order Differences:**

```yaml
# Git:
env:
- name: A
- name: B

# Cluster:
env:
- name: B
- name: A
```

- Order matters in some cases

**Debug:**

```bash
# See actual diff
argocd app diff my-app

# Get detailed status
argocd app get my-app

# Check resource details
kubectl get application my-app -n argocd -o yaml
```

---

### Q14: ArgoCD sync is slow. How to optimize?

**Answer:**

**Causes and Solutions:**

**1. Large Repository:**

```yaml
# Problem: Cloning 10GB repo
# Solution: Use sparse checkout
spec:
  source:
    repoURL: https://github.com/org/monorepo
    path: apps/myapp  # Only this path
```

**2. Many Resources:**

```yaml
# Problem: 1000+ resources
# Solution: Split into multiple apps
apps/
├── app1/  # ArgoCD App 1
├── app2/  # ArgoCD App 2
└── app3/  # ArgoCD App 3
```

**3. Slow Git Server:**

```yaml
# Solution: Enable caching
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
data:
  timeout.reconciliation: 300s
```

**4. Resource-Intensive Operations:**

```yaml
# Solution: Increase controller resources
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: argocd-application-controller
spec:
  template:
    spec:
      containers:
      - name: argocd-application-controller
        resources:
          requests:
            cpu: 1000m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 2Gi
```

**5. Too Many Applications:**

```
# Problem: 100+ apps on single controller
# Solution: Shard controllers
--app-resync: 180  # Increase sync interval
--repo-server-timeout-seconds: 120
```

**Monitoring:**

```promql
# Sync duration
histogram_quantile(0.95, 
  argocd_app_sync_duration_seconds_bucket)

# Reconciliation time
argocd_app_reconcile_duration_seconds
```

---

### Q15: How do you rollback a failed deployment?

**Answer:**

**Method 1: Git Revert (Recommended)**

```bash
# View history
git log --oneline

# Revert bad commit
git revert abc1234

# Push
git push

# ArgoCD auto-syncs to previous state
```

**Method 2: ArgoCD Rollback**

```bash
# View history
argocd app history my-app

# Rollback to previous version
argocd app rollback my-app 5

# Or rollback to specific revision
argocd app rollback my-app --revision abc1234
```

**Method 3: Manual Sync to Previous Commit**

```bash
# Sync to specific Git commit
argocd app sync my-app --revision def5678
```

**Method 4: Emergency kubectl**

```bash
# Last resort - manual fix
kubectl set image deployment/my-app \
  app=myapp:v1.0  # Previous version

# Then update Git to match
vim deployment.yaml
git commit -m "Rollback to v1.0"
git push
```

**Best Practice:**

1. Always use Git revert (audit trail)
2. Test rollback procedure regularly
3. Keep previous versions for quick rollback
4. Monitor after rollback

---

## 🏆 Best Practices Questions

### Q16: What are GitOps best practices for production?

**Answer:**

**1. Repository Structure:**

```
gitops-repo/
├── apps/           # Applications
├── infrastructure/ # Cluster resources
├── argocd/        # ArgoCD config
└── docs/          # Documentation
```

**2. Security:**

- Never commit secrets
- Use sealed secrets or external secrets
- Implement RBAC
- Enable SSO
- Scan images for vulnerabilities

**3. Environments:**

- Use overlays for environments
- Keep environments similar
- Progressive rollout (dev → staging → prod)

**4. Monitoring:**

- Monitor sync status
- Alert on OutOfSync
- Track sync duration
- Log all changes

**5. Disaster Recovery:**

- Backup ArgoCD configuration
- Test recovery procedure
- Document recovery steps
- Keep Git repository backed up

**6. Team Collaboration:**

- Use pull requests
- Code review all changes
- Document everything
- Clear ownership

**7. Performance:**

- Set resource limits
- Optimize sync frequency
- Use caching
- Shard controllers if needed

---

### Q17: How do you implement RBAC in ArgoCD?

**Answer:**

**Project-Based RBAC:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-frontend
spec:
  description: Frontend Team
  
  # What repos they can use
  sourceRepos:
  - 'https://github.com/org/frontend-*'
  
  # Where they can deploy
  destinations:
  - namespace: 'frontend-*'
    server: https://kubernetes.default.svc
  
  # What they can create
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: ''
    kind: Service
  
  # Roles
  roles:
  - name: developer
    policies:
    - p, proj:team-frontend:developer, applications, get, team-frontend/*, allow
    - p, proj:team-frontend:developer, applications, sync, team-frontend/*, allow
    groups:
    - frontend-developers
  
  - name: admin
    policies:
    - p, proj:team-frontend:admin, applications, *, team-frontend/*, allow
    groups:
    - frontend-admins
```

**Global RBAC:**

```yaml
# argocd-rbac-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  
  policy.csv: |
    # Admins - full access
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    g, admins, role:admin
    
    # Developers - limited access
    p, role:developer, applications, get, */*, allow
    p, role:developer, applications, sync, */*, allow
    g, developers, role:developer
    
    # Readonly - view only
    p, role:readonly, applications, get, */*, allow
    g, viewers, role:readonly
```

**SSO Integration:**

```yaml
# argocd-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  dex.config: |
    connectors:
    - type: github
      id: github
      name: GitHub
      config:
        clientID: $GITHUB_CLIENT_ID
        clientSecret: $GITHUB_CLIENT_SECRET
        orgs:
        - name: myorg
          teams:
          - frontend-team
          - backend-team
          - ops-team
```

---

## 🚀 Advanced Topics

### Q18: Explain ArgoCD ApplicationSet

**Answer:**

**What:** Generate multiple Applications from templates

**Use Cases:**

- Multi-cluster deployments
- Multi-tenant applications
- Dynamic application creation

**Example - Git Generator:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-apps
spec:
  generators:
  - git:
      repoURL: https://github.com/org/apps
      revision: HEAD
      directories:
      - path: apps/*
  template:
    metadata:
      name: '{{path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/org/apps
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basename}}'
```

**Result:** Creates Application for each directory in apps/

**Example - Cluster Generator:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-cluster-app
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
  template:
    metadata:
      name: 'myapp-{{name}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/org/myapp
        path: k8s/
      destination:
        server: '{{server}}'
        namespace: myapp
```

**Result:** Deploys myapp to all production clusters

---

### Q19: How do you implement progressive delivery with ArgoCD?

**Answer:**

**Progressive Delivery:** Gradually roll out changes

**1. Canary Deployment with Argo Rollouts:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  replicas: 10
  strategy:
    canary:
      steps:
      - setWeight: 10    # 10% traffic to new version
      - pause: {duration: 5m}
      - setWeight: 25    # 25% traffic
      - pause: {duration: 5m}
      - setWeight: 50    # 50% traffic
      - pause: {duration: 5m}
      - setWeight: 75    # 75% traffic
      - pause: {duration: 5m}
      # 100% traffic (automatic)
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0
```

**2. Blue-Green with Analysis:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp
spec:
  strategy:
    blueGreen:
      activeService: myapp-active
      previewService: myapp-preview
      autoPromotionEnabled: false
      prePromotionAnalysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: myapp-preview
```

**3. Analysis Template:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  metrics:
  - name: success-rate
    interval: 1m
    successCondition: result >= 0.95
    provider:
      prometheus:
        address: http://prometheus:9090
        query: |
          sum(rate(http_requests_total{status=~"2.."}[1m]))
          /
          sum(rate(http_requests_total[1m]))
```

**Benefits:**

- Automated rollout
- Automatic rollback on failure
- Metrics-based decisions
- Reduced risk

---

### Q20: How do you handle multi-cluster deployments?

**Answer:**

**Scenario:** Deploy to multiple Kubernetes clusters

**Setup:**

**1. Register Clusters:**

```bash
# Add cluster to ArgoCD
argocd cluster add cluster1-context --name cluster1
argocd cluster add cluster2-context --name cluster2

# List clusters
argocd cluster list
```

**2. Create ApplicationSet:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-cluster-app
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
  template:
    metadata:
      name: 'myapp-{{name}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/org/myapp
        path: k8s/overlays/{{metadata.labels.environment}}
      destination:
        server: '{{server}}'
        namespace: myapp
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

**3. Label Clusters:**

```bash
# Label clusters
kubectl label secret cluster1 \
  -n argocd \
  environment=production \
  region=us-east

kubectl label secret cluster2 \
  -n argocd \
  environment=production \
  region=us-west
```

**Result:** Application deployed to all production clusters

**Use Cases:**

- Multi-region deployment
- Disaster recovery
- Geographic distribution
- Environment separation

---

## 🎯 Summary

### Key Topics Covered

1. **Fundamentals**: GitOps principles, declarative config
2. **ArgoCD**: Architecture, components, workflows
3. **Scenarios**: Blue-green, secrets, promotion
4. **Troubleshooting**: OutOfSync, performance, rollback
5. **Best Practices**: Security, RBAC, monitoring
6. **Advanced**: ApplicationSet, progressive delivery, multi-cluster

### Interview Preparation Tips

1. **Understand Concepts**: Don't just memorize
2. **Practice Hands-On**: Build real projects
3. **Know Trade-offs**: Understand pros/cons
4. **Real Examples**: Use actual scenarios
5. **Ask Questions**: Show curiosity
6. **Be Honest**: Say "I don't know" if you don't

### Common Interview Flow

```
1. Basic Concepts (10 min)
   - What is GitOps?
   - Why GitOps?
   
2. Technical Deep Dive (20 min)
   - ArgoCD architecture
   - Sync process
   - Troubleshooting
   
3. Scenario Questions (15 min)
   - How would you...?
   - What if...?
   
4. Best Practices (10 min)
   - Production setup
   - Security
   - Team collaboration
   
5. Your Questions (5 min)
   - Ask about their setup
   - Show interest
```

---

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/)
- [Kustomize](https://kustomize.io/)

---

**Good luck with your interview! Remember: Understanding > Memorization** 🎯

**Pro Tip:** Always relate answers to real-world scenarios. Interviewers love practical experience! 💡
