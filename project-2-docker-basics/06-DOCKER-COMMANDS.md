# 🛠️ Essential Docker Commands Reference

## 📖 WHAT: What Is This Guide?

A comprehensive reference of Docker commands you'll use daily. Each command is explained with:

- **WHAT** it does
- **WHY** you'd use it
- **HOW** to use it with examples

---

## 🎯 Command Categories

1. [Image Commands](#-image-commands)
2. [Container Commands](#-container-commands)
3. [Network Commands](#-network-commands)
4. [Volume Commands](#-volume-commands)
5. [System Commands](#-system-commands)
6. [Docker Compose Commands](#-docker-compose-commands)

---

## 📦 Image Commands

### docker images

```bash
docker images

# WHAT: Lists all images on your system
# WHY: See what images you have
# OUTPUT: Repository, tag, ID, created date, size
```

**Example Output**:

```
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
nginx         latest    abc123def456   2 weeks ago    142MB
python        3.9-slim  def456abc123   3 weeks ago    122MB
```

**Useful Flags**:

```bash
docker images -a          # Show all images (including intermediate)
docker images -q          # Show only image IDs
docker images --filter "dangling=true"  # Show untagged images
```

### docker pull

```bash
docker pull nginx:latest

# WHAT: Downloads an image from Docker Hub
# WHY: Get images before running them
# FORMAT: docker pull [registry/]image[:tag]
```

**Examples**:

```bash
docker pull nginx                    # Latest nginx
docker pull nginx:1.21              # Specific version
docker pull ubuntu:22.04            # Ubuntu 22.04
docker pull postgres:15-alpine      # PostgreSQL Alpine version
```

### docker build

```bash
docker build -t myapp:1.0 .

# WHAT: Builds an image from Dockerfile
# WHY: Create custom images
# -t: Tag the image
# .: Build context (current directory)
```

**Useful Flags**:

```bash
docker build -t myapp .                    # Basic build
docker build -t myapp:1.0 .               # With version tag
docker build --no-cache -t myapp .        # Ignore cache
docker build -f Dockerfile.prod -t myapp . # Use specific Dockerfile
docker build --build-arg VERSION=1.0 .    # Pass build arguments
```

### docker tag

```bash
docker tag myapp:latest myapp:1.0

# WHAT: Creates a new tag for an image
# WHY: Version control, multiple names
# FORMAT: docker tag source target
```

**Examples**:

```bash
docker tag myapp:latest myapp:stable
docker tag myapp:latest username/myapp:latest
docker tag myapp:latest gcr.io/project/myapp:1.0
```

### docker push

```bash
docker push username/myapp:latest

# WHAT: Uploads image to registry (Docker Hub)
# WHY: Share images with others
# NOTE: Must login first (docker login)
```

**Complete Push Workflow**:

```bash
# 1. Login to Docker Hub
docker login

# 2. Tag image with your username
docker tag myapp username/myapp:latest

# 3. Push to Docker Hub
docker push username/myapp:latest
```

### docker rmi

```bash
docker rmi nginx

# WHAT: Removes an image
# WHY: Free up disk space
# NOTE: Can't remove if containers are using it
```

**Examples**:

```bash
docker rmi nginx                    # Remove by name
docker rmi abc123def456            # Remove by ID
docker rmi -f nginx                # Force remove
docker rmi $(docker images -q)     # Remove all images
```

### docker history

```bash
docker history myapp

# WHAT: Shows image layers and history
# WHY: Understand how image was built, debug size issues
```

**Example Output**:

```
IMAGE          CREATED        CREATED BY                                      SIZE
abc123def456   2 hours ago    CMD ["python" "app.py"]                        0B
def456abc123   2 hours ago    COPY app.py .                                  1.2kB
```

---

## 🚀 Container Commands

### docker run

```bash
docker run [OPTIONS] IMAGE [COMMAND]

# WHAT: Creates and starts a container
# WHY: Run applications in containers
```

**Common Options**:

```bash
# Basic run
docker run nginx

# Detached mode (background)
docker run -d nginx

# With port mapping
docker run -p 8080:80 nginx

# With name
docker run --name my-nginx nginx

# With environment variables
docker run -e KEY=value nginx

# With volume
docker run -v /host:/container nginx

# Interactive terminal
docker run -it ubuntu bash

# Auto-remove after exit
docker run --rm nginx

# Limit resources
docker run --memory="512m" --cpus="1.0" nginx
```

**Complete Example**:

```bash
docker run -d \
  --name my-web \
  -p 8080:80 \
  -e ENV=production \
  -v $(pwd)/html:/usr/share/nginx/html \
  --restart unless-stopped \
  nginx:latest

# WHAT each flag does:
# -d: Run in background
# --name: Give it a name
# -p: Map port 8080 to 80
# -e: Set environment variable
# -v: Mount volume
# --restart: Restart policy
# nginx:latest: Image to use
```

### docker ps

```bash
docker ps

# WHAT: Lists running containers
# WHY: See what's currently running
```

**Useful Variations**:

```bash
docker ps                  # Running containers only
docker ps -a              # All containers (including stopped)
docker ps -q              # Only container IDs
docker ps --filter "status=exited"  # Only exited containers
docker ps --format "table {{.Names}}\t{{.Status}}"  # Custom format
```

### docker start/stop/restart

```bash
docker start container-name
docker stop container-name
docker restart container-name

# WHAT: Control container lifecycle
# WHY: Manage running containers
```

**Examples**:

```bash
# Start stopped container
docker start my-nginx

# Stop running container (graceful, 10s timeout)
docker stop my-nginx

# Force stop (immediate)
docker kill my-nginx

# Restart container
docker restart my-nginx

# Start multiple containers
docker start web1 web2 web3
```

### docker logs

```bash
docker logs container-name

# WHAT: Shows container output/logs
# WHY: Debug issues, monitor activity
```

**Useful Options**:

```bash
docker logs my-nginx                # Show all logs
docker logs -f my-nginx            # Follow logs (real-time)
docker logs --tail 100 my-nginx    # Last 100 lines
docker logs --since 1h my-nginx    # Last hour
docker logs -t my-nginx            # With timestamps
```

### docker exec

```bash
docker exec [OPTIONS] CONTAINER COMMAND

# WHAT: Runs command in running container
# WHY: Debug, inspect, run tasks
```

**Common Uses**:

```bash
# Run single command
docker exec my-nginx ls -la

# Interactive shell
docker exec -it my-nginx bash

# Run as specific user
docker exec -u root my-nginx whoami

# Set working directory
docker exec -w /app my-nginx pwd

# Set environment variable
docker exec -e VAR=value my-nginx env
```

**Real-World Examples**:

```bash
# Check logs inside container
docker exec my-app cat /var/log/app.log

# Database backup
docker exec my-postgres pg_dump -U postgres mydb > backup.sql

# Clear cache
docker exec my-redis redis-cli FLUSHALL

# Check disk space
docker exec my-app df -h
```

### docker cp

```bash
docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH
docker cp [OPTIONS] SRC_PATH CONTAINER:DEST_PATH

# WHAT: Copy files between container and host
# WHY: Extract files, add files without rebuild
```

**Examples**:

```bash
# Copy from container to host
docker cp my-nginx:/etc/nginx/nginx.conf ./nginx.conf

# Copy from host to container
docker cp ./config.json my-app:/app/config.json

# Copy directory
docker cp my-app:/app/logs ./logs
```

### docker rm

```bash
docker rm container-name

# WHAT: Removes a container
# WHY: Clean up stopped containers
```

**Examples**:

```bash
docker rm my-nginx                     # Remove stopped container
docker rm -f my-nginx                  # Force remove (stop + remove)
docker rm $(docker ps -aq)            # Remove all containers
docker rm $(docker ps -aq -f status=exited)  # Remove exited containers
```

### docker inspect

```bash
docker inspect container-name

# WHAT: Shows detailed container information (JSON)
# WHY: Debug, get IP address, check config
```

**Useful Queries**:

```bash
# Get IP address
docker inspect -f '{{.NetworkSettings.IPAddress}}' my-nginx

# Get port mappings
docker inspect -f '{{.NetworkSettings.Ports}}' my-nginx

# Get environment variables
docker inspect -f '{{.Config.Env}}' my-nginx

# Get volumes
docker inspect -f '{{.Mounts}}' my-nginx
```

### docker stats

```bash
docker stats

# WHAT: Shows real-time resource usage
# WHY: Monitor CPU, memory, network
```

**Example Output**:

```
CONTAINER ID   NAME       CPU %   MEM USAGE / LIMIT   MEM %   NET I/O
abc123def456   my-nginx   0.01%   2.5MB / 1.95GB     0.13%   1.2kB / 0B
```

**Options**:

```bash
docker stats                    # All containers
docker stats my-nginx          # Specific container
docker stats --no-stream       # One-time snapshot
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

---

## 🌐 Network Commands

### docker network ls

```bash
docker network ls

# WHAT: Lists all networks
# WHY: See available networks
```

**Default Networks**:

```
NETWORK ID     NAME      DRIVER    SCOPE
abc123def456   bridge    bridge    local
def456abc123   host      host      local
ghi789jkl012   none      null      local
```

### docker network create

```bash
docker network create my-network

# WHAT: Creates a new network
# WHY: Isolate containers, custom networking
```

**Examples**:

```bash
# Basic network
docker network create my-network

# With specific driver
docker network create --driver bridge my-network

# With subnet
docker network create --subnet=172.18.0.0/16 my-network

# With gateway
docker network create --gateway=172.18.0.1 --subnet=172.18.0.0/16 my-network
```

### docker network connect

```bash
docker network connect my-network my-container

# WHAT: Connects container to network
# WHY: Add container to additional networks
```

**Example**:

```bash
# Create network
docker network create app-network

# Run container
docker run -d --name web nginx

# Connect to network
docker network connect app-network web
```

### docker network inspect

```bash
docker network inspect my-network

# WHAT: Shows network details
# WHY: See connected containers, configuration
```

---

## 💾 Volume Commands

### docker volume ls

```bash
docker volume ls

# WHAT: Lists all volumes
# WHY: See what volumes exist
```

### docker volume create

```bash
docker volume create my-volume

# WHAT: Creates a named volume
# WHY: Persistent data storage
```

**Examples**:

```bash
# Basic volume
docker volume create my-data

# With driver options
docker volume create --driver local my-data

# Use the volume
docker run -v my-data:/app/data nginx
```

### docker volume inspect

```bash
docker volume inspect my-volume

# WHAT: Shows volume details
# WHY: See mount point, driver, options
```

### docker volume rm

```bash
docker volume rm my-volume

# WHAT: Removes a volume
# WHY: Clean up unused volumes
```

**Examples**:

```bash
docker volume rm my-volume                    # Remove specific volume
docker volume rm $(docker volume ls -q)      # Remove all volumes
docker volume prune                           # Remove unused volumes
```

---

## 🧹 System Commands

### docker system df

```bash
docker system df

# WHAT: Shows Docker disk usage
# WHY: See how much space Docker is using
```

**Example Output**:

```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          10        5         2.5GB     1.2GB (48%)
Containers      15        3         100MB     50MB (50%)
Local Volumes   5         2         500MB     300MB (60%)
```

### docker system prune

```bash
docker system prune

# WHAT: Removes unused data
# WHY: Free up disk space
```

**Options**:

```bash
docker system prune              # Remove stopped containers, unused networks, dangling images
docker system prune -a           # Also remove unused images
docker system prune --volumes    # Also remove unused volumes
docker system prune -af          # Remove everything (force, no prompt)
```

### docker info

```bash
docker info

# WHAT: Shows system-wide information
# WHY: Check Docker installation, configuration
```

**Shows**:

- Docker version
- Number of containers/images
- Storage driver
- Kernel version
- Operating system

---

## 🎼 Docker Compose Commands

### docker-compose up

```bash
docker-compose up

# WHAT: Starts all services defined in docker-compose.yml
# WHY: Run multi-container applications
```

**Options**:

```bash
docker-compose up                # Start in foreground
docker-compose up -d            # Start in background
docker-compose up --build       # Rebuild images before starting
docker-compose up --force-recreate  # Recreate containers
docker-compose up service1      # Start specific service
```

### docker-compose down

```bash
docker-compose down

# WHAT: Stops and removes containers, networks
# WHY: Clean shutdown of application
```

**Options**:

```bash
docker-compose down              # Stop and remove
docker-compose down -v          # Also remove volumes
docker-compose down --rmi all   # Also remove images
```

### docker-compose ps

```bash
docker-compose ps

# WHAT: Lists containers for this project
# WHY: See status of services
```

### docker-compose logs

```bash
docker-compose logs

# WHAT: Shows logs from all services
# WHY: Debug multi-container apps
```

**Options**:

```bash
docker-compose logs              # All services
docker-compose logs -f          # Follow logs
docker-compose logs web         # Specific service
docker-compose logs --tail=100  # Last 100 lines
```

---

## 🎯 Common Workflows

### Development Workflow

```bash
# 1. Build image
docker build -t myapp .

# 2. Run container
docker run -d -p 8080:80 --name dev-app myapp

# 3. View logs
docker logs -f dev-app

# 4. Make changes, rebuild
docker build -t myapp .

# 5. Restart container
docker restart dev-app

# 6. Clean up
docker stop dev-app
docker rm dev-app
```

### Debugging Workflow

```bash
# 1. Check if container is running
docker ps

# 2. View logs
docker logs my-app

# 3. Get shell access
docker exec -it my-app bash

# 4. Check processes
docker top my-app

# 5. Check resource usage
docker stats my-app

# 6. Inspect configuration
docker inspect my-app
```

### Cleanup Workflow

```bash
# 1. Stop all containers
docker stop $(docker ps -aq)

# 2. Remove all containers
docker rm $(docker ps -aq)

# 3. Remove all images
docker rmi $(docker images -q)

# 4. Remove all volumes
docker volume prune

# 5. Remove all networks
docker network prune

# 6. Complete cleanup
docker system prune -a --volumes
```

---

## 📝 Quick Reference Cheat Sheet

### Container Lifecycle

```bash
docker run IMAGE              # Create and start
docker start CONTAINER        # Start stopped container
docker stop CONTAINER         # Stop running container
docker restart CONTAINER      # Restart container
docker rm CONTAINER          # Remove container
```

### Viewing Information

```bash
docker ps                    # Running containers
docker ps -a                # All containers
docker images               # List images
docker logs CONTAINER       # View logs
docker inspect CONTAINER    # Detailed info
docker stats               # Resource usage
```

### Building Images

```bash
docker build -t NAME .      # Build image
docker tag SOURCE TARGET    # Tag image
docker push NAME           # Push to registry
docker pull NAME           # Pull from registry
```

### Cleanup

```bash
docker rm CONTAINER         # Remove container
docker rmi IMAGE           # Remove image
docker volume rm VOLUME    # Remove volume
docker system prune        # Clean up everything
```

---

## 🎓 Interview Tips

**Common Questions**:

1. **"What's the difference between docker run and docker start?"**
   - `docker run` creates a NEW container from an image
   - `docker start` starts an EXISTING stopped container

2. **"How do you debug a failing container?"**
   - Check logs: `docker logs container`
   - Get shell: `docker exec -it container bash`
   - Inspect: `docker inspect container`
   - Check resources: `docker stats container`

3. **"How do you clean up Docker resources?"**
   - `docker system prune` for general cleanup
   - `docker system prune -a --volumes` for complete cleanup
   - Regular cleanup prevents disk space issues

---

## ✅ What You've Learned

✅ Essential Docker commands for daily use
✅ Image management (build, tag, push, pull)
✅ Container lifecycle (run, start, stop, rm)
✅ Debugging techniques (logs, exec, inspect)
✅ Resource management (volumes, networks)
✅ System maintenance (prune, cleanup)

---

## 🚀 Next Steps

You've completed Docker Basics! You now know:

- What Docker is and why it's used
- How to install Docker
- How to run containers
- How to build images
- How to create applications
- Essential Docker commands

**Ready for more?** Check out:

- Docker Compose (multi-container apps)
- Docker Swarm (orchestration)
- Kubernetes (advanced orchestration)
- CI/CD with Docker

---

## 💡 Pro Tips

1. **Use aliases** for common commands:

```bash
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
```

1. **Always name your containers** - easier to manage

2. **Use .dockerignore** - faster builds, smaller images

3. **Tag your images** - version control is important

4. **Clean up regularly** - prevent disk space issues

5. **Read the logs** - first step in debugging

6. **Use volumes** - for persistent data

7. **Learn Docker Compose** - for multi-container apps
