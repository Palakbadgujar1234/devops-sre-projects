# 🎨 Building a Complete Application

## 📖 WHAT: What Are We Building?

A complete **To-Do List** web application with:

- ✅ Frontend (HTML/CSS/JavaScript)
- ✅ Backend (Python Flask)
- ✅ Database (SQLite)
- ✅ All running in Docker!

This is a real-world example you can show in interviews!

## 🎯 WHY: Why This Project?

- Shows you can containerize a full application
- Demonstrates best practices
- Similar to real production apps
- Great portfolio piece

---

## 🏗️ Project Structure

```
todo-app/
├── Dockerfile
├── requirements.txt
├── app.py
├── templates/
│   └── index.html
└── static/
    └── style.css
```

---

## 📝 Step-by-Step Implementation

### Step 1: Create Project Directory

```bash
mkdir todo-app
cd todo-app
```

### Step 2: Create requirements.txt

```txt
Flask==2.3.0
```

**WHAT**: Lists Python packages needed
**WHY**: Flask is a web framework for Python
**HOW**: pip will install this when building image

### Step 3: Create app.py (Backend)

```python
# File: app.py
from flask import Flask, render_template, request, jsonify
import json
import os

app = Flask(__name__)

# File to store todos
TODOS_FILE = 'todos.json'

def load_todos():
    """Load todos from file"""
    if os.path.exists(TODOS_FILE):
        with open(TODOS_FILE, 'r') as f:
            return json.load(f)
    return []

def save_todos(todos):
    """Save todos to file"""
    with open(TODOS_FILE, 'w') as f:
        json.dump(todos, f)

@app.route('/')
def index():
    """Serve the main page"""
    return render_template('index.html')

@app.route('/api/todos', methods=['GET'])
def get_todos():
    """Get all todos"""
    todos = load_todos()
    return jsonify(todos)

@app.route('/api/todos', methods=['POST'])
def add_todo():
    """Add a new todo"""
    data = request.get_json()
    todos = load_todos()
    
    new_todo = {
        'id': len(todos) + 1,
        'text': data['text'],
        'completed': False
    }
    
    todos.append(new_todo)
    save_todos(todos)
    
    return jsonify(new_todo), 201

@app.route('/api/todos/<int:todo_id>', methods=['PUT'])
def update_todo(todo_id):
    """Update a todo"""
    data = request.get_json()
    todos = load_todos()
    
    for todo in todos:
        if todo['id'] == todo_id:
            todo['completed'] = data['completed']
            save_todos(todos)
            return jsonify(todo)
    
    return jsonify({'error': 'Todo not found'}), 404

@app.route('/api/todos/<int:todo_id>', methods=['DELETE'])
def delete_todo(todo_id):
    """Delete a todo"""
    todos = load_todos()
    todos = [t for t in todos if t['id'] != todo_id]
    save_todos(todos)
    
    return '', 204

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**Understanding the Code**:

```python
from flask import Flask, render_template, request, jsonify
```

**WHAT**: Imports Flask components
**WHY**:

- `Flask`: Main app class
- `render_template`: Serves HTML files
- `request`: Handles HTTP requests
- `jsonify`: Converts Python dict to JSON

```python
app = Flask(__name__)
```

**WHAT**: Creates Flask application
**WHY**: This is your web server

```python
TODOS_FILE = 'todos.json'
```

**WHAT**: File to store todos
**WHY**: Simple file-based storage (no database needed)

```python
def load_todos():
    if os.path.exists(TODOS_FILE):
        with open(TODOS_FILE, 'r') as f:
            return json.load(f)
    return []
```

**WHAT**: Loads todos from file
**WHY**: Persist data between requests
**HOW**:

- Check if file exists
- Read JSON from file
- Return empty list if no file

```python
@app.route('/')
def index():
    return render_template('index.html')
```

**WHAT**: Route for homepage
**WHY**: When you visit /, serve index.html
**@app.route**: Decorator that defines URL path

```python
@app.route('/api/todos', methods=['GET'])
def get_todos():
    todos = load_todos()
    return jsonify(todos)
```

**WHAT**: API endpoint to get all todos
**WHY**: Frontend calls this to fetch todos
**methods=['GET']**: Only accepts GET requests

```python
@app.route('/api/todos', methods=['POST'])
def add_todo():
    data = request.get_json()
    # ... create new todo ...
    return jsonify(new_todo), 201
```

**WHAT**: API endpoint to add todo
**WHY**: Frontend calls this to create new todo
**201**: HTTP status "Created"

```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**WHAT**: Starts the server
**WHY**:

- `host='0.0.0.0'`: Listen on all interfaces (important for Docker!)
- `port=5000`: Use port 5000
- `debug=True`: Show detailed errors (only for development)

### Step 4: Create templates/index.html (Frontend)

```bash
mkdir templates
```

```html
<!-- File: templates/index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker Todo App</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <h1>🐳 Docker Todo App</h1>
        <p class="subtitle">Running in a Container!</p>
        
        <div class="input-group">
            <input type="text" id="todoInput" placeholder="What needs to be done?">
            <button onclick="addTodo()">Add</button>
        </div>
        
        <ul id="todoList"></ul>
        
        <div class="stats">
            <span id="totalTodos">0 tasks</span>
        </div>
    </div>

    <script>
        // Load todos when page loads
        window.onload = function() {
            loadTodos();
        };

        // Load all todos from API
        async function loadTodos() {
            const response = await fetch('/api/todos');
            const todos = await response.json();
            
            const todoList = document.getElementById('todoList');
            todoList.innerHTML = '';
            
            todos.forEach(todo => {
                addTodoToDOM(todo);
            });
            
            updateStats(todos.length);
        }

        // Add new todo
        async function addTodo() {
            const input = document.getElementById('todoInput');
            const text = input.value.trim();
            
            if (text === '') return;
            
            const response = await fetch('/api/todos', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ text: text })
            });
            
            const todo = await response.json();
            addTodoToDOM(todo);
            input.value = '';
            
            loadTodos(); // Refresh to update count
        }

        // Add todo to DOM
        function addTodoToDOM(todo) {
            const todoList = document.getElementById('todoList');
            const li = document.createElement('li');
            li.className = todo.completed ? 'completed' : '';
            li.innerHTML = `
                <input type="checkbox" 
                       ${todo.completed ? 'checked' : ''} 
                       onchange="toggleTodo(${todo.id}, this.checked)">
                <span>${todo.text}</span>
                <button onclick="deleteTodo(${todo.id})">Delete</button>
            `;
            todoList.appendChild(li);
        }

        // Toggle todo completion
        async function toggleTodo(id, completed) {
            await fetch(`/api/todos/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ completed: completed })
            });
            
            loadTodos();
        }

        // Delete todo
        async function deleteTodo(id) {
            await fetch(`/api/todos/${id}`, {
                method: 'DELETE'
            });
            
            loadTodos();
        }

        // Update statistics
        function updateStats(count) {
            document.getElementById('totalTodos').textContent = 
                `${count} task${count !== 1 ? 's' : ''}`;
        }

        // Allow Enter key to add todo
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('todoInput').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    addTodo();
                }
            });
        });
    </script>
</body>
</html>
```

**Understanding the HTML/JavaScript**:

```javascript
async function loadTodos() {
    const response = await fetch('/api/todos');
    const todos = await response.json();
    // ...
}
```

**WHAT**: Fetches todos from backend API
**WHY**: Get data to display
**async/await**: Modern JavaScript for handling promises

```javascript
await fetch('/api/todos', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ text: text })
});
```

**WHAT**: Sends new todo to backend
**WHY**: Create new todo in database
**HOW**:

- `method: 'POST'`: HTTP POST request
- `headers`: Tell server we're sending JSON
- `body`: The actual data (converted to JSON string)

### Step 5: Create static/style.css

```bash
mkdir static
```

```css
/* File: static/style.css */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.container {
    background: white;
    border-radius: 15px;
    padding: 30px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    max-width: 500px;
    width: 100%;
}

h1 {
    color: #333;
    text-align: center;
    margin-bottom: 10px;
}

.subtitle {
    text-align: center;
    color: #666;
    margin-bottom: 30px;
    font-size: 14px;
}

.input-group {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
}

input[type="text"] {
    flex: 1;
    padding: 12px;
    border: 2px solid #ddd;
    border-radius: 8px;
    font-size: 16px;
    transition: border-color 0.3s;
}

input[type="text"]:focus {
    outline: none;
    border-color: #667eea;
}

button {
    padding: 12px 24px;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 16px;
    transition: background 0.3s;
}

button:hover {
    background: #5568d3;
}

ul {
    list-style: none;
    margin-bottom: 20px;
}

li {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    margin-bottom: 10px;
    transition: all 0.3s;
}

li:hover {
    background: #e9ecef;
}

li.completed span {
    text-decoration: line-through;
    color: #999;
}

li input[type="checkbox"] {
    width: 20px;
    height: 20px;
    cursor: pointer;
}

li span {
    flex: 1;
    font-size: 16px;
}

li button {
    padding: 8px 16px;
    background: #dc3545;
    font-size: 14px;
}

li button:hover {
    background: #c82333;
}

.stats {
    text-align: center;
    color: #666;
    font-size: 14px;
    padding-top: 20px;
    border-top: 1px solid #ddd;
}
```

**Understanding the CSS**:

```css
body {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

**WHAT**: Creates gradient background
**WHY**: Makes it look professional

```css
.container {
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}
```

**WHAT**: Adds shadow to container
**WHY**: Creates depth and modern look

### Step 6: Create Dockerfile

```dockerfile
# File: Dockerfile

# Use Python 3.9 slim image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .
COPY templates/ templates/
COPY static/ static/

# Expose port 5000
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Run the application
CMD ["python", "app.py"]
```

**Understanding the Dockerfile**:

```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```

**WHAT**: Copy requirements first, then install
**WHY**: Docker caching - if requirements don't change, this layer is reused
**--no-cache-dir**: Don't store pip cache (smaller image)

```dockerfile
COPY app.py .
COPY templates/ templates/
COPY static/ static/
```

**WHAT**: Copy all application files
**WHY**: Need all files to run the app
**ORDER**: After dependencies (changes more often)

```dockerfile
ENV FLASK_APP=app.py
ENV FLASK_ENV=development
```

**WHAT**: Set environment variables
**WHY**: Flask uses these for configuration

### Step 7: Create .dockerignore

```
# File: .dockerignore
__pycache__
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info
dist
build
.git
.gitignore
README.md
todos.json
```

**WHAT**: Files to exclude from Docker build
**WHY**: Don't copy unnecessary files

### Step 8: Build the Image

```bash
docker build -t todo-app .

# WHAT: Builds image named "todo-app"
# WHY: Create image from our Dockerfile
```

**Watch the build process**:

```
[+] Building 15.2s (12/12) FINISHED
 => [1/6] FROM python:3.9-slim
 => [2/6] WORKDIR /app
 => [3/6] COPY requirements.txt .
 => [4/6] RUN pip install --no-cache-dir -r requirements.txt
 => [5/6] COPY app.py .
 => [6/6] COPY templates/ templates/
 => [7/6] COPY static/ static/
 => exporting to image
```

### Step 9: Run the Container

```bash
docker run -d -p 5000:5000 --name my-todo-app todo-app

# WHAT: Runs todo app in background
# WHY: Start the application
# -p 5000:5000: Map port 5000
```

### Step 10: Test the Application

```bash
# Open browser:
http://localhost:5000

# You should see:
# - Beautiful todo app interface
# - Add button
# - Empty todo list
```

**Try these actions**:

1. Add a todo: "Learn Docker" ✅
2. Add another: "Build an app" ✅
3. Check one as complete ✅
4. Delete one ✅

### Step 11: Verify Data Persistence

```bash
# Stop the container:
docker stop my-todo-app

# Start it again:
docker start my-todo-app

# Open browser again:
http://localhost:5000

# ❌ Your todos are GONE!
# WHY? Data was stored in container, which is ephemeral
```

### Step 12: Add Data Persistence with Volumes

```bash
# Remove old container:
docker rm -f my-todo-app

# Run with volume:
docker run -d \
  -p 5000:5000 \
  -v $(pwd)/data:/app \
  --name my-todo-app \
  todo-app

# WHAT: -v mounts a volume
# WHY: Persist data outside container
# $(pwd)/data: Current directory + /data folder
# /app: Mount point inside container
```

**Now test again**:

1. Add todos
2. Stop container: `docker stop my-todo-app`
3. Start container: `docker start my-todo-app`
4. ✅ Todos are still there!

**Why?** The `todos.json` file is now stored on your computer, not in the container!

### Step 13: View Logs

```bash
# See application logs:
docker logs my-todo-app

# Follow logs in real-time:
docker logs -f my-todo-app

# You'll see:
# * Running on all addresses (0.0.0.0)
# * Running on http://127.0.0.1:5000
```

### Step 14: Inspect the Container

```bash
# See detailed information:
docker inspect my-todo-app

# See resource usage:
docker stats my-todo-app

# Execute commands inside:
docker exec my-todo-app ls -la
```

---

## 🎯 Understanding Volumes

### What is a Volume?

**WHAT**: A way to persist data outside containers
**WHY**: Containers are ephemeral (temporary)
**HOW**: Maps directory on host to directory in container

```
Your Computer                Container
─────────────               ──────────
/home/user/data    ←→       /app
    ↓                           ↓
todos.json                  todos.json
(same file!)
```

### Volume Types

#### 1. Bind Mount (What we used)

```bash
docker run -v /host/path:/container/path image
```

**WHAT**: Maps specific host directory
**WHY**: Full control over location
**USE**: Development, specific files

#### 2. Named Volume

```bash
# Create volume:
docker volume create todo-data

# Use volume:
docker run -v todo-data:/app image
```

**WHAT**: Docker-managed volume
**WHY**: Docker handles storage location
**USE**: Production, managed by Docker

#### 3. Anonymous Volume

```bash
docker run -v /app/data image
```

**WHAT**: Temporary volume
**WHY**: Automatic cleanup
**USE**: Temporary data

---

## 🔧 Improving the Application

### Add Health Check

```dockerfile
# Add to Dockerfile:
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python -c "import requests; requests.get('http://localhost:5000')"
```

**WHAT**: Checks if app is healthy
**WHY**: Docker can restart if unhealthy
**HOW**: Runs command every 30 seconds

### Multi-Stage Build (Smaller Image)

```dockerfile
# Build stage
FROM python:3.9 as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Runtime stage
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

**WHAT**: Two-stage build
**WHY**: Smaller final image (only runtime needed)

---

## 📊 Complete Project Summary

### What We Built

✅ Full-stack web application
✅ Backend API with Flask
✅ Frontend with HTML/CSS/JavaScript
✅ Data persistence with volumes
✅ Containerized with Docker

### Files Created

```
todo-app/
├── Dockerfile          # Build instructions
├── .dockerignore       # Exclude files
├── requirements.txt    # Python dependencies
├── app.py             # Backend API
├── templates/
│   └── index.html     # Frontend UI
└── static/
    └── style.css      # Styling
```

### Commands Used

```bash
# Build
docker build -t todo-app .

# Run
docker run -d -p 5000:5000 --name my-todo-app todo-app

# Run with volume
docker run -d -p 5000:5000 -v $(pwd)/data:/app --name my-todo-app todo-app

# Manage
docker stop my-todo-app
docker start my-todo-app
docker logs my-todo-app
docker rm my-todo-app
```

---

## 🎓 Interview Talking Points

When discussing this project in interviews:

1. **Architecture**: "I built a full-stack todo application with Flask backend and vanilla JavaScript frontend"

2. **Containerization**: "I containerized it using Docker with a multi-layer Dockerfile, optimizing for build cache"

3. **Data Persistence**: "I implemented volume mounting to persist data outside the container"

4. **Best Practices**: "I used .dockerignore, specific base images, and proper layer ordering"

5. **API Design**: "I created RESTful API endpoints for CRUD operations"

---

## ✅ What You've Learned

✅ Building a complete application
✅ Creating multi-file Docker projects
✅ Using volumes for data persistence
✅ Frontend-backend communication
✅ RESTful API design
✅ Docker best practices

---

## 🚀 Next Step

Now let's learn essential Docker commands and workflows!

👉 Go to [`06-DOCKER-COMMANDS.md`](06-DOCKER-COMMANDS.md)

---

## 💡 Bonus Challenges

1. **Add a database**: Replace JSON file with PostgreSQL
2. **Add authentication**: Implement user login
3. **Add Docker Compose**: Run multiple containers
4. **Add tests**: Write unit tests for the API
5. **Deploy**: Push to Docker Hub and deploy to cloud
