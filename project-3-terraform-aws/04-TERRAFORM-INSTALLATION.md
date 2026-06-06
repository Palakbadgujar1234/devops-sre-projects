# 🔧 Terraform Installation Guide

## 🎯 Learning Objectives

By the end of this guide, you will:

- Install Terraform on your operating system
- Verify Terraform installation
- Understand Terraform CLI commands
- Set up your first Terraform project
- Understand Terraform version management

---

## 🤔 WHAT is Terraform Installation?

### Simple Definition

Installing Terraform means downloading and setting up the Terraform command-line tool on your computer so you can write and execute infrastructure code.

### What You'll Get

```bash
# After installation, you'll have:
terraform --version
# Output: Terraform v1.6.0

# And access to all Terraform commands:
terraform init
terraform plan
terraform apply
terraform destroy
```

---

## 🎯 WHY Install Terraform Locally?

### Reason 1: Development Environment

```
Write code → Test locally → Deploy to cloud
```

### Reason 2: Learning

```
Practice on your machine
No cloud costs while learning
Experiment safely
```

### Reason 3: Version Control

```
Different projects may need different Terraform versions
Local installation lets you manage versions
```

---

## 🏗️ HOW to Install Terraform

### Installation for macOS

#### Method 1: Using Homebrew (Recommended) ✅

**WHAT**: Package manager for macOS  
**WHY**: Easiest way to install and update  
**HOW**:

```bash
# Step 1: Install Homebrew (if not already installed)
# Check if Homebrew is installed
brew --version

# If not installed, install Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Reason: Homebrew makes installing software easy

# Step 2: Install Terraform using Homebrew
brew tap hashicorp/tap
# Reason: Add HashiCorp's official repository

brew install hashicorp/tap/terraform
# Reason: Download and install Terraform

# Step 3: Verify installation
terraform --version
# Expected output: Terraform v1.6.0 (or latest version)
# Reason: Confirm Terraform is installed correctly

# Step 4: Check Terraform location
which terraform
# Expected output: /opt/homebrew/bin/terraform
# Reason: Know where Terraform is installed
```

**What Each Command Does**:

```bash
brew tap hashicorp/tap
# - Adds HashiCorp's repository to Homebrew
# - Like adding a new app store to your phone
# - Lets Homebrew know where to find Terraform

brew install hashicorp/tap/terraform
# - Downloads Terraform binary
# - Installs it in /opt/homebrew/bin/
# - Makes it available system-wide
# - Sets up PATH automatically
```

#### Method 2: Manual Installation

```bash
# Step 1: Download Terraform
# Go to: https://www.terraform.io/downloads
# Download: terraform_1.6.0_darwin_amd64.zip (Intel Mac)
#       or: terraform_1.6.0_darwin_arm64.zip (M1/M2 Mac)

# Step 2: Unzip the file
unzip terraform_1.6.0_darwin_arm64.zip
# Reason: Extract the terraform binary

# Step 3: Move to system path
sudo mv terraform /usr/local/bin/
# Reason: Make terraform available system-wide

# Step 4: Verify
terraform --version
```

---

### Installation for Windows

#### Method 1: Using Chocolatey (Recommended) ✅

**WHAT**: Package manager for Windows  
**WHY**: Easiest way to install and update  
**HOW**:

```powershell
# Step 1: Install Chocolatey (if not already installed)
# Open PowerShell as Administrator
# Run this command:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# Reason: Install Chocolatey package manager

# Step 2: Install Terraform
choco install terraform
# Reason: Download and install Terraform

# Step 3: Verify installation
terraform --version
# Expected output: Terraform v1.6.0
# Reason: Confirm installation worked

# Step 4: Check location
where terraform
# Expected output: C:\ProgramData\chocolatey\bin\terraform.exe
# Reason: Know where Terraform is installed
```

#### Method 2: Manual Installation

```powershell
# Step 1: Download Terraform
# Go to: https://www.terraform.io/downloads
# Download: terraform_1.6.0_windows_amd64.zip

# Step 2: Extract the ZIP file
# Right-click → Extract All
# Extract to: C:\terraform

# Step 3: Add to PATH
# - Open System Properties
# - Click "Environment Variables"
# - Under "System Variables", find "Path"
# - Click "Edit"
# - Click "New"
# - Add: C:\terraform
# - Click "OK" on all windows

# Step 4: Open NEW Command Prompt
# (Must be new to load updated PATH)

# Step 5: Verify
terraform --version
```

---

### Installation for Linux

#### Method 1: Using Package Manager (Recommended) ✅

**For Ubuntu/Debian**:

```bash
# Step 1: Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# Reason: Verify package authenticity

# Step 2: Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# Reason: Tell apt where to find Terraform

# Step 3: Update package list
sudo apt update
# Reason: Refresh available packages

# Step 4: Install Terraform
sudo apt install terraform
# Reason: Download and install Terraform

# Step 5: Verify
terraform --version
# Expected output: Terraform v1.6.0
```

**For CentOS/RHEL/Fedora**:

```bash
# Step 1: Add HashiCorp repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
# Reason: Configure yum to find Terraform

# Step 2: Install Terraform
sudo yum install terraform
# Reason: Download and install Terraform

# Step 3: Verify
terraform --version
```

#### Method 2: Manual Installation

```bash
# Step 1: Download Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
# Reason: Download Terraform binary

# Step 2: Install unzip (if needed)
sudo apt install unzip  # Ubuntu/Debian
# or
sudo yum install unzip  # CentOS/RHEL

# Step 3: Unzip
unzip terraform_1.6.0_linux_amd64.zip
# Reason: Extract the binary

# Step 4: Move to system path
sudo mv terraform /usr/local/bin/
# Reason: Make available system-wide

# Step 5: Verify
terraform --version
```

---

## ✅ Verify Installation

### Complete Verification Steps

```bash
# Test 1: Check version
terraform --version
# Expected output:
# Terraform v1.6.0
# on darwin_arm64 (or your OS)
# ✅ If you see version number, installation worked!

# Test 2: Check help
terraform --help
# Expected output:
# Usage: terraform [global options] <subcommand> [args]
# 
# Common commands:
#     init          Prepare your working directory
#     validate      Check whether the configuration is valid
#     plan          Show changes required by the current configuration
#     apply         Create or update infrastructure
#     destroy       Destroy previously-created infrastructure
# ✅ If you see this, Terraform is working!

# Test 3: Check specific command help
terraform init --help
# Expected output:
# Usage: terraform init [options]
# 
# Initialize a new or existing Terraform working directory...
# ✅ If you see this, Terraform commands work!

# Test 4: Check location
which terraform  # macOS/Linux
where terraform  # Windows
# Expected output: Path to terraform binary
# ✅ Confirms Terraform is in your PATH
```

---

## 🎓 Understanding Terraform CLI

### Essential Terraform Commands

```bash
# 1. terraform init
# WHAT: Initialize a Terraform working directory
# WHY: Downloads providers and sets up backend
# WHEN: First time in a project, or after adding new providers
terraform init

# 2. terraform validate
# WHAT: Check if configuration is syntactically valid
# WHY: Catch errors before planning
# WHEN: After writing/modifying .tf files
terraform validate

# 3. terraform fmt
# WHAT: Format code to canonical style
# WHY: Keep code consistent and readable
# WHEN: Before committing code
terraform fmt

# 4. terraform plan
# WHAT: Preview changes Terraform will make
# WHY: See what will happen before applying
# WHEN: Before every apply
terraform plan

# 5. terraform apply
# WHAT: Create or update infrastructure
# WHY: Actually make the changes
# WHEN: After reviewing plan
terraform apply

# 6. terraform destroy
# WHAT: Destroy all managed infrastructure
# WHY: Clean up resources
# WHEN: Done with infrastructure
terraform destroy

# 7. terraform show
# WHAT: Show current state or plan
# WHY: Inspect what Terraform knows
# WHEN: Debugging or reviewing
terraform show

# 8. terraform output
# WHAT: Show output values
# WHY: Get information about infrastructure
# WHEN: After apply
terraform output
```

### Command Workflow

```
┌─────────────────────────────────────────┐
│  1. Write .tf files                      │
│     (Define infrastructure)              │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  2. terraform init                       │
│     (Download providers)                 │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  3. terraform validate                   │
│     (Check syntax)                       │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  4. terraform fmt                        │
│     (Format code)                        │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  5. terraform plan                       │
│     (Preview changes)                    │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  6. terraform apply                      │
│     (Create infrastructure)              │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  7. terraform destroy                    │
│     (Clean up when done)                 │
└─────────────────────────────────────────┘
```

---

## 🚀 Create Your First Terraform Project

### Step 1: Create Project Directory

```bash
# Create a directory for your Terraform project
mkdir my-first-terraform
# Reason: Organize your Terraform files

cd my-first-terraform
# Reason: Work inside the project directory

# Check you're in the right place
pwd
# Expected output: /path/to/my-first-terraform
```

### Step 2: Create Your First Terraform File

```bash
# Create main.tf file
cat > main.tf << 'EOF'
# This is a comment in Terraform
# Let's create a simple configuration

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# This is just a test - we're not creating anything yet
# We'll add resources in the next guide
EOF

# Reason: Create a basic Terraform configuration
```

**Line-by-Line Explanation**:

```hcl
terraform {
  # This block configures Terraform itself
  
  required_version = ">= 1.0"
  # Means: Require Terraform version 1.0 or higher
  # Why: Ensures compatibility
  
  required_providers {
    # List of providers this project needs
    
    aws = {
      # We're using AWS provider
      
      source  = "hashicorp/aws"
      # Where to download the provider from
      # Format: namespace/provider-name
      
      version = "~> 4.0"
      # Which version to use
      # ~> 4.0 means: 4.0 or higher, but less than 5.0
      # Why: Ensures compatibility, allows minor updates
    }
  }
}

provider "aws" {
  # Configure the AWS provider
  
  region = "us-east-1"
  # Which AWS region to use
  # Why: All resources will be created in this region
}
```

### Step 3: Initialize Terraform

```bash
# Initialize the project
terraform init

# What happens:
# 1. Creates .terraform directory
# 2. Downloads AWS provider plugin
# 3. Creates .terraform.lock.hcl (locks provider versions)
# 4. Initializes backend (state storage)

# Expected output:
# Initializing the backend...
# 
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 4.0"...
# - Installing hashicorp/aws v4.67.0...
# - Installed hashicorp/aws v4.67.0
# 
# Terraform has been successfully initialized!
```

**What Got Created**:

```bash
my-first-terraform/
├── main.tf                    # Your configuration
├── .terraform/                # Provider plugins (don't commit)
│   └── providers/
│       └── registry.terraform.io/
│           └── hashicorp/
│               └── aws/
│                   └── 4.67.0/
│                       └── darwin_arm64/
│                           └── terraform-provider-aws_v4.67.0
└── .terraform.lock.hcl        # Provider version lock (commit this)
```

### Step 4: Validate Configuration

```bash
# Check if configuration is valid
terraform validate

# Expected output:
# Success! The configuration is valid.
# ✅ Your Terraform code has no syntax errors!
```

### Step 5: Format Code

```bash
# Format your code
terraform fmt

# Expected output:
# main.tf
# (Shows which files were formatted)

# Reason: Keeps code style consistent
```

---

## 🔄 Version Management

### Why Version Management Matters

```
Project A needs Terraform 1.5
Project B needs Terraform 1.6
How to manage both?
```

### Using tfenv (Terraform Version Manager)

**Install tfenv**:

**macOS**:

```bash
brew install tfenv
```

**Linux**:

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Use tfenv**:

```bash
# List available Terraform versions
tfenv list-remote

# Install specific version
tfenv install 1.6.0
# Reason: Install Terraform 1.6.0

# Use specific version
tfenv use 1.6.0
# Reason: Switch to Terraform 1.6.0

# Check current version
terraform --version
# Output: Terraform v1.6.0

# Install latest version
tfenv install latest
tfenv use latest
```

---

## 🛠️ Troubleshooting

### Problem 1: "terraform: command not found"

**Cause**: Terraform not in PATH

**Solution**:

```bash
# macOS/Linux: Check PATH
echo $PATH

# Add to PATH (if needed)
export PATH=$PATH:/usr/local/bin

# Make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.zshrc
source ~/.zshrc

# Windows: Add to System PATH
# System Properties → Environment Variables → Path → Add
```

### Problem 2: "Failed to install provider"

**Cause**: Network issues or wrong provider version

**Solution**:

```bash
# Clear Terraform cache
rm -rf .terraform
rm .terraform.lock.hcl

# Re-initialize
terraform init

# If still fails, check internet connection
# Or try different provider version
```

### Problem 3: "Error: Unsupported Terraform version"

**Cause**: Project requires different Terraform version

**Solution**:

```bash
# Check required version in terraform block
cat main.tf | grep required_version

# Install correct version
tfenv install 1.5.0
tfenv use 1.5.0

# Or update required_version in main.tf
```

### Problem 4: Permission Denied (macOS/Linux)

**Cause**: Terraform binary not executable

**Solution**:

```bash
# Make terraform executable
chmod +x /usr/local/bin/terraform

# Verify
ls -l /usr/local/bin/terraform
# Should show: -rwxr-xr-x (x means executable)
```

---

## 🎓 Interview Questions

### Q1: How do you install Terraform?

**Answer**: Multiple methods:

- **macOS**: `brew install hashicorp/tap/terraform`
- **Windows**: `choco install terraform`
- **Linux**: Add HashiCorp repo, then `apt install terraform`
- **Manual**: Download binary, add to PATH

### Q2: What does `terraform init` do?

**Answer**: Initializes a Terraform working directory by:

1. Downloading required provider plugins
2. Setting up backend for state storage
3. Creating `.terraform` directory
4. Creating `.terraform.lock.hcl` for version locking

### Q3: What's the difference between `terraform plan` and `terraform apply`?

**Answer**:

- **plan**: Shows what changes will be made (preview only)
- **apply**: Actually makes the changes (creates/updates/deletes resources)
Always run `plan` before `apply` to review changes.

### Q4: How do you manage multiple Terraform versions?

**Answer**: Use `tfenv` (Terraform version manager):

```bash
tfenv install 1.6.0
tfenv use 1.6.0
```

Allows switching between versions for different projects.

### Q5: What files should be in .gitignore for Terraform?

**Answer**:

```
.terraform/          # Provider plugins
*.tfstate            # State files (contain sensitive data)
*.tfstate.backup     # State backups
.terraform.lock.hcl  # Should be committed (locks versions)
*.tfvars             # May contain secrets
```

### Q6: What is .terraform.lock.hcl?

**Answer**: Dependency lock file that records exact provider versions used. Should be committed to version control to ensure team uses same provider versions.

### Q7: How do you check if Terraform is installed correctly?

**Answer**:

```bash
terraform --version  # Check version
terraform --help     # Check commands work
which terraform      # Check location
```

### Q8: What's the typical Terraform workflow?

**Answer**:

1. Write `.tf` files
2. `terraform init` (download providers)
3. `terraform validate` (check syntax)
4. `terraform plan` (preview changes)
5. `terraform apply` (create infrastructure)
6. `terraform destroy` (clean up)

---

## 🎯 Key Takeaways

1. **Install Terraform** using package manager (easiest) or manual download
2. **Verify installation** with `terraform --version`
3. **Initialize projects** with `terraform init`
4. **Use tfenv** for version management
5. **Essential commands**: init, validate, fmt, plan, apply, destroy
6. **Always plan before apply** to preview changes
7. **Keep .terraform/ out of git** but commit .terraform.lock.hcl

---

## 📚 What's Next?

Now that Terraform is installed, let's learn the basics:

**Next Guide**: [`05-TERRAFORM-BASICS.md`](05-TERRAFORM-BASICS.md)

- HCL syntax fundamentals
- Providers and resources
- Variables and outputs
- Data sources
- Your first real infrastructure

---

## 🔗 Additional Resources

- [Terraform Downloads](https://www.terraform.io/downloads)
- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [tfenv GitHub](https://github.com/tfutils/tfenv)
- [Terraform Registry](https://registry.terraform.io/)

---

**Remember**: Terraform is just a tool - the real power comes from understanding infrastructure concepts! 🚀
