# 3. Bob Inference Model Deployment Flow

## Purpose of this document

This document explains how AI inference model deployment likely works in the Bob ecosystem based on the GitHub repository and workflow screenshots you shared.

This is especially important because model deployment is usually different from normal microservice deployment.

---

## 1. Why model deployment is different from microservice deployment

A normal microservice deployment usually means:

- build application image
- update image tag
- deploy container
- expose service

But model deployment often includes extra concerns:

- model artifact versioning
- model source validation
- environment-specific model selection
- approval before production rollout
- deployment metadata tracking
- compatibility with inference runtime
- rollback to previous model version
- audit trail for AI governance

That is why many organizations separate:

- **application deployment**
- **model deployment**

Your screenshots strongly suggest Bob follows this pattern.

---

## 2. What we observed from the screenshot

From the repository screenshot for [`cme3-devops-mlops`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:28), we can directly observe:

- a GitHub workflow file named [`.github/workflows/model-deployment-json.yml`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:30)
- folders like [`configs`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:31), [`configuration`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:31), [`docs`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:31), [`scripts`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:31), [`tekton`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:31)
- a path [`k8s/manifests/deployed-state`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:32)
- the workflow appears to accept a JSON input called [`config_json`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:33)
- the workflow has a validation/parsing job
- the workflow exposes outputs like environment, model source, and deployment type

This is enough to infer a fairly strong deployment pattern.

---

## 3. Likely model deployment architecture

A simple mental model is:

```text
User / DevOps / ML engineer
        |
        v
GitHub Actions workflow trigger
        |
        v
Validate deployment JSON/config
        |
        v
Determine model source + environment + deployment type
        |
        v
Run deployment logic / scripts / manifests
        |
        +--> update deployed-state
        +--> create PR if needed
        +--> deploy to target runtime
        |
        v
Inference service starts using new model
```

---

## 4. What the workflow name tells us

The file name [`model-deployment-json.yml`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:56) is very informative.

It suggests:

- deployment is driven by structured JSON input
- the workflow may be reusable for multiple models/environments
- the deployment request is probably parameterized rather than hardcoded

This is common in enterprise MLOps because one workflow can support:

- multiple environments
- multiple model types
- multiple deployment modes
- multiple source registries or artifact stores

---

## 5. What the JSON input probably contains

The screenshot shows an input named [`config_json`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:68).

Although we do not have the full file content, such JSON usually contains fields like:

- environment
- inference name
- model name
- model version
- model source
- deployment type
- target cluster or region
- resource sizing
- approval metadata
- optional rollout strategy

Example conceptual input:

```json
{
  "ENV": "prod",
  "INFERENCE_NAME": "bob-inference",
  "MODEL_NAME": "foundation-model-x",
  "MODEL_VERSION": "1.2.3",
  "MODEL_SOURCE": "registry-or-artifact-store",
  "DEPLOYMENT_TYPE": "update"
}
```

This is only an example, but it matches the workflow pattern visible in your screenshot.

---

## 6. Why JSON-driven deployment is useful

JSON-driven deployment helps because it makes the workflow:

- reusable
- standardized
- easier to validate
- easier to audit
- easier to integrate with other tools

For example, another system could generate the JSON automatically from:

- release tooling
- approval systems
- internal portals
- IBM toolchain steps
- model registry events

So the workflow becomes a controlled deployment engine.

---

## 7. Likely stages in the model deployment workflow

Based on the screenshot, the workflow likely has stages like these.

### Stage 1: Trigger

The screenshot shows [`workflow_dispatch`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:102), which means the workflow can be manually triggered from GitHub Actions UI.

This usually means an engineer can start deployment by providing JSON input.

Possible trigger sources:

- manual run by DevOps engineer
- manual run by ML engineer
- another workflow calling this workflow
- automation from release tooling

---

### Stage 2: Validate and parse config

The screenshot clearly shows a validation/parsing job.

This is very important because model deployment is sensitive.

Validation likely checks:

- required fields exist
- environment is valid
- model source is valid
- deployment type is allowed
- naming format is correct
- target config is consistent

If validation fails, deployment should stop early.

---

### Stage 3: Determine deployment path

The workflow outputs shown in the screenshot include:

- config
- env
- model_source
- deployment_type

This means the workflow probably branches based on those values.

For example:

- if model source is internal registry, use one path
- if model source is external artifact store, use another path
- if deployment type is create, do full setup
- if deployment type is update, do rolling update
- if environment is prod, require stricter approvals

---

### Stage 4: Execute deployment logic

The repo contains folders like [`scripts`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:132), [`tekton`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:132), and [`k8s/manifests/deployed-state`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:132).

That suggests deployment may involve one or more of these actions:

- generate manifests
- update deployment state files
- call shell/python scripts
- trigger Tekton tasks
- update Kubernetes/OpenShift resources
- create or update PRs in another repo

This is where the actual rollout happens.

---

## 8. What "deployed-state" probably means

The path [`k8s/manifests/deployed-state`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:145) is very meaningful.

It likely stores the currently deployed model state or desired deployed state.

Possible uses:

- record which model version is deployed in each environment
- provide auditability
- support rollback
- feed ArgoCD or another reconciler
- separate requested state from actual deployed state

This is a common pattern in MLOps:

- deployment pipeline updates a state file
- another system reconciles that state into the cluster

---

## 9. Relationship between model deployment and Bob inference service

This is a key concept.

The Bob inference service and the AI model are related, but they are not always the same thing.

### Bob inference service

Usually a deployed application/service that:

- exposes an API
- receives inference requests
- handles auth/routing/formatting
- talks to model runtime

### Model deployment

Usually the process of:

- registering or selecting a model artifact
- deploying the model into a serving runtime
- updating runtime config to use that model
- making the model available to the inference service

So one possible architecture is:

```text
bob-inference microservice
        |
        v
model serving runtime / endpoint
        |
        v
specific deployed model version
```

This means:

- the inference service may be deployed through ArgoCD
- the model itself may be deployed through GitHub Actions workflow

That is why both deployment systems can exist together.

---

## 10. Typical end-to-end model deployment flow

Here is the likely flow.

### Step 1: New model or model version is ready

This may come from:

- ML team
- model engineering team
- AI platform team
- vendor/model provider update

Examples:

- new model version
- optimized model
- region-specific model
- rollback to previous model

---

### Step 2: Deployment request is prepared

An engineer prepares deployment input, likely in JSON form.

This input probably defines:

- target environment
- model source
- model version
- deployment type
- inference target name

---

### Step 3: GitHub Actions workflow is triggered

The workflow [`model-deployment-json.yml`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:188) is triggered manually or by automation.

This starts the deployment pipeline.

---

### Step 4: Validation happens

The workflow validates the JSON and extracts key values.

If invalid:

- workflow fails
- no deployment happens

This protects production from malformed requests.

---

### Step 5: Deployment logic runs

Depending on the workflow design, it may:

- fetch model artifact
- update deployment manifests
- update deployed-state files
- call Tekton pipeline
- create PR into deployment repo
- deploy directly to serving infrastructure

This is the part you should validate internally because it is the most implementation-specific.

---

### Step 6: Serving runtime or config is updated

The target environment is updated so that the inference layer can use the new model.

This may involve:

- new model endpoint
- updated runtime config
- new deployment object
- changed traffic routing
- changed model alias

---

### Step 7: Verification happens

Teams usually verify:

- model loaded successfully
- inference endpoint is healthy
- latency is acceptable
- error rate is normal
- expected model version is active
- no regression in downstream services

---

## 11. Example scenario: deploying a new model version

### Situation

A new model version `v2.1` is approved for production.

### Likely steps

1. ML/DevOps engineer prepares deployment JSON.
2. Workflow is triggered in GitHub Actions.
3. Workflow validates environment and model source.
4. Workflow updates deployment state or manifests.
5. Deployment logic rolls out the model.
6. Bob inference service starts serving requests through the new model.
7. Monitoring and smoke tests confirm success.

---

## 12. Example scenario: rollback to previous model

Rollback is especially important in AI systems because a model can be technically healthy but functionally worse.

### Situation

New model version causes poor output quality.

### Likely steps

1. Engineer triggers workflow with previous approved model version.
2. Workflow validates rollback request.
3. Deployment state is updated back to old version.
4. Serving runtime switches back.
5. Inference quality is revalidated.

This is why deployment state tracking is important.

---

## 13. Why GitHub Actions may be preferred here

GitHub Actions is a good fit for model deployment when teams need:

- parameterized workflows
- approval gates
- reusable automation
- integration with GitHub PRs/issues
- audit trail of who triggered deployment
- environment-specific logic
- easy manual dispatch for controlled releases

It is especially useful when deployment is not just "apply YAML", but a multi-step orchestration process.

---

## 14. Where Tekton may fit

The repo also contains a [`tekton`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:274) folder.

This suggests one of these possibilities:

1. GitHub Actions triggers Tekton
2. Tekton is used for some internal cluster-side pipeline steps
3. GitHub Actions and Tekton coexist for different deployment paths
4. Tekton is legacy or supplemental automation

This is common in enterprise environments where:

- GitHub handles source/review/workflow orchestration
- Tekton handles cluster-native pipeline execution

---

## 15. How this differs from Bob microservice deployment

### Microservice deployment

Usually:

- update GitOps config
- merge PR
- ArgoCD syncs cluster

### Model deployment

Usually:

- trigger workflow with structured input
- validate deployment request
- run deployment logic
- update state/manifests/runtime
- verify model serving behavior

So the model flow is often more procedural and pipeline-driven.

---

## 16. Beginner summary

If you are new, remember this simple version:

- Bob microservices are likely deployed through ArgoCD GitOps.
- AI models are likely deployed through a GitHub Actions workflow.
- The workflow takes JSON input, validates it, and performs model rollout logic.
- The inference service then uses the deployed model.
- This separation exists because model deployment has extra governance and operational complexity.

---

## 17. What to validate with your team

Ask these exact questions internally:

1. Does [`model-deployment-json.yml`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:309) deploy models directly or only update state/config?
2. What exactly is stored in [`k8s/manifests/deployed-state`](bob-project-knowledge-transfer/03-inference-model-deployment-flow.md:310)?
3. Is GitHub Actions the main deployment engine, or does it trigger Tekton/IBM toolchain?
4. Where are model artifacts stored?
5. How is model approval handled before production deployment?
6. How is rollback performed for a bad model?
7. Does the Bob inference service dynamically pick model versions, or is it statically configured?

Once you know these answers, your understanding of Bob model deployment will be much stronger.
