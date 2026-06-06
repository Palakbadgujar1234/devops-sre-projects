# Sample SPS DevSecOps App for Beginners

This folder is a very simple learning project to help you understand:

- what an app is
- what source code is
- what Terraform is
- what Sonar scan is
- what IBM SPS / DevSecOps toolchain does
- how Git repo connects to CI/CD pipeline
- how a beginner can create a sample CI toolchain for an app

This is a **learning example**, not a production-ready enterprise setup.

---

## 1. What is inside this sample

This sample project will contain:

- a very small Node.js app
- a Dockerfile
- a simple test
- Sonar configuration
- Terraform example files
- IBM DevSecOps pipeline config
- beginner-friendly documentation

---

## 2. First understand the words

### What is an app?

An app is the actual software you want to run.

In this sample, the app is a tiny Node.js web server.

### What is source code?

Source code is the code written by developers.

Example:

- JavaScript files
- package.json
- test files

### What is CI/CD?

CI/CD is automation that:

- checks code
- runs tests
- scans for issues
- builds artifact/image
- deploys app

### What is Terraform?

Terraform is Infrastructure as Code.

It means instead of manually creating cloud resources, you write files that describe infrastructure.

### What is Sonar?

Sonar is a code quality and static analysis tool.

It checks:

- bugs
- code smells
- maintainability issues
- some security issues

### What is IBM SPS / DevSecOps toolchain?

It is IBM Cloud Continuous Delivery + DevSecOps pipeline setup that connects:

- Git repo
- pipeline
- scans
- build
- deploy
- compliance/evidence

---

## 3. Beginner mental model

Think of the full flow like this:

```text
You write app code
      |
      v
Push code to Git repo
      |
      v
IBM toolchain detects change
      |
      v
Pipeline runs checks and scans
      |
      v
Pipeline builds Docker image
      |
      v
Pipeline may deploy app
      |
      v
Pipeline stores evidence/results
```

---

## 4. Files that will be added in this sample

You will see files like:

- [`app.js`](sample-sps-devsecops-app/app.js)
- [`package.json`](sample-sps-devsecops-app/package.json)
- [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js)
- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)
- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)
- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)
- [`terraform/main.tf`](sample-sps-devsecops-app/terraform/main.tf)
- [`terraform/variables.tf`](sample-sps-devsecops-app/terraform/variables.tf)
- [`terraform/outputs.tf`](sample-sps-devsecops-app/terraform/outputs.tf)
- [`docs/01-flow-explained.md`](sample-sps-devsecops-app/docs/01-flow-explained.md)

---

## 5. What you will learn from this sample

After reading and using this sample, you should understand:

1. how a simple app is structured
2. how tests are added
3. how Sonar config is added
4. how Terraform files look
5. how IBM DevSecOps pipeline config looks
6. how Git push triggers pipeline
7. how pipeline reads repo files and runs stages

---

## 6. Important note

This sample is intentionally simple.

The goal is:

- easy to read
- easy to understand
- easy to explain in interview or KT
- easy for a beginner to connect app + infra + CI/CD together

It is not meant to copy your enterprise Bob setup exactly.
It is meant to teach the concepts in a simple way first.
