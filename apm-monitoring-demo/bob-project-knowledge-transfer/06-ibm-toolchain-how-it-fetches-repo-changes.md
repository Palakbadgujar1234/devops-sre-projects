# 6. How IBM Toolchain Fetches Repo Changes End to End

## Purpose of this document

This document explains, in beginner-friendly language, how the IBM Cloud DevOps toolchain likely fetches changes from repositories, how it knows what to run, where the configuration usually lives, and why sometimes you only need to enter an application name.

This explanation is based on:

- your IBM Cloud toolchain screenshot
- the repository links you shared earlier
- common IBM toolchain and enterprise CI/CD patterns

Because I do not have direct access to the actual toolchain configuration files, I will clearly separate:

- **Observed**
- **Inferred**
- **What you should verify**

---

## 1. What we can directly observe from your screenshot

From the IBM Cloud screenshot, we can directly see a toolchain named [`ci-toolchain-bob-prod`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:18).

Inside it, we can see these sections:

### Repositories

There are 5 repositories connected:

- [`bob-dev-inventory`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:24)
- [`bob-dev-issues`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:25)
- [`bob-dev-sample-app`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:26)
- [`compliance-evidence-locker`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:27)
- [`compliance-pipelines`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:28)

### Delivery pipelines

There are 2 pipelines:

- [`ci-pipeline`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:32)
- [`pr-pipeline`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:33)

### IBM Cloud tools

There are 3 tools:

- [`Cloud Object Storage`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:37)
- [`DevOps Insights`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:38)
- [`sm-compliance-secrets`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:39)

This already tells us something important:

> The toolchain is not a single YAML file only. It is a connected system made of repo integrations, pipelines, storage, secrets, and compliance tools.

---

## 2. Simple answer to your question

You asked:

> how toolchain is fetching all changes from repo end to end, where is the config file, and in that we just need to enter app name and done?

The simple answer is:

### The toolchain usually fetches repo changes in 3 layers

1. **Toolchain connection layer**  
   IBM toolchain is connected to one or more Git repositories.

2. **Pipeline trigger/config layer**  
   A pipeline inside the toolchain is configured to watch a branch, PR event, or manual input.

3. **Pipeline script/template layer**  
   The pipeline runs scripts or templates that read repo files and perform actions based on parameters like app name.

So when you enter only an app name, that usually means:

- the rest of the logic is already standardized in pipeline templates/scripts
- the pipeline knows where to look based on naming conventions
- the app name is used as a key to fetch the correct config path

---

## 3. End-to-end mental model

Think of it like this:

```text
Git repository connected to IBM toolchain
        |
        v
A commit / PR / manual run happens
        |
        v
IBM pipeline trigger starts
        |
        v
Pipeline reads its configuration
        |
        v
Pipeline scripts fetch repo content
        |
        v
Scripts locate app-specific config using app name
        |
        v
Pipeline performs validation / build / deploy / CR-DR creation
        |
        v
Deployment or PR/update happens
```

This is the full chain in simple words.

---

## 4. What "connected repository" means in IBM toolchain

When a repository is added to the toolchain, IBM Cloud stores integration metadata such as:

- repository URL
- branch or default branch
- authentication/token
- webhook or polling integration
- which pipeline uses that repo

So the toolchain does **not** magically scan all GitHub repos.

It only knows about repos that are explicitly connected.

From your screenshot, those 5 repos are connected to the toolchain.

That means the toolchain can:

- clone them
- read files from them
- trigger pipelines from them
- use them as inputs to compliance or deployment steps

---

## 5. How changes are usually detected

There are usually 3 common ways a toolchain detects changes.

### Method 1: Webhook trigger

GitHub/GitHub Enterprise sends an event when:

- code is pushed
- PR is opened
- PR is updated
- PR is merged

This is the most common method.

### Method 2: Branch-based pipeline trigger

The pipeline is configured to run when changes happen on:

- [`main`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:88)
- release branch
- PR branch

### Method 3: Manual trigger with parameters

A user clicks "Run pipeline" and enters values like:

- app name
- environment
- branch
- version

This is likely the case when you say:
> we just need to enter app name and done

That means the pipeline is probably parameterized.

---

## 6. Why there are two pipelines: CI and PR

From your screenshot:

- [`ci-pipeline`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:99)
- [`pr-pipeline`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:100)

This is a very common enterprise setup.

### PR pipeline

Usually runs before merge.

Purpose:

- validate PR changes
- run checks
- maybe create preview evidence
- maybe create compliance records
- block bad changes from merging

Typical triggers:

- PR opened
- PR updated
- PR reopened

### CI pipeline

Usually runs after merge or on main branch.

Purpose:

- process accepted changes
- build/deploy/promote
- create official evidence
- trigger downstream deployment or governance steps

Typical triggers:

- merge to main
- push to protected branch
- manual release run

So the toolchain may fetch changes differently depending on whether the change is:

- still in PR stage
- already merged

---

## 7. Where the actual configuration usually lives

This is the most important part of your question.

There is usually **not just one config file**.
Instead, configuration is often split across multiple places.

### Place 1: Toolchain UI configuration

Some settings are stored in IBM Cloud toolchain itself:

- connected repos
- pipeline definitions
- environment properties
- integrations with secrets/storage/compliance tools

This config is often visible in the IBM Cloud UI, not always in your app repo.

### Place 2: Pipeline definition files

The pipeline may use files stored in a repo, such as:

- pipeline YAML
- Tekton definitions
- shell scripts
- JSON config templates
- app inventory files

### Place 3: Shared pipeline template repo

In enterprise setups, the actual logic often lives in a shared repo like [`compliance-pipelines`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:133).

This is very important.

It means your app repo may contain only minimal metadata, while the real pipeline behavior comes from a central reusable pipeline framework.

### Place 4: Inventory/config repo

A repo like [`bob-dev-inventory`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:137) often stores app metadata such as:

- app name
- repo mapping
- deployment type
- environment mapping
- compliance classification
- pipeline parameters

This is often why entering only app name is enough.

Because the pipeline can do:

- look up app name in inventory
- fetch all related metadata
- decide what repo/path/template to use

---

## 8. Why only app name may be enough

This is likely the key thing confusing you.

If the pipeline asks only for app name, then one of these patterns is probably used.

### Pattern A: Inventory-driven pipeline

There is a central inventory file or repo.

Example concept:

```yaml
applications:
  bob-backend:
    repo: github.ibm.com/org/bob-backend
    deploy_repo: github.ibm.com/org/wxca-argocd-deployments
    environment: prod
    pipeline_template: standard-argocd-service
```

Then the pipeline logic is:

1. read app name
2. search inventory
3. fetch matching metadata
4. run standard deployment logic

### Pattern B: Naming convention-driven pipeline

The pipeline assumes standard paths.

Example logic:

- app name = [`bob-backend`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:161)
- deployment path = `bob/resources/prod/washington/bob-backend`
- secret path = `config/external-secrets/prod/bob-backend`

So app name becomes the key to derive all paths.

### Pattern C: Template-driven pipeline

The pipeline uses a shared template where only app-specific variables are needed.

Example:

- app name
- environment
- version

Everything else is inherited from standard templates.

This is very common in platform engineering.

---

## 9. How the pipeline probably fetches repo content internally

Once triggered, the pipeline usually does something like this:

### Step 1: Clone repo

The pipeline checks out the connected repository.

Equivalent conceptually to:

```bash
git clone <repo-url>
git checkout <branch>
```

### Step 2: Read pipeline variables

It reads:

- app name
- branch
- environment
- repo URL
- pipeline properties
- secrets

### Step 3: Read inventory/config files

It may open files like:

- app inventory YAML/JSON
- deployment config
- manifest templates
- compliance config
- environment mapping

### Step 4: Decide what changed

Depending on pipeline type, it may:

- compare PR branch vs target branch
- inspect changed files
- filter by app path
- determine impacted application

### Step 5: Run app-specific logic

Using app name, it may:

- locate deployment folder
- locate Helm values
- locate ArgoCD app definition
- locate compliance metadata
- locate secret references

### Step 6: Trigger downstream actions

Examples:

- create PR
- update deployment repo
- create CR/DR
- store evidence in object storage
- send results to DevOps Insights
- trigger ArgoCD or another deployment system

---

## 10. How "fetch all changes from repo" usually works

This phrase can mean two different things.

### Meaning 1: Fetch latest Git content

The pipeline clones the latest branch content from the repo.

This is basic Git checkout behavior.

### Meaning 2: Detect what changed in this PR/commit

The pipeline compares:

- source branch vs target branch
or
- previous commit vs current commit

Then it identifies changed files.

Example:

- only [`bob/application/prod`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:211) changed
- only [`environment-config.yaml`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:212) changed
- only one app folder changed

Then the pipeline decides what action to take.

So "fetching all changes" usually means:

- clone repo
- inspect diff
- map changed files to app/service/environment

---

## 11. Where compliance tools fit in

Your screenshot shows:

- [`compliance-evidence-locker`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:221)
- [`compliance-pipelines`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:222)
- [`Cloud Object Storage`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:223)
- [`DevOps Insights`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:224)

This strongly suggests the toolchain is not only deploying.
It is also collecting governance evidence.

Likely flow:

- pipeline runs checks
- results/evidence are stored in object storage
- compliance pipeline evaluates controls
- DevOps Insights records quality/compliance status
- DR/CR or audit records may be generated

So the toolchain may fetch repo changes not only for deployment, but also for compliance validation.

---

## 12. Most likely places you should inspect to find "the config"

If you want the exact place where "just app name" is configured, check these in order.

### First place to inspect

The IBM toolchain pipeline configuration in the UI:

- pipeline properties
- trigger settings
- environment variables
- parameters
- integrations

Look for fields like:

- `APP_NAME`
- `APPLICATION_NAME`
- `REPO_URL`
- `INVENTORY_FILE`
- `PIPELINE_TEMPLATE`
- `ENV`
- `TARGET_BRANCH`

### Second place to inspect

The connected repo [`bob-dev-inventory`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:246)

This repo name strongly suggests it may contain app metadata or inventory mapping.

This is my strongest guess for where app-name-based lookup happens.

### Third place to inspect

The connected repo [`compliance-pipelines`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:251)

This repo likely contains reusable pipeline logic and templates.

If the toolchain is standardized, the real logic may be here.

### Fourth place to inspect

The pipeline definition itself inside IBM Cloud UI:

- stages
- jobs
- scripts
- Tekton tasks
- referenced YAML

### Fifth place to inspect

Any repo files named like:

- `pipeline.yaml`
- `toolchain.yml`
- `values.yaml`
- `inventory.yaml`
- `applications.yaml`
- `config.json`
- `manifest.yaml`

---

## 13. Very likely real-world flow in your setup

Based on your screenshot, this is the most likely end-to-end flow:

```text
1. Repo is connected to IBM toolchain
2. PR or merge happens in GitHub Enterprise
3. Webhook triggers pr-pipeline or ci-pipeline
4. Pipeline reads parameters and secrets
5. Pipeline checks inventory/config using app name
6. Pipeline fetches changed files or app metadata
7. Pipeline runs standard compliance/deployment logic
8. Evidence is stored in object storage
9. DevOps Insights/compliance pipeline records results
10. DR/CR records may be created automatically
11. Deployment repo or target environment is updated
```

This is probably very close to what your team is doing.

---

## 14. Beginner-friendly explanation you can use

If someone asks you this in KT or interview, say:

> IBM toolchain does not manually read every repo by itself. Repositories are first connected to the toolchain. Then a pipeline such as PR pipeline or CI pipeline is triggered by webhook, merge, or manual run. That pipeline checks out the repo, reads pipeline parameters and shared templates, and then uses app metadata or inventory mapping to identify which application configuration to process. If only app name is required, it usually means the rest of the deployment logic is standardized in inventory files or shared pipeline templates. The toolchain then runs validation, compliance, evidence collection, and deployment-related actions based on that mapping.

That is a strong answer.

---

## 15. What you should verify in your actual environment

To make this 100 percent accurate, verify these exact things:

1. In [`ci-pipeline`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:286), what are the input parameters?
2. In [`pr-pipeline`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:287), what event triggers it?
3. Does [`bob-dev-inventory`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:288) contain app-to-repo mapping?
4. Does [`compliance-pipelines`](bob-project-knowledge-transfer/06-ibm-toolchain-how-it-fetches-repo-changes.md:289) contain shared pipeline scripts/templates?
5. Which stage creates DR/CR automatically?
6. Is app name mapped to ArgoCD path, deployment repo path, or both?
7. Does the pipeline inspect Git diff, or does it always run app-specific logic based on input?

---

## 16. Final answer in one line

If only app name is entered, then the toolchain is almost certainly using a **central inventory or shared pipeline template** to map that app name to the correct repositories, config paths, compliance flow, and deployment actions.
