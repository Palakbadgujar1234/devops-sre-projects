# Free Account Setup - All 4 Cloud Providers

## 🎯 What You'll Learn

- Create free accounts on AWS, GCP, Azure, and IBM Cloud
- Set up billing alerts to stay within free tier
- Configure security (MFA/2FA)
- Install and configure CLI tools
- Verify your setup

## ⚠️ Before You Start

### What You Need

- ✅ Valid email address (different for each cloud recommended)
- ✅ Phone number for verification
- ✅ Credit/debit card (for verification only - **won't be charged**)
- ✅ 2-3 hours of time
- ✅ Stable internet connection

### Important Notes

1. **Credit card is required** for identity verification
2. **You won't be charged** if you stay within free tier limits
3. **Set up billing alerts immediately** after account creation
4. **Enable MFA/2FA** for security
5. **Use different passwords** for each cloud

---

## 1️⃣ AWS Account Setup (30 minutes)

### Step 1: Create Account

1. Go to: <https://aws.amazon.com>
2. Click **"Create an AWS Account"**
3. Enter email: `your-email@example.com`
4. Account name: `MyDevOpsLearning`
5. Click **"Verify email address"**
6. Check email and enter verification code

### Step 2: Set Password

```
Password: Min 8 characters (use strong password)
Confirm password: Re-enter
```

### Step 3: Contact Information

```
Account type: Personal
Full name: Your Name
Phone: +91-XXXXXXXXXX (India) or your country code
Address: Your complete address
City, State, Postal code
```

- Agree to terms → **Continue**

### Step 4: Payment Information

```
Card number: Your card
Expiration: MM/YY
CVV: XXX
Cardholder name: Name on card
```

- AWS charges ₹2 for verification (refunded immediately)
- Click **"Verify and Continue"**

### Step 5: Identity Verification

```
1. Select country code
2. Enter phone number
3. Solve CAPTCHA
4. Choose "Send SMS" or "Call me"
5. Enter 4-digit verification code
```

### Step 6: Support Plan

```
Select: Basic Support - Free
```

- Click **"Complete sign up"**
- Wait 5-10 minutes for activation

### Step 7: Sign In

1. Go to: <https://console.aws.amazon.com>
2. Select **"Root user"**
3. Enter email and password
4. Click **"Sign in"**

### Step 8: Set Up Billing Alerts (CRITICAL!)

```bash
# Enable billing alerts
1. Click your name (top right) → "Account"
2. Scroll to "IAM User and Role Access to Billing"
3. Click "Edit" → Check box → "Update"

# Create billing alarm
1. Go to CloudWatch service
2. Click "Alarms" → "Billing" → "Create alarm"
3. Set threshold: $5 USD
4. Enter your email
5. Confirm subscription email
```

### Step 9: Enable MFA

```
1. Click your name → "Security credentials"
2. Under "MFA" → "Assign MFA device"
3. Choose "Virtual MFA device"
4. Use Google Authenticator or Authy app
5. Scan QR code
6. Enter two consecutive codes
```

### Step 10: Install AWS CLI

**For Linux/Mac:**

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

**For Windows:**

```powershell
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi
# Run installer
# Verify
aws --version
```

### Step 11: Configure AWS CLI

```bash
# Create access key
1. Go to IAM → Users → Create user
2. Username: devops-user
3. Attach policy: AdministratorAccess (for learning)
4. Create user
5. Security credentials → Create access key
6. Choose "CLI" → Create
7. Download credentials

# Configure CLI
aws configure
# Enter:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json

# Test
aws s3 ls
```

### ✅ AWS Free Tier Limits

- **EC2**: 750 hours/month (t2.micro)
- **S3**: 5GB storage
- **RDS**: 750 hours/month (db.t2.micro)
- **Lambda**: 1 million requests/month
- **Duration**: 12 months

---

## 2️⃣ GCP Account Setup (25 minutes)

### Step 1: Create Account

1. Go to: <https://cloud.google.com/free>
2. Click **"Get started for free"**
3. Sign in with Google account (or create new)

### Step 2: Country and Terms

```
Country: India (or your country)
✓ Terms of Service
✓ Email updates (optional)
```

- Click **"Continue"**

### Step 3: Account Information

```
Account type: Individual
Name: Your Name
Address: Complete address
City, State, Postal code
Phone: +91-XXXXXXXXXX
```

### Step 4: Payment Method

```
Payment method: Credit/Debit card
Card details: Enter card information
```

- ₹2 verification charge (refunded)
- Click **"Start my free trial"**

### Step 5: Welcome Screen

- You get **$300 credit for 90 days**
- Click **"Go to Console"**

### Step 6: Create First Project

```
1. Click "Select a project" (top bar)
2. Click "New Project"
3. Project name: my-devops-learning
4. Click "Create"
```

### Step 7: Set Up Billing Alerts

```bash
1. Go to "Billing" (☰ menu)
2. Click "Budgets & alerts"
3. Click "Create Budget"
4. Budget name: Monthly-Budget
5. Amount: $50
6. Alert thresholds: 50%, 90%, 100%
7. Add email
8. Click "Finish"
```

### Step 8: Enable APIs

```
1. Go to "APIs & Services" → "Library"
2. Search and enable:
   - Compute Engine API
   - Cloud Storage API
   - Cloud Build API
   - Kubernetes Engine API
   - Cloud SQL API
```

### Step 9: Install gcloud CLI

**For Linux:**

```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

**For Mac:**

```bash
# Download from: https://cloud.google.com/sdk/docs/install
# Or use Homebrew
brew install --cask google-cloud-sdk
gcloud init
```

**For Windows:**

```powershell
# Download from: https://cloud.google.com/sdk/docs/install
# Run installer
# Open Cloud SDK Shell
gcloud init
```

### Step 10: Configure gcloud

```bash
# Initialize
gcloud init

# Follow prompts:
# 1. Login to your Google account
# 2. Select project: my-devops-learning
# 3. Select region: us-central1

# Test
gcloud projects list
gcloud compute zones list
```

### ✅ GCP Free Tier

- **$300 credit** for 90 days
- **Always Free**:
  - Compute Engine: 1 f1-micro instance
  - Cloud Storage: 5GB
  - Cloud Functions: 2M invocations/month
  - Cloud Run: 2M requests/month

---

## 3️⃣ Azure Account Setup (30 minutes)

### Step 1: Create Account

1. Go to: <https://azure.microsoft.com/free>
2. Click **"Start free"**
3. Sign in with Microsoft account (or create new)

### Step 2: About You

```
Country: India
First name: Your first name
Last name: Your last name
Email: your-email@example.com
Phone: +91-XXXXXXXXXX
```

### Step 3: Phone Verification

```
1. Select country code
2. Enter phone number
3. Click "Text me" or "Call me"
4. Enter verification code
```

### Step 4: Card Verification

```
Card number: Your card
Expiration: MM/YY
CVV: XXX
Name: Cardholder name
Address: Complete address
```

- ₹2 verification (refunded)

### Step 5: Agreement

```
✓ I agree to subscription agreement
✓ I agree to offer details
```

- Click **"Sign up"**

### Step 6: Welcome to Azure

- You get **$200 credit for 30 days**
- Click **"Go to the Azure portal"**

### Step 7: Set Up Cost Alerts

```bash
1. Search "Cost Management + Billing"
2. Click "Cost Management" → "Budgets"
3. Click "Add"
4. Budget name: Monthly-Budget
5. Reset period: Monthly
6. Amount: $50
7. Alert: 80%, 100%
8. Add email
9. Click "Create"
```

### Step 8: Install Azure CLI

**For Linux:**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify
az --version
```

**For Mac:**

```bash
brew update && brew install azure-cli

# Verify
az --version
```

**For Windows:**

```powershell
# Download from: https://aka.ms/installazurecliwindows
# Run MSI installer
# Verify
az --version
```

### Step 9: Configure Azure CLI

```bash
# Login
az login
# Browser will open, sign in

# List subscriptions
az account list

# Set default subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Test
az group list
az vm list
```

### ✅ Azure Free Tier

- **$200 credit** for 30 days
- **12 months free**:
  - Virtual Machines: 750 hours B1S
  - Blob Storage: 5GB
  - SQL Database: 250GB
  - Functions: 1M executions/month

---

## 4️⃣ IBM Cloud Account Setup (25 minutes)

### Step 1: Create Account

1. Go to: <https://cloud.ibm.com/registration>
2. Enter email: `your-email@example.com`
3. Check email for verification code
4. Enter 7-digit code

### Step 2: Account Details

```
First name: Your first name
Last name: Your last name
Password: Strong password (min 8 chars)
Country: India (or your country)
```

- ✓ Agree to terms
- Click **"Continue"**

### Step 3: Account Type

```
Select: Individual account
```

### Step 4: Phone Verification

```
1. Enter phone: +91-XXXXXXXXXX
2. Click "Send code"
3. Enter verification code
```

### Step 5: Additional Info

```
Address: Your address
City, State, Postal code
```

- Click **"Continue"**

### Step 6: Payment (Optional)

```
Note: IBM Cloud Lite doesn't require card
For full features, add card later
```

- Click **"Skip for now"**

### Step 7: Welcome to IBM Cloud

- Click **"Proceed"**
- You're in IBM Cloud Dashboard

### Step 8: Create Resource Group

```
1. Go to "Manage" → "Account" → "Resource groups"
2. Click "Create"
3. Name: my-devops-resources
4. Click "Add"
```

### Step 9: Install IBM Cloud CLI

**For Linux/Mac:**

```bash
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Verify
ibmcloud --version
```

**For Windows:**

```powershell
# Download from: https://clis.cloud.ibm.com/download/bluemix-cli/latest/win64
# Run installer
# Verify
ibmcloud --version
```

### Step 10: Configure IBM Cloud CLI

```bash
# Login
ibmcloud login

# Enter email and password

# Target resource group
ibmcloud target -g my-devops-resources

# Test
ibmcloud resource groups
ibmcloud regions
```

### ✅ IBM Cloud Lite

- **Free forever** (no credit card needed)
- **Lite services**:
  - Cloud Foundry: 256MB
  - Kubernetes: 1 free cluster
  - Object Storage: 25GB
  - Cloudant: 1GB

---

## 🔒 Security Checklist (ALL CLOUDS)

### Enable MFA/2FA

```
✅ AWS: IAM → Security Credentials → MFA
✅ GCP: Account → Security → 2-Step Verification
✅ Azure: Profile → Security Info
✅ IBM: Profile → Security → MFA
```

### Create Non-Root Users

```
✅ AWS: Create IAM user (don't use root)
✅ GCP: Use service accounts
✅ Azure: Create Azure AD users
✅ IBM: Create IAM users
```

### Set Billing Alerts

```
✅ AWS: CloudWatch Billing Alarms ($5)
✅ GCP: Budgets & Alerts ($50)
✅ Azure: Cost Management Budgets ($50)
✅ IBM: Spending Notifications
```

---

## 🧪 Verify Your Setup

### Test AWS

```bash
aws --version
aws s3 ls
aws ec2 describe-regions
```

### Test GCP

```bash
gcloud --version
gcloud projects list
gcloud compute zones list
```

### Test Azure

```bash
az --version
az account list
az group list
```

### Test IBM Cloud

```bash
ibmcloud --version
ibmcloud resource groups
ibmcloud regions
```

---

## 💰 Free Tier Summary

| Cloud | Credit | Duration | Always Free |
|-------|--------|----------|-------------|
| **AWS** | None | 12 months | Some services |
| **GCP** | $300 | 90 days | Yes |
| **Azure** | $200 | 30 days | 12 months |
| **IBM** | None | Forever | Lite plans |

---

## 🆘 Troubleshooting

### Card Declined

- Try different card
- Contact bank (enable international transactions)
- Use virtual card services

### Phone Verification Failed

- Try "Call me" instead of SMS
- Use different number
- Wait 24 hours

### Account Suspended

- Check email for reason
- Contact support
- Verify information

### CLI Not Working

- Restart terminal
- Check PATH variable
- Reinstall CLI

---

## 📋 Completion Checklist

### AWS

- [ ] Account created
- [ ] Billing alerts set ($5)
- [ ] MFA enabled
- [ ] IAM user created
- [ ] AWS CLI installed
- [ ] CLI configured and tested

### GCP

- [ ] Account created ($300 credit)
- [ ] Project created
- [ ] Budget alerts set ($50)
- [ ] APIs enabled
- [ ] gcloud CLI installed
- [ ] CLI configured and tested

### Azure

- [ ] Account created ($200 credit)
- [ ] Cost budget set ($50)
- [ ] MFA enabled
- [ ] Azure CLI installed
- [ ] CLI configured and tested

### IBM Cloud

- [ ] Account created (Lite)
- [ ] Resource group created
- [ ] Notifications enabled
- [ ] IBM CLI installed
- [ ] CLI configured and tested

---

## 🎯 Next Steps

Congratulations! You now have accounts on all 4 major cloud platforms.

**Next**: [Complete Cloud Services Comparison](./03-complete-cloud-services-comparison.md)

Then proceed to hands-on implementations:

- [Deploy Your First Application](./04-first-app-deployment.md)
- [Kubernetes on All Clouds](./05-kubernetes-all-clouds.md)
- [CI/CD Pipelines](./06-cicd-all-clouds.md)

---

**Remember**:

- ✅ Set billing alerts immediately
- ✅ Enable MFA for security
- ✅ Delete resources after practice
- ✅ Monitor usage daily
- ✅ Stay within free tier limits

**Pro Tip**: Create a spreadsheet to track your usage across all clouds!
