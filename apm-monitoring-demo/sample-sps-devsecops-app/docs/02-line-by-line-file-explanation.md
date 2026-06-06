# 2. Line-by-Line Explanation of Each Sample File

## Purpose

This document explains each sample file in very simple language.

You said you are new, so this document explains:

- what each file is for
- what each important line means
- why it exists in the project

---

# A. [`package.json`](sample-sps-devsecops-app/package.json)

```json
{
  "name": "sample-sps-devsecops-app",
  "version": "1.0.0",
  "description": "Beginner-friendly sample app for IBM SPS DevSecOps toolchain learning",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "node test/app.test.js"
  },
  "keywords": [
    "devsecops",
    "ibm-cloud",
    "toolchain",
    "sonar",
    "terraform",
    "beginner"
  ],
  "author": "Bob",
  "license": "Apache-2.0"
}
```

## What this file is

[`package.json`](sample-sps-devsecops-app/package.json) is the main project file for a Node.js app.

It tells Node/npm:

- project name
- version
- how to start app
- how to run tests

## Line-by-line explanation

### `"name": "sample-sps-devsecops-app"`

This is the project name.

### `"version": "1.0.0"`

This is the app version.

### `"description": "..."`

This is a human-readable description.

### `"main": "app.js"`

This tells Node that the main entry file is [`app.js`](sample-sps-devsecops-app/app.js).

### `"scripts"`

This section defines shortcut commands.

### `"start": "node app.js"`

When you run `npm start`, Node runs [`app.js`](sample-sps-devsecops-app/app.js).

### `"test": "node test/app.test.js"`

When you run `npm test`, Node runs [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js).

### `"keywords"`

These are optional tags for project identification.

### `"author": "Bob"`

This is the author field.

### `"license": "Apache-2.0"`

This tells which license is used.

---

# B. [`app.js`](sample-sps-devsecops-app/app.js)

```javascript
const http = require('http');

const port = process.env.PORT || 8080;

const server = http.createServer((request, response) => {
  if (request.url === '/health') {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end('Hello from sample SPS DevSecOps app\n');
});

server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
```

## What this file is

[`app.js`](sample-sps-devsecops-app/app.js) is the actual application code.

It creates a tiny web server.

## Line-by-line explanation

### `const http = require('http');`

This imports Node's built-in HTTP module.

Simple meaning:
we want to create a web server.

### `const port = process.env.PORT || 8080;`

This says:

- if environment variable `PORT` exists, use it
- otherwise use port `8080`

Why useful?
In cloud/container environments, port is often passed from outside.

### `const server = http.createServer((request, response) => {`

This creates the web server.

Whenever a request comes in, this function runs.

### `if (request.url === '/health') {`

If user opens `/health`, return health response.

This is common in DevOps because health endpoints help monitoring and load balancers.

### `response.writeHead(200, { 'Content-Type': 'application/json' });`

This sends HTTP status `200 OK` and says response type is JSON.

### `response.end(JSON.stringify({ status: 'ok' }));`

This sends JSON response:

```json
{"status":"ok"}
```

### `return;`

Stop further processing after health response.

### `response.writeHead(200, { 'Content-Type': 'text/plain' });`

For normal requests, return plain text.

### `response.end('Hello from sample SPS DevSecOps app\n');`

This sends the main response text.

### `server.listen(port, () => {`

This starts the server on the selected port.

### `console.log(...)`

This prints a startup message in logs.

---

# C. [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js)

```javascript
const { execSync } = require('child_process');

try {
  const output = execSync('node app.js', {
    timeout: 1000,
    env: { ...process.env, PORT: '8090' }
  }).toString();

  if (!output.includes('Server is running on port 8090')) {
    throw new Error('Server did not start correctly');
  }

  process.stdout.write('Sample unit test passed\n');
} catch (error) {
  process.stderr.write(`Sample unit test failed: ${error.message}\n`);
  process.exit(1);
}
```

## What this file is

This is a very simple test file.

It checks whether the app starts correctly.

## Line-by-line explanation

### `const { execSync } = require('child_process');`

This imports a Node function that can run shell commands.

### `try {`

Start a safe block.
If something fails, control goes to `catch`.

### `const output = execSync('node app.js', {`

This runs the app from command line.

### `timeout: 1000`

Stop command after 1000 milliseconds.

Why?
Because server keeps running forever, so test should not hang too long.

### `env: { ...process.env, PORT: '8090' }`

This passes environment variables and sets port to `8090`.

Why?
So test does not conflict with default port.

### `}).toString();`

Convert command output to text.

### `if (!output.includes('Server is running on port 8090')) {`

Check whether startup log contains expected text.

### `throw new Error('Server did not start correctly');`

If expected text is missing, fail the test.

### `process.stdout.write('Sample unit test passed\n');`

If everything is okay, print success message.

### `} catch (error) {`

If any error happens, handle it here.

### `process.stderr.write(...)`

Print failure message.

### `process.exit(1);`

Exit with failure code so pipeline knows test failed.

---

# D. [`Dockerfile`](sample-sps-devsecops-app/Dockerfile)

```dockerfile
FROM registry.access.redhat.com/ubi8/nodejs-20-minimal:latest

USER root

RUN microdnf -y upgrade && microdnf clean all

WORKDIR /opt/app-root/src

COPY package.json app.js ./
COPY test ./test

RUN npm install --omit=dev

USER 1001

EXPOSE 8080

CMD ["npm", "start"]
```

## What this file is

[`Dockerfile`](sample-sps-devsecops-app/Dockerfile) tells Docker how to package the app into a container image.

## Line-by-line explanation

### `FROM registry.access.redhat.com/ubi8/nodejs-20-minimal:latest`

Start from a base image that already has:

- Red Hat UBI 8
- Node.js 20

Simple meaning:
do not build everything from zero; start from a ready Node image.

### `USER root`

Temporarily use root user.

Why?
Some package update/install operations need root permissions.

### `RUN microdnf -y upgrade && microdnf clean all`

Update packages in the image and clean cache.

Why?
Keeps image updated and smaller.

### `WORKDIR /opt/app-root/src`

Set working directory inside container.

Simple meaning:
all next commands run from this folder.

### `COPY package.json app.js ./`

Copy [`package.json`](sample-sps-devsecops-app/package.json) and [`app.js`](sample-sps-devsecops-app/app.js) into container.

### `COPY test ./test`

Copy test folder into container.

### `RUN npm install --omit=dev`

Install Node dependencies.

In this sample there are no extra dependencies, but this is standard practice.

### `USER 1001`

Switch to non-root user.

Why?
Running app as non-root is safer.

### `EXPOSE 8080`

Document that app listens on port `8080`.

### `CMD ["npm", "start"]`

Default command when container starts.

This runs:

- `npm start`
- which runs [`app.js`](sample-sps-devsecops-app/app.js)

---

# E. [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties)

```properties
sonar.projectKey=sample-sps-devsecops-app
sonar.projectName=sample-sps-devsecops-app
sonar.sources=.
sonar.exclusions=node_modules/**,terraform/**,test/**
sonar.tests=test
sonar.test.inclusions=test/**/*.js
```

## What this file is

This file tells Sonar how to scan the project.

## Line-by-line explanation

### `sonar.projectKey=sample-sps-devsecops-app`

Unique key for Sonar project.

### `sonar.projectName=sample-sps-devsecops-app`

Human-readable project name in Sonar UI.

### `sonar.sources=.`

Scan source files from current folder.

### `sonar.exclusions=node_modules/**,terraform/**,test/**`

Do not scan:

- `node_modules`
- Terraform folder
- test folder

Why?
Usually Sonar source scan focuses on app code, not generated/dependency/test files.

### `sonar.tests=test`

Tell Sonar that test files are in `test` folder.

### `sonar.test.inclusions=test/**/*.js`

Include JavaScript files under test folder as test files.

---

# F. [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml)

```yaml
version: '2'

tasks:
  code-checks:
    include:
      - dind
    steps:
      - name: checks-setup
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          cd "$WORKSPACE/$(load_repo app-repo path)"
          echo "Installing dependencies"
          npm install
      - name: static-scan
        include:
          - docker-socket

  code-build:
    include:
      - dind
    steps:
      - name: unit-test
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          cd "$WORKSPACE/$(load_repo app-repo path)"
          echo "Running unit tests"
          npm test
      - name: build-artifact
        include:
          - docker-socket
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          echo "Building Docker image from Dockerfile"
          ${COMMONS_PATH}/build-artifact/docker.sh --source "Dockerfile" --repo-key "app-repo"

  deploy-checks:
    include:
      - dind
    steps:
      - name: deploy
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          echo "This sample keeps deployment simple."
          echo "In a real setup, this stage would deploy with helm or kubectl."
      - name: acceptance-test
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          echo "Acceptance test placeholder"

  deploy-release:
    steps:
      - name: run-stage
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          echo "Releasing build metadata to inventory"
          ${COMMONS_PATH}/release/release.sh

finally:
  code-ci-finish:
    steps:
      - name: run-stage
        image: icr.io/continuous-delivery/base-images/base:v1.19.0
        script: |
          #!/usr/bin/env bash
          echo "Pipeline finished"
```

## What this file is

This file tells IBM SPS DevSecOps pipeline what stages to run.

## Important line-by-line explanation

### `version: '2'`

Pipeline config version.

### `tasks:`

Start of pipeline task definitions.

### `code-checks:`

First stage for checks before build.

### `include: - dind`

Enable Docker-in-Docker support if needed.

### `steps:`

List of steps inside this stage.

### `name: checks-setup`

Name of first step.

### `image: icr.io/...`

Container image used to run this step.

### `script: |`

Multi-line shell script starts here.

### `cd "$WORKSPACE/$(load_repo app-repo path)"`

Move into checked-out app repo.

This is how pipeline accesses your Git repo files.

### `npm install`

Install dependencies.

### `name: static-scan`

Static scan step name.

This is where static analysis/security scan can run using IBM shared logic.

### `code-build:`

Build stage starts here.

### `name: unit-test`

Run tests.

### `npm test`

Execute test command from [`package.json`](sample-sps-devsecops-app/package.json).

### `name: build-artifact`

Build artifact/image step.

### `${COMMONS_PATH}/build-artifact/docker.sh --source "Dockerfile" --repo-key "app-repo"`

Use IBM shared script to build Docker image from [`Dockerfile`](sample-sps-devsecops-app/Dockerfile).

### `deploy-checks:`

Deployment-related stage.

### `name: deploy`

Deployment step.

In this sample it only prints messages.

### `name: acceptance-test`

Placeholder for testing deployed app.

### `deploy-release:`

Release stage.

### `${COMMONS_PATH}/release/release.sh`

Use IBM shared release script.

Usually this updates inventory/release metadata.

### `finally:`

This section runs at the end.

### `code-ci-finish:`

Final cleanup/finish stage.

### `echo "Pipeline finished"`

Print final message.

---

# G. [`terraform/main.tf`](sample-sps-devsecops-app/terraform/main.tf)

```hcl
terraform {
  required_version = ">= 1.5.0"
}

resource "local_file" "app_info" {
  filename = "${path.module}/generated-app-info.txt"
  content  = <<EOT
app_name=${var.app_name}
environment=${var.environment}
owner=${var.owner}
EOT
}
```

## What this file is

This is the main Terraform file.

In this sample, it creates a local text file.

In real life, Terraform can create cloud resources.

## Line-by-line explanation

### `terraform {`

Start Terraform settings block.

### `required_version = ">= 1.5.0"`

Require Terraform version 1.5.0 or higher.

### `resource "local_file" "app_info" {`

Create a resource of type `local_file`.

Simple meaning:
Terraform will create a file on disk.

### `filename = "${path.module}/generated-app-info.txt"`

The file will be created inside current Terraform folder.

### `content = <<EOT`

Start multi-line text content.

### `app_name=${var.app_name}`

Insert value of variable `app_name`.

### `environment=${var.environment}`

Insert value of variable `environment`.

### `owner=${var.owner}`

Insert value of variable `owner`.

### `EOT`

End multi-line content block.

### `}`

End resource block.

---

# H. [`terraform/variables.tf`](sample-sps-devsecops-app/terraform/variables.tf)

```hcl
variable "app_name" {
  description = "Name of the sample application"
  type        = string
  default     = "sample-sps-devsecops-app"
}

variable "environment" {
  description = "Target environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of this sample infrastructure"
  type        = string
  default     = "beginner-devops-user"
}
```

## What this file is

This file defines input variables for Terraform.

## Line-by-line explanation

### `variable "app_name" {`

Define variable named `app_name`.

### `description = "..."`

Explain what variable means.

### `type = string`

Value must be text.

### `default = "sample-sps-devsecops-app"`

Default value if user does not provide one.

Same logic applies for:

- [`environment`](sample-sps-devsecops-app/terraform/variables.tf)
- [`owner`](sample-sps-devsecops-app/terraform/variables.tf)

---

# I. [`terraform/outputs.tf`](sample-sps-devsecops-app/terraform/outputs.tf)

```hcl
output "generated_file_path" {
  description = "Path of the generated sample file"
  value       = local_file.app_info.filename
}

output "app_summary" {
  description = "Simple summary of the sample app"
  value       = "App ${var.app_name} is prepared for environment ${var.environment}"
}
```

## What this file is

This file tells Terraform what values to show after apply.

## Line-by-line explanation

### `output "generated_file_path" {`

Define output named `generated_file_path`.

### `description = "..."`

Explain output meaning.

### `value = local_file.app_info.filename`

Show the filename created by Terraform resource.

### `output "app_summary" {`

Define another output.

### `value = "App ${var.app_name} is prepared for environment ${var.environment}"`

Show a simple summary string using variables.

---

# J. How all files work together

- [`app.js`](sample-sps-devsecops-app/app.js) = actual app
- [`package.json`](sample-sps-devsecops-app/package.json) = Node project config
- [`test/app.test.js`](sample-sps-devsecops-app/test/app.test.js) = test
- [`Dockerfile`](sample-sps-devsecops-app/Dockerfile) = container build instructions
- [`sonar-project.properties`](sample-sps-devsecops-app/sonar-project.properties) = Sonar scan config
- [`.ci-pipeline-config-v2.yaml`](sample-sps-devsecops-app/.ci-pipeline-config-v2.yaml) = IBM pipeline instructions
- [`terraform/*.tf`](sample-sps-devsecops-app/terraform/main.tf) = infrastructure example

That is the full beginner picture.
