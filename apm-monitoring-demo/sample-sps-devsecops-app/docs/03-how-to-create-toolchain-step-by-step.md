# 3. How to Create a Sample IBM Toolchain Step by Step

## Goal

This guide explains how you can try this in your own IBM Cloud account in a simple beginner-friendly way.

You shared a screenshot showing the Toolchains page and the [`Create toolchain`](sample-sps-devsecops-app/docs/03-how-to-create-toolchain-step-by-step.md:6) button. This guide tells you what to do next.

---

## 1. Before creating the toolchain

You need these things first:

1. A Git repository with your sample app files
2. Access to IBM Cloud toolchains
3. A basic understanding that:
   - app repo stores code
   - toolchain connects to repo
   - pipeline runs automation on repo

If you do not yet have a Git repo, first create one and upload the sample folder:

- [`sample-sps-devsecops-app`](sample-sps-devsecops-app/README.md)

---

## 2. What you should upload to Git first

Your Git repo should contain files like:

- [`app.js`](sample-sps-devsecops-app/app.js)
- [`package.json`](sample-sps-devsecops-app/package.json)
- [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js)
- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)
- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)
- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)
- [`terraform/main.tf`](sample-sps-devsecops-app/terraform/main.tf)
- [`terraform/variables.tf`](sample-sps-devsecops-app/terraform/variables.tf)
- [`terraform/outputs.tf`](sample-sps-devsecops-app/terraform/outputs.tf)

Simple meaning:
first put your project in Git, then connect Git to toolchain.

---

## 3. Beginner understanding of what happens next

When you create a toolchain, you are not creating the app.

You are creating the automation system around the app.

### App

Your code and files in Git repo

### Toolchain

The IBM Cloud setup that connects:

- repo
- pipeline
- scans
- secrets
- release flow

### Pipeline

The step-by-step automation inside the toolchain

---

## 4. Step-by-step toolchain creation

### Step 1: Open Toolchains page

You are already on the Toolchains page in IBM Cloud.

### Step 2: Click [`Create toolchain`](sample-sps-devsecops-app/docs/03-how-to-create-toolchain-step-by-step.md:54)

This starts the toolchain creation flow.

### Step 3: Choose a DevSecOps / Continuous Delivery template

Look for a template related to:

- DevSecOps
- Continuous Delivery
- CI/CD
- toolchain with Git + pipeline

If IBM shows multiple templates, choose the simplest one that supports:

- Git repo integration
- delivery pipeline

### Step 4: Connect your Git repository

During setup, IBM will ask for repository details.

You will provide:

- repo URL
- branch
- authentication if needed

This is how toolchain knows where your app code lives.

### Step 5: Name the toolchain

Example:

- `sample-sps-devsecops-toolchain`

### Step 6: Select resource group and region

Choose your account resource group and region.

### Step 7: Create the toolchain

IBM creates the toolchain and opens its dashboard.

---

## 5. What to add inside the toolchain

After toolchain is created, you usually need these components.

### A. Git repository integration

This points to your app repo.

### B. PR pipeline

Used for pull request validation.

### C. CI pipeline

Used for merge/main branch build and release flow.

### D. Optional integrations

Depending on your setup:

- Sonar
- Secrets Manager
- Object Storage
- DevOps Insights

For beginner learning, start with:

- repo
- PR pipeline
- CI pipeline

---

## 6. How pipeline uses your repo files

Once repo is connected, pipeline can read files like:

- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)
- [`package.json`](sample-sps-devsecops-app/package.json)
- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)
- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)

That means:

- pipeline knows how to run tests
- pipeline knows how to build image
- pipeline knows how Sonar should scan
- pipeline knows what stages to run

---

## 7. Where Sonar fits when you create toolchain

There are two simple possibilities.

### Option 1: IBM static scan only

You use IBM built-in static/compliance scanning from pipeline.

This is easiest for beginners.

### Option 2: Add Sonar integration

You configure Sonar server/project/token and let pipeline run Sonar scan using:

- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)

If you are new, start with IBM static scan first, then add Sonar later.

---

## 8. Where Terraform fits when you create toolchain

Terraform is usually handled in one of these ways:

### Option 1: Same repo, separate stage

Your app repo contains Terraform folder and pipeline has a Terraform validation/apply stage.

### Option 2: Separate infra repo

App code repo and Terraform repo are separate.

For beginner learning, keep Terraform in same repo first.

Then later you can split:

- app repo
- infra repo

---

## 9. Suggested beginner pipeline flow

Use this simple flow first:

### PR pipeline

1. checkout repo
2. install dependencies
3. run tests
4. run static scan
5. optional Sonar scan

### CI pipeline

1. checkout repo
2. run tests
3. build Docker image
4. optional Terraform validate
5. optional deploy
6. release metadata

This is enough to understand the basics.

---

## 10. What you should click/configure in simple words

When creating the toolchain, think like this:

### Repo section

"Where is my code?"
Answer:
your Git repo URL

### Pipeline section

"What automation should run?"
Answer:
PR pipeline and CI pipeline

### Environment variables / properties

"What values does pipeline need?"
Examples:

- app name
- branch
- environment
- namespace

### Secrets

"What sensitive values should not be hardcoded?"
Examples:

- Git token
- Sonar token
- registry credentials

---

## 11. Beginner practice plan

Here is the easiest way to practice safely.

### Practice 1

Create Git repo and upload:

- [`sample-sps-devsecops-app`](sample-sps-devsecops-app/README.md)

### Practice 2

Create toolchain and connect repo.

### Practice 3

Create a simple PR pipeline.

### Practice 4

Push a small change in [`app.js`](sample-sps-devsecops-app/app.js).

### Practice 5

Watch pipeline logs:

- dependency install
- test run
- scan run

### Practice 6

Create CI pipeline and run build.

### Practice 7

Later add Sonar token/config.

### Practice 8

Later add Terraform validation stage.

This is the best beginner order.

---

## 12. What not to do at the beginning

Do not try all advanced things at once.

Avoid starting with:

- production deployment
- many environments
- complex Helm charts
- many secrets
- many repos
- advanced compliance gates

Start with:

- one repo
- one app
- one test
- one Dockerfile
- one simple pipeline

---

## 13. Very simple summary

If you are new, remember this:

1. Create app files in Git repo.
2. Create IBM toolchain.
3. Connect repo to toolchain.
4. Add PR and CI pipelines.
5. Let pipeline read [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml).
6. Run tests, scans, and Docker build.
7. Later add Sonar and Terraform stages.

That is the easiest beginner path.

---

## 14. Best next step for you

Since you already opened the Toolchains page, your next real action is:

1. create a Git repo for this sample
2. upload the sample files
3. click [`Create toolchain`](sample-sps-devsecops-app/docs/03-how-to-create-toolchain-step-by-step.md:211)
4. connect the repo
5. create a simple pipeline
6. run it once and read logs slowly

That will teach you much faster than only reading theory.
