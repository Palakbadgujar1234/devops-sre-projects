# 🏗️ Building Your Own Docker Image

## 📖 WHAT: What Are We Building?

We're going to create our own Docker image from scratch! This is like creating your own recipe that others can use.

**Remember**:

- **Image** = Recipe/Blueprint
- **Container** = The actual running instance

## 🎯 WHY: Why Build Your Own Images?

In real projects, you need custom images because:

- ✅ Your app has specific dependencies
- ✅ You need specific configurations
- ✅ You want to package your code
- ✅ You want to share with your team

---

## 📝 The Dockerfile: Your Recipe Card

### What is a Dockerfile?

A **Dockerfile** is a text file with instructions to build an image.

**Think of it like a cooking recipe**:

```
Recipe Card (Dockerfile)          Docker Image
─────────────────────            ──────────────
1. Take a bowl (base)      →     Base OS
2. Add flour (install)     →     Dependencies
3. Add eggs (copy files)   →     Your code
4. Mix (configure)         →     Settings
5. Bake (run command)      →     Start app
```

---

## 🚀 Example 1: Simple Python App

### Step 1: Create Project Directory

```bash
# Create a new directory:
mkdir my-first-docker-app
cd my-first-docker-app

# WHAT: Creates a folder for our project
# WHY: Keep everything organized
```

### Step 2: Create a Simple Python App

```bash
# Create app.py file:
cat > app.py << 'EOF'
print("Hello from Docker!")
print("This is my first containerized app!")
EOF

# WHAT: Creates a Python file
# WHY: This is the app we'll containerize
```

**Or create it manually**:

```python
# File: app.py
print("Hello from Docker!")
print("This is my first containerized app!")
```

### Step 3: Create Your First Dockerfile

```bash
# Create Dockerfile:
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
EOF
```

**Or create it manually**:

```dockerfile
# File: Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

### 🔍 Understanding Each Line

Let's break down the Dockerfile line by line:

#### Line 1: FROM

```dockerfile
FROM python:3.9-slim
```

**WHAT**: Specifies the base image to start from
**WHY**: We need Python installed to run Python code
**BREAKDOWN**:

- `FROM`: Dockerfile keyword for base image
- `python`: Official Python image
- `3.9`: Python version
- `slim`: Smaller version (less bloat)

**Think of it as**: "Start with a computer that has Python 3.9 already installed"

**Alternatives**:

- `python:3.9` - Full version (larger)
- `python:3.9-alpine` - Smallest version
- `ubuntu:22.04` - Start with Ubuntu (you'd need to install Python yourself)

#### Line 2: WORKDIR

```dockerfile
WORKDIR /app
```

**WHAT**: Sets the working directory inside the container
**WHY**: All subsequent commands run from this directory
**BREAKDOWN**:

- `WORKDIR`: Dockerfile keyword
- `/app`: Directory path (creates if doesn't exist)

**Think of it as**: "cd /app" - change to this directory

**What happens**:

```
Before WORKDIR:  You're at /
After WORKDIR:   You're at /app
```

#### Line 3: COPY

```dockerfile
COPY app.py .
```

**WHAT**: Copies files from your computer into the image
**WHY**: We need our code inside the container
**BREAKDOWN**:

- `COPY`: Dockerfile keyword
- `app.py`: Source file (on your computer)
- `.`: Destination (current directory in container = /app)

**Think of it as**: "Copy app.py from my computer to /app in the container"

**The dot (.) means**: Current directory (which is /app because of WORKDIR)

#### Line 4: CMD

```dockerfile
CMD ["python", "app.py"]
```

**WHAT**: Command to run when container starts
**WHY**: Tells Docker what to execute
**BREAKDOWN**:

- `CMD`: Dockerfile keyword
- `["python", "app.py"]`: Command in JSON array format
- `python`: The program to run
- `app.py`: Argument to python

**Think of it as**: "When someone starts this container, run: python app.py"

**Format explanation**:

```dockerfile
CMD ["executable", "param1", "param2"]
# Same as running: executable param1 param2
```

### Step 4: Build the Image

```bash
docker build -t my-python-app .

# Let's break this down:
```

**Command Breakdown**:

```bash
docker build
```

**WHAT**: Command to build an image from Dockerfile
**WHY**: Converts Dockerfile instructions into an image

```bash
-t my-python-app
```

**WHAT**: Tags (names) the image
**WHY**: So you can reference it easily
**BREAKDOWN**:

- `-t`: Tag flag
- `my-python-app`: The name you're giving it

```bash
.
```

**WHAT**: Build context (current directory)
**WHY**: Tells Docker where to find Dockerfile and files
**MEANING**: "Look in current directory for Dockerfile"

### What Happens During Build?

```
Step 1/4 : FROM python:3.9-slim
 ---> Pulling image (if not exists)
 ---> Using cached image (if exists)

Step 2/4 : WORKDIR /app
 ---> Creating directory /app

Step 3/4 : COPY app.py .
 ---> Copying app.py to /app

Step 4/4 : CMD ["python", "app.py"]
 ---> Setting default command

Successfully built abc123def456
Successfully tagged my-python-app:latest
```

**Each step creates a layer** (like layers in a cake):

```
Layer 4: CMD instruction
Layer 3: app.py file
Layer 2: /app directory
Layer 1: Python 3.9 base
```

### Step 5: View Your Image

```bash
docker images

# WHAT: Lists all images on your computer
# WHY: To see your newly built image
```

**Expected Output**:

```
REPOSITORY       TAG       IMAGE ID       CREATED          SIZE
my-python-app    latest    abc123def456   10 seconds ago   125MB
python           3.9-slim  def456abc123   2 weeks ago      122MB
```

**Understanding the output**:

- `REPOSITORY`: Image name
- `TAG`: Version (default is "latest")
- `IMAGE ID`: Unique identifier
- `CREATED`: When it was built
- `SIZE`: How much disk space it uses

### Step 6: Run Your Image

```bash
docker run my-python-app

# WHAT: Creates and runs a container from your image
# WHY: To see if it works!
```

**Expected Output**:

```
Hello from Docker!
This is my first containerized app!
```

**What just happened?**

```
1. Docker created a container from my-python-app image
2. Started the container
3. Ran: python app.py
4. Printed the output
5. Container exited (job done)
```

### Step 7: Run with Auto-Remove

```bash
docker run --rm my-python-app

# WHAT: --rm flag automatically removes container after it exits
# WHY: Keeps your system clean (no leftover containers)
```

---

## 🌐 Example 2: Simple Web Server

Let's build something more interesting - a web server!

### Step 1: Create Project Structure

```bash
# Create directory:
mkdir simple-web-app
cd simple-web-app

# Create app file:
cat > server.py << 'EOF'
from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        message = "<h1>Hello from Docker!</h1><p>This is a containerized web server.</p>"
        self.wfile.write(message.encode())

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8000), SimpleHandler)
    print('Server running on port 8000...')
    server.serve_forever()
EOF
```

**Understanding the Python code**:

```python
from http.server import HTTPServer, BaseHTTPRequestHandler
# WHAT: Imports Python's built-in web server
# WHY: We don't need to install anything extra
```

```python
class SimpleHandler(BaseHTTPRequestHandler):
# WHAT: Creates a custom request handler
# WHY: Defines what to do when someone visits our site
```

```python
def do_GET(self):
# WHAT: Handles GET requests (when you visit in browser)
# WHY: Browser sends GET request when you type URL
```

```python
self.send_response(200)
# WHAT: Sends HTTP 200 status (success)
# WHY: Tells browser everything is OK
```

```python
message = "<h1>Hello from Docker!</h1>..."
self.wfile.write(message.encode())
# WHAT: Sends HTML to browser
# WHY: This is what you'll see on the page
```

```python
server = HTTPServer(('0.0.0.0', 8000), SimpleHandler)
# WHAT: Creates server on all interfaces, port 8000
# WHY: 0.0.0.0 means "listen on all network interfaces"
```

### Step 2: Create Dockerfile

```dockerfile
# File: Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY server.py .

EXPOSE 8000

CMD ["python", "server.py"]
```

**New instruction: EXPOSE**

```dockerfile
EXPOSE 8000
```

**WHAT**: Documents which port the container listens on
**WHY**: Tells users which port to map
**IMPORTANT**: This is just documentation! It doesn't actually publish the port
**THINK**: Like a label saying "This app uses port 8000"

### Step 3: Build the Image

```bash
docker build -t simple-web-app .

# WHAT: Builds image named "simple-web-app"
# WHY: We need an image to create containers
```

### Step 4: Run the Container

```bash
docker run -d -p 8000:8000 --name my-web simple-web-app

# WHAT: Runs container in background, maps port 8000
# WHY: So we can access the web server
```

### Step 5: Test It

```bash
# Open browser:
http://localhost:8000

# Or use curl:
curl http://localhost:8000

# Expected: HTML page with "Hello from Docker!"
```

### Step 6: View Logs

```bash
docker logs my-web

# Expected output:
# Server running on port 8000...
```

### Step 7: Clean Up

```bash
docker stop my-web
docker rm my-web
```

---

## 📦 Example 3: Node.js Application

Let's build a real-world Node.js app!

### Step 1: Create Project

```bash
mkdir node-docker-app
cd node-docker-app
```

### Step 2: Create package.json

```json
{
  "name": "node-docker-app",
  "version": "1.0.0",
  "description": "Simple Node.js app in Docker",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

**Understanding package.json**:

```json
"dependencies": {
  "express": "^4.18.0"
}
```

**WHAT**: Lists packages our app needs
**WHY**: npm will install these
**EXPRESS**: Popular web framework for Node.js

### Step 3: Create server.js

```javascript
// File: server.js
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('<h1>Hello from Node.js in Docker!</h1>');
});

app.get('/api/status', (req, res) => {
  res.json({ 
    status: 'running',
    message: 'API is working!',
    timestamp: new Date()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

**Understanding the code**:

```javascript
const express = require('express');
// WHAT: Imports Express framework
// WHY: Makes building web servers easier
```

```javascript
app.get('/', (req, res) => {
  res.send('<h1>Hello from Node.js in Docker!</h1>');
});
// WHAT: Defines route for homepage
// WHY: When you visit /, you see this message
```

```javascript
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
// WHAT: Starts server on port 3000
// WHY: 0.0.0.0 means listen on all interfaces (important for Docker!)
```

### Step 4: Create Dockerfile

```dockerfile
# File: Dockerfile

# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY server.js ./

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
```

**New instruction: RUN**

```dockerfile
RUN npm install
```

**WHAT**: Executes a command during image build
**WHY**: We need to install dependencies
**DIFFERENCE from CMD**:

- `RUN`: Executes during BUILD (creates layer)
- `CMD`: Executes when container STARTS

**Understanding the order**:

```dockerfile
COPY package*.json ./    # Copy package files first
RUN npm install          # Install dependencies
COPY server.js ./        # Copy code after
```

**WHY this order?**

- Docker caches layers
- If server.js changes, package.json might not
- This way, npm install only runs when dependencies change
- Faster builds!

### Step 5: Create .dockerignore

```bash
# File: .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
```

**WHAT**: Tells Docker which files to ignore when copying
**WHY**: Don't copy unnecessary files (like node_modules)
**SIMILAR TO**: .gitignore for Git

**Why ignore node_modules?**

- We run `npm install` in Dockerfile
- Copying local node_modules is wasteful
- Might cause compatibility issues

### Step 6: Build the Image

```bash
docker build -t node-docker-app .

# Watch the build process:
# Step 1: FROM node:18-alpine
# Step 2: WORKDIR /app
# Step 3: COPY package*.json
# Step 4: RUN npm install  ← This installs Express
# Step 5: COPY server.js
# Step 6: EXPOSE 3000
# Step 7: CMD ["npm", "start"]
```

### Step 7: Run the Container

```bash
docker run -d -p 3000:3000 --name node-app node-docker-app

# WHAT: Runs Node.js app in background
# WHY: Maps port 3000 so we can access it
```

### Step 8: Test the App

```bash
# Test homepage:
curl http://localhost:3000
# Output: <h1>Hello from Node.js in Docker!</h1>

# Test API endpoint:
curl http://localhost:3000/api/status
# Output: {"status":"running","message":"API is working!","timestamp":"..."}

# Or open in browser:
# http://localhost:3000
# http://localhost:3000/api/status
```

### Step 9: View Logs

```bash
docker logs node-app

# Expected:
# Server running on port 3000
```

### Step 10: Clean Up

```bash
docker stop node-app
docker rm node-app
```

---

## 🎯 Dockerfile Instructions Reference

### Essential Instructions

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image | `FROM ubuntu:22.04` |
| `WORKDIR` | Set working directory | `WORKDIR /app` |
| `COPY` | Copy files | `COPY . .` |
| `RUN` | Execute command (build time) | `RUN apt-get update` |
| `CMD` | Default command (runtime) | `CMD ["python", "app.py"]` |
| `EXPOSE` | Document port | `EXPOSE 8080` |
| `ENV` | Set environment variable | `ENV NODE_ENV=production` |
| `ARG` | Build-time variable | `ARG VERSION=1.0` |

### COPY vs ADD

```dockerfile
# COPY - Simple file copy (recommended)
COPY app.py /app/

# ADD - Can extract archives and download URLs
ADD archive.tar.gz /app/
ADD http://example.com/file.txt /app/
```

**BEST PRACTICE**: Use COPY unless you need ADD's special features

### CMD vs ENTRYPOINT

```dockerfile
# CMD - Can be overridden
CMD ["python", "app.py"]
# Run: docker run image  → runs python app.py
# Run: docker run image ls  → runs ls (overrides CMD)

# ENTRYPOINT - Always runs
ENTRYPOINT ["python"]
CMD ["app.py"]
# Run: docker run image  → runs python app.py
# Run: docker run image test.py  → runs python test.py
```

---

## 🏷️ Image Tagging

### Basic Tagging

```bash
# Build with tag:
docker build -t myapp:1.0 .

# WHAT: Creates image named "myapp" with tag "1.0"
# WHY: Version control for images
```

### Multiple Tags

```bash
# Tag existing image:
docker tag myapp:1.0 myapp:latest
docker tag myapp:1.0 myapp:stable

# WHAT: Creates additional tags for same image
# WHY: Different names for same image
```

### Tag Format

```
[registry/][username/]repository:tag

Examples:
myapp:latest                    # Local image
myuser/myapp:1.0               # Docker Hub image
gcr.io/myproject/myapp:1.0     # Google Container Registry
```

---

## 📊 Best Practices

### 1. Use Specific Base Images

```dockerfile
# ❌ Bad - too vague
FROM python

# ✅ Good - specific version
FROM python:3.9-slim
```

### 2. Minimize Layers

```dockerfile
# ❌ Bad - multiple RUN commands
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git

# ✅ Good - combine commands
RUN apt-get update && \
    apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*
```

### 3. Order Matters (Caching)

```dockerfile
# ✅ Good - dependencies first (change less often)
COPY package.json .
RUN npm install
COPY . .

# ❌ Bad - code first (changes often, breaks cache)
COPY . .
RUN npm install
```

### 4. Use .dockerignore

```
# .dockerignore
node_modules
.git
*.log
.env
```

### 5. Don't Run as Root

```dockerfile
# Create non-root user
RUN useradd -m appuser
USER appuser
```

---

## 🔍 Debugging Build Issues

### View Build Steps

```bash
# Build with no cache (fresh build):
docker build --no-cache -t myapp .

# WHAT: Rebuilds everything from scratch
# WHY: Sometimes cache causes issues
```

### Build with Progress

```bash
# See detailed output:
docker build --progress=plain -t myapp .

# WHAT: Shows all output (not just errors)
# WHY: Helps debug build problems
```

### Inspect Image Layers

```bash
# See image history:
docker history myapp

# WHAT: Shows all layers and their sizes
# WHY: Helps optimize image size
```

---

## ✅ Practice Exercises

### Exercise 1: Build a Python Calculator

```python
# File: calculator.py
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

print(f"5 + 3 = {add(5, 3)}")
print(f"5 - 3 = {subtract(5, 3)}")
```

**Your task**: Create Dockerfile and build image

### Exercise 2: Multi-File App

Create an app with:

- `app.py` - Main application
- `utils.py` - Helper functions
- `requirements.txt` - Dependencies

**Your task**: Build image that includes all files

### Exercise 3: Environment Variables

```dockerfile
# Use ENV to set variables
ENV APP_NAME="MyApp"
ENV APP_VERSION="1.0"
```

**Your task**: Create app that uses these variables

---

## 🎓 Interview Questions

**Q: What is a Dockerfile?**
**A**: A Dockerfile is a text file containing instructions to build a Docker image. It defines the base image, dependencies, files to copy, and commands to run. Each instruction creates a layer in the final image.

**Q: What's the difference between COPY and ADD?**
**A**: COPY simply copies files from host to image. ADD can also extract tar archives and download files from URLs. Best practice is to use COPY unless you specifically need ADD's extra features.

**Q: What's the difference between RUN and CMD?**
**A**: RUN executes commands during image build time and creates a new layer. CMD specifies the default command to run when a container starts. RUN is for setup, CMD is for execution.

**Q: Why use .dockerignore?**
**A**: .dockerignore prevents unnecessary files from being copied into the image, reducing image size and build time. It's similar to .gitignore but for Docker builds.

---

## 🚀 Next Step

Now that you can build images, let's create a complete application!

👉 Go to [`05-SIMPLE-APP.md`](05-SIMPLE-APP.md)
