# 🔧 Prerequisites & Environment Setup

## 📖 Overview

This guide covers **everything you need** to set up your development environment before starting the project. Follow each step carefully to ensure a smooth experience.

---

## 📋 System Requirements

### Minimum Requirements

- **OS:** macOS, Linux, or Windows 10/11
- **RAM:** 8GB (16GB recommended)
- **Disk Space:** 20GB free
- **Internet:** Stable connection for downloads

### Recommended Specifications

- **RAM:** 16GB or more
- **CPU:** 4 cores or more
- **Disk:** SSD for better performance

---

## 🛠️ Part 1: Install Required Tools

### 1.1 Install Docker Desktop

**WHAT:** Container runtime for building and running containers

**WHY:** Required to build Docker images and test locally

**HOW:**

#### For macOS

```bash
# Install using Homebrew
brew install --cask docker

# OR download from website
# Visit: https://www.docker.com/products/docker-desktop

# Start Docker Desktop from Applications

# Verify installation
docker --version
# Expected: Docker version 24.0.0 or higher

docker compose version
# Expected: Docker Compose version v2.20.0 or higher

# Test Docker
docker run hello-world
# Should download and run successfully
```

#### For Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group (avoid using sudo)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect

# Verify installation
docker --version
docker compose version
docker run hello-world
```

#### For Windows

```powershell
# Download Docker Desktop for Windows
# Visit: https://www.docker.com/products/docker-desktop

# Install and restart computer

# Verify in PowerShell
docker --version
docker compose version
docker run hello-world
```

**Troubleshooting:**

- If Docker daemon not running: Start Docker Desktop
- If permission denied: Add user to docker group (Linux)
- If WSL2 error (Windows): Enable WSL2 and update

---

### 1.2 Install kubectl

**WHAT:** Kubernetes command-line tool

**WHY:** Required to interact with Kubernetes clusters

**HOW:**

#### For macOS

```bash
# Install using Homebrew
brew install kubectl

# Verify installation
kubectl version --client

# Expected output:
# Client Version: v1.28.0 or higher
```

#### For Linux

```bash
# Download latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

#### For Windows

```powershell
# Using Chocolatey
choco install kubernetes-cli

# OR download manually
# Visit: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

# Verify
kubectl version --client
```

**Configuration:**

```bash
# kubectl uses ~/.kube/config for cluster access
# This will be configured when we create EKS cluster

# Check current context (will fail if no cluster configured yet)
kubectl config current-context
```

---

### 1.3 Install Terraform

**WHAT:** Infrastructure as Code tool

**WHY:** Required to provision AWS infrastructure

**HOW:**

#### For macOS

```bash
# Add HashiCorp tap
brew tap hashicorp/tap

# Install Terraform
brew install hashicorp/tap/terraform

# Verify installation
terraform --version

# Expected: Terraform v1.6.0 or higher
```

#### For Linux

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update
sudo apt install terraform

# Verify
terraform --version
```

#### For Windows

```powershell
# Using Chocolatey
choco install terraform

# Verify
terraform --version
```

**Test Terraform:**

```bash
# Create test directory
mkdir -p ~/terraform-test
cd ~/terraform-test

# Create simple config
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
}

output "hello" {
  value = "Terraform is working!"
}
EOF

# Initialize
terraform init

# Plan
terraform plan

# Should show: hello = "Terraform is working!"
```

---

### 1.4 Install AWS CLI

**WHAT:** Command-line interface for AWS

**WHY:** Required to interact with AWS services

**HOW:**

#### For macOS

```bash
# Install using Homebrew
brew install awscli

# Verify installation
aws --version

# Expected: aws-cli/2.13.0 or higher
```

#### For Linux

```bash
# Download installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip
unzip awscliv2.zip

# Install
sudo ./aws/install

# Verify
aws --version
```

#### For Windows

```powershell
# Download MSI installer
# Visit: https://aws.amazon.com/cli/

# OR using Chocolatey
choco install awscli

# Verify
aws --version
```

---

### 1.5 Install Helm

**WHAT:** Package manager for Kubernetes

**WHY:** Required to install Prometheus, Grafana, and other tools

**HOW:**

#### For macOS

```bash
# Install using Homebrew
brew install helm

# Verify installation
helm version

# Expected: version.BuildInfo{Version:"v3.13.0" or higher}
```

#### For Linux

```bash
# Download install script
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

#### For Windows

```powershell
# Using Chocolatey
choco install kubernetes-helm

# Verify
helm version
```

**Test Helm:**

```bash
# Add a repository
helm repo add stable https://charts.helm.sh/stable

# Update repositories
helm repo update

# Search for charts
helm search repo prometheus
```

---

### 1.6 Install Git

**WHAT:** Version control system

**WHY:** Required for code management and CI/CD

**HOW:**

#### For macOS

```bash
# Usually pre-installed, but can install via Homebrew
brew install git

# Verify
git --version

# Expected: git version 2.40.0 or higher
```

#### For Linux

```bash
# Install
sudo apt-get install git

# Verify
git --version
```

#### For Windows

```powershell
# Download from git-scm.com
# OR using Chocolatey
choco install git

# Verify
git --version
```

**Configure Git:**

```bash
# Set your name
git config --global user.name "Your Name"

# Set your email
git config --global user.email "your.email@example.com"

# Verify configuration
git config --list
```

---

### 1.7 Install Node.js (Optional for local development)

**WHAT:** JavaScript runtime

**WHY:** Required if you want to run backend locally

**HOW:**

#### For macOS

```bash
# Install using Homebrew
brew install node

# Verify
node --version  # v18.0.0 or higher
npm --version   # 9.0.0 or higher
```

#### For Linux

```bash
# Using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

#### For Windows

```powershell
# Download from nodejs.org
# OR using Chocolatey
choco install nodejs

# Verify
node --version
npm --version
```

---

## ☁️ Part 2: AWS Account Setup

### 2.1 Create AWS Account

**If you don't have an AWS account:**

1. Visit <https://aws.amazon.com>
2. Click "Create an AWS Account"
3. Follow the registration process
4. Provide credit card (free tier available)
5. Verify phone number
6. Choose support plan (Basic - Free)

**Free Tier Includes:**

- 750 hours of EC2 t2.micro instances
- 5GB of S3 storage
- 750 hours of RDS db.t2.micro
- Many other services

---

### 2.2 Create IAM User

**WHAT:** Identity and Access Management user

**WHY:** Don't use root account for daily operations

**HOW:**

```bash
# Log in to AWS Console
# Navigate to IAM service

# Create new user:
1. Click "Users" → "Add users"
2. Username: "devops-user"
3. Access type: ✅ Programmatic access
4. Permissions: Attach existing policies
   - AdministratorAccess (for learning)
   - Or create custom policy (for production)
5. Click "Create user"
6. **IMPORTANT:** Download credentials CSV
   - Access Key ID
   - Secret Access Key
   - Save securely!
```

**Security Best Practices:**

- ✅ Enable MFA (Multi-Factor Authentication)
- ✅ Use least privilege principle
- ✅ Rotate access keys regularly
- ✅ Never commit credentials to Git

---

### 2.3 Configure AWS CLI

**WHAT:** Set up AWS credentials locally

**WHY:** Required for Terraform and kubectl

**HOW:**

```bash
# Configure AWS CLI
aws configure

# You'll be prompted for:
AWS Access Key ID [None]: YOUR_ACCESS_KEY_HERE
AWS Secret Access Key [None]: YOUR_SECRET_KEY_HERE
Default region name [None]: us-east-1
Default output format [None]: json

# EXPLANATION:
# Access Key ID     : From IAM user creation
# Secret Access Key : From IAM user creation
# Region            : us-east-1 (recommended)
# Output format     : json (easier to parse)

# Verify configuration
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/devops-user"
# }

# Test AWS access
aws ec2 describe-regions

# Should list all AWS regions
```

**Alternative: Using AWS Profiles**

```bash
# Configure named profile
aws configure --profile devops

# Use profile
export AWS_PROFILE=devops

# Or specify in commands
aws s3 ls --profile devops
```

**Credentials Location:**

```bash
# Credentials stored in:
~/.aws/credentials

# Config stored in:
~/.aws/config

# View credentials (be careful!)
cat ~/.aws/credentials
```

---

## 💻 Part 3: Development Environment

### 3.1 Install Code Editor

**Recommended: Visual Studio Code**

#### For macOS

```bash
brew install --cask visual-studio-code
```

#### For Linux

```bash
# Download .deb package
wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'

# Install
sudo dpkg -i code.deb
```

#### For Windows

Download from <https://code.visualstudio.com>

**Recommended VS Code Extensions:**

```bash
# Install extensions
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension hashicorp.terraform
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
```

---

### 3.2 Install Terminal Tools

**For macOS/Linux:**

```bash
# Install useful tools
brew install jq      # JSON processor
brew install yq      # YAML processor
brew install tree    # Directory tree viewer
brew install watch   # Execute command periodically

# Verify
jq --version
yq --version
tree --version
```

**For Windows:**

```powershell
# Using Chocolatey
choco install jq
choco install yq
```

---

## 🧪 Part 4: Verify Installation

### 4.1 Run Verification Script

Create and run this verification script:

```bash
# Create verification script
cat > verify-setup.sh << 'EOF'
#!/bin/bash

echo "🔍 Verifying DevOps Tools Installation..."
echo ""

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        version=$($1 --version 2>&1 | head -n 1)
        echo "✅ $1: $version"
        return 0
    else
        echo "❌ $1: NOT FOUND"
        return 1
    fi
}

# Check all tools
check_command docker
check_command kubectl
check_command terraform
check_command aws
check_command helm
check_command git
check_command node
check_command npm
check_command jq

echo ""
echo "🔐 Checking AWS Configuration..."
if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS CLI configured correctly"
    aws sts get-caller-identity
else
    echo "❌ AWS CLI not configured"
fi

echo ""
echo "🎉 Verification Complete!"
EOF

# Make executable
chmod +x verify-setup.sh

# Run verification
./verify-setup.sh
```

**Expected Output:**

```
🔍 Verifying DevOps Tools Installation...

✅ docker: Docker version 24.0.0
✅ kubectl: Client Version: v1.28.0
✅ terraform: Terraform v1.6.0
✅ aws: aws-cli/2.13.0
✅ helm: version.BuildInfo{Version:"v3.13.0"}
✅ git: git version 2.40.0
✅ node: v18.17.0
✅ npm: 9.6.7
✅ jq: jq-1.6

🔐 Checking AWS Configuration...
✅ AWS CLI configured correctly
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/devops-user"
}

🎉 Verification Complete!
```

---

## 📁 Part 5: Project Directory Setup

### 5.1 Create Project Structure

```bash
# Create main project directory
mkdir -p ~/devops-projects/microservices-platform
cd ~/devops-projects/microservices-platform

# Create subdirectories
mkdir -p {frontend,backend,k8s/{base,overlays/{dev,staging,prod}},terraform/{modules/{vpc,eks,rds},environments/{dev,prod}},monitoring,logging,.github/workflows,docs}

# Verify structure
tree -L 3

# Expected output:
# .
# ├── backend/
# ├── frontend/
# ├── k8s/
# │   ├── base/
# │   └── overlays/
# │       ├── dev/
# │       ├── staging/
# │       └── prod/
# ├── terraform/
# │   ├── modules/
# │   │   ├── vpc/
# │   │   ├── eks/
# │   │   └── rds/
# │   └── environments/
# │       ├── dev/
# │       └── prod/
# ├── monitoring/
# ├── logging/
# ├── .github/
# │   └── workflows/
# └── docs/
```

### 5.2 Initialize Git Repository

```bash
# Initialize Git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Node
node_modules/
npm-debug.log
.env
.env.local

# Terraform
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Secrets
*.pem
*.key
credentials.csv

# Build
build/
dist/
*.log
EOF

# Create README
cat > README.md << 'EOF'
# Production-Grade Microservices Platform

A complete DevOps/SRE project demonstrating modern cloud-native practices.

## Tech Stack
- Frontend: React + Nginx
- Backend: Node.js + Express
- Database: PostgreSQL
- Container: Docker
- Orchestration: Kubernetes (EKS)
- IaC: Terraform
- CI/CD: GitHub Actions
- GitOps: ArgoCD
- Monitoring: Prometheus + Grafana
- Logging: EFK Stack

## Getting Started
See documentation in `/docs` directory.
EOF

# Initial commit
git add .
git commit -m "Initial project structure"
```

---

## 🎯 Part 6: Cost Optimization

### 6.1 AWS Free Tier Limits

**Be aware of free tier limits:**

- EC2: 750 hours/month of t2.micro
- RDS: 750 hours/month of db.t2.micro
- S3: 5GB storage
- Data Transfer: 15GB/month

**To avoid charges:**

```bash
# Set up billing alerts
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json

# budget.json:
{
  "BudgetName": "Monthly-Budget",
  "BudgetLimit": {
    "Amount": "10",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
```

### 6.2 Resource Cleanup

**Always clean up resources when done:**

```bash
# Destroy Terraform resources
terraform destroy

# Delete EKS cluster
eksctl delete cluster --name my-cluster

# Check for running resources
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`]'
```

---

## ✅ Checklist

Before proceeding, ensure you have:

- [ ] Docker installed and running
- [ ] kubectl installed
- [ ] Terraform installed
- [ ] AWS CLI installed and configured
- [ ] Helm installed
- [ ] Git installed and configured
- [ ] AWS account created
- [ ] IAM user created with credentials
- [ ] AWS CLI configured with credentials
- [ ] Code editor installed (VS Code recommended)
- [ ] Project directory structure created
- [ ] Git repository initialized
- [ ] All tools verified with verification script

---

## 🆘 Troubleshooting

### Common Issues

**1. Docker daemon not running**

```bash
# macOS/Windows: Start Docker Desktop
# Linux:
sudo systemctl start docker
sudo systemctl enable docker
```

**2. kubectl: command not found**

```bash
# Check PATH
echo $PATH

# Add to PATH (Linux/macOS)
export PATH=$PATH:/usr/local/bin

# Add to ~/.bashrc or ~/.zshrc for persistence
```

**3. AWS CLI: Unable to locate credentials**

```bash
# Reconfigure AWS CLI
aws configure

# Check credentials file
cat ~/.aws/credentials

# Verify
aws sts get-caller-identity
```

**4. Terraform: command not found**

```bash
# Check installation
which terraform

# Reinstall if needed
brew reinstall terraform  # macOS
```

**5. Permission denied (Docker)**

```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
```

---

## 🎉 Next Steps

Now that your environment is set up, you can:

1. **Read Architecture:** [`01-ARCHITECTURE-DEEP-DIVE.md`](01-ARCHITECTURE-DEEP-DIVE.md)
2. **Start Implementation:** [`16-COMPLETE-IMPLEMENTATION.md`](16-COMPLETE-IMPLEMENTATION.md)
3. **Build Application:** Begin with backend and frontend development

---

**You're ready to start building! 🚀**
