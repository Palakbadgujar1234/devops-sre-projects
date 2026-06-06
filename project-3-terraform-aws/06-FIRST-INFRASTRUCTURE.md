# 🚀 Your First Infrastructure - Step-by-Step

## 📖 WHAT: What Are We Building?

A complete, working AWS infrastructure:

- ✅ EC2 instance (virtual server)
- ✅ Security group (firewall rules)
- ✅ Key pair (SSH access)
- ✅ Elastic IP (static IP address)
- ✅ All with Terraform!

This is a **real project** you can run and show in interviews!

## 🎯 WHY: Why This Project?

- Shows you can create real infrastructure
- Demonstrates Terraform best practices
- Similar to production setups
- Great portfolio piece
- **Actually works!**

---

## 🏗️ Project Structure

```
my-first-terraform/
├── main.tf           # Main configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── terraform.tfvars  # Variable values (gitignored)
└── .gitignore        # Git ignore file
```

---

## 📝 Step-by-Step Implementation

### Step 1: Create Project Directory

```bash
# Create project directory
mkdir ~/my-first-terraform
cd ~/my-first-terraform

# WHAT: Create a dedicated directory for this project
# WHY: Keep Terraform files organized
# HOW: Standard practice for Terraform projects
```

### Step 2: Create .gitignore

**WHAT**: Prevent committing sensitive files  
**WHY**: Security - don't expose credentials or state  
**HOW**: Create .gitignore file

```bash
cat > .gitignore << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
*.tfstate.backup
.terraform/
.terraform.lock.hcl

# Sensitive files
*.tfvars
*.pem
*.key

# OS files
.DS_Store
Thumbs.db
EOF

# WHAT: List of files to ignore in git
# WHY: Prevent committing sensitive data
# *.tfstate: Contains resource IDs and sensitive data
# *.tfvars: May contain secrets
# *.pem: SSH private keys
```

### Step 3: Create variables.tf

**WHAT**: Define input variables  
**WHY**: Make configuration reusable  
**HOW**: Create variables.tf file

```bash
cat > variables.tf << 'EOF'
# ============================================
# Input Variables
# ============================================

variable "aws_region" {
  description = "AWS region to create resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "my-first-project"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "Your IP address for SSH access (get from https://whatismyip.com)"
  type        = string
  # No default - you must provide this!
}
EOF
```

**Line-by-line explanation**:

```hcl
variable "aws_region" {
  # WHAT: Define a variable for AWS region
  # WHY: Make region configurable
  
  description = "AWS region to create resources"
  # WHAT: Human-readable description
  # WHY: Documentation for users
  
  type        = string
  # WHAT: Variable type
  # WHY: Validation - must be a string
  
  default     = "us-east-1"
  # WHAT: Default value
  # WHY: Use us-east-1 if not specified
  # us-east-1 = N. Virginia (cheapest, most services)
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
  # No default = REQUIRED
  # User MUST provide their IP address
  # WHY: Security - only allow SSH from your IP
}
```

### Step 4: Create terraform.tfvars

**WHAT**: Provide variable values  
**WHY**: Separate configuration from code  
**HOW**: Create terraform.tfvars file

```bash
# First, get your IP address
curl https://api.ipify.org
# This will show your public IP address
# Example output: 203.0.113.45

# Create terraform.tfvars with your IP
cat > terraform.tfvars << 'EOF'
# Your configuration values
aws_region   = "us-east-1"
project_name = "my-first-project"
environment  = "dev"
my_ip        = "YOUR_IP_HERE/32"  # Replace with your actual IP!
EOF

# IMPORTANT: Replace YOUR_IP_HERE with your actual IP!
# Example: my_ip = "203.0.113.45/32"
# The /32 means "only this exact IP"
```

**Edit the file**:

```bash
# Open in your editor
nano terraform.tfvars
# or
code terraform.tfvars

# Replace YOUR_IP_HERE with your actual IP
# Save and close
```

### Step 5: Create main.tf

**WHAT**: Main Terraform configuration  
**WHY**: Defines all infrastructure  
**HOW**: Create main.tf file

```bash
cat > main.tf << 'EOF'
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
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================
# Data Sources
# ============================================

# Get latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================
# Security Group
# ============================================

resource "aws_security_group" "web" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for web server"
  
  # Allow SSH from your IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  # Allow HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-sg"
  }
}

# ============================================
# SSH Key Pair
# ============================================

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file("~/.ssh/id_rsa.pub")
  
  tags = {
    Name = "${var.project_name}-${var.environment}-key"
  }
}

# ============================================
# EC2 Instance
# ============================================

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  
  # User data script - runs on first boot
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
  
  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}

# ============================================
# Elastic IP
# ============================================

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  vpc      = true
  
  tags = {
    Name = "${var.project_name}-${var.environment}-eip"
  }
}
EOF
```

**Detailed Line-by-Line Explanation**:

```hcl
# ============================================
# Data Sources
# ============================================

data "aws_ami" "ubuntu" {
  # WHAT: Query for Ubuntu AMI
  # WHY: Get latest Ubuntu 20.04 automatically
  # HOW: AWS provides official Ubuntu AMIs
  
  most_recent = true
  # WHAT: Get the newest matching AMI
  # WHY: Always use latest security patches
  
  owners      = ["099720109477"]
  # WHAT: Filter by owner
  # WHY: Only official Canonical (Ubuntu) AMIs
  # 099720109477 = Canonical's AWS account ID
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    # WHAT: Filter by AMI name pattern
    # WHY: Get Ubuntu 20.04 (Focal Fossa)
    # hvm-ssd: Hardware Virtual Machine with SSD
    # amd64: 64-bit architecture
    # server: Server edition (no GUI)
    # *: Any version number
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
    # WHAT: Filter by virtualization type
    # WHY: HVM is modern, better performance
    # HVM = Hardware Virtual Machine
  }
}

# ============================================
# Security Group (Firewall Rules)
# ============================================

resource "aws_security_group" "web" {
  # WHAT: Create a security group (firewall)
  # WHY: Control network access to instance
  
  name        = "${var.project_name}-${var.environment}-sg"
  # WHAT: Security group name
  # WHY: Descriptive naming
  # ${...}: String interpolation
  # Result: "my-first-project-dev-sg"
  
  description = "Security group for web server"
  # WHAT: Human-readable description
  # WHY: Documentation
  
  # Ingress = Inbound rules (traffic coming IN)
  
  ingress {
    description = "SSH from my IP"
    # WHAT: Allow SSH connections
    # WHY: Need to connect to server
    
    from_port   = 22
    to_port     = 22
    # WHAT: Port range (22 = SSH)
    # WHY: SSH uses port 22
    
    protocol    = "tcp"
    # WHAT: Network protocol
    # WHY: SSH uses TCP
    
    cidr_blocks = [var.my_ip]
    # WHAT: Allowed IP addresses
    # WHY: Only allow YOUR IP (security!)
    # Example: ["203.0.113.45/32"]
    # /32 = exact IP, not a range
  }
  
  ingress {
    description = "HTTP from anywhere"
    # WHAT: Allow HTTP connections
    # WHY: Web server needs to be accessible
    
    from_port   = 80
    to_port     = 80
    # WHAT: Port 80 (HTTP)
    # WHY: Standard web port
    
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # WHAT: Allow from anywhere
    # WHY: Public web server
    # 0.0.0.0/0 = all IP addresses
  }
  
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # WHAT: Allow HTTPS (secure HTTP)
    # WHY: For SSL/TLS connections
    # Port 443 = HTTPS
  }
  
  # Egress = Outbound rules (traffic going OUT)
  
  egress {
    description = "Allow all outbound"
    # WHAT: Allow all outbound traffic
    # WHY: Server needs to download updates, etc.
    
    from_port   = 0
    to_port     = 0
    # WHAT: All ports
    # WHY: 0-0 means all ports
    
    protocol    = "-1"
    # WHAT: All protocols
    # WHY: -1 means all protocols (TCP, UDP, ICMP, etc.)
    
    cidr_blocks = ["0.0.0.0/0"]
    # WHAT: To anywhere
    # WHY: Allow server to connect to internet
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-sg"
  }
}

# ============================================
# SSH Key Pair
# ============================================

resource "aws_key_pair" "deployer" {
  # WHAT: Upload SSH public key to AWS
  # WHY: Need key to SSH into instance
  
  key_name   = "${var.project_name}-${var.environment}-key"
  # WHAT: Name for the key in AWS
  # WHY: Identify the key
  
  public_key = file("~/.ssh/id_rsa.pub")
  # WHAT: Read public key from file
  # WHY: Upload your existing SSH key
  # file(): Built-in function to read files
  # ~/.ssh/id_rsa.pub: Your SSH public key
  # NOTE: You must have this file! (created in AWS setup guide)
}

# ============================================
# EC2 Instance
# ============================================

resource "aws_instance" "web" {
  # WHAT: Create an EC2 instance (virtual server)
  # WHY: Need a server to run applications
  
  ami           = data.aws_ami.ubuntu.id
  # WHAT: Use the Ubuntu AMI we queried
  # WHY: Get latest Ubuntu automatically
  # data.aws_ami.ubuntu.id: Reference data source
  
  instance_type = "t2.micro"
  # WHAT: Instance size
  # WHY: t2.micro is free tier eligible
  # t2.micro: 1 vCPU, 1 GB RAM
  
  key_name               = aws_key_pair.deployer.key_name
  # WHAT: SSH key to use
  # WHY: Need key to connect
  # aws_key_pair.deployer.key_name: Reference key resource
  
  vpc_security_group_ids = [aws_security_group.web.id]
  # WHAT: Security groups to apply
  # WHY: Control network access
  # []: List (can have multiple security groups)
  # aws_security_group.web.id: Reference security group
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
  # WHAT: Script that runs on first boot
  # WHY: Automatically set up web server
  # <<-EOF...EOF: Multi-line string (heredoc)
  # #!/bin/bash: Bash script
  # apt-get update: Update package list
  # apt-get install -y nginx: Install nginx web server
  # echo "...": Create simple web page
  # systemctl start nginx: Start nginx
  # systemctl enable nginx: Start nginx on boot
  
  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}

# ============================================
# Elastic IP
# ============================================

resource "aws_eip" "web" {
  # WHAT: Create an Elastic IP (static IP)
  # WHY: IP doesn't change if instance restarts
  
  instance = aws_instance.web.id
  # WHAT: Attach to our instance
  # WHY: Associate IP with server
  # aws_instance.web.id: Reference instance
  
  vpc      = true
  # WHAT: Use VPC (Virtual Private Cloud)
  # WHY: Modern AWS networking
  
  tags = {
    Name = "${var.project_name}-${var.environment}-eip"
  }
}
```

### Step 6: Create outputs.tf

**WHAT**: Define output values  
**WHY**: Display important information after creation  
**HOW**: Create outputs.tf file

```bash
cat > outputs.tf << 'EOF'
# ============================================
# Outputs
# ============================================

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address (Elastic IP)"
  value       = aws_eip.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name"
  value       = aws_instance.web.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web.id
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.web.public_ip}"
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_eip.web.public_ip}"
}
EOF
```

**Line-by-line explanation**:

```hcl
output "instance_public_ip" {
  # WHAT: Define output named "instance_public_ip"
  # WHY: Show the IP address after creation
  
  description = "Public IP address (Elastic IP)"
  # WHAT: Human-readable description
  # WHY: Explain what this output is
  
  value       = aws_eip.web.public_ip
  # WHAT: The actual value to output
  # WHY: Get public IP from Elastic IP resource
  # aws_eip.web: The Elastic IP we created
  # .public_ip: Attribute containing the IP address
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.web.public_ip}"
  # WHAT: Complete SSH command
  # WHY: Easy copy-paste to connect
  # ${...}: String interpolation
  # Result: "ssh -i ~/.ssh/id_rsa ubuntu@54.123.45.67"
}
```

### Step 7: Verify Your Setup

```bash
# Check all files are created
ls -la

# Expected output:
# .gitignore
# main.tf
# variables.tf
# terraform.tfvars
# outputs.tf

# WHAT: List all files
# WHY: Verify everything is in place
```

### Step 8: Initialize Terraform

```bash
terraform init

# WHAT: Initialize Terraform working directory
# WHY: Download AWS provider plugin
# HOW: Terraform reads configuration and downloads dependencies

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

**What happened**:

```
1. Created .terraform/ directory
2. Downloaded AWS provider plugin
3. Created .terraform.lock.hcl (version lock file)
4. Ready to use!
```

### Step 9: Validate Configuration

```bash
terraform validate

# WHAT: Check if configuration is valid
# WHY: Catch syntax errors before planning
# HOW: Terraform parses all .tf files

# Expected output:
# Success! The configuration is valid.

# If you see errors:
# - Check syntax (missing quotes, brackets, etc.)
# - Check variable names
# - Check resource references
```

### Step 10: Format Code

```bash
terraform fmt

# WHAT: Format code to standard style
# WHY: Keep code consistent and readable
# HOW: Terraform reformats all .tf files

# Expected output:
# main.tf
# variables.tf
# outputs.tf
# (Shows which files were formatted)
```

### Step 11: Plan Infrastructure

```bash
terraform plan

# WHAT: Preview changes Terraform will make
# WHY: See what will be created before actually creating it
# HOW: Terraform compares desired state with current state

# Expected output (abbreviated):
# Terraform will perform the following actions:
# 
#   # aws_eip.web will be created
#   + resource "aws_eip" "web" {
#       + public_ip = (known after apply)
#       ...
#     }
# 
#   # aws_instance.web will be created
#   + resource "aws_instance" "web" {
#       + ami           = "ami-0c55b159cbfafe1f0"
#       + instance_type = "t2.micro"
#       ...
#     }
# 
#   # aws_key_pair.deployer will be created
#   + resource "aws_key_pair" "deployer" {
#       + key_name   = "my-first-project-dev-key"
#       + public_key = "ssh-rsa AAAAB3..."
#       ...
#     }
# 
#   # aws_security_group.web will be created
#   + resource "aws_security_group" "web" {
#       + name = "my-first-project-dev-sg"
#       ...
#     }
# 
# Plan: 4 to add, 0 to change, 0 to destroy.
```

**Understanding the output**:

```
+ = Will be created
~ = Will be modified
- = Will be destroyed

(known after apply) = Value not known until resource is created
```

### Step 12: Apply Configuration

```bash
terraform apply

# WHAT: Create the infrastructure
# WHY: Actually build what we planned
# HOW: Terraform calls AWS APIs to create resources

# You'll see the plan again, then:
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
# 
# Enter a value: yes

# Type: yes
# Press Enter

# Expected output:
# aws_key_pair.deployer: Creating...
# aws_security_group.web: Creating...
# aws_key_pair.deployer: Creation complete after 1s
# aws_security_group.web: Creation complete after 2s
# aws_instance.web: Creating...
# aws_instance.web: Still creating... [10s elapsed]
# aws_instance.web: Still creating... [20s elapsed]
# aws_instance.web: Still creating... [30s elapsed]
# aws_instance.web: Creation complete after 35s
# aws_eip.web: Creating...
# aws_eip.web: Creation complete after 2s
# 
# Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
# 
# Outputs:
# 
# instance_id = "i-0123456789abcdef"
# instance_public_ip = "54.123.45.67"
# instance_public_dns = "ec2-54-123-45-67.compute-1.amazonaws.com"
# security_group_id = "sg-0123456789abcdef"
# ssh_command = "ssh -i ~/.ssh/id_rsa ubuntu@54.123.45.67"
# web_url = "http://54.123.45.67"
```

**What happened**:

```
1. Created SSH key pair in AWS
2. Created security group with firewall rules
3. Created EC2 instance with Ubuntu
4. Ran user_data script (installed nginx)
5. Created and attached Elastic IP
6. Displayed outputs
```

### Step 13: Verify Infrastructure

```bash
# 1. Check Terraform state
terraform show

# WHAT: Show current state
# WHY: See all created resources
# Output: Detailed information about all resources

# 2. Check specific output
terraform output instance_public_ip

# WHAT: Get specific output value
# WHY: Get just the IP address
# Output: "54.123.45.67"

# 3. Test web server
curl http://$(terraform output -raw instance_public_ip)

# WHAT: Make HTTP request to server
# WHY: Verify nginx is running
# Expected output: <h1>Hello from Terraform!</h1>

# 4. Open in browser
# Copy the web_url from outputs
# Paste in browser
# You should see: "Hello from Terraform!"

# 5. SSH into instance
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)

# WHAT: Connect to server via SSH
# WHY: Verify SSH access works
# You should see Ubuntu welcome message
# Type 'exit' to disconnect
```

### Step 14: Check AWS Console

```bash
# Go to AWS Console: https://console.aws.amazon.com/

# 1. EC2 Dashboard
#    - See your running instance
#    - Check instance details
#    - Verify tags

# 2. Security Groups
#    - See your security group
#    - Check inbound/outbound rules

# 3. Elastic IPs
#    - See your Elastic IP
#    - Verify it's associated with instance

# 4. Key Pairs
#    - See your uploaded key pair
```

---

## 🧪 Testing Your Infrastructure

### Test 1: Web Server

```bash
# Get the IP
IP=$(terraform output -raw instance_public_ip)

# Test HTTP
curl http://$IP

# Expected: <h1>Hello from Terraform!</h1>
```

### Test 2: SSH Access

```bash
# SSH into server
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)

# Once connected, check nginx
sudo systemctl status nginx

# Expected: active (running)

# Exit
exit
```

### Test 3: Security Group

```bash
# Try SSH from different IP (should fail)
# This tests that security group is working

# From your machine (should work)
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)

# From friend's machine (should timeout)
# Because only YOUR IP is allowed
```

---

## 🔄 Making Changes

### Example: Change Instance Type

```bash
# Edit main.tf
nano main.tf

# Find this line:
instance_type = "t2.micro"

# Change to:
instance_type = "t2.small"

# Save and close

# Plan the change
terraform plan

# Expected output:
# ~ aws_instance.web will be updated in-place
#   ~ instance_type = "t2.micro" -> "t2.small"
# 
# Plan: 0 to add, 1 to change, 0 to destroy.

# Apply the change
terraform apply

# Type: yes
```

---

## 🗑️ Cleanup (Destroy Infrastructure)

**IMPORTANT**: Always destroy resources when done to avoid charges!

```bash
# Destroy all resources
terraform destroy

# WHAT: Delete all created resources
# WHY: Avoid AWS charges
# HOW: Terraform deletes in reverse dependency order

# You'll see the plan, then:
# Do you really want to destroy all resources?
#   Terraform will destroy all your managed infrastructure.
#   There is no undo. Only 'yes' will be accepted to confirm.
# 
# Enter a value: yes

# Type: yes
# Press Enter

# Expected output:
# aws_eip.web: Destroying...
# aws_eip.web: Destruction complete after 2s
# aws_instance.web: Destroying...
# aws_instance.web: Still destroying... [10s elapsed]
# aws_instance.web: Still destroying... [20s elapsed]
# aws_instance.web: Destruction complete after 25s
# aws_security_group.web: Destroying...
# aws_security_group.web: Destruction complete after 1s
# aws_key_pair.deployer: Destroying...
# aws_key_pair.deployer: Destruction complete after 1s
# 
# Destroy complete! Resources: 4 destroyed.
```

**What happened**:

```
1. Detached and deleted Elastic IP
2. Terminated EC2 instance
3. Deleted security group
4. Deleted key pair
5. All resources gone!
```

**Verify in AWS Console**:

```
- EC2 instance: terminated
- Security group: deleted
- Elastic IP: released
- Key pair: deleted
```

---

## 🎓 Interview Questions

### Q1: Walk me through creating infrastructure with Terraform

**Answer**:

1. Write configuration files (.tf)
2. Run `terraform init` to download providers
3. Run `terraform plan` to preview changes
4. Run `terraform apply` to create infrastructure
5. Terraform creates resources via cloud APIs
6. State file tracks what was created

### Q2: What is user_data in EC2?

**Answer**: User data is a script that runs when an instance first boots. It's used for initial configuration like installing software, starting services, etc. In our example, we used it to install and configure nginx.

### Q3: Why use Elastic IP?

**Answer**: Elastic IP provides a static public IP address that doesn't change if the instance is stopped/started. Without it, the IP changes each time, breaking DNS records and connections.

### Q4: How does Terraform handle dependencies?

**Answer**: Terraform automatically determines dependencies by analyzing resource references. For example, the instance depends on the security group, so Terraform creates the security group first.

### Q5: What's the difference between terraform plan and apply?

**Answer**:

- **plan**: Shows what will change (preview only, no changes made)
- **apply**: Actually makes the changes (creates/modifies/deletes resources)
Always plan before apply to review changes.

### Q6: How do you update infrastructure?

**Answer**:

1. Modify .tf files
2. Run `terraform plan` to see changes
3. Run `terraform apply` to apply changes
4. Terraform updates only what changed

### Q7: What happens if you run terraform apply twice?

**Answer**: Nothing! Terraform is idempotent - it compares desired state with current state. If they match, no changes are made. This is safe and expected behavior.

### Q8: How do you destroy specific resources?

**Answer**: Use `terraform destroy -target=resource_type.name`
Example: `terraform destroy -target=aws_instance.web`
But generally, destroy all resources together.

---

## 🎯 Key Takeaways

1. **Always plan before apply** - Preview changes first
2. **Use variables** - Make code reusable
3. **Use outputs** - Display important information
4. **Security groups are firewalls** - Control network access
5. **Elastic IPs are static** - Don't change on restart
6. **User data automates setup** - Run scripts on boot
7. **Always destroy when done** - Avoid unnecessary charges
8. **Terraform is idempotent** - Safe to run multiple times

---

## 📚 What's Next?

Now that you've created your first infrastructure, let's build something more complex:

**Next Guide**: [`07-COMPLETE-PROJECT.md`](07-COMPLETE-PROJECT.md)

- Full 3-tier architecture
- VPC with public/private subnets
- Load balancer
- RDS database
- Auto-scaling
- Production-ready setup

---

## 🔗 Additional Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

**Congratulations! You've created real infrastructure with Terraform!** 🎉

**Remember**: Always destroy resources when done practicing to avoid charges! 💰
