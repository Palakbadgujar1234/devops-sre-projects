# ☁️ AWS Setup for Terraform

## 🎯 Learning Objectives

By the end of this guide, you will:

- Understand AWS basics
- Create an AWS account
- Set up IAM user with proper permissions
- Configure AWS credentials for Terraform
- Understand AWS security best practices

---

## 🤔 WHAT is AWS?

### Simple Definition

**Amazon Web Services (AWS)** is a cloud computing platform that provides servers, storage, databases, and many other services over the internet.

### Real-World Analogy 🏢

Think of AWS as a **massive data center rental service**:

**Traditional Way**:

- Buy physical servers ($10,000+)
- Set up in your office
- Pay for electricity, cooling, maintenance
- Stuck with capacity (too much or too little)

**AWS Way**:

- Rent virtual servers (pay per hour)
- No physical hardware
- Scale up/down instantly
- Pay only for what you use

### Key AWS Services We'll Use

```
┌─────────────────────────────────────────┐
│           AWS Services                   │
├─────────────────────────────────────────┤
│ EC2      → Virtual Servers              │
│ VPC      → Private Network              │
│ S3       → File Storage                 │
│ RDS      → Databases                    │
│ IAM      → User Management              │
│ Route53  → DNS Service                  │
└─────────────────────────────────────────┘
```

---

## 🎯 WHY Set Up AWS Properly?

### Reason 1: Security 🔒

**Bad Setup**:

```
❌ Use root account for everything
❌ Share credentials
❌ No MFA (Multi-Factor Authentication)
❌ Full admin access for everyone
Result: Account gets hacked! 😱
```

**Good Setup**:

```
✅ Create IAM users
✅ Use least privilege access
✅ Enable MFA
✅ Rotate credentials regularly
Result: Secure account! 🔐
```

### Reason 2: Cost Control 💰

**Without Proper Setup**:

```
❌ Forget to stop resources
❌ No billing alerts
❌ Unexpected $1000 bill
```

**With Proper Setup**:

```
✅ Set up billing alerts
✅ Use tags for cost tracking
✅ Auto-stop unused resources
✅ Know your spending
```

### Reason 3: Terraform Integration 🔧

**Terraform needs**:

```
✅ AWS credentials (Access Key + Secret Key)
✅ Proper permissions (IAM policies)
✅ Region configuration
✅ Secure credential storage
```

---

## 🏗️ HOW to Set Up AWS

### Step 1: Create AWS Account

#### 1.1 Sign Up for AWS

**WHAT**: Create your AWS account  
**WHY**: You need an account to use AWS services  
**HOW**:

```bash
# Go to AWS website
https://aws.amazon.com/

# Click "Create an AWS Account"
# You'll need:
# - Email address
# - Password
# - Credit card (for verification)
# - Phone number (for verification)
```

**Important Notes**:

- AWS Free Tier gives you free resources for 12 months
- Credit card is required but won't be charged for free tier usage
- You'll get $0 bill if you stay within free tier limits

#### 1.2 Free Tier Limits (Important!)

```
EC2 (Servers):
✅ 750 hours/month of t2.micro instances
✅ Enough for 1 server running 24/7

S3 (Storage):
✅ 5 GB storage
✅ 20,000 GET requests
✅ 2,000 PUT requests

RDS (Database):
✅ 750 hours/month of db.t2.micro
✅ 20 GB storage

⚠️ STAY WITHIN THESE LIMITS TO AVOID CHARGES!
```

#### 1.3 Set Up Billing Alerts

**WHAT**: Get notified if spending exceeds threshold  
**WHY**: Avoid surprise bills  
**HOW**:

```bash
# 1. Go to AWS Console
https://console.aws.amazon.com/

# 2. Click your name (top right) → Billing Dashboard

# 3. Click "Billing Preferences"

# 4. Enable:
☑️ Receive Free Tier Usage Alerts
☑️ Receive Billing Alerts

# 5. Enter your email

# 6. Save preferences

# 7. Create CloudWatch Alarm:
#    - Go to CloudWatch
#    - Create Alarm
#    - Set threshold: $10 (or your limit)
#    - Add email notification
```

**Example Alert Setup**:

```
Alert Name: Monthly Spending Alert
Threshold: $10
Action: Send email to your-email@example.com
Reason: Get notified before spending too much
```

---

### Step 2: Create IAM User

#### 2.1 Why Not Use Root Account?

**Root Account** = Master key to everything

```
❌ If compromised, attacker has full access
❌ Can't restrict permissions
❌ Can't track who did what
❌ Against AWS best practices
```

**IAM User** = Limited access account

```
✅ Can restrict permissions
✅ Can create multiple users
✅ Can track actions
✅ Can revoke access easily
```

#### 2.2 Create IAM User

**WHAT**: Create a user for Terraform  
**WHY**: Secure, trackable access  
**HOW**:

```bash
# 1. Go to IAM Console
https://console.aws.amazon.com/iam/

# 2. Click "Users" in left sidebar

# 3. Click "Add users"

# 4. Enter user details:
User name: terraform-user
Access type: ☑️ Programmatic access
            (This gives you Access Key + Secret Key)

# 5. Click "Next: Permissions"

# 6. Click "Attach existing policies directly"

# 7. Search and select:
☑️ AmazonEC2FullAccess
☑️ AmazonS3FullAccess
☑️ AmazonVPCFullAccess
☑️ AmazonRDSFullAccess

# Note: For production, use more restrictive policies!

# 8. Click "Next: Tags" (optional, skip for now)

# 9. Click "Next: Review"

# 10. Click "Create user"

# 11. IMPORTANT: Download credentials!
#     You'll see:
#     - Access Key ID: AKIAIOSFODNN7EXAMPLE
#     - Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
#
#     ⚠️ SAVE THESE! You can't see Secret Key again!
```

**What You'll Get**:

```
Access Key ID:     AKIAIOSFODNN7EXAMPLE
Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

⚠️ NEVER commit these to git!
⚠️ NEVER share these publicly!
⚠️ Store securely!
```

#### 2.3 Enable MFA (Multi-Factor Authentication)

**WHAT**: Add extra security layer  
**WHY**: Even if password is stolen, attacker needs your phone  
**HOW**:

```bash
# 1. Go to IAM Console → Users → terraform-user

# 2. Click "Security credentials" tab

# 3. Click "Manage" next to "Assigned MFA device"

# 4. Select "Virtual MFA device"

# 5. Use app on your phone:
#    - Google Authenticator (iOS/Android)
#    - Authy (iOS/Android)
#    - Microsoft Authenticator (iOS/Android)

# 6. Scan QR code with app

# 7. Enter two consecutive MFA codes

# 8. Click "Assign MFA"
```

---

### Step 3: Configure AWS Credentials

#### 3.1 Install AWS CLI

**WHAT**: Command-line tool for AWS  
**WHY**: Terraform uses AWS CLI configuration  
**HOW**:

**For macOS**:

```bash
# Using Homebrew
brew install awscli

# Verify installation
aws --version
# Output: aws-cli/2.13.0 Python/3.11.4 Darwin/22.5.0 source/arm64
```

**For Windows**:

```powershell
# Download installer from:
https://awscli.amazonaws.com/AWSCLIV2.msi

# Run installer

# Verify in Command Prompt:
aws --version
```

**For Linux**:

```bash
# Download and install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

#### 3.2 Configure AWS Credentials

**WHAT**: Store your AWS credentials locally  
**WHY**: Terraform needs them to access AWS  
**HOW**:

```bash
# Run AWS configure
aws configure

# You'll be prompted for:

AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
# ↑ Paste your Access Key ID

AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# ↑ Paste your Secret Access Key

Default region name [None]: us-east-1
# ↑ Choose your region (us-east-1 is common)

Default output format [None]: json
# ↑ json is easiest to read
```

**What This Creates**:

```bash
# Creates two files:

# 1. ~/.aws/credentials (Your keys)
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# 2. ~/.aws/config (Your settings)
[default]
region = us-east-1
output = json
```

#### 3.3 Test AWS Configuration

**WHAT**: Verify credentials work  
**WHY**: Catch issues before using Terraform  
**HOW**:

```bash
# Test 1: Check your identity
aws sts get-caller-identity

# Expected output:
{
    "UserId": "AIDAI23HXS2RV5EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
# ✅ If you see this, credentials work!

# Test 2: List S3 buckets
aws s3 ls

# Expected output:
# (Empty list if no buckets, or list of buckets)
# ✅ If no error, credentials work!

# Test 3: List EC2 instances
aws ec2 describe-instances --region us-east-1

# Expected output:
{
    "Reservations": []
}
# ✅ If you see this, credentials work!
```

**If You Get Errors**:

```bash
# Error: "Unable to locate credentials"
# Solution: Run aws configure again

# Error: "Access Denied"
# Solution: Check IAM permissions

# Error: "Invalid security token"
# Solution: Credentials might be wrong, check them
```

---

### Step 4: Understand AWS Regions

#### 4.1 What Are Regions?

**WHAT**: Geographic locations where AWS has data centers  
**WHY**: Choose region close to your users for better performance  

```
AWS Regions (Popular ones):
┌────────────────────────────────────────┐
│ us-east-1      → N. Virginia (USA)     │
│ us-west-2      → Oregon (USA)          │
│ eu-west-1      → Ireland (Europe)      │
│ ap-south-1     → Mumbai (India)        │
│ ap-southeast-1 → Singapore (Asia)      │
└────────────────────────────────────────┘
```

#### 4.2 Choosing a Region

**Factors to Consider**:

1. **Latency** (Speed)

```
User in India → Use ap-south-1 (Mumbai)
User in USA   → Use us-east-1 (Virginia)
User in Europe → Use eu-west-1 (Ireland)
```

1. **Cost** (Pricing varies by region)

```
us-east-1 → Usually cheapest
ap-south-1 → Slightly more expensive
eu-west-1 → Similar to us-east-1
```

1. **Services** (Not all services in all regions)

```
us-east-1 → All services available
Other regions → Some services might be missing
```

**Recommendation for Learning**: Use `us-east-1`

- Cheapest
- All services available
- Most documentation uses it

#### 4.3 Set Default Region

```bash
# Option 1: In AWS CLI config
aws configure set region us-east-1

# Option 2: In Terraform code
provider "aws" {
  region = "us-east-1"
}

# Option 3: Environment variable
export AWS_DEFAULT_REGION=us-east-1
```

---

### Step 5: Security Best Practices

#### 5.1 Credential Security

**DO** ✅:

```bash
# Store in AWS CLI config
~/.aws/credentials

# Use environment variables
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# Use IAM roles (for EC2 instances)
# Use AWS Secrets Manager
# Rotate credentials regularly
```

**DON'T** ❌:

```bash
# Never commit to git
git add credentials.txt  # ❌

# Never hardcode in code
access_key = "AKIAIOSFODNN7EXAMPLE"  # ❌

# Never share publicly
# Never post in Slack/email
# Never store in plain text files
```

#### 5.2 .gitignore for Terraform

**WHAT**: Prevent committing sensitive files  
**WHY**: Avoid exposing credentials  
**HOW**:

```bash
# Create .gitignore in your project
cat > .gitignore << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Sensitive files
*.tfvars
*.pem
*.key

# AWS credentials
.aws/
credentials

# OS files
.DS_Store
Thumbs.db
EOF
```

#### 5.3 IAM Policy Best Practices

**Principle of Least Privilege**:

```hcl
# Bad: Full admin access
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}

# Good: Only what's needed
{
  "Effect": "Allow",
  "Action": [
    "ec2:RunInstances",
    "ec2:TerminateInstances",
    "ec2:DescribeInstances"
  ],
  "Resource": "*"
}
```

#### 5.4 Enable CloudTrail

**WHAT**: Logs all AWS API calls  
**WHY**: Track who did what, when  
**HOW**:

```bash
# 1. Go to CloudTrail console
https://console.aws.amazon.com/cloudtrail/

# 2. Click "Create trail"

# 3. Enter trail name: my-cloudtrail

# 4. Create new S3 bucket: my-cloudtrail-logs

# 5. Enable log file validation

# 6. Click "Create trail"

# Now all AWS actions are logged!
```

---

## 🧪 Verify Your Setup

### Complete Verification Checklist

```bash
# 1. AWS Account created
✅ Can log into AWS Console

# 2. IAM user created
✅ Have Access Key ID
✅ Have Secret Access Key
✅ MFA enabled (optional but recommended)

# 3. AWS CLI installed
aws --version
✅ Shows version number

# 4. Credentials configured
aws configure list
✅ Shows your credentials (partially masked)

# 5. Credentials work
aws sts get-caller-identity
✅ Shows your user ARN

# 6. Can access AWS services
aws s3 ls
✅ No error (even if empty)

# 7. Region configured
aws configure get region
✅ Shows us-east-1 (or your chosen region)

# 8. Billing alerts set up
✅ Will get email if spending > threshold

# 9. .gitignore created
✅ Won't commit sensitive files
```

---

## 🎓 Interview Questions

### Q1: Why not use the AWS root account for Terraform?

**Answer**: Root account has unlimited access. If compromised, attacker has full control. IAM users follow principle of least privilege - only the permissions needed. Also, IAM users provide better audit trails.

### Q2: What are AWS Access Keys?

**Answer**: Access Keys consist of:

- **Access Key ID**: Public identifier (like username)
- **Secret Access Key**: Private key (like password)
Together they authenticate API requests to AWS.

### Q3: How do you secure AWS credentials?

**Answer**:

- Store in `~/.aws/credentials` (not in code)
- Never commit to version control
- Use `.gitignore` to exclude sensitive files
- Rotate credentials regularly
- Enable MFA
- Use IAM roles for EC2 instances

### Q4: What is the AWS Free Tier?

**Answer**: AWS Free Tier provides limited free usage of AWS services for 12 months:

- 750 hours/month of t2.micro EC2 instances
- 5 GB S3 storage
- 750 hours/month of RDS db.t2.micro
Helps learn AWS without cost.

### Q5: What are AWS regions and why do they matter?

**Answer**: Regions are geographic locations with AWS data centers. They matter for:

- **Latency**: Choose region close to users
- **Cost**: Pricing varies by region
- **Compliance**: Data residency requirements
- **Availability**: Not all services in all regions

### Q6: How does Terraform authenticate with AWS?

**Answer**: Terraform uses AWS credentials in this order:

1. Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
2. Shared credentials file (`~/.aws/credentials`)
3. IAM role (if running on EC2)
4. ECS task role (if running in ECS)

### Q7: What is IAM?

**Answer**: Identity and Access Management (IAM) is AWS's service for managing:

- Users (people/applications)
- Groups (collections of users)
- Roles (temporary permissions)
- Policies (permission definitions)

### Q8: What permissions does Terraform need?

**Answer**: Depends on resources you're creating. Minimum:

- EC2: `ec2:*` for instances
- VPC: `ec2:*Vpc*`, `ec2:*Subnet*` for networking
- S3: `s3:*` for buckets
- IAM: `iam:*` if creating IAM resources
Best practice: Start with full access for learning, restrict in production.

---

## 🎯 Key Takeaways

1. **Never use root account** - Create IAM users
2. **Secure credentials** - Use AWS CLI config, never commit to git
3. **Set billing alerts** - Avoid surprise charges
4. **Choose right region** - Consider latency, cost, services
5. **Follow least privilege** - Only grant needed permissions
6. **Enable MFA** - Extra security layer
7. **Use CloudTrail** - Track all actions

---

## 📚 What's Next?

Now that AWS is set up, let's install Terraform:

**Next Guide**: [`04-TERRAFORM-INSTALLATION.md`](04-TERRAFORM-INSTALLATION.md)

- Install Terraform on your system
- Verify installation
- Understand Terraform CLI
- First Terraform commands

---

## 🔗 Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [AWS Regions](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)

---

**Remember**: Proper AWS setup is crucial for security and cost control. Take time to do it right! 🔒
