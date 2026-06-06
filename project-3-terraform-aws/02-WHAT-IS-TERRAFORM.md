# 🏗️ What is Terraform?

## 🎯 Learning Objectives

By the end of this guide, you will understand:

- What Terraform is and how it works
- Terraform's architecture and components
- Why Terraform is the most popular IaC tool
- When to use Terraform vs other tools

---

## 🤔 WHAT is Terraform?

### Simple Definition

**Terraform** is an open-source Infrastructure as Code tool created by HashiCorp that lets you build, change, and version infrastructure safely and efficiently.

### Real-World Analogy 🏗️

Think of Terraform as a **construction manager**:

**Without Terraform**:

- You call different contractors for each task
- Electrician, plumber, carpenter work separately
- Hard to coordinate
- No single source of truth

**With Terraform**:

- One construction manager (Terraform)
- Coordinates all contractors (AWS, Azure, GCP)
- Single blueprint (Terraform code)
- Everything works together

### Technical Definition

Terraform is a declarative IaC tool that uses HashiCorp Configuration Language (HCL) to define and provision infrastructure across multiple cloud providers through their APIs.

---

## 🎯 WHY Use Terraform?

### Reason 1: Multi-Cloud Support 🌍

**Problem**: Different clouds, different tools

```
AWS → CloudFormation
Azure → ARM Templates
GCP → Deployment Manager
```

**Terraform Solution**: One tool for all clouds

```hcl
# Same syntax for all clouds!

# AWS
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}

# Azure
resource "azurerm_virtual_machine" "web" {
  name     = "web-vm"
  vm_size  = "Standard_B1s"
}

# GCP
resource "google_compute_instance" "web" {
  name         = "web-instance"
  machine_type = "f1-micro"
}
```

### Reason 2: Declarative Syntax ✅

**What You Write** (Declarative):

```hcl
resource "aws_instance" "web" {
  count = 5  # I want 5 servers
}
```

**What Terraform Does** (Behind the scenes):

```
1. Check current state: 0 servers exist
2. Calculate: Need to create 5 servers
3. Create server 1
4. Create server 2
5. Create server 3
6. Create server 4
7. Create server 5
```

You just say **WHAT** you want, Terraform figures out **HOW**!

### Reason 3: State Management 🗄️

Terraform keeps track of your infrastructure:

```
Current Infrastructure (Real World)
         ↕️
Terraform State File
         ↕️
Terraform Code (What you want)
```

**Example**:

```hcl
# You have 3 servers running
# State file knows: 3 servers exist

# You change code to 5 servers
resource "aws_instance" "web" {
  count = 5  # Changed from 3 to 5
}

# Terraform calculates:
# Current: 3 servers
# Desired: 5 servers
# Action: Create 2 more servers ✅
```

### Reason 4: Plan Before Apply 🔍

**Preview Changes Before Making Them**:

```bash
terraform plan
# Output:
# + aws_instance.web[3] will be created
# + aws_instance.web[4] will be created
# 
# Plan: 2 to add, 0 to change, 0 to destroy
```

**Then Apply**:

```bash
terraform apply
# Creates the 2 new servers
```

### Reason 5: Huge Ecosystem 🌟

**Providers** (Integrations):

- 3000+ providers
- AWS, Azure, GCP
- GitHub, Datadog, PagerDuty
- Kubernetes, Docker
- Almost everything!

**Modules** (Reusable code):

- Terraform Registry
- Pre-built modules
- Community contributions
- Best practices built-in

---

## 🏗️ HOW Does Terraform Work?

### Terraform Architecture

```
┌─────────────────────────────────────────┐
│         Terraform CLI                    │
│  (terraform plan, apply, destroy)        │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│         Terraform Core                   │
│  • Reads configuration (.tf files)       │
│  • Manages state                         │
│  • Creates execution plan                │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│         Providers                        │
│  • AWS Provider                          │
│  • Azure Provider                        │
│  • GCP Provider                          │
│  • 3000+ more                            │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│         Cloud APIs                       │
│  • AWS API                               │
│  • Azure API                             │
│  • GCP API                               │
└─────────────────────────────────────────┘
```

### Terraform Workflow

```
1. WRITE
   ↓
   Write .tf files
   Define infrastructure

2. INIT
   ↓
   terraform init
   Download providers

3. PLAN
   ↓
   terraform plan
   Preview changes

4. APPLY
   ↓
   terraform apply
   Create infrastructure

5. MANAGE
   ↓
   Update code → Plan → Apply
   Infrastructure evolves
```

### Detailed Example

**Step 1: Write Configuration**

```hcl
# main.tf
terraform {
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

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

**Step 2: Initialize**

```bash
terraform init

# What happens:
# 1. Creates .terraform directory
# 2. Downloads AWS provider plugin
# 3. Initializes backend (state storage)
# 4. Ready to use!
```

**Step 3: Plan**

```bash
terraform plan

# Output:
# Terraform will perform the following actions:
# 
#   # aws_instance.web will be created
#   + resource "aws_instance" "web" {
#       + ami                    = "ami-0c55b159cbfafe1f0"
#       + instance_type          = "t2.micro"
#       + tags                   = {
#           + "Name" = "WebServer"
#         }
#     }
# 
# Plan: 1 to add, 0 to change, 0 to destroy.
```

**Step 4: Apply**

```bash
terraform apply

# Output:
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
# 
# Enter a value: yes
# 
# aws_instance.web: Creating...
# aws_instance.web: Creation complete after 45s [id=i-0123456789abcdef]
# 
# Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**Step 5: Verify State**

```bash
terraform show

# Output:
# # aws_instance.web:
# resource "aws_instance" "web" {
#     ami                    = "ami-0c55b159cbfafe1f0"
#     id                     = "i-0123456789abcdef"
#     instance_type          = "t2.micro"
#     tags                   = {
#         "Name" = "WebServer"
#     }
# }
```

---

## 🧩 Terraform Components

### 1. Configuration Files (.tf)

**Purpose**: Define your infrastructure

```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```

**File Types**:

- `main.tf` - Main configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `terraform.tfvars` - Variable values

### 2. Providers

**Purpose**: Connect to cloud platforms

```hcl
# Configure AWS provider
provider "aws" {
  region     = "us-east-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
}
```

**Popular Providers**:

- `aws` - Amazon Web Services
- `azurerm` - Microsoft Azure
- `google` - Google Cloud Platform
- `kubernetes` - Kubernetes
- `docker` - Docker

### 3. Resources

**Purpose**: Infrastructure components to create

```hcl
# Create an EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}

# Create an S3 bucket
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

# Create a security group
resource "aws_security_group" "web" {
  name = "web-sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 4. Variables

**Purpose**: Make code reusable

```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# main.tf
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = var.instance_type  # Use variable
  
  tags = {
    Environment = var.environment
  }
}
```

### 5. Outputs

**Purpose**: Display information after apply

```hcl
# outputs.tf
output "instance_ip" {
  description = "Public IP of web server"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "ID of web server"
  value       = aws_instance.web.id
}
```

**After apply**:

```bash
terraform apply

# Outputs:
# instance_ip = "54.123.45.67"
# instance_id = "i-0123456789abcdef"
```

### 6. State File

**Purpose**: Track current infrastructure

```json
// terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.5.0",
  "resources": [
    {
      "type": "aws_instance",
      "name": "web",
      "instances": [
        {
          "attributes": {
            "id": "i-0123456789abcdef",
            "ami": "ami-123456",
            "instance_type": "t2.micro",
            "public_ip": "54.123.45.67"
          }
        }
      ]
    }
  ]
}
```

**Important**:

- Never edit state file manually
- Store remotely (S3, Terraform Cloud)
- Contains sensitive data

### 7. Modules

**Purpose**: Reusable infrastructure components

```hcl
# Using a module
module "web_server" {
  source = "./modules/server"
  
  instance_type = "t2.micro"
  environment   = "production"
}

# Module definition (modules/server/main.tf)
variable "instance_type" {}
variable "environment" {}

resource "aws_instance" "this" {
  ami           = "ami-123456"
  instance_type = var.instance_type
  
  tags = {
    Environment = var.environment
  }
}
```

---

## 🆚 Terraform vs Other Tools

### Terraform vs CloudFormation

| Feature | Terraform | CloudFormation |
|---------|-----------|----------------|
| **Cloud Support** | Multi-cloud | AWS only |
| **Language** | HCL (easy) | JSON/YAML (verbose) |
| **State** | Explicit | Implicit |
| **Community** | Huge | AWS only |
| **Learning Curve** | Medium | Medium |
| **Cost** | Free | Free |

**When to use Terraform**: Multi-cloud, better syntax, larger community  
**When to use CloudFormation**: AWS-only, deep AWS integration

### Terraform vs Ansible

| Feature | Terraform | Ansible |
|---------|-----------|---------|
| **Purpose** | Provision infrastructure | Configure servers |
| **Type** | Declarative | Procedural/Declarative |
| **State** | Yes | No |
| **Idempotent** | Yes | Yes |
| **Best For** | Creating resources | Installing software |

**Best Practice**: Use both together!

```
1. Terraform creates servers
2. Ansible configures servers
```

### Terraform vs Pulumi

| Feature | Terraform | Pulumi |
|---------|-----------|--------|
| **Language** | HCL | Python/JS/Go/C# |
| **Learning** | New language | Use existing skills |
| **Community** | Larger | Growing |
| **Maturity** | More mature | Newer |

**When to use Terraform**: Standard choice, proven  
**When to use Pulumi**: Want to use real programming languages

---

## 🎯 When to Use Terraform

### ✅ Use Terraform When

1. **Multi-Cloud Infrastructure**

```hcl
# Same tool for AWS, Azure, GCP
provider "aws" { }
provider "azurerm" { }
provider "google" { }
```

1. **Need to Provision Infrastructure**

```hcl
# Create servers, networks, databases
resource "aws_instance" "web" { }
resource "aws_vpc" "main" { }
resource "aws_rds_instance" "db" { }
```

1. **Want Declarative Approach**

```hcl
# Describe what you want
resource "aws_instance" "web" {
  count = 5  # I want 5 servers
}
```

1. **Need State Management**

```
Track what exists
Know what changed
Plan before applying
```

1. **Team Collaboration**

```
Version control
Code reviews
Shared state
```

### ❌ Don't Use Terraform When

1. **Only Configuring Existing Servers**

```
Use Ansible instead
Terraform creates, Ansible configures
```

1. **Need Complex Logic**

```
Terraform is declarative
Limited programming constructs
Use Pulumi for complex logic
```

1. **Very Simple One-Time Tasks**

```
Manual might be faster
Terraform has overhead
```

---

## 🏗️ Terraform Architecture Deep Dive

### How Terraform Executes

```
1. READ CONFIGURATION
   ↓
   Parse .tf files
   Validate syntax
   
2. LOAD STATE
   ↓
   Read terraform.tfstate
   Know current infrastructure
   
3. REFRESH
   ↓
   Query cloud APIs
   Update state with reality
   
4. CREATE PLAN
   ↓
   Compare desired vs current
   Calculate changes needed
   
5. EXECUTE PLAN
   ↓
   Call cloud APIs
   Create/update/delete resources
   
6. UPDATE STATE
   ↓
   Save new state
   Track changes
```

### Terraform Graph

Terraform builds a dependency graph:

```
┌─────────────┐
│   VPC       │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│   Subnet    │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  Instance   │
└─────────────┘
```

**Code**:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id  # Depends on VPC
  cidr_block = "10.0.1.0/24"
}

resource "aws_instance" "web" {
  ami           = "ami-123456"
  subnet_id     = aws_subnet.main.id  # Depends on Subnet
  instance_type = "t2.micro"
}
```

**Terraform automatically**:

1. Creates VPC first
2. Then creates Subnet
3. Finally creates Instance

---

## 💡 Terraform Best Practices

### 1. Use Version Control

```bash
git init
git add *.tf
git commit -m "Initial infrastructure"
```

### 2. Use Remote State

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 3. Use Variables

```hcl
# Don't hardcode
resource "aws_instance" "web" {
  instance_type = "t2.micro"  # ❌
}

# Use variables
variable "instance_type" {
  default = "t2.micro"
}

resource "aws_instance" "web" {
  instance_type = var.instance_type  # ✅
}
```

### 4. Use Modules

```hcl
# Reusable code
module "web_server" {
  source = "./modules/server"
  count  = 3
}
```

### 5. Always Plan Before Apply

```bash
terraform plan  # Review changes
terraform apply # Apply if looks good
```

### 6. Use Workspaces for Environments

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

---

## 🎓 Interview Questions

### Q1: What is Terraform?

**Answer**: Terraform is an open-source Infrastructure as Code tool that uses declarative configuration files to provision and manage infrastructure across multiple cloud providers.

### Q2: How does Terraform work?

**Answer**: Terraform:

1. Reads configuration files (.tf)
2. Compares desired state with current state
3. Creates an execution plan
4. Applies changes through provider APIs
5. Updates state file

### Q3: What is Terraform state?

**Answer**: State is a file (terraform.tfstate) that tracks the current state of your infrastructure. It maps real-world resources to your configuration and tracks metadata.

### Q4: Why use Terraform over CloudFormation?

**Answer**:

- **Multi-cloud**: Works with AWS, Azure, GCP, etc.
- **Better syntax**: HCL is cleaner than JSON/YAML
- **Larger community**: More modules and examples
- **Explicit state**: Better control over infrastructure state

### Q5: What are Terraform providers?

**Answer**: Providers are plugins that enable Terraform to interact with cloud platforms, SaaS providers, and APIs. Examples: AWS, Azure, GCP, Kubernetes, Docker.

### Q6: What is the difference between Terraform and Ansible?

**Answer**:

- **Terraform**: Provisions infrastructure (creates servers, networks)
- **Ansible**: Configures infrastructure (installs software, manages files)
- **Best Practice**: Use both - Terraform creates, Ansible configures

### Q7: What is a Terraform module?

**Answer**: A module is a container for multiple resources that are used together. It's a way to package and reuse Terraform configurations.

### Q8: How do you handle secrets in Terraform?

**Answer**:

- Use environment variables
- Use AWS Secrets Manager / Vault
- Never commit secrets to version control
- Use terraform.tfvars (gitignored)
- Use encrypted remote state

---

## 🎯 Key Takeaways

1. **Terraform = Multi-cloud IaC tool**
2. **Declarative**: Describe what you want, not how
3. **State Management**: Tracks current infrastructure
4. **Plan Before Apply**: Preview changes first
5. **Huge Ecosystem**: 3000+ providers, thousands of modules
6. **Best for**: Provisioning infrastructure across clouds

---

## 📚 What's Next?

Now that you understand Terraform, let's set up AWS:

**Next Guide**: [`03-AWS-SETUP.md`](03-AWS-SETUP.md)

- Create AWS account
- Set up IAM user
- Configure AWS credentials
- Understand AWS basics

---

## 🔗 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform)

---

**Remember**: Terraform is like a construction manager for your cloud infrastructure - it coordinates everything and keeps track of what's built! 🏗️
