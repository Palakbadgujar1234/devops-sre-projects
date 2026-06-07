# Deploy Your First Application - All 4 Clouds

## 🎯 What You'll Build

A simple **"Hello World" web application** deployed on:

- AWS EC2
- GCP Compute Engine
- Azure Virtual Machine
- IBM Cloud Virtual Server

## 📋 Prerequisites

- ✅ All 4 cloud accounts set up
- ✅ CLI tools installed and configured
- ✅ Basic Linux command knowledge
- ✅ SSH key pair (we'll create if needed)

## 🏗️ Architecture

```
Internet → Public IP → Virtual Machine → Web Server (Nginx) → Hello World Page
```

---

## 1️⃣ AWS EC2 Deployment (20 minutes)

### Step 1: Create SSH Key Pair

```bash
# Create key pair
aws ec2 create-key-pair \
  --key-name my-devops-key \
  --query 'KeyMaterial' \
  --output text > my-devops-key.pem

# Set permissions
chmod 400 my-devops-key.pem

# Verify
ls -l my-devops-key.pem
```

### Step 2: Create Security Group

```bash
# Create security group
aws ec2 create-security-group \
  --group-name web-server-sg \
  --description "Security group for web server"

# Note the GroupId from output (e.g., sg-0123456789abcdef0)

# Allow SSH (port 22)
aws ec2 authorize-security-group-ingress \
  --group-name web-server-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Allow HTTP (port 80)
aws ec2 authorize-security-group-ingress \
  --group-name web-server-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

### Step 3: Launch EC2 Instance

```bash
# Get latest Amazon Linux 2 AMI ID
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'Images[0].ImageId' \
  --output text)

# Launch instance
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name my-devops-key \
  --security-groups web-server-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyWebServer}]'

# Note the InstanceId from output
```

### Step 4: Get Public IP

```bash
# Wait for instance to be running (takes 1-2 minutes)
aws ec2 wait instance-running --instance-ids i-XXXXXXXXXXXXXXXXX

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids i-XXXXXXXXXXXXXXXXX \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Public IP: $PUBLIC_IP"
```

### Step 5: Connect and Install Web Server

```bash
# SSH into instance
ssh -i my-devops-key.pem ec2-user@$PUBLIC_IP

# Once connected, run these commands:
sudo yum update -y
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Create custom page
sudo bash -c 'cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>AWS EC2 - Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 3em; margin: 0; }
        p { font-size: 1.5em; }
        .cloud { color: #FF9900; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Hello from <span class="cloud">AWS EC2</span>!</h1>
        <p>Your first cloud deployment is live!</p>
        <p>Instance Type: t2.micro</p>
        <p>Region: us-east-1</p>
    </div>
</body>
</html>
EOF'

# Exit SSH
exit
```

### Step 6: Test Your Application

```bash
# Open in browser
echo "Visit: http://$PUBLIC_IP"

# Or test with curl
curl http://$PUBLIC_IP
```

### Step 7: Clean Up (Important!)

```bash
# Terminate instance
aws ec2 terminate-instances --instance-ids i-XXXXXXXXXXXXXXXXX

# Wait for termination
aws ec2 wait instance-terminated --instance-ids i-XXXXXXXXXXXXXXXXX

# Delete security group
aws ec2 delete-security-group --group-name web-server-sg

# Delete key pair
aws ec2 delete-key-pair --key-name my-devops-key
rm my-devops-key.pem
```

---

## 2️⃣ GCP Compute Engine Deployment (20 minutes)

### Step 1: Set Project and Region

```bash
# Set project
gcloud config set project my-devops-learning

# Set region
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

### Step 2: Create Firewall Rules

```bash
# Allow HTTP traffic
gcloud compute firewall-rules create allow-http \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags web-server \
  --description "Allow HTTP traffic"

# Allow SSH (usually already exists)
gcloud compute firewall-rules create allow-ssh \
  --allow tcp:22 \
  --source-ranges 0.0.0.0/0 \
  --target-tags web-server \
  --description "Allow SSH traffic"
```

### Step 3: Create Startup Script

```bash
# Create startup script file
cat > startup-script.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y nginx

cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>GCP Compute Engine - Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #4285f4 0%, #34a853 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 3em; margin: 0; }
        p { font-size: 1.5em; }
        .cloud { color: #fbbc04; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Hello from <span class="cloud">GCP Compute Engine</span>!</h1>
        <p>Your first cloud deployment is live!</p>
        <p>Instance Type: e2-micro</p>
        <p>Region: us-central1</p>
    </div>
</body>
</html>
HTML

systemctl start nginx
systemctl enable nginx
EOF
```

### Step 4: Create Instance

```bash
# Create instance
gcloud compute instances create my-web-server \
  --machine-type=e2-micro \
  --zone=us-central1-a \
  --tags=web-server \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --metadata-from-file startup-script=startup-script.sh

# Get public IP
PUBLIC_IP=$(gcloud compute instances describe my-web-server \
  --zone=us-central1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo "Public IP: $PUBLIC_IP"
```

### Step 5: Wait and Test

```bash
# Wait 2-3 minutes for startup script to complete
sleep 120

# Test
echo "Visit: http://$PUBLIC_IP"
curl http://$PUBLIC_IP
```

### Step 6: SSH into Instance (Optional)

```bash
# SSH using gcloud
gcloud compute ssh my-web-server --zone=us-central1-a

# Check nginx status
sudo systemctl status nginx

# Exit
exit
```

### Step 7: Clean Up

```bash
# Delete instance
gcloud compute instances delete my-web-server \
  --zone=us-central1-a \
  --quiet

# Delete firewall rules
gcloud compute firewall-rules delete allow-http --quiet
gcloud compute firewall-rules delete allow-ssh --quiet

# Remove startup script
rm startup-script.sh
```

---

## 3️⃣ Azure Virtual Machine Deployment (25 minutes)

### Step 1: Create Resource Group

```bash
# Create resource group
az group create \
  --name myDevOpsResourceGroup \
  --location eastus
```

### Step 2: Create Virtual Machine

```bash
# Create VM (this also creates network, IP, etc.)
az vm create \
  --resource-group myDevOpsResourceGroup \
  --name myWebServerVM \
  --image UbuntuLTS \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard

# Note the publicIpAddress from output
```

### Step 3: Open Port 80

```bash
# Open HTTP port
az vm open-port \
  --resource-group myDevOpsResourceGroup \
  --name myWebServerVM \
  --port 80 \
  --priority 1001
```

### Step 4: Get Public IP

```bash
# Get public IP
PUBLIC_IP=$(az vm show \
  --resource-group myDevOpsResourceGroup \
  --name myWebServerVM \
  --show-details \
  --query publicIps \
  --output tsv)

echo "Public IP: $PUBLIC_IP"
```

### Step 5: Install Web Server

```bash
# SSH into VM
ssh azureuser@$PUBLIC_IP

# Install nginx
sudo apt-get update
sudo apt-get install -y nginx

# Create custom page
sudo bash -c 'cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Azure VM - Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #0078d4 0%, #00bcf2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 3em; margin: 0; }
        p { font-size: 1.5em; }
        .cloud { color: #50e6ff; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Hello from <span class="cloud">Azure VM</span>!</h1>
        <p>Your first cloud deployment is live!</p>
        <p>Instance Type: Standard_B1s</p>
        <p>Region: eastus</p>
    </div>
</body>
</html>
EOF'

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Exit
exit
```

### Step 6: Test Application

```bash
# Test
echo "Visit: http://$PUBLIC_IP"
curl http://$PUBLIC_IP
```

### Step 7: Clean Up

```bash
# Delete entire resource group (deletes all resources)
az group delete \
  --name myDevOpsResourceGroup \
  --yes \
  --no-wait
```

---

## 4️⃣ IBM Cloud Virtual Server Deployment (25 minutes)

### Step 1: Set Target

```bash
# Login if not already
ibmcloud login

# Target resource group
ibmcloud target -g my-devops-resources

# Set region
ibmcloud target -r us-south
```

### Step 2: Create SSH Key

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ibm_cloud_key -N ""

# Upload SSH key to IBM Cloud
ibmcloud is key-create my-ssh-key @~/.ssh/ibm_cloud_key.pub
```

### Step 3: Create VPC and Subnet

```bash
# Create VPC
ibmcloud is vpc-create my-devops-vpc

# Note the VPC ID from output

# Create subnet
ibmcloud is subnet-create my-devops-subnet <VPC_ID> \
  --zone us-south-1 \
  --ipv4-cidr-block 10.240.0.0/24
```

### Step 4: Create Security Group

```bash
# Get VPC ID
VPC_ID=$(ibmcloud is vpcs --output json | jq -r '.[0].id')

# Create security group
ibmcloud is security-group-create my-web-sg $VPC_ID

# Get security group ID
SG_ID=$(ibmcloud is security-groups --output json | jq -r '.[0].id')

# Allow SSH (port 22)
ibmcloud is security-group-rule-add $SG_ID inbound tcp \
  --port-min 22 --port-max 22

# Allow HTTP (port 80)
ibmcloud is security-group-rule-add $SG_ID inbound tcp \
  --port-min 80 --port-max 80
```

### Step 5: Create Virtual Server

```bash
# Get subnet ID
SUBNET_ID=$(ibmcloud is subnets --output json | jq -r '.[0].id')

# Get image ID (Ubuntu)
IMAGE_ID=$(ibmcloud is images --output json | \
  jq -r '.[] | select(.name | contains("ubuntu")) | .id' | head -1)

# Create instance
ibmcloud is instance-create my-web-server \
  $VPC_ID \
  us-south-1 \
  cx2-2x4 \
  $SUBNET_ID \
  --image $IMAGE_ID \
  --keys my-ssh-key \
  --security-groups $SG_ID

# Wait for instance to be running (2-3 minutes)
sleep 180
```

### Step 6: Create and Attach Floating IP

```bash
# Get instance ID
INSTANCE_ID=$(ibmcloud is instances --output json | jq -r '.[0].id')

# Get network interface ID
NIC_ID=$(ibmcloud is instance $INSTANCE_ID --output json | \
  jq -r '.network_interfaces[0].id')

# Create floating IP
ibmcloud is floating-ip-reserve my-web-ip \
  --nic $NIC_ID

# Get floating IP
FLOATING_IP=$(ibmcloud is floating-ips --output json | jq -r '.[0].address')

echo "Public IP: $FLOATING_IP"
```

### Step 7: Install Web Server

```bash
# SSH into instance
ssh -i ~/.ssh/ibm_cloud_key root@$FLOATING_IP

# Install nginx
apt-get update
apt-get install -y nginx

# Create custom page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>IBM Cloud - Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #054ada 0%, #00b4a0 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 3em; margin: 0; }
        p { font-size: 1.5em; }
        .cloud { color: #00b4a0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Hello from <span class="cloud">IBM Cloud</span>!</h1>
        <p>Your first cloud deployment is live!</p>
        <p>Instance Type: cx2-2x4</p>
        <p>Region: us-south</p>
    </div>
</body>
</html>
EOF

# Start nginx
systemctl start nginx
systemctl enable nginx

# Exit
exit
```

### Step 8: Test Application

```bash
# Test
echo "Visit: http://$FLOATING_IP"
curl http://$FLOATING_IP
```

### Step 9: Clean Up

```bash
# Delete instance
ibmcloud is instance-delete $INSTANCE_ID --force

# Delete floating IP
ibmcloud is floating-ip-release my-web-ip --force

# Delete security group
ibmcloud is security-group-delete $SG_ID --force

# Delete subnet
ibmcloud is subnet-delete $SUBNET_ID --force

# Delete VPC
ibmcloud is vpc-delete $VPC_ID --force

# Delete SSH key
ibmcloud is key-delete my-ssh-key --force
```

---

## 📊 Comparison Summary

| Feature | AWS EC2 | GCP Compute | Azure VM | IBM Cloud |
|---------|---------|-------------|----------|-----------|
| **Setup Time** | 15-20 min | 15-20 min | 20-25 min | 25-30 min |
| **Complexity** | Medium | Easy | Medium | Hard |
| **Free Tier** | 750 hrs/month | 1 f1-micro | 750 hrs/month | Limited |
| **Startup Script** | User Data | Metadata | Custom Script | Cloud-init |
| **SSH Key** | Key Pair | SSH Keys | SSH Keys | SSH Keys |
| **Networking** | VPC, SG | VPC, Firewall | VNet, NSG | VPC, SG |

---

## 🎓 What You Learned

### Concepts

- ✅ Virtual machine creation
- ✅ Security groups/firewalls
- ✅ SSH key management
- ✅ Public IP assignment
- ✅ Web server installation
- ✅ Resource cleanup

### Skills

- ✅ Using CLI tools for all 4 clouds
- ✅ Deploying applications
- ✅ Configuring networking
- ✅ Managing security
- ✅ Cost management (cleanup)

---

## 🐛 Troubleshooting

### Can't SSH into Instance

```bash
# Check security group allows port 22
# Verify SSH key permissions (chmod 400)
# Check instance is running
# Verify public IP is correct
```

### Web Page Not Loading

```bash
# Check security group allows port 80
# Verify nginx is running: sudo systemctl status nginx
# Check firewall: sudo ufw status
# Wait 2-3 minutes after startup
```

### Instance Creation Failed

```bash
# Check free tier limits
# Verify region/zone availability
# Check quota limits
# Try different instance type
```

---

## 💡 Best Practices

### 1. Always Clean Up Resources

```bash
# Set reminders
# Use tags for tracking
# Delete immediately after practice
```

### 2. Use Smallest Instance Types

```bash
AWS: t2.micro
GCP: e2-micro / f1-micro
Azure: B1s
IBM: cx2-2x4
```

### 3. Monitor Costs

```bash
# Check billing dashboard daily
# Set up alerts
# Use cost calculators
```

### 4. Security

```bash
# Use strong SSH keys
# Limit security group rules
# Enable MFA
# Don't expose unnecessary ports
```

---

## 🚀 Next Steps

Now that you've deployed on all 4 clouds, try:

1. **[Deploy with Docker](./05-docker-deployment-all-clouds.md)**
   - Containerize your application
   - Deploy containers on all clouds

2. **[Kubernetes Deployment](./06-kubernetes-all-clouds.md)**
   - Use managed Kubernetes services
   - Deploy multi-container apps

3. **[CI/CD Pipeline](./07-cicd-all-clouds.md)**
   - Automate deployments
   - Set up continuous integration

4. **[Monitoring Setup](./08-monitoring-all-clouds.md)**
   - Add monitoring and logging
   - Set up alerts

---

## 📝 Practice Exercises

### Exercise 1: Modify the Web Page

- Change colors and text
- Add your name
- Add current date/time

### Exercise 2: Install Different Web Server

- Try Apache instead of Nginx
- Compare performance
- Document differences

### Exercise 3: Add Database

- Install MySQL/PostgreSQL
- Create simple database
- Connect from web app

### Exercise 4: Automation

- Create scripts to automate deployment
- Use Infrastructure as Code (Terraform)
- Compare automation approaches

---

**Congratulations!** 🎉 You've successfully deployed your first application on all 4 major cloud platforms!

**Remember**: Always clean up resources to avoid charges!
