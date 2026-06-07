# ☁️ Complete OpenShift Learning Path (Cloud-Based)

## Using Red Hat Developer Sandbox - No Installation Required

---

## 🎯 **PERFECT FOR YOU IF:**

- ✅ You don't have a powerful computer
- ✅ You want to start learning immediately
- ✅ You prefer cloud-based learning
- ✅ You don't want to install anything locally
- ✅ You want a real OpenShift environment

---

## 🚀 **STEP 1: GET YOUR FREE OPENSHIFT CLUSTER (5 MINUTES)**

### **Sign Up for Red Hat Developer Sandbox**

**What You Get:**

- ✅ Real OpenShift 4.x cluster
- ✅ 14 GB RAM quota
- ✅ 40 GB storage
- ✅ 30 days access (renewable)
- ✅ Full OpenShift features
- ✅ Web console access
- ✅ CLI access
- ✅ 100% FREE!

### **Registration Steps:**

**1. Go to Developer Sandbox:**

```
URL: https://developers.redhat.com/developer-sandbox
```

**2. Click "Start your sandbox for free"**

**3. Create Red Hat Account:**

```
- Enter email address
- Create password
- Fill in basic details
- Verify email
```

**4. Accept Terms:**

```
- Read and accept terms of service
- Click "Start using your sandbox"
```

**5. Wait for Provisioning (2-3 minutes):**

```
- Cluster is being created
- You'll see progress indicator
- Don't close the page
```

**6. Access Your Cluster:**

```
You'll receive:
- Cluster URL
- Login credentials
- Web console link
```

**🎉 Congratulations! You now have a real OpenShift cluster!**

---

## 💻 **STEP 2: ACCESS YOUR CLUSTER**

### **Option A: Web Console (Easiest)**

**1. Open Web Console:**

```
Click the link provided in your email
Or go to: https://console-openshift-console.apps.sandbox.x8i5.p1.openshiftapps.com
(Your URL will be different)
```

**2. Login:**

```
- Click "DevSandbox"
- Use your Red Hat credentials
- Accept permissions
```

**3. You're In!**

```
You'll see the OpenShift web console
- Developer perspective (default)
- Administrator perspective (limited)
- Topology view
- All OpenShift features
```

### **Option B: CLI Access (Optional but Recommended)**

**1. Get Login Command:**

```
In web console:
- Click your name (top right)
- Click "Copy login command"
- Click "Display Token"
- Copy the oc login command
```

**2. Install oc CLI (One-time):**

**On Windows:**

```powershell
# Download from web console
# Or use this direct link:
# https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-windows.zip

# Extract and add to PATH
# Or run from download folder
```

**On macOS:**

```bash
# Download from web console
# Or install via Homebrew:
brew install openshift-cli

# Or download directly:
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-mac.tar.gz
tar -xvf openshift-client-mac.tar.gz
sudo mv oc /usr/local/bin/
```

**On Linux:**

```bash
# Download from web console
# Or download directly:
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
tar -xvf openshift-client-linux.tar.gz
sudo mv oc /usr/local/bin/
```

**3. Login via CLI:**

```bash
# Paste the command you copied
oc login --token=sha256~xxxxx --server=https://api.sandbox.x8i5.p1.openshiftapps.com:6443

# Verify
oc whoami
oc project
```

---

## 📚 **STEP 3: YOUR LEARNING PATH**

### **Week 1: Foundations**

#### **Day 1-2: Understand Concepts**

```
1. Read: 01-WHAT-IS-KUBERNETES-OPENSHIFT.md
   - Understand containers
   - Learn about Kubernetes
   - Understand OpenShift features
   
2. Explore Web Console:
   - Developer perspective
   - Topology view
   - Project/namespace concept
   - Navigation menu
```

#### **Day 3-4: First Application**

```
1. Deploy Hello World App:

Via Web Console:
- Click "+Add"
- Select "Container images"
- Image: docker.io/nginx:latest
- Application name: hello-world
- Name: nginx
- Create a route: ✓
- Click "Create"

Via CLI:
oc new-app nginx:latest --name=hello-world
oc expose service hello-world
oc get route hello-world

2. Access Your App:
- Click the route URL
- See nginx welcome page
- Success! 🎉
```

#### **Day 5-7: Core Concepts Practice**

```
1. Understand Pods:
oc get pods
oc describe pod <pod-name>
oc logs <pod-name>

2. Scale Application:
oc scale deployment hello-world --replicas=3
oc get pods -w

3. Update Application:
oc set image deployment/hello-world nginx=nginx:alpine
oc rollout status deployment/hello-world

4. Rollback:
oc rollout undo deployment/hello-world
```

---

### **Week 2: Real Applications**

#### **Deploy Node.js Application**

**1. Create Project:**

```bash
oc new-project my-nodejs-app
```

**2. Create Application Files:**

Create these files locally, then we'll deploy:

**app.js:**

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head><title>My OpenShift App</title></head>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1>🚀 Hello from OpenShift!</h1>
        <p>Running on: ${require('os').hostname()}</p>
        <p>Environment: ${process.env.NODE_ENV || 'development'}</p>
      </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**package.json:**

```json
{
  "name": "openshift-demo",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

**3. Deploy Using Source-to-Image (S2I):**

**Option A: From GitHub (Recommended):**

```bash
# First, push your code to GitHub
# Then deploy:
oc new-app nodejs~https://github.com/yourusername/your-repo --name=my-app

# Expose service:
oc expose service my-app

# Watch build:
oc logs -f bc/my-app

# Get URL:
oc get route my-app
```

**Option B: From Local Files:**

```bash
# Create build config:
oc new-build nodejs:18 --name=my-app --binary=true

# Start build from local directory:
oc start-build my-app --from-dir=. --follow

# Deploy:
oc new-app my-app

# Expose:
oc expose service my-app

# Get URL:
oc get route my-app
```

**4. Verify:**

```bash
# Check pods:
oc get pods

# Check logs:
oc logs -f deployment/my-app

# Test app:
curl $(oc get route my-app -o jsonpath='{.spec.host}')
```

---

### **Week 3: Microservices Project**

#### **Deploy Complete E-Commerce App**

**Architecture:**

```
Frontend (React) → Backend API (Node.js) → Database (MongoDB)
```

**1. Create Project:**

```bash
oc new-project ecommerce-demo
```

**2. Deploy MongoDB:**

```bash
# Deploy MongoDB
oc new-app mongodb-ephemeral \
  --param=MONGODB_USER=admin \
  --param=MONGODB_PASSWORD=password \
  --param=MONGODB_DATABASE=products \
  --param=MONGODB_ADMIN_PASSWORD=adminpass

# Wait for deployment:
oc get pods -w
```

**3. Deploy Backend API:**

**backend/server.js:**

```javascript
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://admin:password@mongodb:27017/products?authSource=admin';

app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

// Product Schema
const productSchema = new mongoose.Schema({
  name: String,
  price: Number,
  description: String
});

const Product = mongoose.model('Product', productSchema);

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.get('/api/products', async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/products', async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.status(201).json(product);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Initialize sample data
async function initData() {
  const count = await Product.countDocuments();
  if (count === 0) {
    await Product.insertMany([
      { name: 'Laptop', price: 999, description: 'High-performance laptop' },
      { name: 'Mouse', price: 29, description: 'Wireless mouse' },
      { name: 'Keyboard', price: 79, description: 'Mechanical keyboard' }
    ]);
    console.log('Sample data initialized');
  }
}

app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
  initData();
});
```

**backend/package.json:**

```json
{
  "name": "backend-api",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.0.0",
    "cors": "^2.8.5"
  }
}
```

**Deploy Backend:**

```bash
# Push to GitHub, then:
oc new-app nodejs~https://github.com/yourusername/backend-repo --name=backend-api

# Set environment variable:
oc set env deployment/backend-api \
  MONGODB_URI=mongodb://admin:password@mongodb:27017/products?authSource=admin

# Expose:
oc expose service backend-api

# Watch logs:
oc logs -f deployment/backend-api
```

**4. Deploy Frontend:**

**frontend/src/App.js:**

```javascript
import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  const API_URL = process.env.REACT_APP_API_URL || 'http://backend-api:8080';

  useEffect(() => {
    fetch(`${API_URL}/api/products`)
      .then(res => res.json())
      .then(data => {
        setProducts(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error:', err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div className="App">
      <header>
        <h1>🛍️ E-Commerce Store</h1>
      </header>
      <main>
        <div className="products">
          {products.map(product => (
            <div key={product._id} className="product-card">
              <h3>{product.name}</h3>
              <p>{product.description}</p>
              <p className="price">${product.price}</p>
              <button>Add to Cart</button>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}

export default App;
```

**Deploy Frontend:**

```bash
# Push to GitHub, then:
oc new-app nodejs~https://github.com/yourusername/frontend-repo --name=frontend

# Set backend URL:
oc set env deployment/frontend \
  REACT_APP_API_URL=http://$(oc get route backend-api -o jsonpath='{.spec.host}')

# Expose:
oc expose service frontend

# Get URL:
oc get route frontend
```

**5. Test Complete Application:**

```bash
# Get frontend URL:
FRONTEND_URL=$(oc get route frontend -o jsonpath='{.spec.host}')
echo "Open: http://$FRONTEND_URL"

# Open in browser and see your e-commerce app!
```

---

### **Week 4: Advanced Features**

#### **1. Implement Auto-Scaling:**

```bash
# Enable autoscaling:
oc autoscale deployment backend-api \
  --min=2 --max=5 --cpu-percent=70

# Verify:
oc get hpa
```

#### **2. Add Health Checks:**

```bash
# Add liveness probe:
oc set probe deployment/backend-api \
  --liveness --get-url=http://:8080/health \
  --initial-delay-seconds=30 \
  --period-seconds=10

# Add readiness probe:
oc set probe deployment/backend-api \
  --readiness --get-url=http://:8080/health \
  --initial-delay-seconds=5 \
  --period-seconds=5
```

#### **3. Configure Resource Limits:**

```bash
# Set resource limits:
oc set resources deployment/backend-api \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=500m,memory=512Mi
```

#### **4. Add ConfigMaps and Secrets:**

```bash
# Create ConfigMap:
oc create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=info

# Create Secret:
oc create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=secretpass

# Use in deployment:
oc set env deployment/backend-api \
  --from=configmap/app-config \
  --from=secret/db-credentials
```

---

## 🎯 **COMPLETE LEARNING CHECKLIST**

### **Week 1: Basics**

- [ ] Sign up for Developer Sandbox
- [ ] Access web console
- [ ] Deploy first application (nginx)
- [ ] Scale application
- [ ] View logs
- [ ] Update and rollback

### **Week 2: Real Apps**

- [ ] Deploy Node.js application
- [ ] Use Source-to-Image (S2I)
- [ ] Expose services with Routes
- [ ] Configure environment variables
- [ ] Monitor application health

### **Week 3: Microservices**

- [ ] Deploy MongoDB database
- [ ] Deploy backend API
- [ ] Deploy frontend application
- [ ] Connect services together
- [ ] Test complete application

### **Week 4: Production Skills**

- [ ] Implement auto-scaling
- [ ] Add health checks
- [ ] Configure resource limits
- [ ] Use ConfigMaps and Secrets
- [ ] Monitor and troubleshoot

---

## 💡 **TIPS FOR SUCCESS**

### **1. Sandbox Limitations:**

```
- 30-day limit (renewable)
- Limited resources (sufficient for learning)
- No admin access (developer access only)
- Shared environment
```

### **2. Renew Your Sandbox:**

```
- Before 30 days expire
- Go to developer.redhat.com
- Click "Extend sandbox"
- Get another 30 days free!
```

### **3. Save Your Work:**

```
- Export YAML files:
  oc get deployment my-app -o yaml > my-app-deployment.yaml
  
- Save to GitHub
- Document your learning
- Take screenshots
```

### **4. Practice Regularly:**

```
- 1-2 hours daily
- Follow guides in order
- Build real projects
- Experiment and break things
```

---

## 🚀 **NEXT STEPS**

### **After Completing This Path:**

**1. Build Portfolio Projects:**

```
- E-commerce application
- Blog platform
- Task management app
- API gateway
- Microservices demo
```

**2. Learn Advanced Topics:**

```
- CI/CD with Tekton
- Service Mesh (Istio)
- Monitoring (Prometheus/Grafana)
- Security and RBAC
- Multi-environment deployments
```

**3. Get Certified:**

```
- Red Hat Certified Specialist in OpenShift
- Certified Kubernetes Administrator (CKA)
- Certified Kubernetes Application Developer (CKAD)
```

**4. Apply for Jobs:**

```
- OpenShift Engineer
- DevOps Engineer
- Platform Engineer
- Site Reliability Engineer
```

---

## 📚 **ADDITIONAL RESOURCES**

### **Official Resources:**

- Developer Sandbox: <https://developers.redhat.com/developer-sandbox>
- OpenShift Docs: <https://docs.openshift.com>
- Interactive Learning: <https://learn.openshift.com>
- OpenShift Blog: <https://www.openshift.com/blog>

### **Community:**

- OpenShift Commons: <https://commons.openshift.org>
- Stack Overflow: Tag [openshift]
- Reddit: r/openshift
- YouTube: OpenShift channel

---

## ✅ **YOU'RE ALL SET!**

**Start your journey now:**

1. **Sign up:** <https://developers.redhat.com/developer-sandbox>
2. **Read concepts:** [`01-WHAT-IS-KUBERNETES-OPENSHIFT.md`](./01-WHAT-IS-KUBERNETES-OPENSHIFT.md)
3. **Follow this guide:** Deploy your first app today!
4. **Build projects:** Create real applications
5. **Get job-ready:** Complete the interview guide

**Remember: You don't need expensive hardware to learn OpenShift!** 🚀

**Your cloud-based learning journey starts NOW!** 🎉
