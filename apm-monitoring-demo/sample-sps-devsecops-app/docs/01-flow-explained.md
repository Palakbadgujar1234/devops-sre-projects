# 1. Beginner Flow: From Git Repo to IBM SPS Toolchain

## Goal

This document explains the full beginner flow in very simple language.

---

## 1. What is the app in this sample?

The app is the software you want to run.

In this sample, the app is:

- [`app.js`](sample-sps-devsecops-app/app.js)

It is a tiny Node.js server.

That means:

- developer writes code in [`app.js`](sample-sps-devsecops-app/app.js)
- project info is stored in [`package.json`](sample-sps-devsecops-app/package.json)
- tests are stored in [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js)

So when someone says "application repo", they usually mean the Git repository that stores these files.

---

## 2. What is infrastructure in this sample?

Infrastructure means the environment or resources needed to run the app.

In this sample, Terraform files are used only as a simple learning example:

- [`terraform/main.tf`](sample-sps-devsecops-app/terraform/main.tf)
- [`terraform/variables.tf`](sample-sps-devsecops-app/terraform/variables.tf)
- [`terraform/outputs.tf`](sample-sps-devsecops-app/terraform/outputs.tf)

In real life, Terraform may create:

- resource groups
- storage
- Kubernetes clusters
- secrets
- networking
- service instances

In this sample, Terraform just creates a local file so you can understand the structure safely.

---

## 3. What is Sonar in this sample?

Sonar checks code quality.

The config file is:

- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)

This tells Sonar:

- project name
- source path
- test path
- exclusions

So Sonar is not your app.
Sonar is a tool that checks your app code.

---

## 4. What is the CI/CD pipeline config in this sample?

The pipeline config file is:

- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)

This file tells IBM SPS / DevSecOps pipeline:

- what stages to run
- what scripts to run
- when to build
- when to test
- when to release

So this file is not the app itself.
It is the automation instruction file for the toolchain.

---

## 5. Full beginner flow

### Step 1: You create a Git repo

Example repo contents:

- app code
- tests
- Dockerfile
- Sonar config
- Terraform files
- pipeline config

### Step 2: You connect repo to IBM toolchain

In IBM Cloud toolchain:

- add your Git repo
- create PR pipeline
- create CI pipeline
- add secrets if needed

### Step 3: You push code to Git

When you push code or open PR:

- toolchain detects event
- pipeline starts

### Step 4: Pipeline fetches repo

IBM pipeline checks out the repo into workspace.

That is how it reads:

- [`app.js`](sample-sps-devsecops-app/app.js)
- [`package.json`](sample-sps-devsecops-app/package.json)
- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)
- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)

### Step 5: Code checks run

Pipeline may:

- install dependencies
- run static scan
- run Sonar
- run secret scan

### Step 6: Unit tests run

Pipeline runs:

- [`npm test`](sample-sps-devsecops-app/package.json:8)

That executes:

- [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js)

### Step 7: Docker image build runs

Pipeline reads:

- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)

Then it builds the container image.

### Step 8: Deployment stage runs

In this sample, deployment is only explained simply.

In real life, this stage may:

- deploy with Helm
- deploy with kubectl
- deploy to OpenShift
- deploy to Kubernetes

### Step 9: Release/inventory stage runs

Pipeline stores metadata about what was built and released.

This helps with:

- audit
- traceability
- compliance

---

## 6. Where Terraform fits

Terraform is usually separate from app code deployment.

Simple understanding:

- app code = what your software does
- Terraform = what infrastructure/resources are needed

In some teams:

- one pipeline handles app build/deploy
- another pipeline handles Terraform infra changes

In beginner learning, keep them in same repo first so you can understand both.

---

## 7. Where Sonar fits

Sonar usually runs in CI stage before deployment.

Flow:

1. code pushed
2. pipeline starts
3. Sonar scans code
4. if quality is bad, pipeline may fail
5. if quality is okay, pipeline continues

So Sonar is a quality gate.

---

## 8. Very simple real-world mapping

### App files

- [`app.js`](sample-sps-devsecops-app/app.js)
- [`package.json`](sample-sps-devsecops-app/package.json)

### Test files

- [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js)

### Build file

- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)

### Scan file

- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)

### Infra files

- [`terraform/main.tf`](sample-sps-devsecops-app/terraform/main.tf)
- [`terraform/variables.tf`](sample-sps-devsecops-app/terraform/variables.tf)
- [`terraform/outputs.tf`](sample-sps-devsecops-app/terraform/outputs.tf)

### Pipeline file

- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)

---

## 9. If you are totally new, remember this

- **App** = your software code
- **Terraform** = infrastructure code
- **Sonar** = code quality scanner
- **Dockerfile** = how to package app into container
- **Pipeline config** = instructions for CI/CD automation
- **Toolchain** = the full IBM setup that connects repo + pipeline + scans + release flow

---

## 10. What you should do next in real life

1. Create a Git repo for your sample app.
2. Add files like this sample.
3. Connect repo to IBM toolchain.
4. Add PR pipeline and CI pipeline.
5. Add Sonar integration or static scan stage.
6. Add Terraform validation stage if needed.
7. Push code and watch pipeline stages run.
8. Read logs stage by stage.

That is the easiest beginner path.
