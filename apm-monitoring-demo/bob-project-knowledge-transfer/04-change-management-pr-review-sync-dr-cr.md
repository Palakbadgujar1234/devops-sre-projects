# 4. Change Management, PR Review, ArgoCD Sync, DR and CR Flow

## Purpose of this document

This document explains the operational flow around configuration changes in Bob:

- who changes config
- where they change it
- how PR review works
- what happens after merge
- how ArgoCD sync fits in
- how DR and CR may be created automatically through IBM toolchain or related enterprise automation

This document is written for a beginner and focuses on practical understanding.

---

## 1. First understand the difference between code and config

In enterprise DevOps, many production changes are **not code changes**.

They are often:

- image tag changes
- scaling changes
- secret reference changes
- environment variable changes
- route/network changes
- cluster/environment config changes
- model deployment input changes

So when people say "deployment change", they often mean:

- changing YAML
- changing Helm values
- changing workflow input
- changing environment config

not necessarily changing application source code.

That is why GitOps and PR review are so important.

---

## 2. Who usually makes these changes

Depending on the organization, changes may be made by:

### Application team

Usually changes:

- service version
- app-specific config
- feature flags

### DevOps team

Usually changes:

- deployment pipeline config
- Helm values
- workflow automation
- release parameters

### SRE team

Usually changes:

- production scaling
- reliability settings
- emergency config
- sync timing
- rollback actions

### Platform team

Usually changes:

- cluster config
- environment config
- worker pools
- infrastructure settings
- upgrade-related settings

In Bob, all of these teams may touch different repos.

---

## 3. What "change management" means

Change management means:

> production changes should be controlled, reviewed, approved, traceable, and recoverable.

This is especially important in:

- regulated environments
- enterprise production systems
- AI systems with governance requirements

A good change-management process answers:

- who requested the change?
- what exactly changed?
- who approved it?
- when was it deployed?
- what environment was affected?
- how can it be rolled back?
- was a DR/CR record created?

---

## 4. Likely repositories involved in change flow

Based on your screenshots and links, the flow likely touches these repositories:

### ArgoCD deployment repo

Used for:

- Bob microservice deployment config
- ArgoCD application definitions
- environment-specific resources

### Cluster/platform repo

Used for:

- cluster-level config
- upgrade automation
- environment config
- operational controls

### MLOps/model deployment repo

Used for:

- model deployment workflows
- deployment state
- scripts and automation
- model rollout orchestration

Each repo may have its own PR and approval process.

---

## 5. Standard PR-based change flow

This is the most important operational pattern to understand.

### Step 1: Change requirement appears

Examples:

- deploy new service version
- increase replicas
- rotate secret reference
- update environment config
- deploy new model version
- prepare DR environment
- fix production incident

This requirement may come from:

- release plan
- incident ticket
- service owner request
- security remediation
- platform maintenance
- model approval process

---

### Step 2: Engineer creates branch and edits config

The engineer creates a feature branch and updates the relevant files.

Examples:

- ArgoCD YAML
- Helm values
- environment config
- workflow config
- model deployment JSON input
- deployed-state manifests

At this point, nothing is yet deployed.
Only Git content has changed in a branch.

---

### Step 3: Engineer raises PR

The PR is the formal request to accept the change.

A good PR usually includes:

- summary of change
- reason for change
- target environment
- risk assessment
- rollback plan
- linked ticket/change record
- testing evidence
- screenshots/logs if relevant

This is where enterprise governance starts becoming visible.

---

### Step 4: Automated checks run

Before humans approve, automation may run checks such as:

- YAML validation
- schema validation
- linting
- policy checks
- secret scanning
- branch protection checks
- workflow validation
- deployment preview checks

If checks fail, PR should not merge.

---

### Step 5: Human review happens

Reviewers may check:

- correctness
- production safety
- naming consistency
- environment targeting
- rollback readiness
- compliance with change window
- whether DR/CR references are present

Typical reviewers:

- service owner
- DevOps engineer
- SRE engineer
- platform engineer
- release approver

---

### Step 6: PR is approved and merged

Once approved, the PR is merged into the protected branch, usually [`main`](bob-project-knowledge-transfer/04-change-management-pr-review-sync-dr-cr.md:122).

This is the official acceptance point.

After merge:

- desired state changes
- audit trail is preserved
- deployment automation can proceed

---

## 6. What happens after merge for Bob microservices

For Bob microservices, the likely flow is:

```text
Config change merged to Git
        |
        v
ArgoCD detects repo change
        |
        v
Application becomes OutOfSync or auto-sync starts
        |
        v
ArgoCD applies manifests to cluster
        |
        v
Kubernetes/OpenShift rolls out updated resources
        |
        v
Post-deployment verification happens
```

This is the GitOps reconciliation model.

---

## 7. What happens after merge for model deployment

For model deployment, the flow may be slightly different.

Possible patterns:

### Pattern A: Workflow deploys directly

PR merge or manual trigger causes GitHub Actions to:

- validate config
- fetch model
- deploy/update runtime
- record deployed state

### Pattern B: Workflow creates another PR

GitHub Actions may:

- validate deployment request
- generate deployment state changes
- create PR into another repo
- wait for approval
- then deployment happens through GitOps

### Pattern C: Workflow triggers another pipeline

GitHub Actions may:

- validate request
- call Tekton or IBM toolchain
- that downstream system performs deployment and records change

From your screenshot, any of these are possible.
You should validate which one is used in Bob.

---

## 8. What ArgoCD sync means in simple words

ArgoCD sync means:

> "Make the cluster match what Git says."

If Git says:

- replicas = 3
- image tag = 2.4.1
- env var = enabled

then ArgoCD sync applies those values to the cluster.

### OutOfSync

Means:

- Git and cluster are different

### Synced

Means:

- cluster matches Git

### Healthy

Means:

- resources are not only applied, but also running correctly

These three ideas are very important when talking to SRE/DevOps teams.

---

## 9. Manual sync approval in production

In many enterprises, production sync is not fully automatic.

Possible production controls:

- PR merge allowed only after approvals
- ArgoCD sync allowed only in change window
- manual sync by SRE
- sync blocked until CR approved
- sync blocked until DR/rollback plan exists

So even after merge, deployment may still wait for an operational approval step.

---

## 10. What DR and CR usually mean

These terms can vary by company, but in enterprise DevOps they often mean:

### CR = Change Request / Change Record

A formal record that documents:

- what change is happening
- why it is needed
- when it will happen
- who approved it
- risk and rollback details

### DR = Deployment Record / Disaster Recovery related record / Delivery Request

This depends on internal terminology.

From your wording "auto DR and CR creation", likely meanings are:

- a deployment-related record is created automatically
- a change-management record is created automatically
- both are linked to the PR/pipeline/deployment event

You should confirm the exact expansion used in your organization.

---

## 11. How IBM toolchain may fit into DR/CR creation

You mentioned:

> in some process we are using CI/CD IBM toolchain for auto DR and CR creation

This strongly suggests the deployment process is integrated with enterprise governance tooling.

A likely pattern is:

```text
Engineer raises PR
      |
      v
PR approved / pipeline triggered
      |
      v
IBM toolchain step creates DR/CR records automatically
      |
      v
Record IDs are attached to deployment metadata
      |
      v
Deployment proceeds only if governance checks pass
```

Possible integration points:

- on PR creation
- on PR merge
- before production deployment
- during release pipeline execution
- after successful deployment for audit logging

This is common in large enterprises where deployment must be tied to formal change records.

---

## 12. Why auto DR/CR creation is useful

Automatic DR/CR creation helps because it:

- reduces manual paperwork
- improves auditability
- ensures every production change is tracked
- links Git activity to enterprise change records
- reduces missed compliance steps
- standardizes release governance

Without automation, engineers may forget to create records or enter inconsistent details.

---

## 13. Example: microservice config change with PR and ArgoCD sync

### Situation

Need to increase [`bob-broker`](bob-project-knowledge-transfer/04-change-management-pr-review-sync-dr-cr.md:239) replicas in production.

### Likely flow

1. SRE identifies high load.
2. Engineer updates replica config in ArgoCD repo.
3. PR is raised with incident/change reference.
4. Automated checks pass.
5. Reviewer approves.
6. PR merges.
7. IBM toolchain may create/update CR and DR records.
8. ArgoCD sync happens automatically or manually.
9. Cluster creates more broker pods.
10. Monitoring confirms stability.

---

## 14. Example: model deployment with governance

### Situation

A new approved model version must go to production.

### Likely flow

1. ML/DevOps engineer prepares deployment input.
2. GitHub Actions workflow is triggered.
3. Validation passes.
4. Approval/governance checks run.
5. IBM toolchain may create CR/DR records.
6. Deployment proceeds directly or through another PR.
7. Model becomes active in target environment.
8. Verification confirms health and quality.

This shows that model deployment may have stronger governance than normal service rollout.

---

## 15. What reviewers usually care about most

When a PR is reviewed for production, reviewers usually care about:

- Is the target environment correct?
- Is the change minimal and safe?
- Is rollback clear?
- Are secrets handled correctly?
- Is there a linked incident/change ticket?
- Is this within approved change window?
- Will ArgoCD sync safely?
- Does this affect DR readiness?
- Does this require CR approval first?

If you understand these questions, you understand the mindset of DevOps/SRE review.

---

## 16. Beginner-friendly mental model

Use this simple model:

```text
Need a production change
        |
        v
Edit config in Git branch
        |
        v
Raise PR
        |
        v
Checks + review + approvals
        |
        v
Merge PR
        |
        +--> For microservices: ArgoCD syncs cluster
        |
        +--> For models: workflow/toolchain performs rollout
        |
        v
DR/CR records may be created automatically
        |
        v
Verify deployment
```

---

## 17. What you should say in an interview or KT discussion

A strong beginner-friendly explanation would be:

> Bob uses a GitOps-style deployment model for microservices, where deployment configuration is changed through PRs in Git and ArgoCD syncs those approved changes to the cluster. For AI model deployment, GitHub Actions appears to handle a more workflow-driven process using structured deployment input. Across both flows, enterprise governance is likely enforced through PR review, approval gates, and IBM toolchain integration for automatic DR/CR creation and auditability.

That is a very solid summary.

---

## 18. What to validate with your team

Ask these exact questions internally:

1. What does DR stand for in this project?
2. What does CR stand for in this project?
3. Which IBM toolchain stage creates DR/CR automatically?
4. Is DR/CR creation triggered on PR, merge, or deployment?
5. Is ArgoCD production sync automatic or manually approved?
6. Which team is the final approver for production changes?
7. Are model deployments required to create separate change records from microservice deployments?

These answers will make your understanding much more accurate.
