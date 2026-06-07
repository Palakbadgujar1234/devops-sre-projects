# 🛠️ OpenShift Installation and Setup

## Complete Step-by-Step Guide for Beginners

---

## 📋 **WHAT YOU'LL LEARN**

By the end of this guide, you'll have:

- ✅ OpenShift Local (CRC) installed on your computer
- ✅ oc CLI tool configured
- ✅ Access to OpenShift web console
- ✅ A running local OpenShift cluster
- ✅ Verified everything works correctly

---

## 💻 **SYSTEM REQUIREMENTS**

### **Minimum Requirements:**

- **CPU:** 4 physical cores
- **RAM:** 9 GB free memory
- **Disk:** 35 GB free space
- **OS:** Windows 10/11, macOS 10.14+, or Linux

### **Recommended Requirements:**

- **CPU:** 6+ physical cores
- **RAM:** 16 GB total (10 GB free)
- **Disk:** 50 GB SSD
- **OS:** Latest version

### **Check Your System:**

**On macOS/Linux:**

```bash
# Check CPU cores
sysctl -n hw.ncpu  # macOS
nproc              # Linux

# Check RAM
free -h            # Linux
vm_stat            # macOS

# Check disk space
df -h
```

**On Windows:**

```powershell
# Check CPU cores
Get-WmiObject -Class Win32_Processor | Select-Object NumberOfCores

# Check RAM
Get-WmiObject -Class Win32_ComputerSystem | Select-Object TotalPhysicalMemory

# Check disk space
Get-PSDrive C
```

---

## 🎯 **WHAT IS OPENSHIFT LOCAL (CRC)?**

### **Simple Explanation:**

**OpenShift Local** (formerly CodeReady Containers - CRC) is a **mini OpenShift cluster** that runs on your laptop.

**Analogy:**

```
Full OpenShift Cluster = Full Restaurant
    - Multiple servers
    - Production environment
    - Serves real customers

OpenShift Local (CRC) = Kitchen at Home
    - Single machine
    - Learning/testing environment
    - Practice cooking (development)
```

### **What CRC Includes:**

- ✅ Single-node OpenShift cluster
- ✅ Web console
- ✅ All OpenShift features
- ✅ Built-in monitoring
- ✅ Image registry
- ✅ Perfect for learning!

---

## 📥 **STEP 1: DOWNLOAD OPENSHIFT LOCAL**

### **1.1 Create Red Hat Account (Free)**

1. Go to: <https://console.redhat.com>
2. Click **"Register for a Red Hat account"**
3. Fill in your details:
   - Email address
   - Password
   - First/Last name
4. Verify your email
5. Log in to Red Hat Console

**Why do we need an account?**

- To download OpenShift Local
- To get a pull secret (required for installation)
- It's completely FREE for learning!

### **1.2 Download OpenShift Local**

1. Go to: <https://console.redhat.com/openshift/create/local>
2. Click **"Download OpenShift Local"**
3. Choose your operating system:
   - **macOS:** Download `.pkg` file
   - **Windows:** Download `.msi` file
   - **Linux:** Download `.tar.xz` file

4. **Download Pull Secret:**
   - On the same page, click **"Copy pull secret"**
   - Save it in a text file (you'll need it later)

**File sizes:**

- macOS: ~2.5 GB
- Windows: ~2.5 GB
- Linux: ~2.5 GB

---

## 🔧 **STEP 2: INSTALL OPENSHIFT LOCAL**

### **2.1 Installation on macOS**

```bash
# 1. Open the downloaded .pkg file
# Double-click: crc-macos-amd64.pkg

# 2. Follow the installation wizard
# Click "Continue" → "Install" → Enter password

# 3. Verify installation
crc version

# Expected output:
# CRC version: 2.x.x+xxxxx
# OpenShift version: 4.x.x
```

### **2.2 Installation on Windows**

```powershell
# 1. Run the downloaded .msi file as Administrator
# Right-click → "Run as administrator"

# 2. Follow the installation wizard
# Accept license → Choose install location → Install

# 3. Open PowerShell as Administrator

# 4. Verify installation
crc version

# Expected output:
# CRC version: 2.x.x+xxxxx
# OpenShift version: 4.x.x
```

### **2.3 Installation on Linux**

```bash
# 1. Extract the archive
tar -xvf crc-linux-amd64.tar.xz

# 2. Move to /usr/local/bin
sudo mv crc-linux-*-amd64/crc /usr/local/bin/

# 3. Make it executable
sudo chmod +x /usr/local/bin/crc

# 4. Verify installation
crc version

# Expected output:
# CRC version: 2.x.x+xxxxx
# OpenShift version: 4.x.x
```

---

## ⚙️ **STEP 3: SETUP OPENSHIFT LOCAL**

### **3.1 Initial Setup**

This step prepares your system for OpenShift Local.

```bash
# Run setup command
crc setup

# This will:
# ✓ Check system requirements
# ✓ Download required files (~2 GB)
# ✓ Configure networking
# ✓ Set up virtualization
# ✓ Create necessary directories

# Time: 5-10 minutes
# Be patient, it's downloading OpenShift!
```

**What you'll see:**

```
INFO Checking if running as non-root
INFO Checking if crc-admin-helper executable is cached
INFO Checking for obsolete admin-helper executable
INFO Checking if running on a supported CPU architecture
INFO Checking minimum RAM requirements
INFO Checking if crc executable symlink exists
INFO Checking if Podman binary exists
INFO Checking if old launchd config for tray exists
INFO Checking if CRC bundle is extracted in '$HOME/.crc'
INFO Checking if /usr/local/bin/oc exists
INFO Checking if running emulated on Apple silicon
INFO Checking if vfkit is installed
INFO Checking if CRC bundle is cached in '$HOME/.crc'
INFO Downloading bundle for OpenShift 4.x.x...
```

### **3.2 Troubleshooting Setup Issues**

**Issue: "Not enough memory"**

```bash
# Solution: Close other applications
# Free up at least 9 GB RAM

# Check available memory:
# macOS: Activity Monitor
# Windows: Task Manager
# Linux: free -h
```

**Issue: "Virtualization not enabled"**

```bash
# Solution: Enable virtualization in BIOS
# 1. Restart computer
# 2. Enter BIOS (usually F2, F10, or Del key)
# 3. Enable VT-x (Intel) or AMD-V (AMD)
# 4. Save and exit
```

---

## 🚀 **STEP 4: START OPENSHIFT LOCAL**

### **4.1 Start the Cluster**

```bash
# Start OpenShift Local
crc start

# You'll be prompted for the pull secret
# Paste the pull secret you downloaded earlier
```

**What happens during start:**

```
INFO Checking if running as non-root
INFO Checking if crc-admin-helper executable is cached
INFO Checking for obsolete admin-helper executable
INFO Checking if running on a supported CPU architecture
INFO Checking minimum RAM requirements
INFO Checking if crc executable symlink exists
INFO Checking if Podman binary exists
INFO Checking if old launchd config for tray exists
INFO Checking if CRC bundle is extracted in '$HOME/.crc'
INFO Checking if /usr/local/bin/oc exists
INFO Checking if running emulated on Apple silicon
INFO Checking if vfkit is installed
INFO Starting CRC VM for OpenShift 4.x.x...
INFO CRC instance is running with IP 192.168.127.2
INFO CRC VM is running
INFO Updating authorized keys...
INFO Configuring shared directories
INFO Check internal and public DNS query...
INFO Check DNS query from host...
INFO Verifying validity of the kubelet certificates...
INFO Starting OpenShift kubelet service
INFO Waiting for kube-apiserver availability... [takes around 2min]
INFO Waiting for user's pull secret part of instance disk...
INFO Starting OpenShift cluster... [takes around 5min]
INFO Updating SSH key to machine...
INFO Updating cluster ID...
INFO Updating root CA cert to admin-kubeconfig-client-ca configmap...
INFO Starting kubelet and all OpenShift services...
INFO Waiting for the cluster to be ready...
```

**Time:** 10-15 minutes (first time)

### **4.2 After Successful Start**

You'll see output like this:

```
Started the OpenShift cluster.

The server is accessible via web console at:
  https://console-openshift-console.apps-crc.testing

Log in as administrator:
  Username: kubeadmin
  Password: xxxxx-xxxxx-xxxxx-xxxxx

Log in as user:
  Username: developer
  Password: developer

Use the 'oc' command line interface:
  $ eval $(crc oc-env)
  $ oc login -u developer https://api.crc.testing:6443
```

**IMPORTANT:** Save these credentials!

---

## 🔑 **STEP 5: INSTALL OC CLI TOOL**

### **5.1 What is oc CLI?**

**oc** is the **OpenShift command-line tool** - like a remote control for OpenShift.

**Analogy:**

```
Web Console = TV Remote (visual, easy)
oc CLI = Universal Remote (powerful, flexible)
```

### **5.2 Install oc CLI**

**Option 1: Use CRC's oc (Recommended)**

```bash
# Set up environment to use CRC's oc
eval $(crc oc-env)

# Verify
oc version

# Expected output:
# Client Version: 4.x.x
# Kubernetes Version: v1.xx.x
```

**Option 2: Download Separately**

**macOS:**

```bash
# Download
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-mac.tar.gz

# Extract
tar -xvf openshift-client-mac.tar.gz

# Move to PATH
sudo mv oc /usr/local/bin/

# Verify
oc version
```

**Windows:**

```powershell
# Download from:
# https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-windows.zip

# Extract to C:\Program Files\OpenShift\

# Add to PATH:
# System Properties → Environment Variables → Path → Add C:\Program Files\OpenShift\

# Verify
oc version
```

**Linux:**

```bash
# Download
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

# Extract
tar -xvf openshift-client-linux.tar.gz

# Move to PATH
sudo mv oc /usr/local/bin/

# Verify
oc version
```

---

## 🔐 **STEP 6: LOGIN TO OPENSHIFT**

### **6.1 Login via CLI**

```bash
# Set up oc environment (if not done)
eval $(crc oc-env)

# Login as developer
oc login -u developer -p developer https://api.crc.testing:6443

# Expected output:
# Login successful.
# You have access to 67 projects...
```

**Two Default Users:**

| User | Password | Role | Use For |
|------|----------|------|---------|
| `developer` | `developer` | Regular user | Development, testing |
| `kubeadmin` | (shown at start) | Admin | Cluster management |

### **6.2 Login as Admin**

```bash
# Get admin password
crc console --credentials

# Output shows:
# To login as a regular user, run 'oc login -u developer -p developer https://api.crc.testing:6443'.
# To login as an admin, run 'oc login -u kubeadmin -p xxxxx-xxxxx-xxxxx-xxxxx https://api.crc.testing:6443'

# Login as admin
oc login -u kubeadmin -p <password-from-above> https://api.crc.testing:6443
```

---

## 🌐 **STEP 7: ACCESS WEB CONSOLE**

### **7.1 Open Web Console**

```bash
# Open web console in browser
crc console

# This opens: https://console-openshift-console.apps-crc.testing
```

**Or manually:**

1. Open browser
2. Go to: `https://console-openshift-console.apps-crc.testing`
3. Accept security warning (it's local, it's safe)
4. Login with credentials

### **7.2 Web Console Tour**

**Login Screen:**

```
1. Choose login method: "htpasswd"
2. Enter username: developer
3. Enter password: developer
4. Click "Log in"
```

**Main Interface:**

```
┌─────────────────────────────────────────┐
│  [OpenShift Logo]  [Search] [?] [User]  │
├─────────────────────────────────────────┤
│                                         │
│  Perspective Switcher:                  │
│  • Administrator (cluster management)   │
│  • Developer (app development)          │
│                                         │
│  Left Sidebar:                          │
│  • Projects                             │
│  • Workloads                            │
│  • Networking                           │
│  • Storage                              │
│  • Builds                               │
│  • Pipelines                            │
│  • Monitoring                           │
│                                         │
└─────────────────────────────────────────┘
```

---

## ✅ **STEP 8: VERIFY INSTALLATION**

### **8.1 Check Cluster Status**

```bash
# Check if cluster is running
crc status

# Expected output:
# CRC VM:          Running
# OpenShift:       Running (v4.x.x)
# RAM Usage:       10.5GB of 10.5GB
# Disk Usage:      15GB of 31GB (Inside the CRC VM)
# Cache Usage:     35GB
# Cache Directory: /Users/username/.crc/cache
```

### **8.2 Check Nodes**

```bash
# List cluster nodes
oc get nodes

# Expected output:
# NAME                 STATUS   ROLES                         AGE   VERSION
# crc-xxxxx-master-0   Ready    control-plane,master,worker   10m   v1.xx.x
```

**Explanation:**

- **NAME:** Node identifier
- **STATUS:** Should be "Ready"
- **ROLES:** This node is master + worker (all-in-one)
- **AGE:** How long it's been running
- **VERSION:** Kubernetes version

### **8.3 Check Pods**

```bash
# List all pods in all namespaces
oc get pods --all-namespaces

# You should see many pods running
# Example output:
# NAMESPACE                              NAME                                         READY   STATUS
# openshift-apiserver                    apiserver-7d8c9f8b9-xxxxx                   2/2     Running
# openshift-authentication               oauth-openshift-xxxxx                       1/1     Running
# openshift-console                      console-xxxxx                               1/1     Running
# openshift-monitoring                   prometheus-k8s-0                            6/6     Running
```

### **8.4 Create Test Project**

```bash
# Create a new project (namespace)
oc new-project my-first-project

# Expected output:
# Now using project "my-first-project" on server "https://api.crc.testing:6443".

# List projects
oc projects

# You should see your new project listed
```

### **8.5 Deploy Test Application**

```bash
# Deploy a simple test app
oc new-app httpd-example

# Wait for deployment
oc get pods -w

# Press Ctrl+C when pod is Running

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# httpd-example-xxxxx-xxxxx         1/1     Running   0          2m
```

### **8.6 Expose the Application**

```bash
# Create a route to access the app
oc expose service httpd-example

# Get the route URL
oc get route httpd-example

# Expected output:
# NAME            HOST/PORT                                      PATH   SERVICES        PORT       TERMINATION   WILDCARD
# httpd-example   httpd-example-my-first-project.apps-crc.testing          httpd-example   8080-tcp                 None

# Open in browser
# Copy the HOST/PORT value and paste in browser
```

**Success!** If you see a webpage, your OpenShift is working perfectly! 🎉

---

## 🛠️ **USEFUL CRC COMMANDS**

### **Basic Commands:**

```bash
# Start OpenShift Local
crc start

# Stop OpenShift Local
crc stop

# Check status
crc status

# Delete cluster (careful!)
crc delete

# Get console URL
crc console --url

# Get credentials
crc console --credentials

# View logs
crc logs

# Get cluster info
crc info

# Cleanup (removes everything)
crc cleanup
```

### **Resource Management:**

```bash
# Configure CPU cores (before start)
crc config set cpus 6

# Configure memory (before start)
crc config set memory 16384  # in MB

# Configure disk size (before start)
crc config set disk-size 50  # in GB

# View current config
crc config view
```

---

## 🐛 **COMMON ISSUES AND SOLUTIONS**

### **Issue 1: "Not enough memory"**

**Error:**

```
ERRO Not enough memory to start the instance
```

**Solution:**

```bash
# Close other applications
# Or increase memory allocation
crc config set memory 10240  # 10 GB
crc delete
crc start
```

### **Issue 2: "Pull secret required"**

**Error:**

```
ERRO Failed to start: pull secret is required
```

**Solution:**

```bash
# Get pull secret from:
# https://console.redhat.com/openshift/create/local
# Copy and paste when prompted during crc start
```

### **Issue 3: "Cannot connect to console"**

**Error:**

```
Browser shows: "This site can't be reached"
```

**Solution:**

```bash
# Check if cluster is running
crc status

# If not running, start it
crc start

# Check DNS resolution
ping console-openshift-console.apps-crc.testing

# If ping fails, restart CRC
crc stop
crc start
```

### **Issue 4: "oc command not found"**

**Error:**

```
bash: oc: command not found
```

**Solution:**

```bash
# Set up environment
eval $(crc oc-env)

# Add to shell profile for permanent fix
echo 'eval $(crc oc-env)' >> ~/.bashrc  # Linux/macOS
echo 'eval $(crc oc-env)' >> ~/.zshrc   # macOS with zsh
```

### **Issue 5: "Cluster won't start"**

**Solution:**

```bash
# Complete cleanup and restart
crc stop
crc delete
crc cleanup
crc setup
crc start
```

---

## 📝 **POST-INSTALLATION CHECKLIST**

- [ ] OpenShift Local installed
- [ ] `crc setup` completed successfully
- [ ] `crc start` completed successfully
- [ ] Can access web console
- [ ] `oc` CLI tool working
- [ ] Can login via CLI
- [ ] Test project created
- [ ] Test application deployed
- [ ] Can access test application

---

## 🎯 **NEXT STEPS**

Congratulations! You now have a working OpenShift cluster! 🎉

**What you've accomplished:**

- ✅ Installed OpenShift Local
- ✅ Started your first cluster
- ✅ Accessed web console
- ✅ Used oc CLI
- ✅ Deployed your first app

**Ready to learn more?**

👉 **Next Guide:** [`03-FIRST-APPLICATION.md`](./03-FIRST-APPLICATION.md)

In the next guide, you'll:

- Understand Pods, Deployments, and Services in detail
- Deploy a real application from scratch
- Learn how to scale applications
- Troubleshoot common issues
- Access your application from outside

---

## 💡 **PRO TIPS**

### **Tip 1: Save Resources**

```bash
# Stop CRC when not using
crc stop

# This frees up 10+ GB RAM
```

### **Tip 2: Quick Restart**

```bash
# If something seems broken
crc stop && crc start
```

### **Tip 3: Persistent Shell Setup**

```bash
# Add to ~/.bashrc or ~/.zshrc
eval $(crc oc-env)

# Now oc works in every new terminal
```

### **Tip 4: Bookmark Console**

```
Bookmark: https://console-openshift-console.apps-crc.testing
Save credentials in password manager
```

### **Tip 5: Learn Keyboard Shortcuts**

```
In Web Console:
- Ctrl+K (Cmd+K on Mac): Quick search
- ? : Show keyboard shortcuts
```

---

## 🎓 **INTERVIEW QUESTIONS**

### **Q1: What is OpenShift Local (CRC)?**

**Answer:**
"OpenShift Local, formerly CodeReady Containers, is a minimal OpenShift cluster that runs on a local machine. It's designed for development and testing, providing a single-node cluster with all OpenShift features. It's perfect for learning and local development before deploying to production clusters."

### **Q2: What are the minimum requirements for CRC?**

**Answer:**
"CRC requires 4 physical CPU cores, 9 GB of free RAM, and 35 GB of free disk space. However, for better performance, 6+ cores and 16 GB RAM are recommended. It supports Windows, macOS, and Linux."

### **Q3: How is CRC different from Minikube?**

**Answer:**
"While Minikube provides a basic Kubernetes cluster, CRC provides a complete OpenShift environment with additional features like built-in image registry, web console, monitoring, logging, and OpenShift-specific resources like Routes and BuildConfigs. CRC is specifically for OpenShift development."

---

## 📚 **ADDITIONAL RESOURCES**

- **Official Docs:** <https://crc.dev/crc/>
- **Getting Started:** <https://access.redhat.com/documentation/en-us/red_hat_openshift_local>
- **Troubleshooting:** <https://crc.dev/crc/troubleshooting/>
- **Community:** <https://github.com/crc-org/crc>

---

**Your OpenShift journey has begun! Keep practicing and exploring! 🚀**
