# 2. Bob Microservice Deployment Flow

## Purpose of this document

This document explains how Bob microservices are likely deployed using ArgoCD, GitOps repositories, configuration files, pull requests, and cluster synchronization.

This is written for a beginner who wants to understand the full deployment flow from config change to production rollout.

---

## 1. What is a microservice in Bob?

A microservice is one small part of the Bob platform that does one focused job.

From your screenshots, Bob microservices likely include:

- backend
- gateway
- authn
- authz
- broker
- inference

Each service may run as its own Kubernetes/OpenShift workload.

That means each service can have its own:

- image version
- replica count
- environment variables
- secrets
- routes
- scaling rules
- resource limits

---

## 2. Why ArgoCD is used

ArgoCD is a GitOps deployment tool.

GitOps means:

> Git is treated as the source of truth for what should run in the cluster.

So instead of a person manually logging into the cluster and changing things, the team updates Git-managed deployment configuration.

Then ArgoCD reads that configuration and applies it to the cluster.

This gives:

- audit trail
- PR review process
- rollback through Git history
- consistent deployments
- less manual production change risk

---

## 3. Repository structure visible from your screenshots

From your screenshots, the Bob ArgoCD deployment repository appears to look like this conceptually:

```text
wxca-argocd-deployments/
└── bob/
    ├── application/
    │   └── prod/
    │       └── bob-services/
    ├── resources/
    │   └── prod/
    │       └── washington/
    │           ├── bob-backend/
    │           ├── bob-gateway/
    │           ├── bob-authn/
    │           ├── bob-authz/
    │           ├── bob-broker/
    │           ├── bob-inference/
    │           └── ...
    └── config/
        └── external-secrets/
            └── prod/
                └── [service-name]/
```

### What this likely means

- [`application/prod`](bob-project-knowledge-transfer/02-microservice-deployment-flow.md:57) contains ArgoCD application definitions
- [`resources/prod/...`](bob-project-knowledge-transfer/02-microservice-deployment-flow.md:58) contains service deployment manifests or Helm values
- [`config/external-secrets/prod`](bob-project-knowledge-transfer/02-microservice-deployment-flow.md:59) contains secret integration configuration

This is a common GitOps layout:

- one area defines **what ArgoCD should manage**
- another area defines **what should actually be deployed**
- another area defines **supporting config like secrets**

---

## 4. What an ArgoCD application usually does

An ArgoCD application is a definition that tells ArgoCD:

- which Git repo to watch
- which path in the repo to use
- which cluster/namespace to deploy to
- whether to auto-sync or wait for manual sync

So for Bob, an ArgoCD application under [`bob/application/prod`](bob-project-knowledge-transfer/02-microservice-deployment-flow.md:72) probably points to the production Bob resources.

That means ArgoCD continuously watches the Bob production deployment definitions.

---

## 5. What kinds of changes DevOps/SRE teams usually make

When DevOps or SRE teams work on this repo, they usually do **configuration changes**, not application code changes.

Typical changes include:

### 5.1 Image version updates

Example:

- change container image tag from old version to new version

Purpose:

- deploy a new release of a service

### 5.2 Replica/scaling changes

Example:

- increase replicas from 2 to 4

Purpose:

- handle more traffic
- improve availability

### 5.3 Resource changes

Example:

- update CPU/memory requests and limits

Purpose:

- fix performance issues
- reduce resource waste

### 5.4 Environment variable changes

Example:

- update service endpoint URL
- enable/disable feature flags

Purpose:

- change runtime behavior without changing code

### 5.5 Secret reference changes

Example:

- point to a new external secret path

Purpose:

- rotate credentials
- update integrations securely

### 5.6 Route/ingress/network changes

Example:

- update hostname or path routing

Purpose:

- expose service correctly
- support new traffic patterns

### 5.7 Region/environment-specific changes

Example:

- update only production us-east values

Purpose:

- environment-specific rollout
- regional customization

---

## 6. Typical microservice deployment flow end to end

Here is the likely flow.

### Step 1: Need for change is identified

A change request comes from:

- application team
- DevOps team
- SRE team
- incident response
- release planning
- security remediation

Examples:

- deploy new backend version
- increase gateway replicas
- update auth secret reference
- change inference service config

---

### Step 2: Engineer updates Git-managed config

The engineer creates a branch and edits deployment config in the ArgoCD repo.

Possible files changed:

- Helm values
- Kubernetes YAML
- ArgoCD application definitions
- environment config
- secret references

Important point:

The engineer is **not** directly changing the running cluster.
They are changing the **desired state in Git**.

---

### Step 3: Pull request is raised

The engineer opens a PR.

The PR usually contains:

- what changed
- why it changed
- target environment
- risk level
- rollback plan
- evidence or testing notes

In mature teams, PR templates may require:

- incident/change ticket reference
- approval from service owner
- SRE approval for production
- security review if secrets/network changed

---

### Step 4: PR review happens

Reviewers may include:

- service owner
- DevOps engineer
- SRE engineer
- platform engineer
- release manager

They check:

- is the config correct?
- is the target environment correct?
- is the image tag valid?
- are secrets handled safely?
- is scaling reasonable?
- does this match the approved change request?

---

### Step 5: PR is merged

Once approved, the PR is merged into the main branch.

This is the key GitOps moment.

After merge, the desired state in Git has officially changed.

---

### Step 6: ArgoCD detects drift

ArgoCD compares:

- current cluster state
- new desired Git state

If they differ, the application becomes:

- **OutOfSync** until applied
or
- automatically synced if auto-sync is enabled

---

### Step 7: ArgoCD sync applies the change

During sync, ArgoCD applies the updated manifests.

This may update:

- Deployment
- StatefulSet
- ConfigMap
- Secret reference
- Service
- Route/Ingress
- HorizontalPodAutoscaler

Kubernetes/OpenShift then performs the rollout.

For example:

- old pods terminate gradually
- new pods start with updated config
- readiness/liveness checks validate health

---

### Step 8: Post-deployment verification

After sync, teams usually verify:

- pods are healthy
- rollout completed
- logs show no errors
- metrics are normal
- service endpoint works
- no alert is firing

This may be done by:

- DevOps
- SRE
- service owner
- automated monitoring

---

## 7. Manual sync vs auto sync

This is very important in production.

### Auto sync

ArgoCD automatically applies merged changes.

Benefits:

- faster deployment
- less manual work

Risks:

- bad merge can deploy immediately

### Manual sync

ArgoCD waits for a human to click sync or approve sync.

Benefits:

- more control for production
- easier coordination with change windows

Risks:

- slower deployment
- more operational steps

Your team should confirm which mode Bob production uses.

---

## 8. How environment config fits in

Your screenshot showed an [`environment-config.yaml`](bob-project-knowledge-transfer/02-microservice-deployment-flow.md:191) file with cluster and worker pool details.

This kind of file usually influences:

- cluster metadata
- region
- infrastructure type
- worker pool sizing
- account/secret references
- environment behavior

This means not every change is service-specific.
Some changes are environment/platform-level and affect many services.

Examples:

- cluster version update
- worker pool scaling
- infrastructure migration
- DR environment setup

These changes are usually more sensitive and often reviewed by platform/SRE teams.

---

## 9. External secrets concept

Your screenshot also showed a path like external secrets config.

This usually means:

- secrets are not stored directly in plain YAML
- Kubernetes/OpenShift pulls secrets from an external secret manager
- the deployment repo stores only references or mappings

This is a best practice because:

- secrets stay outside Git
- rotation is easier
- access control is stronger

So a Bob service may reference:

- API keys
- database passwords
- service credentials
- cloud account tokens

without storing the actual secret value in the repo.

---

## 10. Example scenario: deploying a new Bob backend version

Let us walk through a simple example.

### Situation

The Bob backend team released image:
`bob-backend:2.4.1`

### Likely steps

1. DevOps engineer updates the backend image tag in the Bob production deployment config.
2. Engineer creates a branch.
3. Engineer raises a PR with release notes.
4. Reviewers approve the PR.
5. PR is merged.
6. ArgoCD detects the new image tag.
7. ArgoCD syncs the deployment.
8. Kubernetes rolls out new backend pods.
9. Team verifies health and logs.
10. If issue occurs, revert the Git change and sync again.

This is the GitOps rollback model:

- rollback is often just another Git change

---

## 11. Example scenario: scaling gateway during high traffic

### Situation

Traffic is increasing and gateway pods are overloaded.

### Likely steps

1. SRE updates replica count or autoscaling config for [`bob-gateway`](bob-project-knowledge-transfer/02-microservice-deployment-flow.md:245).
2. PR is raised with incident/change reference.
3. Review happens quickly.
4. PR is merged.
5. ArgoCD syncs.
6. More gateway pods are created.
7. Monitoring confirms recovery.

This shows that not all deployments are new versions.
Some are operational config changes.

---

## 12. Where DevOps and SRE differ in this flow

### DevOps focus

Usually more focused on:

- pipeline automation
- deployment templates
- release mechanics
- config structure
- CI/CD integration

### SRE focus

Usually more focused on:

- production safety
- reliability
- sync timing
- incident-driven changes
- rollback decisions
- monitoring after rollout

In practice, both may work in the same repo.

---

## 13. What can go wrong in microservice deployment

Common failure points:

- wrong image tag
- wrong namespace
- invalid YAML/Helm values
- missing secret reference
- insufficient CPU/memory
- readiness probe failure
- incompatible config with new app version
- ArgoCD sync failure
- cluster quota/resource shortage

That is why PR review and post-sync verification are important.

---

## 14. Beginner summary

If you are completely new, remember this simple version:

1. Bob microservice deployment config is stored in Git.
2. Engineers change config in the repo, not directly in the cluster.
3. They raise a PR.
4. Reviewers approve it.
5. PR is merged.
6. ArgoCD notices the change.
7. ArgoCD syncs the cluster to match Git.
8. The service gets updated in Kubernetes/OpenShift.

That is the core Bob microservice deployment flow.

---

## 15. What to validate with your team

Ask these exact questions internally:

1. Which repo is the final production source of truth for Bob microservices?
2. Are Bob production apps on ArgoCD auto-sync or manual sync?
3. Are Helm charts used directly, or are manifests pre-rendered?
4. Which team owns production sync approval?
5. How are rollback and emergency fixes handled?
6. Which monitoring dashboards are checked after sync?
7. Are external secrets managed through Vault, Secrets Manager, or another IBM internal tool?

These answers will make your understanding production-ready.
