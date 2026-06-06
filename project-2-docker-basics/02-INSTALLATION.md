# 🔧 Installing Docker

## 📖 WHAT: What Are We Installing?

We're installing **Docker Desktop** - a complete package that includes:

- Docker Engine (the core)
- Docker CLI (command line tool)
- Docker Compose (for multi-container apps)
- A nice graphical interface

## 🎯 WHY: Why This Installation Method?

Docker Desktop is the easiest way for beginners because:

- ✅ One-click installation
- ✅ Works on Mac, Windows, and Linux
- ✅ Includes everything you need
- ✅ Easy to manage

## 🖥️ HOW: Step-by-Step Installation

### For macOS (Mac Users)

#### Step 1: Download Docker Desktop

```bash
# Open your browser and go to:
https://www.docker.com/products/docker-desktop

# OR use this direct link:
https://desktop.docker.com/mac/main/arm64/Docker.dmg  # For M1/M2/M3 Macs
https://desktop.docker.com/mac/main/amd64/Docker.dmg  # For Intel Macs
```

**How to know which Mac you have?**

- Click Apple menu (top left) → About This Mac
- If it says "Apple M1/M2/M3" → Download ARM version
- If it says "Intel" → Download Intel version

#### Step 2: Install

1. Open the downloaded `.dmg` file
2. Drag Docker icon to Applications folder
3. Open Docker from Applications
4. Click "Open" when macOS asks for permission
5. Enter your password when prompted

#### Step 3: Verify Installation

```bash
# Open Terminal (Cmd + Space, type "Terminal")
# Type this command:
docker --version

# You should see something like:
# Docker version 24.0.0, build abc123
```

**WHAT this command does**: Checks if Docker is installed and shows the version

**WHY we run it**: To confirm Docker is working

---

### For Windows (Windows Users)

#### Step 1: Check Windows Version

```powershell
# Press Win + R, type: winver
# You need Windows 10/11 (64-bit)
```

#### Step 2: Enable WSL 2 (Windows Subsystem for Linux)

```powershell
# Open PowerShell as Administrator
# (Right-click Start → Windows PowerShell (Admin))

# Run this command:
wsl --install

# WHAT: Installs Linux compatibility layer
# WHY: Docker needs Linux to run
# HOW LONG: 5-10 minutes
```

**Restart your computer after this step!**

#### Step 3: Download Docker Desktop

```bash
# Go to:
https://www.docker.com/products/docker-desktop

# Download "Docker Desktop for Windows"
```

#### Step 4: Install

1. Run the installer (Docker Desktop Installer.exe)
2. Keep all default options checked
3. Click "Ok" to install
4. Restart computer when prompted

#### Step 5: Start Docker Desktop

1. Search for "Docker Desktop" in Start menu
2. Click to open
3. Accept the terms
4. Wait for Docker to start (whale icon in system tray)

#### Step 6: Verify Installation

```powershell
# Open PowerShell or Command Prompt
# Type:
docker --version

# You should see:
# Docker version 24.0.0, build abc123
```

---

### For Linux (Ubuntu/Debian Users)

#### Step 1: Update System

```bash
# Open Terminal (Ctrl + Alt + T)
# Update package list:
sudo apt-get update

# WHAT: Updates the list of available packages
# WHY: Ensures we get the latest version
# SUDO: Gives admin permission (you'll need to enter password)
```

#### Step 2: Install Prerequisites

```bash
# Install required packages:
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# WHAT each package does:
# ca-certificates: Allows secure downloads
# curl: Tool to download files
# gnupg: Encryption tool
# lsb-release: Identifies your Linux version
```

#### Step 3: Add Docker's Official GPG Key

```bash
# Create directory for keys:
sudo mkdir -p /etc/apt/keyrings

# Download Docker's key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# WHAT: Downloads Docker's security key
# WHY: Verifies packages are from Docker (security)
```

#### Step 4: Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# WHAT: Adds Docker's download location to your system
# WHY: So apt-get knows where to download Docker from
```

#### Step 5: Install Docker

```bash
# Update package list again:
sudo apt-get update

# Install Docker:
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# WHAT each component is:
# docker-ce: Docker Community Edition (main engine)
# docker-ce-cli: Command line tool
# containerd.io: Container runtime
```

#### Step 6: Start Docker

```bash
# Start Docker service:
sudo systemctl start docker

# Enable Docker to start on boot:
sudo systemctl enable docker

# WHAT: Starts Docker and sets it to auto-start
# WHY: So Docker runs automatically when you restart
```

#### Step 7: Add Your User to Docker Group (Optional but Recommended)

```bash
# Add yourself to docker group:
sudo usermod -aG docker $USER

# WHAT: Adds you to the docker group
# WHY: So you don't need to type 'sudo' before every docker command

# Log out and log back in for this to take effect!
```

#### Step 8: Verify Installation

```bash
# Check Docker version:
docker --version

# Test Docker:
docker run hello-world

# WHAT: Runs a test container
# WHY: Confirms Docker is working correctly
```

---

## ✅ Verification Steps (All Platforms)

### Test 1: Check Version

```bash
docker --version

# Expected output:
# Docker version 24.0.0, build abc123

# WHAT: Shows Docker version
# WHY: Confirms Docker is installed
```

### Test 2: Check Docker is Running

```bash
docker info

# Expected output: Lots of information about Docker
# If you see "Cannot connect to Docker daemon" → Docker is not running

# WHAT: Shows detailed Docker information
# WHY: Confirms Docker daemon is running
```

### Test 3: Run Your First Container

```bash
docker run hello-world

# Expected output:
# "Hello from Docker!"
# "This message shows that your installation appears to be working correctly."

# WHAT this command does:
# 1. Looks for 'hello-world' image locally
# 2. Downloads it from Docker Hub (if not found)
# 3. Creates a container from the image
# 4. Runs the container
# 5. Shows the message
# 6. Stops the container

# WHY: This is the traditional "Hello World" test for Docker
```

---

## 🔍 Understanding What Just Happened

When you ran `docker run hello-world`:

```
Step 1: Docker looked for 'hello-world' image on your computer
        ↓
Step 2: Didn't find it, so downloaded from Docker Hub
        ↓
Step 3: Created a container from the image
        ↓
Step 4: Started the container
        ↓
Step 5: Container printed "Hello from Docker!"
        ↓
Step 6: Container stopped (its job was done)
```

---

## 🐛 Troubleshooting Common Issues

### Issue 1: "Docker daemon is not running"

**Solution**:

- **Mac/Windows**: Open Docker Desktop application
- **Linux**: Run `sudo systemctl start docker`

### Issue 2: "Permission denied" (Linux)

**Solution**:

```bash
# Add yourself to docker group:
sudo usermod -aG docker $USER

# Log out and log back in
```

### Issue 3: "Cannot connect to Docker daemon" (Windows)

**Solution**:

- Make sure WSL 2 is installed
- Restart Docker Desktop
- Check if virtualization is enabled in BIOS

### Issue 4: Docker Desktop won't start (Mac)

**Solution**:

- Check if you have enough disk space (need at least 4GB)
- Try restarting your Mac
- Reinstall Docker Desktop

---

## 📊 Docker Desktop Interface (Mac/Windows)

After installation, you'll see Docker Desktop with:

```
┌─────────────────────────────────────┐
│  Docker Desktop                      │
├─────────────────────────────────────┤
│  🐳 Containers/Apps                 │  ← See running containers
│  📦 Images                           │  ← See downloaded images
│  📚 Volumes                          │  ← Data storage
│  🌐 Dev Environments                 │  ← Development setups
│  ⚙️  Settings                        │  ← Configure Docker
└─────────────────────────────────────┘
```

**You don't need to use the GUI** - we'll use command line, but it's nice to have!

---

## 🎯 What You've Accomplished

✅ Installed Docker on your computer
✅ Verified Docker is working
✅ Ran your first container
✅ Understand basic Docker commands

---

## 📝 Commands Summary

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `docker --version` | Shows Docker version | Check if installed |
| `docker info` | Shows Docker details | Check if running |
| `docker run hello-world` | Runs test container | Verify installation |

---

## 🚀 Next Step

Now that Docker is installed and working, let's run some real containers!

👉 Go to [`03-FIRST-CONTAINER.md`](03-FIRST-CONTAINER.md)

---

## 💡 Pro Tips

1. **Keep Docker Desktop running** (Mac/Windows) - it needs to be open for Docker to work
2. **Docker uses disk space** - it's normal to see it use 2-5 GB
3. **First downloads are slow** - Docker images can be large, be patient
4. **Use Docker Desktop GUI** - great for beginners to visualize what's happening
5. **Update regularly** - Docker releases updates frequently

---

## 🎓 Interview Tip

**Question**: "How do you install Docker?"

**Your Answer**:
> "I install Docker Desktop on Mac/Windows for the complete package, or use the official Docker repository on Linux. After installation, I verify it works by running `docker --version` and `docker run hello-world`. I also ensure the Docker daemon is running and my user has proper permissions to execute Docker commands without sudo."
