# 🔧 Installing Ansible

## 📖 WHAT: What Are We Installing?

We're installing **Ansible** on your computer (the control node). This is where you'll write and run playbooks to manage other servers.

**Important**: You only install Ansible on YOUR computer, not on the servers you want to manage!

## 🎯 WHY: Why This Installation Method?

- ✅ Official installation methods
- ✅ Latest stable version
- ✅ Easy to update
- ✅ Works on all platforms

## 🖥️ HOW: Step-by-Step Installation

### For macOS (Mac Users)

#### Method 1: Using Homebrew (Recommended)

**Step 1: Install Homebrew** (if not already installed)

```bash
# Check if Homebrew is installed
brew --version

# If not installed, install it:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# WHAT: Package manager for macOS
# WHY: Easiest way to install software on Mac
```

**Step 2: Install Ansible**

```bash
# Install Ansible
brew install ansible

# WHAT: Installs Ansible and all dependencies
# WHY: Homebrew handles everything automatically
# TIME: 2-3 minutes
```

**Step 3: Verify Installation**

```bash
# Check Ansible version
ansible --version

# Expected output:
# ansible [core 2.15.0]
#   config file = None
#   configured module search path = ['/Users/yourname/.ansible/plugins/modules']
#   ansible python module location = /opt/homebrew/lib/python3.11/site-packages/ansible
#   ansible collection location = /Users/yourname/.ansible/collections
#   executable location = /opt/homebrew/bin/ansible
#   python version = 3.11.4

# WHAT: Shows Ansible version and configuration
# WHY: Confirms installation was successful
```

#### Method 2: Using pip (Python Package Manager)

```bash
# Install using pip
pip3 install ansible

# Or with specific version
pip3 install ansible==2.15.0

# WHAT: Installs Ansible via Python package manager
# WHY: Alternative if Homebrew doesn't work
```

---

### For Linux (Ubuntu/Debian Users)

#### Method 1: Using apt (Recommended)

**Step 1: Update Package List**

```bash
# Update package list
sudo apt update

# WHAT: Refreshes list of available packages
# WHY: Ensures you get the latest version
```

**Step 2: Install Software Properties**

```bash
# Install software-properties-common
sudo apt install software-properties-common

# WHAT: Allows adding PPAs (Personal Package Archives)
# WHY: Needed to add Ansible repository
```

**Step 3: Add Ansible Repository**

```bash
# Add Ansible PPA
sudo add-apt-repository --yes --update ppa:ansible/ansible

# WHAT: Adds official Ansible repository
# WHY: Gets latest Ansible version (not old Ubuntu version)
```

**Step 4: Install Ansible**

```bash
# Install Ansible
sudo apt install ansible

# WHAT: Installs Ansible and dependencies
# WHY: Main installation step
# TIME: 2-3 minutes
```

**Step 5: Verify Installation**

```bash
# Check version
ansible --version

# Expected output similar to:
# ansible [core 2.15.0]
#   config file = /etc/ansible/ansible.cfg
#   ...
```

#### Method 2: Using pip

```bash
# Install pip if not installed
sudo apt install python3-pip

# Install Ansible
pip3 install ansible

# Add to PATH (if needed)
export PATH=$PATH:~/.local/bin

# WHAT: Installs via Python package manager
# WHY: Alternative installation method
```

---

### For Linux (RedHat/CentOS/Fedora Users)

**Step 1: Enable EPEL Repository** (CentOS/RHEL only)

```bash
# For CentOS/RHEL 8
sudo dnf install epel-release

# For CentOS/RHEL 7
sudo yum install epel-release

# WHAT: Enables Extra Packages for Enterprise Linux
# WHY: Ansible is in EPEL repository
```

**Step 2: Install Ansible**

```bash
# For Fedora/RHEL 8+
sudo dnf install ansible

# For CentOS/RHEL 7
sudo yum install ansible

# WHAT: Installs Ansible
# WHY: Main installation
```

**Step 3: Verify**

```bash
ansible --version
```

---

### For Windows (Windows Users)

**Important**: Ansible control node doesn't run natively on Windows. You have 3 options:

#### Option 1: WSL (Windows Subsystem for Linux) - Recommended

**Step 1: Install WSL**

```powershell
# Open PowerShell as Administrator
wsl --install

# WHAT: Installs Windows Subsystem for Linux
# WHY: Allows running Linux on Windows
# NOTE: Requires restart
```

**Step 2: Install Ubuntu from Microsoft Store**

- Open Microsoft Store
- Search for "Ubuntu"
- Install Ubuntu 22.04 LTS

**Step 3: Open Ubuntu and Install Ansible**

```bash
# Inside Ubuntu terminal
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

**Step 4: Verify**

```bash
ansible --version
```

#### Option 2: Use Docker

```bash
# Pull Ansible Docker image
docker pull ansible/ansible:latest

# Run Ansible in container
docker run -it ansible/ansible:latest ansible --version

# WHAT: Runs Ansible in Docker container
# WHY: Isolated environment, no system changes
```

#### Option 3: Use Virtual Machine

- Install VirtualBox or VMware
- Create Ubuntu VM
- Follow Linux installation steps

---

## ✅ Verification Steps

### Test 1: Check Version

```bash
ansible --version

# Should show:
# - Ansible version
# - Python version
# - Config file location
```

### Test 2: Check Ansible Commands

```bash
# List all ansible commands
ansible --help

# Common commands:
# ansible          - Run ad-hoc commands
# ansible-playbook - Run playbooks
# ansible-galaxy   - Manage roles
# ansible-vault    - Encrypt sensitive data
# ansible-doc      - View module documentation
```

### Test 3: Test Localhost Connection

```bash
# Ping localhost
ansible localhost -m ping

# Expected output:
# localhost | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }

# WHAT: Tests if Ansible can connect to localhost
# WHY: Verifies Ansible is working
# -m ping: Uses ping module
```

### Test 4: Run Simple Command

```bash
# Run command on localhost
ansible localhost -m command -a "echo Hello Ansible"

# Expected output:
# localhost | CHANGED | rc=0 >>
# Hello Ansible

# WHAT: Runs echo command on localhost
# WHY: Tests command execution
# -m command: Uses command module
# -a "...": Arguments for the module
```

---

## 🔧 Post-Installation Configuration

### Create Ansible Configuration Directory

```bash
# Create directory for Ansible files
mkdir -p ~/ansible-projects
cd ~/ansible-projects

# Create basic structure
mkdir -p inventory playbooks roles

# WHAT: Creates organized directory structure
# WHY: Keep Ansible files organized
```

### Create Basic Inventory File

```bash
# Create inventory file
cat > inventory/hosts << 'EOF'
# Ansible Inventory File

[local]
localhost ansible_connection=local

[webservers]
# Add your web servers here
# web1.example.com
# web2.example.com

[databases]
# Add your database servers here
# db1.example.com
EOF

# WHAT: Creates inventory file
# WHY: Defines servers to manage
```

### Create Ansible Configuration File (Optional)

```bash
# Create ansible.cfg
cat > ansible.cfg << 'EOF'
[defaults]
inventory = ./inventory/hosts
host_key_checking = False
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

# WHAT: Custom Ansible configuration
# WHY: Sets default behaviors
```

---

## 📚 Understanding Ansible Components

### What Got Installed?

```
Ansible Installation Includes:
├── ansible              # Main command
├── ansible-playbook     # Run playbooks
├── ansible-galaxy       # Manage roles
├── ansible-vault        # Encrypt data
├── ansible-doc          # Documentation
├── ansible-config       # View configuration
├── ansible-inventory    # Manage inventory
└── ansible-pull         # Pull configuration
```

### Directory Structure

```
Default Locations:
├── /etc/ansible/                    # System-wide config (Linux)
│   ├── ansible.cfg                  # Main config file
│   └── hosts                        # Default inventory
├── ~/.ansible/                      # User config
│   ├── collections/                 # Installed collections
│   └── roles/                       # Downloaded roles
└── /usr/lib/python3.x/site-packages/ansible/  # Ansible code
    └── modules/                     # Built-in modules
```

---

## 🐛 Troubleshooting

### Issue 1: "ansible: command not found"

**Solution**:

```bash
# Check if installed
which ansible

# If not in PATH, add it:
# For pip installation:
export PATH=$PATH:~/.local/bin

# Add to ~/.bashrc or ~/.zshrc to make permanent:
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

### Issue 2: Permission Denied

**Solution**:

```bash
# Don't use sudo with pip
pip3 install --user ansible

# Or use virtual environment:
python3 -m venv ansible-venv
source ansible-venv/bin/activate
pip install ansible
```

### Issue 3: Python Version Issues

**Solution**:

```bash
# Check Python version (need 3.8+)
python3 --version

# If too old, install newer Python:
# Ubuntu:
sudo apt install python3.11

# macOS:
brew install python@3.11
```

### Issue 4: "No module named 'ansible'"

**Solution**:

```bash
# Reinstall Ansible
pip3 uninstall ansible
pip3 install ansible

# Or use system package manager
```

---

## 🎯 Quick Reference

### Installation Commands Summary

```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# RedHat/CentOS
sudo dnf install epel-release
sudo dnf install ansible

# Using pip (any OS)
pip3 install ansible

# Verify
ansible --version
```

### First Commands to Try

```bash
# 1. Check version
ansible --version

# 2. Test localhost
ansible localhost -m ping

# 3. Run command
ansible localhost -m command -a "date"

# 4. Get system info
ansible localhost -m setup
```

---

## ✅ Installation Checklist

Before proceeding, verify:

- [ ] Ansible is installed
- [ ] `ansible --version` works
- [ ] `ansible localhost -m ping` succeeds
- [ ] Created project directory structure
- [ ] Created basic inventory file
- [ ] Understand where Ansible is installed

---

## 🚀 Next Step

Now that Ansible is installed, let's learn the basics!

👉 Go to [`03-ANSIBLE-BASICS.md`](03-ANSIBLE-BASICS.md)

---

## 💡 Pro Tips

1. **Use Virtual Environments**: Keep Ansible isolated

   ```bash
   python3 -m venv ansible-env
   source ansible-env/bin/activate
   pip install ansible
   ```

2. **Update Regularly**: Keep Ansible current

   ```bash
   # Homebrew
   brew upgrade ansible
   
   # pip
   pip3 install --upgrade ansible
   
   # apt
   sudo apt update && sudo apt upgrade ansible
   ```

3. **Check Documentation**: Built-in help is excellent

   ```bash
   ansible-doc -l              # List all modules
   ansible-doc ping            # Module documentation
   ansible-doc -t connection   # Connection plugins
   ```

4. **Use Ansible Galaxy**: Thousands of ready-to-use roles

   ```bash
   ansible-galaxy search nginx
   ansible-galaxy install geerlingguy.nginx
   ```

5. **Enable Tab Completion**: Makes CLI easier

   ```bash
   # Add to ~/.bashrc
   eval $(register-python-argcomplete ansible)
   eval $(register-python-argcomplete ansible-playbook)
