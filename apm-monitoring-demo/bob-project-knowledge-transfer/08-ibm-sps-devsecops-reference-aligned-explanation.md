# 8. IBM SPS / DevSecOps Reference-Aligned Explanation

## Purpose of this document

This document refines the earlier explanation by aligning it with the IBM Cloud DevSecOps documentation page for [`Understanding DevSecOps pipelines`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:5) and with the real pipeline file you shared: [`bob-dev-sample-app/.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:5).

This is useful because now we can explain your Bob toolchain in the same language IBM uses:

- reference pipelines
- Tekton-based pipeline support
- predefined pipeline structure
- custom scripts
- environment properties
- inventory release
- compliance and evidence flow

---

## 1. What IBM docs confirm

From the IBM docs page [`Understanding DevSecOps pipelines`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:16), the important idea visible on the page is:

> the reference CI/CD toolchains are based on Continuous Delivery support for Tekton Pipelines

and also:

> users do not need to be Tekton experts because reference pipelines are predefined and include placeholders for custom scripts for steps such as builds, automated tests, and deployment

This matches your pipeline file exactly.

### What that means in simple words

IBM SPS / DevSecOps gives you a **standard pipeline framework**.
Your team does not build every pipeline from scratch.

Instead:

- IBM provides a predefined pipeline structure
- your app repo plugs into that structure
- your app repo adds only app-specific config and scripts
- shared IBM pipeline logic does the heavy lifting

That is why the pipeline can feel "automatic".

---

## 2. How to understand your Bob toolchain using IBM's model

Using IBM's DevSecOps terminology, your setup likely has these layers:

### Layer 1: Toolchain

The IBM Cloud toolchain is the container that groups:

- repositories
- delivery pipelines
- secrets
- object storage
- DevOps Insights
- compliance integrations

### Layer 2: Reference pipelines

The toolchain contains pipelines like:

- [`pr-pipeline`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:42)
- [`ci-pipeline`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:43)

These are IBM-style reference pipelines.

### Layer 3: Pipeline config file

Your app repo contains [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:47).

This file customizes the reference pipeline for your application.

### Layer 4: Shared pipeline scripts

The YAML calls shared framework scripts through:

- [`${COMMONS_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:51)
- [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:52)

These are part of IBM's reusable DevSecOps framework.

### Layer 5: App-specific files

Your app repo contributes:

- [`Dockerfile`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:56)
- tests like [`test/test.js`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:57)
- scan config like [`.whitesource`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:58)
- [`sonar-project.properties`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:59)

So the full system is:

```text
IBM Toolchain
  -> IBM Reference Pipelines
    -> App pipeline config
      -> Shared IBM scripts
        -> App repo files
```

This is the correct mental model.

---

## 3. How the toolchain fetches repo changes in IBM SPS terms

Now let us explain your main question in IBM DevSecOps language.

### Step 1: Repository integration

The toolchain is connected to the application repository.

This means IBM Continuous Delivery knows:

- which repo to clone
- which credentials to use
- which branch or PR event triggered the run

### Step 2: Pipeline trigger

A pipeline starts because of:

- PR event
- merge/push event
- manual run
- release action

This is why you have both [`pr-pipeline`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:82) and [`ci-pipeline`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:82).

### Step 3: Repo checkout into workspace

The pipeline framework checks out the repo into the workspace and exposes it through a repo key such as [`app-repo`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:86).

Your YAML proves this because it uses:

- [`load_repo app-repo path`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:88)
- [`load_repo app-repo url`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:89)

So the repo is fetched before your custom steps run.

### Step 4: Reference pipeline executes predefined stages

IBM reference pipeline then runs standard stages such as:

- code checks
- build
- deploy checks
- release

### Step 5: Custom scripts and app files are used inside those stages

The pipeline enters the checked-out repo and runs app-specific logic.

That is why your YAML repeatedly does:

```bash
cd "$WORKSPACE/$(load_repo app-repo path)"
```

So the answer is:

> IBM toolchain fetches repo changes by checking out the connected repository into the Tekton/Continuous Delivery workspace, then the reference pipeline executes predefined stages and uses your app config file plus shared IBM scripts to process that checked-out content.

---

## 4. Why IBM calls these "reference pipelines"

The docs page says the pipelines are predefined and include placeholders for custom scripts.

That means:

- IBM already defines the stage structure
- IBM already defines common security/compliance/build/deploy behavior
- your team only customizes selected steps

This is exactly what your YAML shows.

For example:

- [`code-checks`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:113)
- [`code-build`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:114)
- [`deploy-checks`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:115)
- [`deploy-release`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:116)

These are standard pipeline phases.
Inside them, your app config chooses:

- which scripts to run
- which files to use
- which deployment mode to use

So [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:120) is not the whole pipeline engine.
It is the app-specific customization layer for IBM's reference pipeline.

---

## 5. Where the configuration really lives

This is the most important clarification.

### Part A: IBM toolchain UI configuration

Stored in IBM Cloud:

- repo integrations
- triggers
- secrets
- environment properties
- pipeline namespace
- cluster target settings

### Part B: App pipeline config

Stored in your app repo:

- [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:132)

This tells the reference pipeline which tasks and steps to run.

### Part C: Shared IBM framework logic

Referenced through:

- [`${COMMONS_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:136)
- [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:137)

This is where the reusable implementation lives.

### Part D: App repo implementation files

Stored in your app repo:

- [`Dockerfile`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:141)
- tests
- scan config
- deployment files
- Helm chart if used

### Part E: Inventory/compliance repos

Stored in connected repos like:

- [`bob-dev-inventory`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:146)
- [`compliance-pipelines`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:147)

These support release metadata, compliance, and reusable pipeline behavior.

So there is **not one single config file**.
The behavior is distributed across these layers.

---

## 6. Why only app name may be enough

IBM reference pipelines are designed to reduce repeated manual input.

If your team says:
> just enter app name and done

that usually means the rest is already standardized through:

- toolchain properties
- repo integration
- environment defaults
- shared scripts
- naming conventions
- inventory mapping

In your YAML, [`app-name`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:161) is used especially in Helm deployment mode to derive:

- Helm release name
- environment-specific deployment naming

So app name acts like a lookup key.

Once the pipeline knows:

- repo = [`app-repo`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:166)
- deployment type = helm or kubectl
- target environment
- cluster namespace
- chart path or deployment file path

then [`app-name`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:171) is enough to complete the app-specific part.

This is exactly how IBM reference pipelines are supposed to simplify onboarding.

---

## 7. Mapping your YAML to IBM DevSecOps concepts

Here is the clean mapping.

### IBM concept: predefined reference pipeline stages

Your YAML:

- [`code-checks`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:179)
- [`code-build`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:180)
- [`deploy-checks`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:181)
- [`deploy-release`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:182)

### IBM concept: placeholders for custom scripts

Your YAML:

- custom [`script:`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:185) blocks
- [`source $WORKSPACE/$PIPELINE_CONFIG_REPO_PATH/scripts/run_test.sh`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:186)

### IBM concept: build, automated tests, deployment

Your YAML:

- [`npm ci`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:189)
- [`run_unit_test`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:190)
- [`docker.sh`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:191)
- [`helm.sh`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:192)
- [`kubectl.sh`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:193)

### IBM concept: environment properties

Your YAML:

- [`get_env pipeline_namespace`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:196)
- [`get_env deployment-type`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:197)
- [`get_env target-environment`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:198)
- [`get_env app-name`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:199)
- [`get_env app-url`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:200)

### IBM concept: release/inventory

Your YAML:

- [`${COMMONS_PATH}/release/release.sh`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:203)

This is a very strong match with IBM docs.

---

## 8. End-to-end IBM SPS style explanation

Here is the full explanation in IBM-style language.

### PR stage

1. A PR event triggers the reference PR pipeline.
2. IBM Continuous Delivery checks out the connected repo into workspace.
3. The pipeline reads [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:211).
4. The reference pipeline runs predefined stages like [`code-checks`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:212).
5. Shared scripts perform:
   - branch protection setup
   - dependency install
   - secret detection
   - compliance checks
   - static scanning
6. Results become PR evidence for review.

### CI stage

1. Merge or CI trigger starts the reference CI pipeline.
2. Repo is checked out again.
3. [`code-build`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:221) runs:
   - setup
   - unit tests
   - Docker build
4. [`deploy-checks`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:225) runs:
   - deploy
   - dynamic scan
   - acceptance test
5. [`deploy-release`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:229) updates release/inventory metadata.
6. Compliance evidence and release traceability are preserved.

This is exactly what IBM means by a predefined DevSecOps pipeline with customizable steps.

---

## 9. Where SPS/compliance behavior appears in your setup

Your toolchain screenshot showed:

- [`compliance-evidence-locker`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:236)
- [`compliance-pipelines`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:237)
- [`Cloud Object Storage`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:238)
- [`DevOps Insights`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:239)

This strongly supports the IBM SPS / DevSecOps model:

- evidence is collected
- compliance checks are standardized
- release metadata is tracked
- pipeline behavior is reusable across apps

So your Bob toolchain is not just CI/CD.
It is a compliance-aware DevSecOps reference pipeline setup.

---

## 10. Final direct answer

### How does the toolchain fetch changes?

IBM Continuous Delivery checks out the connected repository into the pipeline workspace and exposes it through repo helpers like [`load_repo`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:249). Then the reference pipeline stages process that checked-out repo.

### Where is the config?

The main app-level config is [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:252), but the full behavior is split across:

- IBM toolchain UI properties
- shared framework scripts under [`${COMMONS_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:254)
- shared tools under [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:255)
- app repo files like [`Dockerfile`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:256)
- inventory/compliance repos

### Why is app name enough?

Because IBM reference pipelines are standardized. Once repo, environment, deployment mode, and shared scripts are already configured, [`app-name`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:260) is enough as the app-specific key for naming and deployment behavior.

---

## 11. Best next validation steps

To make your Bob understanding fully accurate, inspect these next in your real environment:

1. IBM toolchain pipeline properties for:
   - [`app-name`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:267)
   - [`deployment-type`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:268)
   - [`target-environment`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:269)
   - [`cluster-namespace`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:270)

2. Shared scripts referenced through:
   - [`${COMMONS_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:273)
   - [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:274)

3. Inventory and compliance repos:
   - [`bob-dev-inventory`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:277)
   - [`compliance-pipelines`](bob-project-knowledge-transfer/08-ibm-sps-devsecops-reference-aligned-explanation.md:278)

These will show you the remaining hidden part of the pipeline behavior.
