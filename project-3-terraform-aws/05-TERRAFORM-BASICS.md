# 📚 Terraform Basics - HCL Syntax & Core Concepts

## 🎯 Learning Objectives

By the end of this guide, you will understand:

- HCL (HashiCorp Configuration Language) syntax
- Terraform blocks and their purposes
- Resources, variables, and outputs
- Data sources and locals
- How to write clean, maintainable Terraform code

---

## 🤔 WHAT is HCL?

### Simple Definition

**HCL (HashiCorp Configuration Language)** is the language used to write Terraform configuration files. It's designed to be human-readable and easy to learn.

### Real-World Analogy 📝

Think of HCL like a **recipe card**:

**Recipe Card**:

```
Recipe: Chocolate Cake
Ingredients:
  - 2 cups flour
  - 1 cup sugar
  - 3 eggs
Instructions:
  1. Mix ingredients
  2. Bake at 350°F
```

**Terraform HCL**:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

Both are structured, readable, and tell you exactly what to do!

---

## 🏗️ HCL Syntax Fundamentals

### 1. Comments

```hcl
# This is a single-line comment
# Use # for comments

// This also works (C-style)

/* This is a
   multi-line
   comment */
```

**When to use**:

```hcl
# Good: Explain WHY
# This instance runs our production web server
resource "aws_instance" "web" {
  ami = "ami-123456"
}

# Bad: Explain WHAT (code already shows this)
# Create an instance
resource "aws_instance" "web" {
  ami = "ami-123456"
}
```

### 2. Blocks

**WHAT**: Containers for configuration  
**WHY**: Organize related settings  
**HOW**: Use curly braces `{}`

```hcl
# Block structure
block_type "label1" "label2" {
  argument1 = value1
  argument2 = value2
  
  nested_block {
    nested_argument = value
  }
}
```

**Example**:

```hcl
resource "aws_instance" "web" {
  # ↑ block_type  ↑ label1  ↑ label2
  
  ami           = "ami-123456"  # argument
  instance_type = "t2.micro"    # argument
  
  tags {                        # nested block
    Name = "WebServer"
  }
}
```

### 3. Arguments

**WHAT**: Key-value pairs that configure blocks  
**WHY**: Specify settings  
**HOW**: `key = value`

```hcl
# String
name = "my-server"

# Number
count = 3

# Boolean
enabled = true

# List
availability_zones = ["us-east-1a", "us-east-1b"]

# Map
tags = {
  Name        = "WebServer"
  Environment = "Production"
}
```

### 4. Strings

```hcl
# Simple string
name = "my-server"

# String with interpolation
name = "server-${var.environment}"
# Result: "server-production"

# Multi-line string
user_data = <<-EOF
  #!/bin/bash
  echo "Hello World"
  apt-get update
EOF
```

### 5. Numbers

```hcl
# Integer
count = 5

# Float
cpu_credits = 0.5
```

### 6. Booleans

```hcl
# True/False
enabled = true
monitoring = false
```

### 7. Lists

```hcl
# List of strings
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Access elements
first_zone = availability_zones[0]  # "us-east-1a"
```

### 8. Maps (Objects)

```hcl
# Map
tags = {
  Name        = "WebServer"
  Environment = "Production"
  Owner       = "DevOps Team"
}

# Access values
server_name = tags["Name"]  # "WebServer"
```

---

## 🧩 Core Terraform Blocks

### 1. Terraform Block

**WHAT**: Configures Terraform itself  
**WHY**: Set version requirements and backend  
**HOW**: Always at the top of your configuration

```hcl
terraform {
  # Terraform version requirement
  required_version = ">= 1.0"
  
  # Provider requirements
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # Backend configuration (where to store state)
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

**Line-by-line explanation**:

```hcl
terraform {
  # This block configures Terraform behavior
  
  required_version = ">= 1.0"
  # WHAT: Minimum Terraform version needed
  # WHY: Ensures compatibility
  # >= 1.0 means: version 1.0 or higher
  
  required_providers {
    # WHAT: List of providers this project needs
    # WHY: Terraform downloads these automatically
    
    aws = {
      # Provider name
      
      source  = "hashicorp/aws"
      # WHAT: Where to download from
      # WHY: Official AWS provider from HashiCorp
      # Format: namespace/provider-name
      
      version = "~> 4.0"
      # WHAT: Which version to use
      # WHY: Ensures compatibility
      # ~> 4.0 means: 4.0 <= version < 5.0
      # Allows: 4.0, 4.1, 4.67
      # Blocks: 5.0, 3.9
    }
  }
  
  backend "s3" {
    # WHAT: Where to store state file
    # WHY: Team collaboration, state locking
    # s3: Use AWS S3 bucket
    
    bucket = "my-terraform-state"
    # WHAT: S3 bucket name
    # WHY: Where state file is stored
    
    key    = "prod/terraform.tfstate"
    # WHAT: Path within bucket
    # WHY: Organize multiple projects
    
    region = "us-east-1"
    # WHAT: AWS region for bucket
    # WHY: Where bucket is located
  }
}
```

### 2. Provider Block

**WHAT**: Configures cloud provider  
**WHY**: Tells Terraform how to connect to AWS/Azure/GCP  
**HOW**: One provider block per provider

```hcl
provider "aws" {
  region = "us-east-1"
  
  # Optional: Explicit credentials (not recommended)
  # access_key = "YOUR_ACCESS_KEY"
  # secret_key = "YOUR_SECRET_KEY"
  
  # Better: Use AWS CLI credentials or environment variables
  
  default_tags {
    tags = {
      Project     = "MyApp"
      ManagedBy   = "Terraform"
    }
  }
}
```

**Line-by-line explanation**:

```hcl
provider "aws" {
  # WHAT: Configure AWS provider
  # WHY: Terraform needs to know how to talk to AWS
  
  region = "us-east-1"
  # WHAT: Default AWS region
  # WHY: All resources created here unless specified
  # us-east-1 = N. Virginia
  
  default_tags {
    # WHAT: Tags applied to ALL resources
    # WHY: Automatic tagging for organization
    
    tags = {
      Project     = "MyApp"
      # WHAT: Project name tag
      # WHY: Identify which project owns resource
      
      ManagedBy   = "Terraform"
      # WHAT: Management tool tag
      # WHY: Know resource is managed by Terraform
    }
  }
}
```

### 3. Resource Block

**WHAT**: Defines infrastructure component to create  
**WHY**: The actual "things" you're building  
**HOW**: `resource "type" "name" { }`

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

**Line-by-line explanation**:

```hcl
resource "aws_instance" "web" {
  # WHAT: Create an AWS EC2 instance
  # WHY: Need a server to run application
  # "aws_instance": Resource type (EC2 instance)
  # "web": Local name (how we reference it)
  
  ami           = "ami-0c55b159cbfafe1f0"
  # WHAT: Amazon Machine Image ID
  # WHY: Defines OS and software
  # This AMI: Ubuntu 20.04
  
  instance_type = "t2.micro"
  # WHAT: Instance size
  # WHY: Defines CPU/RAM
  # t2.micro: 1 vCPU, 1 GB RAM (free tier)
  
  tags = {
    # WHAT: Metadata labels
    # WHY: Identify and organize resources
    
    Name = "WebServer"
    # WHAT: Name tag
    # WHY: Shows in AWS console
  }
}
```

**Resource Naming Convention**:

```hcl
resource "provider_resourcetype" "local_name" {
  # provider: aws, azurerm, google
  # resourcetype: instance, bucket, database
  # local_name: how YOU reference it
}

# Examples:
resource "aws_instance" "web" { }        # AWS EC2 instance
resource "aws_s3_bucket" "data" { }      # AWS S3 bucket
resource "azurerm_virtual_machine" "vm" { }  # Azure VM
resource "google_compute_instance" "app" { } # GCP instance
```

### 4. Variable Block

**WHAT**: Input parameters for your configuration  
**WHY**: Make code reusable and flexible  
**HOW**: Define once, use many times

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  # No default = required input
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10"
  }
}
```

**Line-by-line explanation**:

```hcl
variable "instance_type" {
  # WHAT: Define a variable named "instance_type"
  # WHY: Make instance type configurable
  
  description = "EC2 instance type"
  # WHAT: Human-readable description
  # WHY: Documentation for users
  
  type        = string
  # WHAT: Data type
  # WHY: Validation (must be string)
  # Types: string, number, bool, list, map, object
  
  default     = "t2.micro"
  # WHAT: Default value if not provided
  # WHY: Sensible default for most cases
  # If no default: variable is required
}

variable "environment" {
  description = "Environment name"
  type        = string
  # No default = REQUIRED
  # User MUST provide value
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
  
  validation {
    # WHAT: Custom validation rule
    # WHY: Prevent invalid values
    
    condition     = var.instance_count > 0 && var.instance_count <= 10
    # WHAT: Validation logic
    # WHY: Must be between 1 and 10
    # && means AND
    
    error_message = "Instance count must be between 1 and 10"
    # WHAT: Error message if validation fails
    # WHY: Help user fix the problem
  }
}
```

**Using Variables**:

```hcl
# Define variable
variable "instance_type" {
  default = "t2.micro"
}

# Use variable
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = var.instance_type  # Reference with var.
}
```

**Variable Types**:

```hcl
# String
variable "name" {
  type    = string
  default = "my-server"
}

# Number
variable "count" {
  type    = number
  default = 3
}

# Boolean
variable "enabled" {
  type    = bool
  default = true
}

# List
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# Map
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "myapp"
  }
}

# Object (complex type)
variable "server_config" {
  type = object({
    instance_type = string
    disk_size     = number
    monitoring    = bool
  })
  default = {
    instance_type = "t2.micro"
    disk_size     = 20
    monitoring    = true
  }
}
```

### 5. Output Block

**WHAT**: Values to display after apply  
**WHY**: Get information about created resources  
**HOW**: Define what to show

```hcl
output "instance_ip" {
  description = "Public IP of web server"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "ID of web server"
  value       = aws_instance.web.id
}

output "connection_string" {
  description = "How to connect to server"
  value       = "ssh ubuntu@${aws_instance.web.public_ip}"
}
```

**Line-by-line explanation**:

```hcl
output "instance_ip" {
  # WHAT: Define output named "instance_ip"
  # WHY: Show IP address after creation
  
  description = "Public IP of web server"
  # WHAT: Human-readable description
  # WHY: Explain what this output is
  
  value       = aws_instance.web.public_ip
  # WHAT: The actual value to output
  # WHY: Get public IP from created instance
  # Format: resource_type.local_name.attribute
  # aws_instance.web: The resource we created
  # .public_ip: Attribute we want
}

output "connection_string" {
  description = "How to connect to server"
  value       = "ssh ubuntu@${aws_instance.web.public_ip}"
  # WHAT: String interpolation
  # WHY: Build connection command
  # ${...}: Insert variable value
  # Result: "ssh ubuntu@54.123.45.67"
}
```

**After terraform apply**:

```bash
terraform apply

# Outputs:
# instance_ip = "54.123.45.67"
# instance_id = "i-0123456789abcdef"
# connection_string = "ssh ubuntu@54.123.45.67"

# Query specific output
terraform output instance_ip
# Output: "54.123.45.67"
```

### 6. Data Source Block

**WHAT**: Query existing resources  
**WHY**: Use information from resources not managed by Terraform  
**HOW**: `data "type" "name" { }`

```hcl
# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu)
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Use the AMI
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id  # Use data source
  instance_type = "t2.micro"
}
```

**Line-by-line explanation**:

```hcl
data "aws_ami" "ubuntu" {
  # WHAT: Query for an AMI (not create one)
  # WHY: Get latest Ubuntu AMI automatically
  # data: Read-only query
  # "aws_ami": Type of data to query
  # "ubuntu": Local name for reference
  
  most_recent = true
  # WHAT: Get the newest matching AMI
  # WHY: Always use latest version
  
  owners      = ["099720109477"]
  # WHAT: Filter by owner ID
  # WHY: Only get official Ubuntu AMIs
  # 099720109477: Canonical's AWS account
  
  filter {
    # WHAT: Additional filtering criteria
    # WHY: Find specific AMI pattern
    
    name   = "name"
    # WHAT: Filter by AMI name
    
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    # WHAT: Name pattern to match
    # WHY: Ubuntu 20.04 (Focal) server images
    # *: Wildcard (any version number)
  }
}

# Use the data source
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  # WHAT: Reference data source
  # WHY: Use the AMI ID we queried
  # Format: data.type.name.attribute
  # .id: Get the AMI ID
}
```

### 7. Local Values

**WHAT**: Computed values used multiple times  
**WHY**: Avoid repetition, make code cleaner  
**HOW**: `locals { }` block

```hcl
locals {
  # Computed values
  common_tags = {
    Project     = "MyApp"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  instance_name = "${var.environment}-web-server"
  
  # Conditional logic
  instance_type = var.environment == "prod" ? "t2.small" : "t2.micro"
}

# Use locals
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = local.instance_type  # Reference with local.
  
  tags = merge(
    local.common_tags,
    {
      Name = local.instance_name
    }
  )
}
```

**Line-by-line explanation**:

```hcl
locals {
  # WHAT: Define local values
  # WHY: Reusable computed values
  
  common_tags = {
    # WHAT: Tags used on all resources
    # WHY: Consistent tagging
    
    Project     = "MyApp"
    Environment = var.environment  # Use variable
    ManagedBy   = "Terraform"
  }
  
  instance_name = "${var.environment}-web-server"
  # WHAT: Computed instance name
  # WHY: Dynamic naming based on environment
  # Result: "prod-web-server" or "dev-web-server"
  
  instance_type = var.environment == "prod" ? "t2.small" : "t2.micro"
  # WHAT: Conditional expression
  # WHY: Different sizes for different environments
  # Format: condition ? true_value : false_value
  # If prod: t2.small, else: t2.micro
}

# Use locals
resource "aws_instance" "web" {
  instance_type = local.instance_type
  # WHAT: Reference local value
  # WHY: Use computed instance type
  # Format: local.name (no 's')
  
  tags = merge(
    local.common_tags,
    {
      Name = local.instance_name
    }
  )
  # WHAT: Merge two maps
  # WHY: Combine common tags + specific tags
  # merge(): Built-in function
}
```

---

## 🔗 Resource References

### Referencing Resources

```hcl
# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create subnet (references VPC)
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id  # Reference VPC
  cidr_block = "10.0.1.0/24"
}

# Create instance (references subnet)
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id  # Reference subnet
}
```

**Reference Format**:

```
resource_type.local_name.attribute

Examples:
aws_vpc.main.id              # VPC ID
aws_instance.web.public_ip   # Instance public IP
aws_subnet.public.cidr_block # Subnet CIDR
```

**Terraform automatically handles dependencies**:

```
1. Creates VPC first
2. Then creates Subnet (needs VPC)
3. Finally creates Instance (needs Subnet)
```

---

## 🎯 Complete Example

Let's put it all together:

```hcl
# ============================================
# Terraform Configuration
# ============================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# ============================================
# Provider Configuration
# ============================================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# ============================================
# Variables
# ============================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

# ============================================
# Local Values
# ============================================

locals {
  common_tags = {
    Project     = "WebApp"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  instance_name = "${var.environment}-web"
}

# ============================================
# Data Sources
# ============================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# ============================================
# Resources
# ============================================

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "${local.instance_name}-${count.index + 1}"
  }
}

# ============================================
# Outputs
# ============================================

output "instance_ids" {
  description = "IDs of created instances"
  value       = aws_instance.web[*].id
}

output "instance_ips" {
  description = "Public IPs of created instances"
  value       = aws_instance.web[*].public_ip
}
```

---

## 🎓 Interview Questions

### Q1: What is HCL?

**Answer**: HashiCorp Configuration Language - the declarative language used to write Terraform configurations. It's human-readable and designed for defining infrastructure.

### Q2: What's the difference between a resource and a data source?

**Answer**:

- **Resource**: Creates/manages infrastructure (write operation)
- **Data Source**: Queries existing infrastructure (read operation)

### Q3: How do you reference one resource from another?

**Answer**: Use `resource_type.local_name.attribute`
Example: `aws_vpc.main.id` references the ID of a VPC resource named "main"

### Q4: What are local values used for?

**Answer**: Local values store computed values that are used multiple times in your configuration. They help avoid repetition and make code cleaner.

### Q5: How do you make a variable required?

**Answer**: Don't provide a `default` value. Terraform will prompt for the value or error if not provided.

### Q6: What's the difference between variables and locals?

**Answer**:

- **Variables**: Input parameters (set by user)
- **Locals**: Computed values (calculated from variables/resources)

### Q7: How do you use conditional logic in Terraform?

**Answer**: Use ternary operator: `condition ? true_value : false_value`
Example: `var.env == "prod" ? "t2.large" : "t2.micro"`

### Q8: What does `count` do in a resource?

**Answer**: Creates multiple instances of a resource. `count = 3` creates 3 identical resources. Access with `resource_name[0]`, `resource_name[1]`, etc.

---

## 🎯 Key Takeaways

1. **HCL is declarative** - Describe what you want, not how to create it
2. **Blocks organize configuration** - terraform, provider, resource, variable, output
3. **Variables make code reusable** - Input parameters
4. **Locals avoid repetition** - Computed values
5. **Data sources query existing resources** - Read-only
6. **Resources create infrastructure** - Write operations
7. **Outputs display information** - Results after apply
8. **References create dependencies** - Terraform handles order

---

## 📚 What's Next?

Now that you understand Terraform basics, let's create your first infrastructure:

**Next Guide**: [`06-FIRST-INFRASTRUCTURE.md`](06-FIRST-INFRASTRUCTURE.md)

- Create your first EC2 instance
- Add security groups
- Configure networking
- Complete step-by-step implementation

---

**Remember**: HCL is designed to be readable - if you can read it, you can write it! 🚀
