# 7. DevSecOps Pipeline End-to-End from [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:1)

## Purpose of this document

You shared the actual pipeline configuration from [`bob-dev-sample-app/.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:5).

This is the most useful file so far because now we can explain the IBM DevSecOps toolchain flow much more accurately.

This document explains:

- how the toolchain fetches repo changes
- how the pipeline knows what to do
- where app name is used
- how CI, PR, security, build, deploy, and release stages work
- how inventory and compliance fit into the flow

---

## 1. Most important answer first

The file [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:16) is the main app-level configuration file that tells the IBM DevSecOps pipeline **which standard tasks and steps to run**.

But this file does **not** contain all logic by itself.

It mainly wires your app into IBM's shared DevSecOps framework by calling reusable scripts such as:

- [`${COMMONS_PATH}/utils/setup_branch-protection.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:22)
- [`${COMMONS_PATH}/build-artifact/docker.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:23)
- [`${COMMONS_PATH}/deploy/kubectl.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:24)
- [`${COMMONS_PATH}/deploy/helm.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:25)
- [`${COMMONS_PATH}/release/release.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:26)

So the real model is:

```text
Your app repo provides pipeline config
        +
IBM shared DevSecOps framework provides reusable scripts
        +
Toolchain UI provides repo connections, triggers, secrets, env vars
        =
Full pipeline behavior
```

That is the key idea.

---

## 2. What this file is doing at a high level

The file declares:

- [`version: '2'`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:39)
- a set of pipeline [`tasks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:40)
- a [`finally`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:41) section

The main tasks are:

1. [`code-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:45)
2. [`cc-repo-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:46)
3. [`code-build`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:47)
4. [`deploy-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:48)
5. [`deploy-release`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:49)
6. [`async-stage`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:50)

This means the pipeline is not just "build and deploy".

It is a full DevSecOps pipeline with:

- code validation
- secret detection
- compliance checks
- static scanning
- unit testing
- artifact build
- artifact signing/scanning
- deployment
- dynamic scanning
- acceptance testing
- release to inventory
- final completion stage

---

## 3. How the toolchain fetches repo changes

Now we can explain this more concretely.

### Step 1: Toolchain is connected to the repo

IBM toolchain has a repository integration for the app repo.

That means when the pipeline starts, it already knows:

- repo URL
- branch
- credentials
- workspace path

### Step 2: Pipeline loads the repo into workspace

The config repeatedly uses:

- [`load_repo app-repo path`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:72)
- [`load_repo app-repo url`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:73)

This is very important.

It means the pipeline framework already checked out the repository and registered it under the key [`app-repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:75).

So the toolchain fetches repo content by:

- cloning the connected repo
- placing it in pipeline workspace
- exposing helper functions like [`load_repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:79) to access it

### Step 3: Steps move into the repo folder

The config repeatedly does:

```bash
cd "$WORKSPACE/$(load_repo app-repo path)"
```

This means:

- the repo has already been fetched
- the step enters that checked-out repo directory
- then it runs commands like [`npm ci`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:89), tests, Docker build, etc.

So the answer to "how is toolchain fetching changes?" is:

> The toolchain fetches the connected repository into the pipeline workspace before task execution, and the steps access it through the [`app-repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:93) repo key using helpers like [`load_repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:93).

---

## 4. How PR pipeline and CI pipeline differ

Your toolchain screenshot showed:

- [`pr-pipeline`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:99)
- [`ci-pipeline`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:100)

This YAML is mainly the task definition used by those pipelines.

### PR pipeline

Usually runs on pull request events.

Purpose:

- validate proposed changes before merge
- run security/compliance checks
- run tests
- block unsafe changes

### CI pipeline

Usually runs after merge or on protected branch.

Purpose:

- build official artifact
- deploy to target environment
- run acceptance/dynamic checks
- release artifact metadata to inventory

The config itself checks pipeline namespace:

- [`get_env pipeline_namespace`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:113)

and contains logic like:

- if namespace contains `pr`
- if namespace contains `ci`

That means the same shared config can behave differently depending on which pipeline invoked it.

---

## 5. What happens in [`code-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:121)

This task includes:

- [`checks-setup`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:122)
- [`detect-secrets`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:123)
- [`compliance-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:124)
- [`static-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:125)

### What [checks-setup](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:127) does

It:

1. checks debug mode
2. checks whether pipeline namespace is PR or CI
3. runs branch protection setup
4. moves into the source app repo
5. runs [`npm ci`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:132)

This means before scanning, the pipeline ensures:

- repo is ready
- dependencies are installed
- branch protection is enforced

### What [detect-secrets](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:136) does

It scans for accidentally committed secrets.

### What [compliance-checks](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:138) does

It likely checks policy/compliance rules.

### What [static-scan](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:140) does

It likely runs SAST and code quality/security scanning.

This is why it is called DevSecOps:

- development checks
- security checks
- compliance checks
- all inside CI

---

## 6. What [`.whitesource`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:146) and [`sonar-project.properties`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:146) are doing

You shared:

- [`.whitesource`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:149)
- [`sonar-project.properties`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:150)
- [`scan_excludes.txt`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:151)

These files support the security/compliance scanning stages.

### [`.whitesource`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:154)

This is for dependency/open-source vulnerability and license scanning.

It inherits settings from:

- [`whitesource-config/whitesource-config@issues_none`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:157)

Meaning:

- scanning policy is centrally managed
- app repo only references the shared policy

### [`sonar-project.properties`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:161)

This configures Sonar scanning:

- project key
- exclusions

Meaning:

- static analysis is part of the pipeline
- some files are excluded intentionally

### [`scan_excludes.txt`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:167)

This excludes files like [`app.js`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:168) from some scans.

So the app repo contributes scan configuration, while the pipeline framework executes the scans.

---

## 7. What happens in [`code-build`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:173)

This task includes:

- [`setup`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:174)
- [`unit-test`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:175)
- [`build-artifact`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:176)

### [setup](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:178)

Again:

- enters repo
- runs [`npm ci`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:180)

### [unit-test](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:182)

It runs:

- [`source $WORKSPACE/$PIPELINE_CONFIG_REPO_PATH/scripts/run_test.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:183)
- [`run_unit_test`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:184)

This is very important.

It means:

- the test execution logic is not fully hardcoded in the YAML
- it is delegated to a shared or pipeline-config repo script
- the app repo provides the tests, such as [`test/test.js`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:188)

Your sample test:

- runs a dummy test
- prints `"Sample test"`

So the pipeline fetches the repo, installs dependencies, then runs the app's tests through a shared wrapper script.

### [build-artifact](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:194)

This step builds the container image using:

- [`${COMMONS_PATH}/build-artifact/docker.sh --source "Dockerfile" --repo-key "app-repo"`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:197)

This means:

- the app repo's [`Dockerfile`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:199) is used
- the shared IBM script performs the actual standardized build process

So the app repo provides:

- source code
- Dockerfile
- tests

The shared framework provides:

- how to build
- how to scan
- how to store evidence

---

## 8. What the [`Dockerfile`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:207) tells us

Your [`Dockerfile`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:207) does this:

1. uses UBI Node.js 20 base image
2. upgrades packages
3. copies app source
4. runs [`npm install --omit=dev`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:212)
5. exposes port 8080
6. starts app with [`npm run -d start`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:214)

So during build:

- pipeline fetches repo
- shared build script reads this Dockerfile
- image is built in a standard secure way

---

## 9. What happens in [`deploy-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:219)

This task includes:

- [`deploy`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:220)
- [`dynamic-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:221)
- [`acceptance-test`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:222)

### [deploy](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:224)

This step first gets repo name from:

- [`get_repo_name "$(load_repo app-repo url)"`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:225)

Then it checks:

- [`get_env deployment-type "deployment"`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:227)

This is one of the most important lines in the whole file.

It means deployment behavior depends on a pipeline environment variable called [`deployment-type`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:229).

Possible values:

- `helm`
- default `deployment`

### If deployment type is [`helm`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:233)

Then the pipeline:

- saves Helm chart artifact
- saves dev config artifact
- reads [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:236)
- computes Helm release name from [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:237)
- sets additional values file based on target environment
- runs [`${COMMONS_PATH}/deploy/helm.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:240)

This directly answers your question about app name.

### Why only app name may be enough

Because in Helm mode:

- [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:244) is used to derive release name
- target environment decides which values file to use
- chart path is standardized
- deployment script is standardized

So if the framework already knows:

- repo
- chart location
- environment
- cluster namespace

then entering [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:250) can be enough to complete the deployment naming and release logic.

### If deployment type is normal Kubernetes deployment

Then the pipeline:

- chooses deployment file based on cluster type
- uses [`deployment_os.yml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:255) for OpenShift
- uses [`deployment_iks.yml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:256) for IKS
- runs [`${COMMONS_PATH}/deploy/kubectl.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:257)
- saves deployment artifacts for both IKS and OpenShift

This means the same pipeline supports multiple deployment styles.

---

## 10. What happens in [`dynamic-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:263)

This stage is optional.

It runs only if:

- [`opt-in-dynamic-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:266) is set

Then it can trigger OWASP ZAP scans using:

- API definitions
- UI scripts
- environment setup scripts

This means after deployment, the pipeline can run runtime security testing against the deployed app.

That is a strong DevSecOps pattern:

- not only static scan before deploy
- but also dynamic scan after deploy

---

## 11. What happens in [`acceptance-test`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:275)

This step:

- gets [`APP_URL`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:276)
- sources [`run_test.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:277)
- runs [`run_acceptance_test`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:278)

Meaning:

- after deployment, the pipeline can test the running application
- not just the source code

So the flow is:

- build app
- deploy app
- test live app

---

## 12. What happens in [`deploy-release`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:283)

This is another very important stage.

It checks:

- [`one-pipeline-status`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:286)
- [`skip-inventory-update-on-failure`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:287)

If earlier stages failed, it may skip release.

If successful, it eventually runs:

- [`${COMMONS_PATH}/release/release.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:292)

This is the inventory update stage.

### What this likely means

The pipeline writes artifact/deployment metadata into the inventory repository.

This is probably why your toolchain has a connected repo like [`bob-dev-inventory`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:297).

So the flow is not only:

- build and deploy

It is also:

- register what was built/released
- store metadata for governance and traceability

This is a major DevSecOps/compliance feature.

---

## 13. Where the real logic lives

Now we can answer this very clearly.

### App repo contains

- [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:307)
- [`Dockerfile`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:308)
- tests like [`test/test.js`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:309)
- scan config like [`.whitesource`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:310), [`sonar-project.properties`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:310), [`scan_excludes.txt`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:310)

### Shared pipeline framework contains

- [`${COMMONS_PATH}`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:313) scripts
- [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:314) tools
- pipeline-config repo scripts like [`$PIPELINE_CONFIG_REPO_PATH/scripts/run_test.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:315)

### Toolchain UI contains

- repo integrations
- secrets
- environment variables
- trigger definitions
- pipeline namespace
- deployment target settings

So the answer to "where is the config file?" is:

> The app-level config starts in [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:321), but the full behavior is split across the app repo, IBM shared pipeline scripts, pipeline-config repo scripts, and IBM toolchain UI variables.

---

## 14. End-to-end flow in simple sequence

Here is the full flow in simple words.

### PR flow

1. Developer pushes code or opens PR.
2. IBM toolchain receives trigger.
3. [`pr-pipeline`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:329) starts.
4. Repo is fetched into workspace as [`app-repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:330).
5. [`code-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:331) runs:
   - setup
   - dependency install
   - secret scan
   - compliance checks
   - static scan
6. [`code-build`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:336) may run tests/build depending on pipeline design.
7. PR gets pass/fail evidence.

### CI / merge flow

1. PR is merged or CI trigger happens.
2. [`ci-pipeline`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:341) starts.
3. Repo is fetched again.
4. Dependencies are installed.
5. Unit tests run.
6. Docker image is built from [`Dockerfile`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:345).
7. Deployment happens using Helm or kubectl depending on [`deployment-type`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:346).
8. Dynamic scan may run.
9. Acceptance test may run.
10. Release stage updates inventory.
11. Final stage completes pipeline.

---

## 15. Where app name is used

From the YAML, [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:353) is especially used in Helm deployment mode.

It is used to:

- derive Helm release name
- combine with cluster namespace
- standardize deployment naming

So if your team says:
> just enter app name and done

that usually means:

- chart path is already fixed
- repo is already connected
- environment is already configured
- cluster namespace is already configured
- shared scripts know how to deploy
- only the app-specific identifier is needed

This is exactly how platform-standardized pipelines are designed.

---

## 16. Why this is called DevSecOps

This pipeline is DevSecOps because security and compliance are built into the normal delivery flow.

You can see that directly from the stages:

- [`detect-secrets`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:369)
- [`compliance-checks`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:370)
- [`static-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:371)
- [`dynamic-scan`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:372)
- inventory release and evidence handling

So security is not a separate manual step.
It is part of the pipeline itself.

---

## 17. Final direct answer to your question

### How does toolchain fetch all changes from repo?

It connects the repo as [`app-repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:379), checks it out into pipeline workspace, and pipeline steps access it using [`load_repo`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:379) and `cd "$WORKSPACE/$(load_repo app-repo path)"`.

### Where is the config file?

The main app-level config file is [`.ci-pipeline-config-v2.yaml`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:382), but full behavior also depends on shared scripts under [`${COMMONS_PATH}`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:382), [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:382), pipeline-config repo scripts, and IBM toolchain UI variables.

### Why do we only enter app name?

Because the pipeline is standardized. The repo, chart/deployment path, environment, namespace, and deployment scripts are already predefined. [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:385) is used as the key to derive release naming and app-specific deployment behavior.

---

## 18. What to inspect next in your environment

To understand your real Bob setup fully, inspect these next:

1. Pipeline properties in IBM toolchain UI:
   - [`app-name`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:391)
   - [`deployment-type`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:392)
   - [`target-environment`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:393)
   - [`cluster-namespace`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:394)
   - [`app-url`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:395)

2. Shared pipeline-config repo script:
   - [`scripts/run_test.sh`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:398)

3. Shared framework scripts referenced through:
   - [`${COMMONS_PATH}`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:401)
   - [`${ONE_PIPELINE_PATH}`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:402)

4. Inventory repo to see what gets written during release:
   - [`bob-dev-inventory`](bob-project-knowledge-transfer/07-devsecops-pipeline-end-to-end-from-ci-config.md:405)

Once you inspect those, you will know the Bob DevSecOps pipeline almost completely.
