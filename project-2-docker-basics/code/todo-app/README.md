# 🐳 Docker Todo App - Complete Example

## 📖 What Is This?

A complete, production-ready Todo application demonstrating Docker best practices. Perfect for learning and interviews!

## 🎯 What You'll Learn

- Building Docker images from scratch
- Writing clean Dockerfiles
- Creating multi-file applications
- Using volumes for data persistence
- Health checks
- Best practices

## 📁 Project Structure

```
todo-app/
├── Dockerfile              # Docker build instructions
├── .dockerignore          # Files to exclude from build
├── requirements.txt       # Python dependencies
├── app.py                 # Backend API (Flask)
├── templates/
│   └── index.html        # Frontend UI
└── static/
    └── style.css         # Styling
```

## 🚀 Quick Start

### Step 1: Build the Image

```bash
# Navigate to this directory
cd todo-app

# Build the Docker image
docker build -t todo-app .

# WHAT: Creates Docker image named "todo-app"
# WHY: Need image to create containers
# TIME: ~30 seconds (first time)
```

### Step 2: Run the Container

```bash
# Run without data persistence
docker run -d -p 5000:5000 --name my-todo todo-app

# WHAT: Starts container in background
# WHY: Run the application
# -d: Detached mode (background)
# -p 5000:5000: Map port 5000
# --name my-todo: Give it a name
```

### Step 3: Access the App

```bash
# Open in browser:
http://localhost:5000

# You should see a beautiful todo app!
```

### Step 4: Test It

```bash
# Add some todos
# Mark them as complete
# Delete them
# Check the stats

# View logs
docker logs my-todo

# Check health
curl http://localhost:5000/health
```

## 💾 Running with Data Persistence

### Problem: Data is Lost

```bash
# Add some todos
# Stop container
docker stop my-todo

# Start again
docker start my-todo

# ❌ Todos are gone!
```

### Solution: Use Volumes

```bash
# Remove old container
docker rm -f my-todo

# Run with volume
docker run -d \
  -p 5000:5000 \
  -v $(pwd)/data:/app \
  --name my-todo \
  todo-app

# WHAT: Mounts current directory's data folder to /app in container
# WHY: Data persists outside container
# NOW: Todos survive container restarts!
```

## 🔍 Understanding the Code

### app.py (Backend)

```python
# Flask web framework
# RESTful API endpoints:
# GET    /api/todos       - Get all todos
# POST   /api/todos       - Create new todo
# PUT    /api/todos/:id   - Update todo
# DELETE /api/todos/:id   - Delete todo
# GET    /health          - Health check
```

### Dockerfile (Build Instructions)

```dockerfile
FROM python:3.9-slim     # Base image
WORKDIR /app             # Working directory
COPY requirements.txt .  # Copy dependencies
RUN pip install -r requirements.txt  # Install
COPY . .                 # Copy code
EXPOSE 5000              # Document port
CMD ["python", "app.py"] # Start command
```

### index.html (Frontend)

```html
<!-- Simple, clean UI -->
<!-- JavaScript for API calls -->
<!-- Real-time updates -->
<!-- Keyboard shortcuts -->
```

### style.css (Styling)

```css
/* Modern, responsive design */
/* Gradient background */
/* Smooth animations */
/* Mobile-friendly */
```

## 🛠️ Development Workflow

### Make Changes

```bash
# 1. Edit code (e.g., app.py)
# 2. Rebuild image
docker build -t todo-app .

# 3. Stop old container
docker stop my-todo
docker rm my-todo

# 4. Run new container
docker run -d -p 5000:5000 --name my-todo todo-app

# 5. Test changes
```

### Quick Rebuild

```bash
# One-liner to rebuild and run
docker stop my-todo && docker rm my-todo && docker build -t todo-app . && docker run -d -p 5000:5000 --name my-todo todo-app
```

## 🐛 Debugging

### View Logs

```bash
# All logs
docker logs my-todo

# Follow logs (real-time)
docker logs -f my-todo

# Last 50 lines
docker logs --tail 50 my-todo
```

### Get Shell Access

```bash
# Open bash inside container
docker exec -it my-todo bash

# Inside container, you can:
ls -la              # List files
cat app.py          # View code
python              # Run Python
exit                # Exit container
```

### Check Health

```bash
# Health endpoint
curl http://localhost:5000/health

# Expected: {"status":"healthy","service":"todo-app"}
```

### Inspect Container

```bash
# Detailed information
docker inspect my-todo

# Just the IP address
docker inspect -f '{{.NetworkSettings.IPAddress}}' my-todo
```

## 📊 Best Practices Demonstrated

### 1. ✅ Specific Base Image

```dockerfile
FROM python:3.9-slim  # Not just "python"
```

### 2. ✅ Layer Caching

```dockerfile
COPY requirements.txt .        # Copy deps first
RUN pip install -r requirements.txt  # Install
COPY . .                       # Copy code last
```

### 3. ✅ .dockerignore

```
__pycache__/
*.pyc
.git/
```

### 4. ✅ Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python -c "import urllib.request; ..."
```

### 5. ✅ Non-Root User (Production)

```dockerfile
RUN useradd -m appuser
USER appuser
```

### 6. ✅ Environment Variables

```dockerfile
ENV FLASK_APP=app.py
ENV FLASK_ENV=development
```

## 🎓 Interview Talking Points

### Architecture

"I built a full-stack todo application with Flask backend providing RESTful API endpoints and a vanilla JavaScript frontend. The backend handles CRUD operations and persists data to a JSON file."

### Containerization

"I containerized it using Docker with a multi-layer Dockerfile. I optimized for build cache by copying dependencies before application code, used a slim base image to reduce size, and implemented health checks for monitoring."

### Data Persistence

"I demonstrated both ephemeral and persistent storage. Initially, data was lost on container restart. I solved this by mounting a volume, mapping the host directory to the container's data directory."

### Best Practices

"I followed Docker best practices including using .dockerignore, specific base image versions, proper layer ordering, health checks, and security considerations like not running as root in production."

## 🚀 Next Steps

### Enhancements You Can Make

1. **Add Database**

```bash
# Replace JSON file with PostgreSQL
docker run -d --name postgres postgres:15
# Update app.py to use PostgreSQL
```

1. **Add Docker Compose**

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "5000:5000"
  db:
    image: postgres:15
```

1. **Add Tests**

```python
# test_app.py
def test_get_todos():
    response = client.get('/api/todos')
    assert response.status_code == 200
```

1. **Add CI/CD**

```yaml
# .github/workflows/docker.yml
- name: Build Docker image
  run: docker build -t todo-app .
```

1. **Deploy to Cloud**

```bash
# Push to Docker Hub
docker tag todo-app username/todo-app
docker push username/todo-app

# Deploy to cloud
# AWS ECS, Google Cloud Run, Azure Container Instances
```

## 📝 Common Commands

```bash
# Build
docker build -t todo-app .

# Run
docker run -d -p 5000:5000 --name my-todo todo-app

# Run with volume
docker run -d -p 5000:5000 -v $(pwd)/data:/app --name my-todo todo-app

# Logs
docker logs my-todo
docker logs -f my-todo

# Stop/Start
docker stop my-todo
docker start my-todo

# Remove
docker rm -f my-todo

# Shell access
docker exec -it my-todo bash

# Rebuild and run
docker stop my-todo && docker rm my-todo && docker build -t todo-app . && docker run -d -p 5000:5000 --name my-todo todo-app
```

## 🎯 Learning Checklist

- [ ] Built the Docker image
- [ ] Ran the container
- [ ] Accessed the app in browser
- [ ] Added and managed todos
- [ ] Viewed container logs
- [ ] Used volumes for persistence
- [ ] Debugged with shell access
- [ ] Understood each line of Dockerfile
- [ ] Can explain the architecture
- [ ] Ready to discuss in interview

## 💡 Tips

1. **Read every comment** in the code - they explain WHAT, WHY, HOW
2. **Type commands yourself** - don't copy-paste
3. **Break things intentionally** - learn by fixing
4. **Modify the code** - add features, change styling
5. **Explain to someone** - teaching solidifies learning

## 🆘 Troubleshooting

### Port Already in Use

```bash
# Use different port
docker run -d -p 5001:5000 --name my-todo todo-app
# Access: http://localhost:5001
```

### Container Exits Immediately

```bash
# Check logs
docker logs my-todo

# Common issues:
# - Syntax error in Python code
# - Missing dependencies
# - Wrong CMD in Dockerfile
```

### Can't Access App

```bash
# Check if container is running
docker ps

# Check port mapping
docker port my-todo

# Check logs
docker logs my-todo
```

## ✅ Success Criteria

You've mastered this when you can:

- Build and run the app without looking at docs
- Explain each line of the Dockerfile
- Debug issues using logs and shell access
- Implement data persistence with volumes
- Discuss the architecture in an interview
- Make modifications and rebuild

---

**Congratulations! You've built a real Docker application! 🎉**
