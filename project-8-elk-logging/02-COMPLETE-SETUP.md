# 🚀 Complete ELK Stack Setup - Step-by-Step

## 📖 WHAT: What Are We Building?

A complete, working ELK Stack that:

- ✅ Collects logs from multiple sources
- ✅ Processes and structures log data
- ✅ Stores logs in Elasticsearch
- ✅ Visualizes logs in Kibana dashboards
- ✅ Monitors application in real-time

This is a **production-ready setup** you can use and show in interviews!

## 🎯 WHY: Why This Project?

- Shows you can set up centralized logging
- Demonstrates log analysis skills
- Similar to production setups
- Great portfolio piece
- **Actually works!**

---

## 🏗️ Project Structure

```
elk-logging-project/
├── docker-compose.yml          # ELK stack definition
├── logstash/
│   └── pipeline/
│       └── logstash.conf      # Log processing pipeline
├── sample-app/
│   ├── app.js                 # Sample Node.js app
│   ├── package.json           # Dependencies
│   └── Dockerfile             # Container definition
└── sample-logs/
    └── app.log                # Test log file
```

---

## 📝 Step-by-Step Implementation

### Step 1: Create Project Directory

```bash
# Create project directory
mkdir ~/elk-logging-project
cd ~/elk-logging-project

# Create subdirectories
mkdir -p logstash/pipeline sample-app sample-logs

# WHAT: Organized structure for ELK files
# WHY: Keep everything organized
# HOW: Standard ELK project layout
```

### Step 2: Create Docker Compose File

**WHAT**: Define all ELK components  
**WHY**: Easy to start/stop entire stack  
**HOW**: Create docker-compose.yml

```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Elasticsearch - Search and Analytics Engine
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - elk

  # Logstash - Log Processing Pipeline
  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      - ./sample-logs:/logs
    ports:
      - "5044:5044"
      - "9600:9600"
    environment:
      - "LS_JAVA_OPTS=-Xms256m -Xmx256m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  # Kibana - Visualization Dashboard
  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    networks:
      - elk
    depends_on:
      - elasticsearch

volumes:
  elasticsearch-data:
    driver: local

networks:
  elk:
    driver: bridge
EOF
```

**Line-by-Line Explanation**:

```yaml
version: '3.8'
# WHAT: Docker Compose file version
# WHY: Defines syntax version
# HOW: Use latest stable version

services:
# WHAT: Define all containers
# WHY: Each component runs in its own container

  elasticsearch:
    # WHAT: Elasticsearch service definition
    # WHY: Search and storage engine
    
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    # WHAT: Official Elasticsearch Docker image
    # WHY: Version 8.11.0 is stable and tested
    # docker.elastic.co: Official Elastic registry
    
    container_name: elasticsearch
    # WHAT: Name for the container
    # WHY: Easy to identify and reference
    
    environment:
      - discovery.type=single-node
      # WHAT: Run as single node (not cluster)
      # WHY: Simpler for development/learning
      # Production: Use cluster mode
      
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      # WHAT: Java memory settings
      # WHY: Limit memory usage
      # -Xms512m: Initial heap size 512MB
      # -Xmx512m: Maximum heap size 512MB
      # Adjust based on your system
      
      - xpack.security.enabled=false
      # WHAT: Disable security features
      # WHY: Simpler for learning
      # Production: Enable security!
    
    ports:
      - "9200:9200"
      # WHAT: Expose Elasticsearch HTTP API
      # WHY: Access from host machine
      # 9200: Standard Elasticsearch port
      
      - "9300:9300"
      # WHAT: Expose Elasticsearch transport port
      # WHY: Node-to-node communication
    
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
      # WHAT: Persist Elasticsearch data
      # WHY: Don't lose data when container restarts
      # elasticsearch-data: Named volume
    
    networks:
      - elk
      # WHAT: Connect to elk network
      # WHY: Allow communication between containers

  logstash:
    # WHAT: Logstash service definition
    # WHY: Process and transform logs
    
    image: docker.elastic.co/logstash/logstash:8.11.0
    # WHAT: Official Logstash Docker image
    # WHY: Same version as Elasticsearch (compatibility)
    
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      # WHAT: Mount pipeline configuration
      # WHY: Logstash reads config from here
      # ./logstash/pipeline: Local directory
      # /usr/share/logstash/pipeline: Container path
      
      - ./sample-logs:/logs
      # WHAT: Mount log files directory
      # WHY: Logstash reads logs from here
    
    ports:
      - "5044:5044"
      # WHAT: Beats input port
      # WHY: Receive logs from Filebeat/other beats
      
      - "9600:9600"
      # WHAT: Logstash monitoring API
      # WHY: Check Logstash status
    
    environment:
      - "LS_JAVA_OPTS=-Xms256m -Xmx256m"
      # WHAT: Java memory settings for Logstash
      # WHY: Limit memory usage (256MB)
    
    depends_on:
      - elasticsearch
      # WHAT: Start after Elasticsearch
      # WHY: Logstash needs Elasticsearch running

  kibana:
    # WHAT: Kibana service definition
    # WHY: Visualization and UI
    
    image: docker.elastic.co/kibana/kibana:8.11.0
    # WHAT: Official Kibana Docker image
    # WHY: Same version as Elasticsearch
    
    ports:
      - "5601:5601"
      # WHAT: Expose Kibana web interface
      # WHY: Access from browser
      # 5601: Standard Kibana port
    
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      # WHAT: Tell Kibana where Elasticsearch is
      # WHY: Kibana needs to connect to Elasticsearch
      # elasticsearch: Container name (DNS)
      # 9200: Elasticsearch port
    
    depends_on:
      - elasticsearch
      # WHAT: Start after Elasticsearch
      # WHY: Kibana needs Elasticsearch running

volumes:
  elasticsearch-data:
    driver: local
    # WHAT: Named volume for Elasticsearch data
    # WHY: Persist data across container restarts
    # driver: local = store on host machine

networks:
  elk:
    driver: bridge
    # WHAT: Create elk network
    # WHY: Allow containers to communicate
    # driver: bridge = standard Docker network
```

### Step 3: Create Logstash Pipeline Configuration

**WHAT**: Define how to process logs  
**WHY**: Transform unstructured logs into structured data  
**HOW**: Create logstash.conf

```bash
cat > logstash/pipeline/logstash.conf << 'EOF'
input {
  # Read from file
  file {
    path => "/logs/app.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
  
  # Accept logs via TCP
  tcp {
    port => 5000
    codec => json_lines
  }
}

filter {
  # Parse log lines
  grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:log_message}" }
  }
  
  # Convert timestamp
  date {
    match => [ "timestamp", "ISO8601" ]
    target => "@timestamp"
  }
  
  # Add fields
  mutate {
    add_field => { "environment" => "development" }
  }
}

output {
  # Send to Elasticsearch
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
  
  # Also print to console (for debugging)
  stdout {
    codec => rubydebug
  }
}
EOF
```

**Line-by-Line Explanation**:

```ruby
input {
  # WHAT: Define log sources
  # WHY: Tell Logstash where to get logs
  
  file {
    # WHAT: Read logs from file
    # WHY: Common log source
    
    path => "/logs/app.log"
    # WHAT: Path to log file
    # WHY: Where logs are located
    # /logs: Mounted volume in container
    
    start_position => "beginning"
    # WHAT: Read from start of file
    # WHY: Process all existing logs
    # Options: "beginning" or "end"
    
    sincedb_path => "/dev/null"
    # WHAT: Don't track file position
    # WHY: Always read entire file (for testing)
    # Production: Use real path to track position
  }
  
  tcp {
    # WHAT: Accept logs via TCP
    # WHY: Applications can send logs directly
    
    port => 5000
    # WHAT: Listen on port 5000
    # WHY: Standard port for log input
    
    codec => json_lines
    # WHAT: Expect JSON format
    # WHY: Structured logs are easier to parse
  }
}

filter {
  # WHAT: Transform and enrich logs
  # WHY: Structure unstructured data
  
  grok {
    # WHAT: Parse log lines with patterns
    # WHY: Extract fields from text
    
    match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:log_message}" }
    # WHAT: Pattern to match log format
    # WHY: Extract timestamp, level, message
    # %{TIMESTAMP_ISO8601:timestamp}: Match ISO timestamp, save as "timestamp"
    # %{LOGLEVEL:level}: Match log level (INFO, ERROR, etc.), save as "level"
    # %{GREEDYDATA:log_message}: Match rest of line, save as "log_message"
  }
  
  date {
    # WHAT: Parse timestamp field
    # WHY: Use log timestamp, not ingestion time
    
    match => [ "timestamp", "ISO8601" ]
    # WHAT: Parse "timestamp" field as ISO8601
    # WHY: Convert string to date object
    
    target => "@timestamp"
    # WHAT: Store in @timestamp field
    # WHY: Elasticsearch uses @timestamp for time-based queries
  }
  
  mutate {
    # WHAT: Modify fields
    # WHY: Add/remove/rename fields
    
    add_field => { "environment" => "development" }
    # WHAT: Add "environment" field
    # WHY: Tag logs with environment
    # Useful for filtering in Kibana
  }
}

output {
  # WHAT: Where to send processed logs
  # WHY: Store for searching and analysis
  
  elasticsearch {
    # WHAT: Send to Elasticsearch
    # WHY: Primary storage for logs
    
    hosts => ["elasticsearch:9200"]
    # WHAT: Elasticsearch address
    # WHY: Where to send logs
    # elasticsearch: Container name (DNS)
    # 9200: Elasticsearch HTTP port
    
    index => "app-logs-%{+YYYY.MM.dd}"
    # WHAT: Index name pattern
    # WHY: Organize logs by date
    # app-logs-2024.01.15: Daily indices
    # Makes it easy to delete old logs
  }
  
  stdout {
    # WHAT: Print to console
    # WHY: Debugging (see what Logstash is doing)
    
    codec => rubydebug
    # WHAT: Pretty-print format
    # WHY: Easy to read
    # Production: Remove this (performance)
  }
}
```

### Step 4: Create Sample Application

**WHAT**: Node.js app that generates logs  
**WHY**: Test the ELK stack  
**HOW**: Create sample app

```bash
cat > sample-app/package.json << 'EOF'
{
  "name": "elk-sample-app",
  "version": "1.0.0",
  "description": "Sample app for ELK logging",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "winston": "^3.11.0"
  }
}
EOF

cat > sample-app/app.js << 'EOF'
const express = require('express');
const winston = require('winston');

// Configure logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.printf(({ timestamp, level, message }) => {
      return `${timestamp} ${level.toUpperCase()} ${message}`;
    })
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: '/logs/app.log' })
  ]
});

const app = express();
const PORT = 3000;

// Routes
app.get('/', (req, res) => {
  logger.info('Home page accessed');
  res.send('Hello from ELK Sample App!');
});

app.get('/api/users', (req, res) => {
  logger.info('Users API called');
  res.json({ users: ['Alice', 'Bob', 'Charlie'] });
});

app.get('/api/error', (req, res) => {
  logger.error('Intentional error triggered');
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, () => {
  logger.info(`Server started on port ${PORT}`);
});

// Generate some logs periodically
setInterval(() => {
  const actions = [
    () => logger.info('Periodic health check'),
    () => logger.warn('High memory usage detected'),
    () => logger.error('Database connection timeout'),
    () => logger.info('User logged in successfully')
  ];
  
  const randomAction = actions[Math.floor(Math.random() * actions.length)];
  randomAction();
}, 10000); // Every 10 seconds
EOF

cat > sample-app/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY app.js ./

CMD ["npm", "start"]
EOF
```

### Step 5: Create Sample Log File

**WHAT**: Test log file  
**WHY**: Test Logstash without running app  
**HOW**: Create sample logs

```bash
cat > sample-logs/app.log << 'EOF'
2024-01-15T10:00:00Z INFO Application started
2024-01-15T10:00:05Z INFO User logged in: user@example.com
2024-01-15T10:00:10Z WARN High memory usage: 85%
2024-01-15T10:00:15Z ERROR Database connection failed
2024-01-15T10:00:20Z INFO Request processed successfully
2024-01-15T10:00:25Z ERROR API timeout after 30s
2024-01-15T10:00:30Z INFO User logged out: user@example.com
EOF
```

### Step 6: Start ELK Stack

```bash
# Start all services
docker-compose up -d

# WHAT: Start Elasticsearch, Logstash, Kibana
# WHY: Run the entire ELK stack
# -d: Detached mode (run in background)

# Expected output:
# Creating network "elk-logging-project_elk" ... done
# Creating volume "elk-logging-project_elasticsearch-data" ... done
# Creating elasticsearch ... done
# Creating logstash      ... done
# Creating kibana        ... done
```

**What happens**:

```
1. Docker creates elk network
2. Docker creates elasticsearch-data volume
3. Starts Elasticsearch (takes ~30 seconds)
4. Starts Logstash (waits for Elasticsearch)
5. Starts Kibana (waits for Elasticsearch)
```

### Step 7: Verify Services

```bash
# Check if containers are running
docker-compose ps

# Expected output:
# NAME            STATUS    PORTS
# elasticsearch   Up        0.0.0.0:9200->9200/tcp, 9300/tcp
# logstash        Up        0.0.0.0:5044->5044/tcp, 9600/tcp
# kibana          Up        0.0.0.0:5601->5601/tcp

# Check Elasticsearch
curl http://localhost:9200

# Expected output:
# {
#   "name" : "elasticsearch",
#   "cluster_name" : "docker-cluster",
#   "version" : { ... },
#   "tagline" : "You Know, for Search"
# }

# Check Logstash
curl http://localhost:9600

# Expected output:
# {
#   "host": "logstash",
#   "version": "8.11.0",
#   "http_address": "0.0.0.0:9600"
# }

# Check Kibana (in browser)
open http://localhost:5601
# Should see Kibana welcome page
```

### Step 8: View Logs in Kibana

```bash
# 1. Open Kibana
open http://localhost:5601

# 2. Wait for Kibana to load (30-60 seconds)

# 3. Create Index Pattern
#    - Click "Discover" in left menu
#    - Click "Create index pattern"
#    - Enter: app-logs-*
#    - Click "Next step"
#    - Select "@timestamp" as time field
#    - Click "Create index pattern"

# 4. View Logs
#    - Click "Discover" again
#    - You should see your logs!
#    - Try searching: level:ERROR
#    - Try filtering by time range
```

### Step 9: Send Test Logs

```bash
# Send a test log via TCP
echo '{"message":"Test log from command line","level":"INFO"}' | nc localhost 5000

# WHAT: Send JSON log to Logstash
# WHY: Test TCP input
# nc: netcat command
# localhost:5000: Logstash TCP input

# Check in Kibana
# Refresh Discover page
# You should see the new log!
```

### Step 10: Create Visualization

```bash
# In Kibana:

# 1. Click "Visualize" in left menu
# 2. Click "Create visualization"
# 3. Select "Vertical bar"
# 4. Select "app-logs-*" index
# 5. Configure:
#    - Y-axis: Count
#    - X-axis: Date Histogram on @timestamp
#    - Split series: Terms on level.keyword
# 6. Click "Update"
# 7. Save visualization as "Log Levels Over Time"
```

### Step 11: Create Dashboard

```bash
# In Kibana:

# 1. Click "Dashboard" in left menu
# 2. Click "Create dashboard"
# 3. Click "Add"
# 4. Select your "Log Levels Over Time" visualization
# 5. Resize and position as desired
# 6. Add more visualizations:
#    - Pie chart of log levels
#    - Table of recent errors
#    - Metric showing total log count
# 7. Save dashboard as "Application Monitoring"
```

---

## 🧪 Testing Your Setup

### Test 1: Log Collection

```bash
# Add more logs to file
echo "2024-01-15T11:00:00Z ERROR Critical system failure" >> sample-logs/app.log

# Wait 10 seconds (Logstash polling interval)
sleep 10

# Check in Kibana
# Refresh Discover
# Search for "Critical system failure"
# Should see the new log!
```

### Test 2: Real-Time Logging

```bash
# Send logs continuously
for i in {1..10}; do
  echo "{\"message\":\"Test log $i\",\"level\":\"INFO\"}" | nc localhost 5000
  sleep 1
done

# Watch in Kibana
# Enable auto-refresh (top right)
# See logs appear in real-time!
```

### Test 3: Search and Filter

```bash
# In Kibana Discover:

# Search for errors:
level:ERROR

# Search for specific message:
message:"database"

# Search with time range:
# Use time picker (top right)
# Select "Last 15 minutes"

# Complex query:
level:ERROR AND message:"timeout"
```

---

## 🔄 Managing the Stack

### View Logs

```bash
# View all logs
docker-compose logs

# View specific service
docker-compose logs elasticsearch
docker-compose logs logstash
docker-compose logs kibana

# Follow logs (real-time)
docker-compose logs -f logstash
```

### Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart logstash
```

### Stop and Clean Up

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (deletes data!)
docker-compose down -v

# WHAT: Stop containers and remove volumes
# WHY: Clean slate for next run
# WARNING: This deletes all logs!
```

---

## 🎓 Interview Questions

### Q1: Walk me through your ELK setup

**Answer**: I use Docker Compose to run Elasticsearch (storage), Logstash (processing), and Kibana (visualization). Logs flow from applications → Logstash → Elasticsearch → Kibana for visualization.

### Q2: How does Logstash process logs?

**Answer**: Logstash uses a pipeline with three stages:

1. **Input**: Collect logs (file, TCP, etc.)
2. **Filter**: Parse with grok, transform with mutate
3. **Output**: Send to Elasticsearch

### Q3: How do you search logs in Elasticsearch?

**Answer**: Use Kibana's Discover interface or Elasticsearch Query DSL. Example: `level:ERROR AND message:"timeout"` finds all error logs containing "timeout".

### Q4: How do you handle log retention?

**Answer**: Use index lifecycle management (ILM) or delete old indices:

```bash
# Delete indices older than 30 days
curl -X DELETE "localhost:9200/app-logs-2024.01.*"
```

### Q5: How do you scale ELK?

**Answer**:

- **Elasticsearch**: Add more nodes to cluster
- **Logstash**: Run multiple instances
- **Kibana**: Run behind load balancer

---

## 🎯 Key Takeaways

1. **ELK Stack = Centralized Logging**
2. **Docker Compose = Easy Setup**
3. **Logstash Pipeline = Input → Filter → Output**
4. **Elasticsearch = Fast Search**
5. **Kibana = Visualization**
6. **Index Patterns = Organize Logs**
7. **Dashboards = Monitor Applications**

---

## 📚 What's Next?

You now have a working ELK stack! Next steps:

- Add more log sources
- Create custom dashboards
- Set up alerts
- Practice log analysis

---

**Congratulations! You've built a production-ready ELK Stack!** 🎉

**Remember**: Always monitor your logs - they're your first line of defense in production! 🔍
