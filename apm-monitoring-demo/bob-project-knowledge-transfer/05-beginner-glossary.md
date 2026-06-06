# 5. Beginner Glossary for Bob DevOps, SRE, ArgoCD and Model Deployment

## Purpose of this document

This glossary explains important terms in simple language so that a beginner can understand the Bob project discussions more confidently.

---

## A

### ArgoCD

A GitOps deployment tool for Kubernetes/OpenShift.

Simple meaning:
It watches Git and makes the cluster match what is written in Git.

In Bob, ArgoCD likely manages microservice deployment configuration.

---

## B

### Branch

A separate line of work in Git.

Simple meaning:
You create a branch when you want to make changes safely without directly changing the main production configuration.

---

## C

### CI/CD

Short for Continuous Integration / Continuous Delivery or Deployment.

Simple meaning:
Automation that helps teams validate, build, test, approve, and deploy changes.

In Bob, CI/CD may include:

- GitHub Actions
- Tekton
- IBM toolchain
- ArgoCD sync process

### Cluster

A group of machines/nodes running Kubernetes or OpenShift workloads.

Simple meaning:
This is where Bob services actually run.

### Config

Settings that control how an application or deployment behaves.

Examples:

- image tag
- replica count
- environment variables
- secret references
- CPU/memory limits

### Config drift

A mismatch between what Git says should run and what is actually running.

ArgoCD is used to detect and fix this.

### CR

Usually means Change Request or Change Record.

Simple meaning:
A formal record that tracks a production change for governance and audit purposes.

In your project, confirm the exact meaning internally.

---

## D

### Deployment

The process of releasing or updating software in an environment.

In Bob, deployment may mean:

- microservice deployment through ArgoCD
- model deployment through GitHub Actions workflow

### Desired state

The target configuration stored in Git.

Simple meaning:
What the system should look like after deployment.

### DR

This term must be confirmed internally because companies use it differently.

Possible meanings:

- Deployment Record
- Disaster Recovery related record
- Delivery Request

From your description, it seems to be an automatically created governance/deployment record.

---

## E

### Environment

A target stage where software runs.

Common examples:

- dev
- test
- prod
- DR

Simple meaning:
Different places for testing and running the same platform.

### External secrets

A pattern where secret values are stored outside Git and only references are stored in deployment config.

Simple meaning:
Passwords and keys are not written directly in YAML files.

---

## G

### Git

Version control system used to track changes.

Simple meaning:
It stores history of who changed what and when.

### GitHub Actions

A workflow automation system inside GitHub.

In Bob, it appears to be used for model deployment workflows.

### GitOps

An operating model where Git is the source of truth for deployment state.

Simple meaning:
Instead of manually changing the cluster, engineers change Git and automation applies it.

---

## H

### Helm

A packaging and templating tool for Kubernetes applications.

Simple meaning:
It helps teams manage reusable deployment templates and values.

### Health

A deployment status meaning the application is running correctly.

In ArgoCD, an app can be:

- Synced
- OutOfSync
- Healthy
- Degraded

---

## I

### Image tag

The version label of a container image.

Example:
`bob-backend:2.4.1`

Changing the image tag usually means deploying a new application version.

### Inference

The process of using a trained AI model to generate predictions or responses.

In Bob, inference likely means the runtime use of deployed AI models.

### Inference service

A service that receives requests and interacts with the model runtime.

In Bob, [`bob-inference`](bob-project-knowledge-transfer/05-beginner-glossary.md:104) likely plays this role.

### Infrastructure

The underlying platform resources needed to run applications.

Examples:

- clusters
- worker nodes
- networking
- storage
- cloud accounts

---

## K

### Kubernetes

A container orchestration platform.

Simple meaning:
It manages containers, scaling, rollout, restart, and service networking.

### Kubernetes manifest

A YAML file that defines a Kubernetes resource.

Examples:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress

---

## M

### Manifest

A configuration file that defines what should be deployed.

Simple meaning:
A YAML file that tells Kubernetes or ArgoCD what to create or update.

### Merge

The action of accepting a PR into the main branch.

Simple meaning:
Once merged, the change becomes part of the official desired state.

### Microservice

A small service that performs one focused function in a larger platform.

In Bob, examples likely include:

- backend
- gateway
- authn
- authz
- broker
- inference

### Model artifact

The packaged output of a trained AI model.

This may include:

- weights
- metadata
- configuration
- runtime packaging

### Model deployment

The process of making a model available for inference in a target environment.

This may include:

- selecting model version
- validating config
- updating runtime
- recording deployed state

### MLOps

Operational practices for managing machine learning models in production.

Simple meaning:
DevOps for AI/ML systems.

---

## O

### OpenShift

Red Hat's enterprise Kubernetes platform.

Simple meaning:
A managed enterprise platform for running containerized applications.

### OutOfSync

An ArgoCD status meaning Git and the cluster do not match.

Simple meaning:
A change exists in Git that has not yet been applied, or the cluster drifted away from Git.

---

## P

### Pipeline

A sequence of automated steps.

Examples:

- validate config
- run tests
- create records
- deploy changes
- verify rollout

### PR

Pull Request.

Simple meaning:
A formal request to review and merge a change into the main branch.

### Production

The live environment used by real users.

Simple meaning:
The most sensitive environment where changes need the strongest control.

---

## R

### Reconcile / reconciliation

The process of making actual state match desired state.

ArgoCD continuously reconciles Git state with cluster state.

### Replica

One running copy of a service pod.

If replicas increase from 2 to 4, more copies of the service run.

### Rollback

Returning to a previous known-good version or configuration.

In GitOps, rollback often means reverting a Git change and syncing again.

### Runtime

The environment that actually runs an application or model.

For AI, runtime may mean the serving system that loads and executes the model.

---

## S

### Secret

Sensitive information such as:

- passwords
- API keys
- tokens
- certificates

### Service

A network-accessible application component.

In Bob, each microservice is likely exposed internally or externally through service definitions.

### SRE

Site Reliability Engineering.

Simple meaning:
The team or role focused on reliability, availability, monitoring, incident response, and safe production operations.

### Sync

In ArgoCD, sync means applying Git-defined changes to the cluster.

Simple meaning:
Make the cluster match Git.

---

## T

### Tekton

A Kubernetes-native pipeline framework.

In your screenshots, the model deployment repo contains a [`tekton`](bob-project-knowledge-transfer/05-beginner-glossary.md:220) folder, so it may be part of the deployment automation.

### Toolchain

A connected set of automation tools used to build, validate, approve, and deploy changes.

In your project, IBM toolchain may also create DR/CR records automatically.

---

## W

### Workflow

An automated process defined in a tool like GitHub Actions.

Example:
[`model-deployment-json.yml`](bob-project-knowledge-transfer/05-beginner-glossary.md:231)

### Worker pool

A group of worker nodes in a cluster.

Simple meaning:
The machines where application pods run.

---

## Final beginner summary

If you are new, remember these 10 terms first:

1. **GitOps** = change Git, not cluster directly
2. **ArgoCD** = sync Git changes to cluster
3. **PR** = request review before merge
4. **Merge** = approved change becomes official
5. **Sync** = apply Git state to cluster
6. **Microservice** = one small service in Bob
7. **Inference** = using AI model to answer/predict
8. **Model deployment** = making a model available in runtime
9. **CR** = change record/request
10. **SRE** = team focused on production reliability

If you understand these, you can follow most Bob DevOps discussions.
