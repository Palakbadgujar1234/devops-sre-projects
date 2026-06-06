# 🏆 GitOps Best Practices - Production Ready

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [Repository Structure](#repository-structure)
3. [Security Best Practices](#security-best-practices)
4. [RBAC Configuration](#rbac-configuration)
5. [Monitoring and Observability](#monitoring-and-observability)
6. [Disaster Recovery](#disaster-recovery)
7. [Performance Optimization](#performance-optimization)
8. [Team Collaboration](#team-collaboration)

---

## 🎯 Introduction

### WHAT are Best Practices?

Proven patterns and guidelines for **production-ready GitOps** implementations.

### WHY Follow Best Practices?

```
Without Best Practices:
- Security vulnerabilities
- Difficult to maintain
- Poor performance
- Hard to recover from failures
- Team conflicts

With Best Practices:
- Secure by default
- Easy to maintain
- Optimized performance
- Quick disaster recovery
- Smooth team collaboration
```

---

## 📁 Repository Structure

### Best Practice 1: Mono-Repo vs Multi-Repo

**Mono-Repo (Recommended for Small/Medium Teams):**

```
my-gitops-repo/
├── apps/
│   ├── frontend/
│   ├── backend/
│   └── database/
├── infrastructure/
│   ├── namespaces/
│   ├── ingress/
│   └── monitoring/
├── argocd/
│   ├── applications/
│   └── projects/
└── docs/
    └── README.md
```

**Pros:**

- ✅ Single source of truth
- ✅ Easy to search
- ✅ Atomic changes across apps
- ✅ Simpler CI/CD

**Cons:**

- ⚠️ Large repository
- ⚠️ All teams have access
- ⚠️ Slower Git operations

**Multi-Repo (Recommended for Large Teams):**

```
frontend-gitops/
backend-gitops/
database-gitops/
infrastructure-gitops/
argocd-config/
```

**Pros:**

- ✅ Team ownership
- ✅ Independent versioning
- ✅ Smaller repositories
- ✅ Better access control

**Cons:**

- ⚠️ Harder to coordinate changes
- ⚠️ Multiple sources of truth
- ⚠️ Complex CI/CD

### Best Practice 2: Directory Structure

**Recommended Structure:**

```
gitops-repo/
├── README.md                    # Documentation
├── .gitignore                   # Ignore patterns
│
├── apps/                        # Application manifests
│   ├── app-name/
│   │   ├── base/               # Common config
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── configmap.yaml
│   │   │   └── kustomization.yaml
│   │   └── overlays/           # Environment-specific
│   │       ├── dev/
│   │       ├── staging/
│   │       └── prod/
│   │
│   └── another-app/
│
├── infrastructure/              # Cluster infrastructure
│   ├── namespaces/
│   ├── ingress/
│   ├── cert-manager/
│   └── monitoring/
│
├── argocd/                      # ArgoCD configurations
│   ├── applications/           # Application definitions
│   ├── projects/               # Project definitions
│   └── bootstrap/              # Bootstrap ArgoCD itself
│
├── scripts/                     # Utility scripts
│   ├── deploy.sh
│   ├── rollback.sh
│   └── test.sh
│
└── docs/                        # Documentation
    ├── architecture.md
    ├── deployment.md
    └── troubleshooting.md
```

### Best Practice 3: Naming Conventions

**Consistent Naming:**

```yaml
# Applications
frontend-dev
frontend-staging
frontend-prod

# Namespaces
dev
staging
production

# Resources
<env>-<app>-<resource>
dev-frontend-deployment
staging-backend-service
prod-database-statefulset

# Labels
app: frontend
environment: production
tier: web
managed-by: argocd
version: v1.2.3
```

---

## 🔐 Security Best Practices

### Best Practice 1: Never Commit Secrets

**❌ WRONG:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-password
data:
  password: cGFzc3dvcmQxMjM=  # ← Base64 is NOT encryption!
```

**✅ RIGHT - Use Sealed Secrets:**

```bash
# Create secret
kubectl create secret generic db-password \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml | \
  kubeseal -o yaml > sealed-secret.yaml

# Commit sealed secret
git add sealed-secret.yaml
git commit -m "Add sealed database password"
```

**✅ RIGHT - Use External Secrets:**

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: db-password
spec:
  secretStoreRef:
    name: aws-secrets-manager
  data:
  - secretKey: password
    remoteRef:
      key: prod/db/password
```

### Best Practice 2: Least Privilege Access

**ArgoCD Service Account:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-application-controller
  namespace: argocd

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argocd-application-controller
  namespace: production
rules:
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["services", "configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
# ❌ Don't give cluster-admin!
# ✅ Only necessary permissions
```

### Best Practice 3: Image Security

**Use Specific Tags:**

```yaml
# ❌ WRONG - Mutable tag
image: nginx:latest

# ✅ BETTER - Specific version
image: nginx:1.25.3

# ✅ BEST - SHA digest
image: nginx:1.25.3@sha256:abc123...
```

**Scan Images:**

```bash
# Use Trivy to scan images
trivy image nginx:1.25.3

# Fail build if vulnerabilities found
trivy image --severity HIGH,CRITICAL --exit-code 1 nginx:1.25.3
```

### Best Practice 4: Network Policies

**Restrict Traffic:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Only allow from ingress controller
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 80
  egress:
  # Only allow to backend
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3000
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

---

## 👥 RBAC Configuration

### Best Practice 1: ArgoCD Projects for Teams

**Create Team-Specific Projects:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-frontend
  namespace: argocd
spec:
  description: Frontend Team Project
  
  # Only these repos
  sourceRepos:
  - 'https://github.com/myorg/frontend-*'
  
  # Only these namespaces
  destinations:
  - namespace: 'frontend-*'
    server: https://kubernetes.default.svc
  
  # Only these resources
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: ''
    kind: Service
  - group: ''
    kind: ConfigMap
  
  # Team members
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

### Best Practice 2: SSO Integration

**Configure SSO with GitHub:**

```yaml
# argocd-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.example.com
  
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

**Map Teams to Roles:**

```yaml
# argocd-rbac-cm ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    # Frontend team - can manage frontend apps
    p, role:frontend-developer, applications, get, */*, allow
    p, role:frontend-developer, applications, sync, frontend-*/*, allow
    g, myorg:frontend-team, role:frontend-developer
    
    # Ops team - can manage everything
    p, role:ops-admin, applications, *, */*, allow
    p, role:ops-admin, clusters, *, *, allow
    p, role:ops-admin, repositories, *, *, allow
    g, myorg:ops-team, role:ops-admin
    
    # Read-only for everyone else
    p, role:readonly, applications, get, */*, allow
    g, myorg:*, role:readonly
```

---

## 📊 Monitoring and Observability

### Best Practice 1: Application Health Checks

**Configure Health Assessment:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-prod
spec:
  # ... other config ...
  
  # Health assessment
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas  # Ignore HPA changes
  
  # Custom health checks
  health:
    checks:
    - name: frontend-health
      type: http
      http:
        url: http://frontend.production.svc.cluster.local/health
        expectedStatus: 200
```

### Best Practice 2: Prometheus Metrics

**Expose ArgoCD Metrics:**

```yaml
# ServiceMonitor for Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-server
  endpoints:
  - port: metrics
```

**Key Metrics to Monitor:**

```promql
# Application sync status
argocd_app_info{sync_status="Synced"}

# Application health
argocd_app_info{health_status="Healthy"}

# Sync failures
rate(argocd_app_sync_total{phase="Failed"}[5m])

# Sync duration
histogram_quantile(0.95, argocd_app_sync_duration_seconds_bucket)
```

### Best Practice 3: Alerting

**Prometheus Alerts:**

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: argocd-alerts
  namespace: argocd
spec:
  groups:
  - name: argocd
    interval: 30s
    rules:
    # Alert on out of sync
    - alert: ArgoCDAppOutOfSync
      expr: argocd_app_info{sync_status!="Synced"} == 1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "ArgoCD app {{ $labels.name }} is out of sync"
    
    # Alert on unhealthy
    - alert: ArgoCDAppUnhealthy
      expr: argocd_app_info{health_status!="Healthy"} == 1
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "ArgoCD app {{ $labels.name }} is unhealthy"
    
    # Alert on sync failures
    - alert: ArgoCDSyncFailure
      expr: rate(argocd_app_sync_total{phase="Failed"}[5m]) > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "ArgoCD sync failures detected"
```

### Best Practice 4: Logging

**Structured Logging:**

```yaml
# Configure ArgoCD logging
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  namespace: argocd
data:
  # Log level
  application.controller.log.level: "info"
  server.log.level: "info"
  
  # Log format (json for parsing)
  application.controller.log.format: "json"
  server.log.format: "json"
```

**Collect Logs:**

```yaml
# Fluentd/Fluent Bit configuration
<filter kubernetes.var.log.containers.argocd-**>
  @type parser
  key_name log
  <parse>
    @type json
  </parse>
</filter>

<match kubernetes.var.log.containers.argocd-**>
  @type elasticsearch
  host elasticsearch.logging.svc.cluster.local
  port 9200
  index_name argocd
</match>
```

---

## 🚨 Disaster Recovery

### Best Practice 1: Backup Strategy

**What to Backup:**

```bash
# 1. ArgoCD configuration
kubectl get configmap -n argocd -o yaml > argocd-config-backup.yaml
kubectl get secret -n argocd -o yaml > argocd-secrets-backup.yaml

# 2. Application definitions
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# 3. Projects
kubectl get appprojects -n argocd -o yaml > argocd-projects-backup.yaml

# 4. Git repository (already backed up by Git!)
git clone --mirror https://github.com/myorg/gitops-repo.git
```

**Automated Backup Script:**

```bash
#!/bin/bash
# backup-argocd.sh

BACKUP_DIR="/backups/argocd/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup ArgoCD resources
kubectl get configmap -n argocd -o yaml > "$BACKUP_DIR/configmaps.yaml"
kubectl get secret -n argocd -o yaml > "$BACKUP_DIR/secrets.yaml"
kubectl get applications -n argocd -o yaml > "$BACKUP_DIR/applications.yaml"
kubectl get appprojects -n argocd -o yaml > "$BACKUP_DIR/projects.yaml"

# Backup to S3
aws s3 sync "$BACKUP_DIR" "s3://my-backups/argocd/$(date +%Y%m%d-%H%M%S)/"

echo "Backup completed: $BACKUP_DIR"
```

### Best Practice 2: Disaster Recovery Plan

**Recovery Steps:**

```bash
# 1. Create new cluster
# (Using your cloud provider)

# 2. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Restore ArgoCD configuration
kubectl apply -f argocd-config-backup.yaml
kubectl apply -f argocd-secrets-backup.yaml

# 4. Restore projects
kubectl apply -f argocd-projects-backup.yaml

# 5. Restore applications
kubectl apply -f argocd-apps-backup.yaml

# 6. Wait for sync
argocd app sync --all

# 7. Verify
kubectl get pods --all-namespaces
```

**Recovery Time Objective (RTO):**

```
Target: < 30 minutes

Steps:
1. Create cluster: 10 minutes
2. Install ArgoCD: 5 minutes
3. Restore config: 2 minutes
4. Restore apps: 3 minutes
5. Sync all: 10 minutes
Total: 30 minutes
```

### Best Practice 3: GitOps for ArgoCD Itself

**Bootstrap ArgoCD:**

```yaml
# argocd/bootstrap/argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/gitops-repo
    targetRevision: HEAD
    path: argocd/bootstrap
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**Benefits:**

- ✅ ArgoCD manages itself
- ✅ Configuration in Git
- ✅ Easy to recreate
- ✅ Version controlled

---

## ⚡ Performance Optimization

### Best Practice 1: Resource Limits

**Set Appropriate Limits:**

```yaml
# ArgoCD Application Controller
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
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 2000m
            memory: 2Gi
```

### Best Practice 2: Sync Optimization

**Configure Sync Settings:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  # Sync timeout
  timeout.reconciliation: 180s
  
  # Concurrent syncs
  application.resourceTrackingMethod: annotation
  
  # Diff customization
  resource.customizations: |
    apps/Deployment:
      ignoreDifferences: |
        jsonPointers:
        - /spec/replicas  # Ignore HPA changes
```

### Best Practice 3: Repository Caching

**Enable Caching:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  # Cache repository data
  repository.credentials: |
    - url: https://github.com/myorg
      usernameSecret:
        name: github-creds
        key: username
      passwordSecret:
        name: github-creds
        key: password
```

---

## 🤝 Team Collaboration

### Best Practice 1: Code Review Process

**Pull Request Template:**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New application
- [ ] Configuration update
- [ ] Bug fix
- [ ] Infrastructure change

## Environments Affected
- [ ] Development
- [ ] Staging
- [ ] Production

## Testing
- [ ] Tested in dev
- [ ] Tested in staging
- [ ] Smoke tests passed
- [ ] Integration tests passed

## Rollback Plan
Describe how to rollback if needed

## Checklist
- [ ] No secrets committed
- [ ] Documentation updated
- [ ] Monitoring configured
- [ ] Alerts configured
```

### Best Practice 2: Documentation

**Maintain Documentation:**

```markdown
# GitOps Repository Documentation

## Overview
Description of the repository and its purpose

## Structure
Explanation of directory structure

## Applications
List of all applications and their owners

## Deployment Process
Step-by-step deployment guide

## Troubleshooting
Common issues and solutions

## Contacts
Team contacts and escalation paths
```

### Best Practice 3: Change Management

**Change Process:**

```
1. Create feature branch
2. Make changes
3. Test locally
4. Create pull request
5. Code review
6. Merge to main
7. Deploy to dev (automatic)
8. Test in dev
9. Promote to staging
10. Test in staging
11. Promote to production
12. Monitor production
```

---

## 🎯 Summary

### Key Best Practices

1. **Repository Structure**: Organized, consistent, documented
2. **Security**: No secrets in Git, least privilege, image scanning
3. **RBAC**: Team-based access, SSO integration
4. **Monitoring**: Metrics, alerts, logging
5. **Disaster Recovery**: Backups, recovery plan, tested regularly
6. **Performance**: Resource limits, sync optimization
7. **Collaboration**: Code review, documentation, change management

### Production Checklist

- [ ] Repository structure follows best practices
- [ ] No secrets committed to Git
- [ ] RBAC configured for teams
- [ ] SSO integrated
- [ ] Monitoring and alerting configured
- [ ] Backup strategy implemented
- [ ] Disaster recovery plan tested
- [ ] Resource limits set
- [ ] Documentation complete
- [ ] Team trained on GitOps workflow

---

## 🚀 Next Steps

**Next Guide:** [`07-INTERVIEW-QUESTIONS.md`](07-INTERVIEW-QUESTIONS.md)

Prepare for interviews with:

- 50+ GitOps questions
- ArgoCD-specific questions
- Scenario-based questions
- Best practice questions

---

**Remember:** Best practices are learned from experience. Start with these, adapt to your needs, and continuously improve! 🏆
