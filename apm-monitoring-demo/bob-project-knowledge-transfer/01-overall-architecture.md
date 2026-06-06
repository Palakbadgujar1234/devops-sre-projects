# 1. Bob Overall Architecture

## Purpose of this document

This document explains the Bob project architecture in simple language for someone who is new to DevOps, SRE, GitOps, ArgoCD, CI/CD, and AI model deployment.

This explanation is based on:

- repository names and paths shared by you
- screenshots shared by you
- common enterprise deployment patterns

Where needed, I clearly mention whether something is **Observed**, **Inferred**, or **Assumed**.

---

## 1. What Bob appears to be

**Observed / Inferred**

Bob appears to be an AI-based platform made of multiple microservices plus one or more inference/model-serving components.

From your screenshots, Bob seems to include services such as:

- bob-backend
- bob-gateway
- bob-authn
- bob-authz
- bob-broker
- bob-inference

This strongly suggests Bob is not a single application. It is a platform composed of many smaller services, where each service has a specific responsibility.

---

## 2. High-level architecture

A simple way to understand the architecture is:

```text
Users / Client Apps
        |
        v
   Gateway / Entry Layer
        |
        v
 Application / Backend Services
        |
        +--> Auth services
        |
        +--> Broker / orchestration services
        |
        +--> Inference service
                 |
                 v
          AI model runtime / model endpoint
```

---

## 3. Main building blocks

### 3.1 User-facing layer

This is usually the entry point into the platform.

Possible components:

- API gateway
- ingress
- routing layer
- authentication entry checks

From your screenshot, [`bob-gateway`](bob-project-knowledge-transfer/01-overall-architecture.md:35) likely plays this role.

Its job is usually:

- receive incoming requests
- route requests to the correct internal service
- apply security or policy checks
- expose stable APIs to clients

---

### 3.2 Core application services

These are the business logic services.

From your screenshot, likely examples are:

- [`bob-backend`](bob-project-knowledge-transfer/01-overall-architecture.md:47)
- [`bob-broker`](bob-project-knowledge-transfer/01-overall-architecture.md:48)

Typical responsibilities:

- process requests
- call other internal services
- manage workflows
- prepare prompts or inference requests
- store or retrieve metadata

---

### 3.3 Authentication and authorization services

From your screenshot:

- [`bob-authn`](bob-project-knowledge-transfer/01-overall-architecture.md:58)
- [`bob-authz`](bob-project-knowledge-transfer/01-overall-architecture.md:59)

Typical meaning:

- **authn** = authentication = who are you?
- **authz** = authorization = what are you allowed to do?

These services usually:

- validate tokens
- integrate with identity providers
- enforce access rules
- protect internal APIs

---

### 3.4 Inference service

From your screenshot:

- [`bob-inference`](bob-project-knowledge-transfer/01-overall-architecture.md:71)

This is one of the most important parts for an AI-based platform.

Its likely role:

- receive inference requests from Bob services
- call the actual model runtime or model endpoint
- transform request/response payloads
- manage model-specific routing or configuration
- expose a stable internal API to the rest of Bob

This is important because application teams usually do **not** want every microservice to directly manage model deployment details.

Instead, they often use an inference layer that hides model complexity.

---

## 4. Two deployment worlds inside the same platform

One of the most important things to understand is that Bob likely has **two different deployment flows**.

### 4.1 Microservice deployment flow

**Observed / Inferred**

Your screenshots show that Bob microservices use:

- ArgoCD
- GitOps-style repositories
- environment configuration files
- application/resource folders

This means normal Bob services are likely deployed as Kubernetes/OpenShift workloads using ArgoCD.

Examples:

- backend
- gateway
- auth services
- broker
- inference service container itself

---

### 4.2 AI model deployment flow

**Observed / Inferred**

Your screenshots show:

- repository [`cme3-devops-mlops`](bob-project-knowledge-transfer/01-overall-architecture.md:104)
- GitHub workflow file [`model-deployment-json.yml`](bob-project-knowledge-transfer/01-overall-architecture.md:105)

This strongly suggests model deployment is handled differently from normal microservices.

Instead of only relying on ArgoCD, model deployment appears to use:

- GitHub Actions workflows
- JSON-based deployment input
- pipeline logic for validation and deployment

This is common because model deployment often needs:

- model artifact handling
- registry access
- approval gates
- environment-specific rollout logic
- metadata validation
- deployment tracking

So the platform likely separates:

- **application deployment**
- **model deployment**

---

## 5. Repositories and likely responsibilities

### 5.1 ArgoCD deployment repository

**Observed**

You shared:
`https://github.ibm.com/automation-paas-cd-pipeline/wxca-argocd-deployments/tree/main/bob/application/prod`

This repository likely stores:

- ArgoCD application definitions
- Helm values
- environment-specific deployment manifests
- references to Bob services for production deployment

This is usually the **desired state repository** for GitOps.

Meaning:

- what is in Git is what should run in the cluster

---

### 5.2 Cluster / platform / upgrade repository

**Observed**

You shared:
`https://github.ibm.com/automation-paas-cd-pipeline`

This likely contains:

- cluster-level automation
- platform deployment logic
- upgrade workflows
- shared deployment tooling
- DR/CR automation hooks
- operational scripts or templates

This repo may be used more by platform engineering / SRE / cluster operations than by application developers.

---

### 5.3 MLOps / model deployment repository

**Observed**

You shared:
`https://github.ibm.com/code-assistant/cme3-devops-mlops`

From the screenshot, this repo contains:

- [`.github/workflows/model-deployment-json.yml`](bob-project-knowledge-transfer/01-overall-architecture.md:154)
- [`configs`](bob-project-knowledge-transfer/01-overall-architecture.md:155)
- [`configuration`](bob-project-knowledge-transfer/01-overall-architecture.md:156)
- [`docs`](bob-project-knowledge-transfer/01-overall-architecture.md:157)
- [`k8s/manifests/deployed-state`](bob-project-knowledge-transfer/01-overall-architecture.md:158)
- [`scripts`](bob-project-knowledge-transfer/01-overall-architecture.md:159)
- [`tekton`](bob-project-knowledge-transfer/01-overall-architecture.md:160)

This suggests a mature deployment repo that may support:

- model deployment orchestration
- validation
- deployment state tracking
- Kubernetes manifest generation
- Tekton integration
- GitHub Actions orchestration

---

## 6. What ArgoCD is probably doing here

ArgoCD is likely responsible for continuously comparing:

- **desired state in Git**
vs
- **actual state in the cluster**

If there is a difference, ArgoCD can:

- show the application as out-of-sync
- sync the changes
- apply the updated manifests to the cluster

For Bob microservices, ArgoCD likely manages:

- Deployments / StatefulSets
- Services
- ConfigMaps
- Secrets references
- Ingress / Routes
- Helm releases or rendered manifests

---

## 7. What GitHub Actions is probably doing for models

The workflow screenshot shows a file named [`model-deployment-json.yml`](bob-project-knowledge-transfer/01-overall-architecture.md:181) with:

- manual dispatch input
- JSON config input
- validation/parsing steps
- environment variables
- outputs for deployment type and model source

This strongly suggests the model deployment process is more pipeline-driven than plain GitOps.

Likely responsibilities:

- accept deployment request input
- validate model deployment configuration
- determine environment and model source
- trigger deployment logic
- possibly update deployed-state manifests
- possibly create PRs into ArgoCD/config repos
- possibly integrate with approvals and change records

---

## 8. Environment configuration concept

One screenshot shows an [`environment-config.yaml`](bob-project-knowledge-transfer/01-overall-architecture.md:194) under a Bob cluster path.

That file appears to contain:

- environment name
- cluster version
- infrastructure type
- location
- worker pool settings
- account/secret references
- service-related settings

This means deployment is likely environment-aware.

Typical environments may include:

- dev
- test
- prod
- DR

This kind of file usually controls:

- where workloads are deployed
- cluster-specific settings
- scaling defaults
- infrastructure metadata
- account bindings

---

## 9. Likely team responsibilities

### DevOps team

Usually responsible for:

- CI/CD pipelines
- deployment automation
- GitHub Actions / Tekton / toolchain integration
- Helm/chart/config structure
- release process support

### SRE team

Usually responsible for:

- production reliability
- cluster health
- ArgoCD sync governance
- incident response
- DR readiness
- operational controls and change governance

### Application / AI teams

Usually responsible for:

- service code
- model code or model artifacts
- service configuration inputs
- testing and release readiness

### Platform team

Usually responsible for:

- cluster upgrades
- shared deployment frameworks
- base infrastructure
- common templates and controls

In real enterprise environments, these responsibilities often overlap.

---

## 10. Simplified end-to-end picture

```text
Code / Config change happens in Git
        |
        +--> For Bob microservices:
        |       update ArgoCD/Helm/config repo
        |       -> PR
        |       -> review
        |       -> merge
        |       -> ArgoCD detects drift
        |       -> sync to cluster
        |
        +--> For AI models:
                trigger GitHub Actions workflow
                -> validate JSON/config
                -> deploy model or update deployment state
                -> possibly create PR / change record
                -> rollout to target environment
```

---

## 11. Most important takeaway

If you remember only one thing, remember this:

- **Bob microservices** appear to be deployed mainly through **ArgoCD GitOps**
- **Bob AI inference models** appear to be deployed mainly through **GitHub Actions based MLOps workflow**
- both flows may still connect through shared config repos, approvals, and enterprise change-management controls

That is the core architecture idea behind this project.

---

## 12. What to validate internally

Because this guide is based on screenshots and naming, validate these points with your team:

1. Does [`bob-inference`](bob-project-knowledge-transfer/01-overall-architecture.md:258) call an internal model runtime, external model endpoint, or both?
2. Does the GitHub Actions workflow deploy directly, or does it create PRs into another repo?
3. Is ArgoCD auto-sync enabled, manual-sync enabled, or approval-gated for production?
4. Which IBM toolchain component creates DR and CR automatically?
5. Which repo is the final source of truth for production model state?

These answers will make your understanding fully production-accurate.
