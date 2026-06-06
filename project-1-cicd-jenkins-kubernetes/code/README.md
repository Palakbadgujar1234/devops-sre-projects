# CI/CD Pipeline Project - Code Files

## 📁 Project Structure

```
code/
├── app.js                 # Main application
├── package.json           # Dependencies
├── Dockerfile             # Container definition
├── Jenkinsfile            # CI/CD pipeline
├── .dockerignore          # Docker ignore file
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Deployment config
│   └── service.yaml       # Service config
└── test/                  # Test files
    └── app.test.js        # Unit tests
```

## 🚀 Quick Start

### 1. Run Locally

```bash
# Install dependencies
npm install

# Start application
npm start

# Test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/ready
curl http://localhost:3000/api/info
```

### 2. Run with Docker

```bash
# Build image
docker build -t myapp:1.0 .

# Run container
docker run -p 3000:3000 myapp:1.0

# Test
curl http://localhost:3000/
```

### 3. Deploy to Kubernetes

```bash
# Start Minikube
minikube start

# Deploy application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Get service URL
minikube service myapp-service --url

# Test
curl $(minikube service myapp-service --url)/
```

## 🧪 Run Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run with coverage
npm test -- --coverage
```

## 📝 Available Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Main endpoint |
| `/health` | GET | Health check (liveness probe) |
| `/ready` | GET | Readiness check (readiness probe) |
| `/api/info` | GET | API information |

## 🔧 Configuration

### Environment Variables

- `PORT` - Port to listen on (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `APP_VERSION` - Application version

### Docker Image

- Base: `node:16-alpine`
- Size: ~150MB
- Exposed Port: 3000

### Kubernetes Resources

- **Replicas**: 3
- **CPU Request**: 100m
- **CPU Limit**: 200m
- **Memory Request**: 128Mi
- **Memory Limit**: 256Mi

## 📚 Documentation

For detailed documentation, see the parent directory:

- [00-QUICK-START-CHECKLIST.md](../00-QUICK-START-CHECKLIST.md) - Step-by-step guide
- [01-PROJECT-OVERVIEW.md](../01-PROJECT-OVERVIEW.md) - Project overview
- [02-TOOLS-AND-WHY.md](../02-TOOLS-AND-WHY.md) - Tool explanations
- [03-TOOL-COMPARISONS.md](../03-TOOL-COMPARISONS.md) - Tool comparisons
- [04-ARCHITECTURE.md](../04-ARCHITECTURE.md) - Architecture details
- [05-IMPLEMENTATION-GUIDE.md](../05-IMPLEMENTATION-GUIDE.md) - Implementation guide
- [06-CODE-EXPLANATION.md](../06-CODE-EXPLANATION.md) - Code explanation
- [07-INTERVIEW-QUESTIONS.md](../07-INTERVIEW-QUESTIONS.md) - Interview Q&A

## 🎯 Next Steps

1. ✅ Copy these files to your project directory
2. ✅ Update `username/myapp` in files to your Docker Hub username
3. ✅ Follow [00-QUICK-START-CHECKLIST.md](../00-QUICK-START-CHECKLIST.md)
4. ✅ Build and deploy!

## 💡 Tips

- Replace `username` with your Docker Hub username in:
  - `Jenkinsfile` (line 5)
  - `k8s/deployment.yaml` (line 20)
  
- Update credentials in Jenkins:
  - Docker Hub credentials ID: `docker-hub-credentials`
  
- Customize as needed:
  - Change port numbers
  - Adjust resource limits
  - Add more endpoints
  - Add database connections

**Happy coding!** 🚀
