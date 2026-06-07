# 🚀 Deploy Your First Application on OpenShift

## Complete Hands-On Guide with Real Examples

---

## 📋 **WHAT YOU'LL LEARN**

By the end of this guide, you'll:

- ✅ Understand Pods, Deployments, and Services deeply
- ✅ Deploy a real web application
- ✅ Scale your application
- ✅ Expose it to the internet
- ✅ View logs and troubleshoot
- ✅ Update your application without downtime

---

## 🎯 **PREREQUISITES**

Before starting, ensure:

- [ ] OpenShift Local (CRC) is running
- [ ] You can access the web console
- [ ] `oc` CLI is working
- [ ] You're logged in as developer

**Quick Check:**

```bash
# Check CRC status
crc status

# Login if needed
oc login -u developer -p developer https://api.crc.testing:6443

# Verify
oc whoami
# Should output: developer
```

---

## 📦 **PART 1: UNDERSTANDING THE BASICS**

### **1.1 What is a Pod?**

**Simple Explanation:**
A **Pod** is the smallest unit in Kubernetes/OpenShift. It's a wrapper around one or more containers.

**Real-World Analogy:**

```
Pod = Apartment 🏠
Container(s) = Roommate(s) 👥

- Roommates share the apartment (pod)
- They share utilities (network, storage)
- If apartment is destroyed, all roommates leave
- Usually 1 roommate per apartment (1 container per pod)
```

**Key Points:**

- Pods are temporary (ephemeral)
- Each pod gets a unique IP address
- Containers in a pod share network and storage
- If a pod dies, it's replaced with a new one (new IP)

**Example Pod:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-first-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

### **1.2 What is a Deployment?**

**Simple Explanation:**
A **Deployment** manages multiple copies (replicas) of your pods.

**Real-World Analogy:**

```
Deployment = Franchise Manager 🏢
Pods = Individual Stores 🏪

Manager ensures:
- Always X stores are open (desired replicas)
- Opens new stores if one closes (self-healing)
- Can open more stores when busy (scaling)
- Updates all stores with new products (rolling updates)
```

**Key Points:**

- Maintains desired number of pod replicas
- Automatically replaces failed pods
- Enables scaling (up/down)
- Manages rolling updates
- Provides rollback capability

**Example Deployment:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3  # Always keep 3 pods running
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

### **1.3 What is a Service?**

**Simple Explanation:**
A **Service** provides a stable way to access your pods.

**Real-World Analogy:**

```
Service = Company Phone Number ☎️
Pods = Employees 👨‍💼👩‍💼

- Employees may change (pods come and go)
- Phone number stays the same (service IP is stable)
- Calls are routed to available employees (load balancing)
- Customers don't need to know individual employee numbers
```

**Key Points:**

- Provides stable IP and DNS name
- Load balances traffic across pods
- Survives pod restarts
- Enables service discovery

**Example Service:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app  # Routes to pods with this label
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP  # Internal access only
```

### **1.4 What is a Route? (OpenShift Specific)**

**Simple Explanation:**
A **Route** exposes your service to the internet.

**Real-World Analogy:**

```
Route = Website Domain 🌐
Service = Internal Phone System ☎️

- Domain (myapp.com) → Internal system
- Users access via domain
- Internal routing handled automatically
```

**Example Route:**

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app-route
spec:
  to:
    kind: Service
    name: my-app-service
  port:
    targetPort: 8080
```

---

## 🎨 **PART 2: DEPLOY YOUR FIRST APP (METHOD 1: WEB CONSOLE)**

### **2.1 Create a New Project**

1. **Open Web Console:**

   ```bash
   crc console
   ```

2. **Login:**
   - Username: `developer`
   - Password: `developer`

3. **Switch to Developer Perspective:**
   - Top-left corner: Click "Administrator" → Select "Developer"

4. **Create Project:**
   - Click "Project" dropdown → "Create Project"
   - Name: `my-first-app`
   - Display Name: `My First Application`
   - Click "Create"

### **2.2 Deploy Application from Container Image**

1. **Click "+Add" in left sidebar**

2. **Select "Container images"**

3. **Fill in details:**

   ```
   Image name: docker.io/nginx:latest
   
   Application name: nginx-app
   Name: nginx
   
   Resources: Deployment
   
   Create a route to the Application: ✓ (checked)
   ```

4. **Click "Create"**

### **2.3 Watch Deployment**

**Topology View:**

```
You'll see:
- A circle representing your deployment
- Pod count inside the circle
- Status indicators (blue = running)
```

**Click on the deployment circle to see:**

- Pods
- Builds
- Services
- Routes
- Logs

### **2.4 Access Your Application**

1. **Find the Route:**
   - In Topology view, click the "Open URL" icon (↗️)
   - Or go to: Networking → Routes
   - Copy the URL

2. **Open in Browser:**
   - You should see the Nginx welcome page!
   - URL format: `http://nginx-my-first-app.apps-crc.testing`

**🎉 Congratulations! Your first app is running!**

---

## 💻 **PART 3: DEPLOY YOUR FIRST APP (METHOD 2: CLI)**

### **3.1 Create Project**

```bash
# Create new project
oc new-project my-cli-app

# Verify
oc project
# Output: Using project "my-cli-app" on server "https://api.crc.testing:6443"
```

### **3.2 Deploy Application**

```bash
# Deploy nginx
oc new-app nginx:latest --name=my-nginx

# Watch the deployment
oc get pods -w

# Press Ctrl+C when pod is Running
```

**What happened?**

```
OpenShift automatically created:
1. Deployment (manages pods)
2. Service (provides stable access)
3. ImageStream (tracks the image)
```

### **3.3 Check Resources**

```bash
# List all resources
oc get all

# Output shows:
# - pod/my-nginx-xxxxx
# - deployment.apps/my-nginx
# - replicaset.apps/my-nginx-xxxxx
# - service/my-nginx
# - imagestream.image.openshift.io/my-nginx
```

### **3.4 Expose the Application**

```bash
# Create a route
oc expose service my-nginx

# Get the route URL
oc get route my-nginx

# Output:
# NAME       HOST/PORT                              PATH   SERVICES   PORT       TERMINATION   WILDCARD
# my-nginx   my-nginx-my-cli-app.apps-crc.testing          my-nginx   8080-tcp                 None
```

### **3.5 Test the Application**

```bash
# Get the URL
URL=$(oc get route my-nginx -o jsonpath='{.spec.host}')

# Test with curl
curl http://$URL

# Or open in browser
echo "Open: http://$URL"
```

---

## 📝 **PART 4: DEPLOY A REAL APPLICATION**

Let's deploy a real Node.js application!

### **4.1 Create Application Files**

First, let's create the application code:

```bash
# Create project directory
mkdir -p ~/openshift-apps/hello-node
cd ~/openshift-apps/hello-node
```

**Create `app.js`:**

```javascript
// Simple Node.js web server
const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Home route
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Hello OpenShift!</title>
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
            border-radius: 20px;
            backdrop-filter: blur(10px);
          }
          h1 { font-size: 3em; margin: 0; }
          p { font-size: 1.5em; }
          .info { margin-top: 20px; font-size: 1em; opacity: 0.8; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🚀 Hello from OpenShift!</h1>
          <p>Your first Node.js app is running!</p>
          <div class="info">
            <p>Hostname: ${require('os').hostname()}</p>
            <p>Version: 1.0.0</p>
          </div>
        </div>
      </body>
    </html>
  `);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**Create `package.json`:**

```json
{
  "name": "hello-openshift",
  "version": "1.0.0",
  "description": "Simple Node.js app for OpenShift",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=14.0.0"
  }
}
```

**Create `Dockerfile`:**

```dockerfile
# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY app.js ./

# Expose port
EXPOSE 8080

# Set non-root user (OpenShift requirement)
USER 1001

# Start application
CMD ["npm", "start"]
```

### **4.2 Build and Deploy**

**Option A: Using Source-to-Image (S2I)**

```bash
# Create new project
oc new-project hello-node-app

# Deploy from local directory
oc new-app nodejs:18~. --name=hello-node

# This will:
# 1. Detect it's a Node.js app
# 2. Build the image
# 3. Deploy it
# 4. Create all necessary resources

# Watch the build
oc logs -f bc/hello-node

# Wait for build to complete
oc get pods -w
```

**Option B: Using Dockerfile**

```bash
# Create new project
oc new-project hello-node-docker

# Build from Dockerfile
oc new-build --name=hello-node --binary --strategy=docker

# Start the build
oc start-build hello-node --from-dir=. --follow

# Deploy the built image
oc new-app hello-node

# Expose the service
oc expose service hello-node

# Get the URL
oc get route hello-node
```

### **4.3 Verify Deployment**

```bash
# Check all resources
oc get all

# Check pod status
oc get pods

# View pod logs
oc logs -f deployment/hello-node

# Check service
oc get service hello-node

# Check route
oc get route hello-node
```

### **4.4 Access Your Application**

```bash
# Get the URL
URL=$(oc get route hello-node -o jsonpath='{.spec.host}')

# Open in browser
echo "Open: http://$URL"

# Or test with curl
curl http://$URL
```

**You should see your beautiful web page! 🎉**

---

## 📊 **PART 5: SCALING YOUR APPLICATION**

### **5.1 Why Scale?**

**Scenario:**

```
Normal traffic: 100 users → 1 pod handles it fine
Black Friday: 10,000 users → 1 pod crashes!
Solution: Scale to 10 pods → Traffic distributed
```

### **5.2 Scale Using Web Console**

1. **Go to Topology view**
2. **Click on your deployment**
3. **In the Details tab:**
   - Find "Pod" section
   - Click the up arrow (↑) to increase replicas
   - Click the down arrow (↓) to decrease replicas

4. **Watch pods being created in real-time!**

### **5.3 Scale Using CLI**

```bash
# Scale to 3 replicas
oc scale deployment hello-node --replicas=3

# Watch pods being created
oc get pods -w

# You'll see:
# hello-node-xxxxx-xxxxx   1/1     Running   0          2m
# hello-node-xxxxx-yyyyy   1/1     Running   0          5s
# hello-node-xxxxx-zzzzz   1/1     Running   0          5s

# Press Ctrl+C to stop watching
```

### **5.4 Verify Load Balancing**

```bash
# Get the route URL
URL=$(oc get route hello-node -o jsonpath='{.spec.host}')

# Make multiple requests
for i in {1..10}; do
  curl -s http://$URL | grep "Hostname"
done

# You'll see different hostnames (different pods handling requests)
# Hostname: hello-node-xxxxx-xxxxx
# Hostname: hello-node-xxxxx-yyyyy
# Hostname: hello-node-xxxxx-zzzzz
```

**This proves load balancing is working!** ✅

### **5.5 Scale Down**

```bash
# Scale back to 1 replica
oc scale deployment hello-node --replicas=1

# Watch pods terminating
oc get pods -w
```

---

## 🔄 **PART 6: UPDATING YOUR APPLICATION**

### **6.1 Update Application Code**

Let's update our app to version 2.0:

**Edit `app.js`:**

```javascript
// Change the version and color
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Hello OpenShift v2!</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
          }
          .container {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
          }
          h1 { font-size: 3em; margin: 0; }
          p { font-size: 1.5em; }
          .info { margin-top: 20px; font-size: 1em; opacity: 0.8; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🎉 Hello from OpenShift v2.0!</h1>
          <p>Your app has been updated!</p>
          <div class="info">
            <p>Hostname: ${require('os').hostname()}</p>
            <p>Version: 2.0.0</p>
          </div>
        </div>
      </body>
    </html>
  `);
});
```

### **6.2 Rebuild and Deploy**

```bash
# Start new build
oc start-build hello-node --from-dir=. --follow

# Watch the rollout
oc rollout status deployment/hello-node

# Check pods (you'll see rolling update)
oc get pods -w
```

**What happens during rolling update:**

```
1. New pod (v2.0) starts
2. Wait for new pod to be ready
3. Old pod (v1.0) terminates
4. Result: Zero downtime! ✅
```

### **6.3 Verify Update**

```bash
# Get URL
URL=$(oc get route hello-node -o jsonpath='{.spec.host}')

# Open in browser
echo "Open: http://$URL"

# You should see version 2.0 with new colors!
```

### **6.4 Rollback if Needed**

```bash
# View rollout history
oc rollout history deployment/hello-node

# Rollback to previous version
oc rollout undo deployment/hello-node

# Watch the rollback
oc rollout status deployment/hello-node

# Verify
curl http://$URL | grep "Version"
```

---

## 📋 **PART 7: VIEWING LOGS AND DEBUGGING**

### **7.1 View Pod Logs**

```bash
# List pods
oc get pods

# View logs of a specific pod
oc logs hello-node-xxxxx-xxxxx

# Follow logs in real-time
oc logs -f hello-node-xxxxx-xxxxx

# View logs from all pods
oc logs -l app=hello-node

# View previous pod logs (if pod crashed)
oc logs hello-node-xxxxx-xxxxx --previous
```

### **7.2 Describe Resources**

```bash
# Describe pod (shows events, status, etc.)
oc describe pod hello-node-xxxxx-xxxxx

# Describe deployment
oc describe deployment hello-node

# Describe service
oc describe service hello-node
```

### **7.3 Execute Commands in Pod**

```bash
# Get a shell in the pod
oc rsh hello-node-xxxxx-xxxxx

# Inside the pod, you can:
ls -la
cat app.js
env | grep PORT
exit

# Run a single command
oc exec hello-node-xxxxx-xxxxx -- ls -la
oc exec hello-node-xxxxx-xxxxx -- env
```

### **7.4 Port Forwarding (Local Testing)**

```bash
# Forward pod port to local machine
oc port-forward hello-node-xxxxx-xxxxx 8080:8080

# Now access at: http://localhost:8080
# Press Ctrl+C to stop
```

---

## 🐛 **PART 8: COMMON ISSUES AND SOLUTIONS**

### **Issue 1: Pod Not Starting**

**Symptoms:**

```bash
oc get pods
# NAME                          READY   STATUS             RESTARTS   AGE
# hello-node-xxxxx-xxxxx        0/1     ImagePullBackOff   0          2m
```

**Solution:**

```bash
# Check pod events
oc describe pod hello-node-xxxxx-xxxxx

# Common causes:
# - Wrong image name
# - Image doesn't exist
# - Network issues

# Fix: Use correct image
oc set image deployment/hello-node hello-node=nginx:latest
```

### **Issue 2: Pod Crashing**

**Symptoms:**

```bash
oc get pods
# NAME                          READY   STATUS             RESTARTS   AGE
# hello-node-xxxxx-xxxxx        0/1     CrashLoopBackOff   5          5m
```

**Solution:**

```bash
# Check logs
oc logs hello-node-xxxxx-xxxxx

# Check previous logs
oc logs hello-node-xxxxx-xxxxx --previous

# Common causes:
# - Application error
# - Missing dependencies
# - Wrong port configuration
```

### **Issue 3: Cannot Access Application**

**Symptoms:**

```bash
curl http://hello-node-my-project.apps-crc.testing
# curl: (7) Failed to connect
```

**Solution:**

```bash
# Check if route exists
oc get route

# Check if service exists
oc get service

# Check if pods are running
oc get pods

# Recreate route if needed
oc delete route hello-node
oc expose service hello-node
```

### **Issue 4: Application Slow**

**Solution:**

```bash
# Check resource usage
oc adm top pods

# Scale up if needed
oc scale deployment hello-node --replicas=3

# Check pod events
oc describe pod hello-node-xxxxx-xxxxx
```

---

## ✅ **PART 9: CLEANUP**

### **9.1 Delete Application**

```bash
# Delete all resources in project
oc delete all --all

# Or delete specific resources
oc delete deployment hello-node
oc delete service hello-node
oc delete route hello-node
```

### **9.2 Delete Project**

```bash
# Delete entire project
oc delete project my-cli-app

# This deletes everything in the project
```

---

## 🎯 **PART 10: HANDS-ON EXERCISES**

### **Exercise 1: Deploy Apache Web Server**

```bash
# 1. Create project
oc new-project apache-test

# 2. Deploy Apache
oc new-app httpd:latest --name=my-apache

# 3. Expose service
oc expose service my-apache

# 4. Get URL and test
oc get route my-apache
```

### **Exercise 2: Scale and Test**

```bash
# 1. Scale to 5 replicas
oc scale deployment my-apache --replicas=5

# 2. Verify all pods running
oc get pods

# 3. Test load balancing
URL=$(oc get route my-apache -o jsonpath='{.spec.host}')
for i in {1..20}; do curl -s http://$URL | grep "It works"; done
```

### **Exercise 3: Update and Rollback**

```bash
# 1. Update to different version
oc set image deployment/my-apache my-apache=httpd:2.4

# 2. Watch rollout
oc rollout status deployment/my-apache

# 3. Rollback
oc rollout undo deployment/my-apache

# 4. Verify
oc rollout status deployment/my-apache
```

---

## 📊 **SUMMARY: WHAT YOU LEARNED**

### **Concepts:**

- ✅ Pods: Smallest unit, wraps containers
- ✅ Deployments: Manages pod replicas
- ✅ Services: Stable access to pods
- ✅ Routes: External access (OpenShift)

### **Skills:**

- ✅ Deploy apps via Web Console
- ✅ Deploy apps via CLI
- ✅ Scale applications
- ✅ Update applications (zero downtime)
- ✅ View logs and debug
- ✅ Troubleshoot common issues

### **Commands Mastered:**

```bash
oc new-project <name>          # Create project
oc new-app <image>             # Deploy app
oc expose service <name>       # Create route
oc scale deployment <name>     # Scale app
oc logs <pod>                  # View logs
oc describe <resource>         # Get details
oc get all                     # List resources
oc delete <resource>           # Delete resource
```

---

## 🎓 **INTERVIEW QUESTIONS**

### **Q1: Explain the difference between a Pod and a Deployment.**

**Answer:**
"A Pod is the smallest deployable unit that wraps one or more containers. It's ephemeral and has a lifecycle. A Deployment is a higher-level controller that manages multiple pod replicas. It ensures the desired number of pods are always running, handles scaling, rolling updates, and self-healing. You typically don't create pods directly; you create deployments that manage pods."

### **Q2: How does OpenShift achieve zero-downtime deployments?**

**Answer:**
"OpenShift uses rolling updates. During an update, it gradually replaces old pods with new ones. It starts new pods, waits for them to be ready and pass health checks, then terminates old pods. This ensures at least some pods are always available to serve traffic. The process is: new pod starts → becomes ready → old pod terminates → repeat."

### **Q3: What's the difference between a Service and a Route?**

**Answer:**
"A Service provides internal cluster networking and load balancing. It gives pods a stable IP and DNS name within the cluster. A Route is OpenShift-specific and provides external access to services. It acts as an ingress point, mapping external URLs to internal services. Think of Service as internal phone system, Route as the public website domain."

---

## 🎯 **NEXT STEPS**

Great job! You've successfully deployed and managed applications on OpenShift!

👉 **Next Guide:** [`04-OPENSHIFT-WEB-CONSOLE.md`](./04-OPENSHIFT-WEB-CONSOLE.md)

In the next guide, you'll:

- Master the OpenShift Web Console
- Learn Developer vs Administrator perspectives
- Use advanced console features
- Monitor applications visually
- Manage resources efficiently

---

**Keep practicing! The more you deploy, the more confident you'll become! 🚀**
