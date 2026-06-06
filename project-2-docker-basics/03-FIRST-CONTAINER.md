# 🚀 Running Your First Real Container

## 📖 WHAT: What Are We Doing?

We're going to run actual applications inside Docker containers! You'll learn how to:

- Run a web server
- Access it in your browser
- Stop and start containers
- Manage containers

## 🎯 WHY: Why Start With These Examples?

These examples are:

- ✅ Simple and visual (you can see them in browser)
- ✅ Commonly used in real projects
- ✅ Great for understanding Docker basics
- ✅ Asked in interviews

---

## 🌐 Example 1: Running NGINX Web Server

### What is NGINX?

NGINX is a popular web server (like Apache). It serves web pages.

### Step 1: Run NGINX Container

```bash
docker run -d -p 8080:80 --name my-nginx nginx

# Let's break down EVERY part of this command:
```

### 🔍 Command Breakdown (Line by Line)

```bash
docker run
```

**WHAT**: The main command to create and start a container
**WHY**: This is how we tell Docker to run something

```bash
-d
```

**WHAT**: "Detached mode" - runs container in background
**WHY**: So you can continue using your terminal
**WITHOUT -d**: Container would run in foreground and block your terminal

```bash
-p 8080:80
```

**WHAT**: Port mapping - connects your computer's port to container's port
**WHY**: So you can access the web server from your browser
**BREAKDOWN**:

- `8080` = Port on YOUR computer (host)
- `80` = Port inside the container
- `:` = Maps one to the other
**MEANING**: "When I visit localhost:8080, send me to container's port 80"

```bash
--name my-nginx
```

**WHAT**: Gives the container a friendly name
**WHY**: Easier to remember than random ID like "a3f2b1c4d5e6"
**WITHOUT --name**: Docker assigns random name like "happy_einstein"

```bash
nginx
```

**WHAT**: The image name to use
**WHY**: Tells Docker which application to run
**WHAT HAPPENS**: Docker downloads nginx image from Docker Hub (if not already downloaded)

### Complete Flow

```
You type command
    ↓
Docker checks: Do I have nginx image?
    ↓
No? Download from Docker Hub
    ↓
Create container from image
    ↓
Start container in background
    ↓
Map port 8080 → 80
    ↓
Name it "my-nginx"
    ↓
Container is running!
```

### Step 2: Verify Container is Running

```bash
docker ps

# WHAT: Lists all running containers
# WHY: To confirm our container started successfully
```

**Expected Output**:

```
CONTAINER ID   IMAGE   COMMAND                  CREATED         STATUS         PORTS                  NAMES
a1b2c3d4e5f6   nginx   "/docker-entrypoint.…"   10 seconds ago  Up 9 seconds   0.0.0.0:8080->80/tcp   my-nginx
```

**Understanding the Output**:

- `CONTAINER ID`: Unique identifier (short version)
- `IMAGE`: Which image was used
- `COMMAND`: What command is running inside
- `CREATED`: When container was created
- `STATUS`: Is it running? For how long?
- `PORTS`: Port mapping (8080 on host → 80 in container)
- `NAMES`: The friendly name we gave it

### Step 3: Access NGINX in Browser

```bash
# Open your web browser and go to:
http://localhost:8080

# WHAT: localhost means "this computer"
# WHY: We mapped port 8080 to container's port 80
```

**You should see**: "Welcome to nginx!" page

**What Just Happened?**

```
Your Browser (localhost:8080)
    ↓
Your Computer's Port 8080
    ↓
Docker forwards to Container's Port 80
    ↓
NGINX inside container responds
    ↓
You see the webpage!
```

### Step 4: View Container Logs

```bash
docker logs my-nginx

# WHAT: Shows what the container is printing/logging
# WHY: To see what's happening inside the container
```

**Expected Output**:

```
/docker-entrypoint.sh: Configuration complete; ready for start up
```

**When you refresh the browser**, you'll see new log entries:

```
172.17.0.1 - - [05/Jun/2026:07:20:00 +0000] "GET / HTTP/1.1" 200 615
```

**Understanding the Log**:

- `172.17.0.1`: Your computer's IP (from Docker's perspective)
- `GET /`: You requested the homepage
- `200`: Success status code
- `615`: Size of response in bytes

### Step 5: Stop the Container

```bash
docker stop my-nginx

# WHAT: Stops the running container
# WHY: Container keeps running until you stop it
# HOW: Sends a graceful shutdown signal
```

**Verify it stopped**:

```bash
docker ps

# You'll see: No containers (empty list)
```

**See ALL containers (including stopped)**:

```bash
docker ps -a

# WHAT: Shows all containers (running + stopped)
# WHY: Stopped containers still exist, just not running
```

### Step 6: Start the Container Again

```bash
docker start my-nginx

# WHAT: Starts a stopped container
# WHY: Reuses existing container instead of creating new one
# DIFFERENCE from 'docker run': 
#   - 'run' creates NEW container
#   - 'start' starts EXISTING container
```

### Step 7: Remove the Container

```bash
# First, stop it:
docker stop my-nginx

# Then remove it:
docker rm my-nginx

# WHAT: Deletes the container permanently
# WHY: Clean up when you don't need it anymore
# NOTE: You can't remove a running container (must stop first)
```

**Force remove (stop + remove in one command)**:

```bash
docker rm -f my-nginx

# WHAT: -f means "force" - stops and removes
# WHY: Faster than two separate commands
```

---

## 🐍 Example 2: Running Python Web App

### Step 1: Run Python HTTP Server

```bash
docker run -d -p 8000:8000 --name python-server python:3.9 python -m http.server

# Let's break this down:
```

**Command Breakdown**:

```bash
docker run -d -p 8000:8000
```

**WHAT**: Run in background, map port 8000 to 8000
**WHY**: Same as before, but using port 8000 this time

```bash
--name python-server
```

**WHAT**: Name the container "python-server"
**WHY**: Easy to identify

```bash
python:3.9
```

**WHAT**: Use Python 3.9 image
**WHY**: We need Python to run Python code
**NOTE**: This downloads Python 3.9 if you don't have it

```bash
python -m http.server
```

**WHAT**: Command to run INSIDE the container
**WHY**: Starts a simple web server using Python
**BREAKDOWN**:

- `python`: Run Python
- `-m http.server`: Use the http.server module
- This creates a basic file server

### Step 2: Access Python Server

```bash
# Open browser:
http://localhost:8000

# You'll see: Directory listing (empty for now)
```

### Step 3: Execute Command Inside Running Container

```bash
docker exec python-server ls -la

# WHAT: Runs a command inside a running container
# WHY: To see what's inside the container
# BREAKDOWN:
#   - docker exec: Execute command in container
#   - python-server: Which container
#   - ls -la: The command to run (list files)
```

### Step 4: Interactive Shell Inside Container

```bash
docker exec -it python-server /bin/bash

# WHAT: Opens an interactive terminal inside container
# WHY: To explore and run commands interactively
# BREAKDOWN:
#   - -i: Interactive (keep STDIN open)
#   - -t: Allocate a pseudo-TTY (terminal)
#   - /bin/bash: Start bash shell
```

**Now you're INSIDE the container!** Your prompt changes to something like:

```bash
root@a1b2c3d4e5f6:/#
```

**Try these commands inside**:

```bash
# See where you are:
pwd
# Output: /

# List files:
ls
# Output: bin  boot  dev  etc  home  lib  ...

# Check Python version:
python --version
# Output: Python 3.9.x

# Exit the container:
exit
```

**WHAT just happened**: You were literally inside the container's filesystem!

### Step 5: Clean Up

```bash
docker stop python-server
docker rm python-server
```

---

## 📊 Example 3: Running a Database (PostgreSQL)

### Step 1: Run PostgreSQL

```bash
docker run -d \
  --name my-postgres \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  postgres:15

# Let's break down the NEW parts:
```

**New Concepts**:

```bash
\
```

**WHAT**: Line continuation character
**WHY**: Makes long commands readable (splits across lines)
**NOTE**: On Windows CMD, use `^` instead of `\`

```bash
-e POSTGRES_PASSWORD=mysecretpassword
```

**WHAT**: Sets an environment variable inside container
**WHY**: PostgreSQL needs a password to start
**BREAKDOWN**:

- `-e`: Environment variable flag
- `POSTGRES_PASSWORD`: Variable name
- `=`: Assignment
- `mysecretpassword`: The value
**SECURITY NOTE**: In real projects, never use simple passwords!

```bash
postgres:15
```

**WHAT**: PostgreSQL version 15 image
**WHY**: Specific version for consistency

### Step 2: Check Database Logs

```bash
docker logs my-postgres

# Look for this line:
# "database system is ready to accept connections"
```

### Step 3: Connect to Database

```bash
docker exec -it my-postgres psql -U postgres

# WHAT: Opens PostgreSQL command line
# BREAKDOWN:
#   - docker exec -it: Interactive execution
#   - my-postgres: Container name
#   - psql: PostgreSQL client
#   - -U postgres: Username is "postgres"
```

**Inside PostgreSQL, try**:

```sql
-- List databases:
\l

-- Create a database:
CREATE DATABASE testdb;

-- Connect to it:
\c testdb

-- Create a table:
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- Insert data:
INSERT INTO users (name) VALUES ('Alice'), ('Bob');

-- Query data:
SELECT * FROM users;

-- Exit:
\q
```

### Step 4: Clean Up

```bash
docker stop my-postgres
docker rm my-postgres
```

---

## 🎯 Essential Docker Commands Summary

### Container Lifecycle

```bash
# Create and start container:
docker run [options] image [command]

# Start stopped container:
docker start container-name

# Stop running container:
docker stop container-name

# Restart container:
docker restart container-name

# Remove container:
docker rm container-name

# Force remove (stop + remove):
docker rm -f container-name
```

### Viewing Information

```bash
# List running containers:
docker ps

# List all containers (including stopped):
docker ps -a

# View container logs:
docker logs container-name

# Follow logs in real-time:
docker logs -f container-name

# View container details:
docker inspect container-name

# View container resource usage:
docker stats container-name
```

### Interacting with Containers

```bash
# Execute command in container:
docker exec container-name command

# Interactive shell:
docker exec -it container-name /bin/bash

# Copy file from container to host:
docker cp container-name:/path/in/container /path/on/host

# Copy file from host to container:
docker cp /path/on/host container-name:/path/in/container
```

---

## 🔍 Common Flags Explained

| Flag | What It Does | Example |
|------|--------------|---------|
| `-d` | Detached mode (background) | `docker run -d nginx` |
| `-p` | Port mapping | `docker run -p 8080:80 nginx` |
| `--name` | Give container a name | `docker run --name web nginx` |
| `-e` | Set environment variable | `docker run -e KEY=value image` |
| `-v` | Mount volume (data storage) | `docker run -v /host:/container image` |
| `-it` | Interactive terminal | `docker exec -it container bash` |
| `--rm` | Auto-remove when stopped | `docker run --rm nginx` |

---

## 🎓 Practice Exercises

### Exercise 1: Run Apache Web Server

```bash
# Try running Apache (another web server):
docker run -d -p 8081:80 --name my-apache httpd

# Access: http://localhost:8081
# You should see: "It works!"
```

### Exercise 2: Run Redis (In-Memory Database)

```bash
# Run Redis:
docker run -d --name my-redis -p 6379:6379 redis

# Connect to Redis:
docker exec -it my-redis redis-cli

# Inside Redis, try:
SET mykey "Hello Docker"
GET mykey
# Output: "Hello Docker"
```

### Exercise 3: Run Multiple Containers

```bash
# Run NGINX on port 8080:
docker run -d -p 8080:80 --name web1 nginx

# Run another NGINX on port 8081:
docker run -d -p 8081:80 --name web2 nginx

# List both:
docker ps

# Stop both:
docker stop web1 web2

# Remove both:
docker rm web1 web2
```

---

## 🐛 Troubleshooting

### Problem 1: "Port is already allocated"

```bash
# Error: Bind for 0.0.0.0:8080 failed: port is already allocated

# REASON: Another container or program is using that port
# SOLUTION: Use a different port
docker run -d -p 8081:80 nginx  # Use 8081 instead
```

### Problem 2: "Cannot connect to Docker daemon"

```bash
# REASON: Docker is not running
# SOLUTION:
# Mac/Windows: Start Docker Desktop
# Linux: sudo systemctl start docker
```

### Problem 3: Container exits immediately

```bash
# Check why it exited:
docker logs container-name

# Common reasons:
# - Wrong command
# - Missing environment variables
# - Configuration error
```

---

## ✅ What You've Learned

✅ How to run containers with `docker run`
✅ Port mapping with `-p`
✅ Running containers in background with `-d`
✅ Viewing running containers with `docker ps`
✅ Checking logs with `docker logs`
✅ Executing commands inside containers with `docker exec`
✅ Starting, stopping, and removing containers
✅ Setting environment variables with `-e`

---

## 🚀 Next Step

Now that you can run containers, let's learn how to BUILD your own Docker images!

👉 Go to [`04-BUILD-YOUR-IMAGE.md`](04-BUILD-YOUR-IMAGE.md)

---

## 💡 Pro Tips

1. **Always name your containers** - easier to manage than IDs
2. **Use `docker ps -a`** - to see stopped containers too
3. **Clean up regularly** - remove containers you don't need
4. **Check logs first** - when something doesn't work
5. **Use `--rm` flag** - for temporary containers that auto-delete

---

## 🎓 Interview Questions

**Q: What's the difference between `docker run` and `docker start`?**
**A**: `docker run` creates a NEW container from an image and starts it. `docker start` starts an EXISTING stopped container. Think of it like: `run` = create + start, `start` = just start.

**Q: What does the `-p 8080:80` flag do?**
**A**: It maps port 8080 on the host machine to port 80 inside the container. This allows you to access the container's service (running on port 80) via localhost:8080 on your computer.

**Q: How do you see logs of a running container?**
**A**: Use `docker logs container-name`. Add `-f` flag to follow logs in real-time: `docker logs -f container-name`.
