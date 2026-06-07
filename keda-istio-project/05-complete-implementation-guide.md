# Complete End-to-End Implementation: KEDA + Istio Project

## 🎯 What We're Building

A **complete microservices e-commerce system** with:

- ✅ Frontend web application
- ✅ API Gateway
- ✅ Order Service
- ✅ Payment Service (KEDA autoscaling)
- ✅ RabbitMQ message queue
- ✅ Istio service mesh (traffic management, security, observability)
- ✅ Complete monitoring (Kiali, Grafana, Jaeger, Prometheus)

### Architecture

```
                    Internet
                       ↓
              [Istio Ingress Gateway]
                       ↓
┌──────────────────────────────────────────────────────┐
│                 Istio Service Mesh                    │
│                                                       │
│  [Frontend] → [API Gateway] → [Order Service]       │
│                                        ↓              │
│                                  [RabbitMQ Queue]    │
│                                        ↓              │
│                              [Payment Service]       │
│                                   ↑                   │
│                              [KEDA Scaler]           │
│                                                       │
│  Observability:                                      │
│  - Kiali (Service Graph)                            │
│  - Grafana (Metrics)                                │
│  - Jaeger (Tracing)                                 │
│  - Prometheus (Metrics Storage)                     │
└──────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

### Required Tools

```bash
# Check if you have these installed:
docker --version          # Docker 20.10+
kubectl version --client  # kubectl 1.24+
minikube version         # Minikube 1.28+ (or any K8s cluster)
helm version             # Helm 3.10+
```

### System Requirements

- **CPU**: 4 cores minimum (8 cores recommended)
- **RAM**: 8GB minimum (16GB recommended)
- **Disk**: 20GB free space
- **OS**: Linux, macOS, or Windows with WSL2

---

## 🚀 Step 1: Setup Kubernetes Cluster

### Option A: Minikube (Local Development)

```bash
# Start Minikube with enough resources
minikube start \
  --cpus=4 \
  --memory=8192 \
  --disk-size=20g \
  --driver=docker

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Expected output:
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   1m    v1.28.0
```

### Option B: Kind (Alternative)

```bash
# Create cluster
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

# Verify
kubectl get nodes
```

### Option C: Cloud Kubernetes (GKE/EKS/AKS)

```bash
# GKE Example
gcloud container clusters create keda-istio-cluster \
  --num-nodes=3 \
  --machine-type=e2-standard-4 \
  --zone=us-central1-a

# Get credentials
gcloud container clusters get-credentials keda-istio-cluster
```

---

## 🔧 Step 2: Install Istio

### Download Istio

```bash
# Download Istio 1.20
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -

# Add to PATH
cd istio-1.20.0
export PATH=$PWD/bin:$PATH

# Verify
istioctl version
```

### Install Istio

```bash
# Install with demo profile (includes observability tools)
istioctl install --set profile=demo -y

# Expected output:
# ✔ Istio core installed
# ✔ Istiod installed
# ✔ Ingress gateways installed
# ✔ Egress gateways installed
# ✔ Installation complete

# Verify installation
kubectl get pods -n istio-system

# Expected pods:
# istio-ingressgateway
# istio-egressgateway
# istiod
```

### Enable Sidecar Injection

```bash
# Label default namespace for automatic sidecar injection
kubectl label namespace default istio-injection=enabled

# Verify label
kubectl get namespace -L istio-injection

# Expected output:
# NAME      STATUS   AGE   ISTIO-INJECTION
# default   Active   10m   enabled
```

### Install Observability Add-ons

```bash
# Install Kiali, Prometheus, Grafana, Jaeger
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=kiali -n istio-system --timeout=300s

# Verify all pods are running
kubectl get pods -n istio-system
```

---

## 🔧 Step 3: Install KEDA

```bash
# Add KEDA Helm repository
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

# Install KEDA
helm install keda kedacore/keda --namespace keda --create-namespace

# Verify installation
kubectl get pods -n keda

# Expected pods:
# keda-operator
# keda-metrics-apiserver

# Check KEDA version
kubectl get deployment -n keda keda-operator -o jsonpath='{.spec.template.spec.containers[0].image}'
```

---

## 🔧 Step 4: Install RabbitMQ

```bash
# Create RabbitMQ deployment
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
  labels:
    app: rabbitmq
spec:
  ports:
  - port: 5672
    name: amqp
  - port: 15672
    name: management
  selector:
    app: rabbitmq
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rabbitmq
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rabbitmq
  template:
    metadata:
      labels:
        app: rabbitmq
    spec:
      containers:
      - name: rabbitmq
        image: rabbitmq:3.12-management
        ports:
        - containerPort: 5672
          name: amqp
        - containerPort: 15672
          name: management
        env:
        - name: RABBITMQ_DEFAULT_USER
          value: "admin"
        - name: RABBITMQ_DEFAULT_PASS
          value: "admin123"
EOF

# Wait for RabbitMQ to be ready
kubectl wait --for=condition=ready pod -l app=rabbitmq --timeout=300s

# Verify
kubectl get pods -l app=rabbitmq
```

---

## 💻 Step 5: Build Application Services

### Create Project Structure

```bash
mkdir -p keda-istio-demo/{frontend,api-gateway,order-service,payment-service,k8s}
cd keda-istio-demo
```

### 5.1 Frontend Service

```bash
# Create frontend/app.py
cat > frontend/app.py <<'EOF'
from flask import Flask, render_template_string, request
import requests
import os

app = Flask(__name__)
API_GATEWAY_URL = os.getenv('API_GATEWAY_URL', 'http://api-gateway:8080')

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>E-Commerce Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { text-align: center; }
        .order-form {
            background: rgba(255,255,255,0.2);
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }
        input, button {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            border: none;
        }
        button {
            background: #4CAF50;
            color: white;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover { background: #45a049; }
        .status {
            margin-top: 20px;
            padding: 15px;
            border-radius: 5px;
            background: rgba(255,255,255,0.2);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛒 E-Commerce Order System</h1>
        <p>Powered by Istio + KEDA</p>
        
        <div class="order-form">
            <h2>Place Order</h2>
            <form method="POST" action="/order">
                <input type="text" name="product" placeholder="Product Name" required>
                <input type="number" name="quantity" placeholder="Quantity" required>
                <input type="number" name="price" placeholder="Price" step="0.01" required>
                <button type="submit">Place Order</button>
            </form>
        </div>
        
        {% if message %}
        <div class="status">
            <h3>{{ message }}</h3>
        </div>
        {% endif %}
    </div>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/order', methods=['POST'])
def create_order():
    try:
        order_data = {
            'product': request.form['product'],
            'quantity': int(request.form['quantity']),
            'price': float(request.form['price'])
        }
        
        response = requests.post(f'{API_GATEWAY_URL}/api/orders', json=order_data, timeout=5)
        
        if response.status_code == 200:
            message = f"✅ Order placed successfully! Order ID: {response.json().get('order_id')}"
        else:
            message = f"❌ Order failed: {response.text}"
            
    except Exception as e:
        message = f"❌ Error: {str(e)}"
    
    return render_template_string(HTML_TEMPLATE, message=message)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Create frontend/requirements.txt
cat > frontend/requirements.txt <<EOF
flask==3.0.0
requests==2.31.0
EOF

# Create frontend/Dockerfile
cat > frontend/Dockerfile <<EOF
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF
```

### 5.2 API Gateway Service

```bash
# Create api-gateway/app.py
cat > api-gateway/app.py <<'EOF'
from flask import Flask, request, jsonify
import requests
import os
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

ORDER_SERVICE_URL = os.getenv('ORDER_SERVICE_URL', 'http://order-service:8080')

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/orders', methods=['POST'])
def create_order():
    try:
        order_data = request.json
        logger.info(f"Received order: {order_data}")
        
        # Forward to order service
        response = requests.post(
            f'{ORDER_SERVICE_URL}/orders',
            json=order_data,
            timeout=10
        )
        
        logger.info(f"Order service response: {response.status_code}")
        return jsonify(response.json()), response.status_code
        
    except Exception as e:
        logger.error(f"Error processing order: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Create api-gateway/requirements.txt
cat > api-gateway/requirements.txt <<EOF
flask==3.0.0
requests==2.31.0
EOF

# Create api-gateway/Dockerfile
cat > api-gateway/Dockerfile <<EOF
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF
```

### 5.3 Order Service

```bash
# Create order-service/app.py
cat > order-service/app.py <<'EOF'
from flask import Flask, request, jsonify
import pika
import json
import uuid
import os
import logging
import time

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'rabbitmq')
RABBITMQ_USER = os.getenv('RABBITMQ_USER', 'admin')
RABBITMQ_PASS = os.getenv('RABBITMQ_PASS', 'admin123')
RABBITMQ_QUEUE = 'payment-queue'

def get_rabbitmq_connection():
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        credentials=credentials,
        heartbeat=600,
        blocked_connection_timeout=300
    )
    return pika.BlockingConnection(parameters)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/orders', methods=['POST'])
def create_order():
    try:
        order_data = request.json
        order_id = str(uuid.uuid4())
        
        logger.info(f"Creating order {order_id}: {order_data}")
        
        # Create payment message
        payment_message = {
            'order_id': order_id,
            'product': order_data.get('product'),
            'quantity': order_data.get('quantity'),
            'price': order_data.get('price'),
            'total': order_data.get('quantity', 0) * order_data.get('price', 0)
        }
        
        # Send to RabbitMQ
        connection = get_rabbitmq_connection()
        channel = connection.channel()
        channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
        
        channel.basic_publish(
            exchange='',
            routing_key=RABBITMQ_QUEUE,
            body=json.dumps(payment_message),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Make message persistent
            )
        )
        
        connection.close()
        
        logger.info(f"Order {order_id} sent to payment queue")
        
        return jsonify({
            'order_id': order_id,
            'status': 'pending',
            'message': 'Order created and sent for payment processing'
        }), 200
        
    except Exception as e:
        logger.error(f"Error creating order: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Wait for RabbitMQ to be ready
    time.sleep(10)
    app.run(host='0.0.0.0', port=8080)
EOF

# Create order-service/requirements.txt
cat > order-service/requirements.txt <<EOF
flask==3.0.0
pika==1.3.2
EOF

# Create order-service/Dockerfile
cat > order-service/Dockerfile <<EOF
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF
```

### 5.4 Payment Service (KEDA Scaled)

```bash
# Create payment-service/app.py
cat > payment-service/app.py <<'EOF'
import pika
import json
import time
import os
import logging
import signal
import sys

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'rabbitmq')
RABBITMQ_USER = os.getenv('RABBITMQ_USER', 'admin')
RABBITMQ_PASS = os.getenv('RABBITMQ_PASS', 'admin123')
RABBITMQ_QUEUE = 'payment-queue'

def process_payment(payment_data):
    """Simulate payment processing"""
    order_id = payment_data.get('order_id')
    total = payment_data.get('total')
    
    logger.info(f"Processing payment for order {order_id}, amount: ${total}")
    
    # Simulate payment processing time
    time.sleep(5)
    
    logger.info(f"Payment completed for order {order_id}")
    return True

def callback(ch, method, properties, body):
    try:
        payment_data = json.loads(body)
        logger.info(f"Received payment request: {payment_data}")
        
        # Process payment
        success = process_payment(payment_data)
        
        if success:
            ch.basic_ack(delivery_tag=method.delivery_tag)
            logger.info(f"Payment processed successfully")
        else:
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
            logger.error(f"Payment failed, requeuing")
            
    except Exception as e:
        logger.error(f"Error processing payment: {str(e)}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

def main():
    # Wait for RabbitMQ
    time.sleep(15)
    
    logger.info("Starting payment service...")
    
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        credentials=credentials,
        heartbeat=600,
        blocked_connection_timeout=300
    )
    
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    
    channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=RABBITMQ_QUEUE, on_message_callback=callback)
    
    logger.info("Payment service ready, waiting for messages...")
    
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        logger.info("Shutting down...")
        channel.stop_consuming()
        connection.close()

if __name__ == '__main__':
    main()
EOF

# Create payment-service/requirements.txt
cat > payment-service/requirements.txt <<EOF
pika==1.3.2
EOF

# Create payment-service/Dockerfile
cat > payment-service/Dockerfile <<EOF
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
CMD ["python", "app.py"]
EOF
```

---

## 🐳 Step 6: Build and Push Docker Images

```bash
# Build all images
docker build -t frontend:v1 ./frontend
docker build -t api-gateway:v1 ./api-gateway
docker build -t order-service:v1 ./order-service
docker build -t payment-service:v1 ./payment-service

# If using Minikube, load images directly
eval $(minikube docker-env)
docker build -t frontend:v1 ./frontend
docker build -t api-gateway:v1 ./api-gateway
docker build -t order-service:v1 ./order-service
docker build -t payment-service:v1 ./payment-service

# Verify images
docker images | grep -E "frontend|api-gateway|order-service|payment-service"
```

---

## ☸️ Step 7: Deploy to Kubernetes

### 7.1 Create Kubernetes Manifests

```bash
# Create k8s/01-frontend.yaml
cat > k8s/01-frontend.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: frontend
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
      version: v1
  template:
    metadata:
      labels:
        app: frontend
        version: v1
    spec:
      containers:
      - name: frontend
        image: frontend:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        env:
        - name: API_GATEWAY_URL
          value: "http://api-gateway:8080"
EOF

# Create k8s/02-api-gateway.yaml
cat > k8s/02-api-gateway.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  labels:
    app: api-gateway
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: api-gateway
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
      version: v1
  template:
    metadata:
      labels:
        app: api-gateway
        version: v1
    spec:
      containers:
      - name: api-gateway
        image: api-gateway:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        env:
        - name: ORDER_SERVICE_URL
          value: "http://order-service:8080"
EOF

# Create k8s/03-order-service.yaml
cat > k8s/03-order-service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: order-service
  labels:
    app: order-service
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: order-service
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
      version: v1
  template:
    metadata:
      labels:
        app: order-service
        version: v1
    spec:
      containers:
      - name: order-service
        image: order-service:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        env:
        - name: RABBITMQ_HOST
          value: "rabbitmq"
        - name: RABBITMQ_USER
          value: "admin"
        - name: RABBITMQ_PASS
          value: "admin123"
EOF

# Create k8s/04-payment-service.yaml
cat > k8s/04-payment-service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: payment-service
  labels:
    app: payment-service
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: payment-service
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payment-service
      version: v1
  template:
    metadata:
      labels:
        app: payment-service
        version: v1
    spec:
      containers:
      - name: payment-service
        image: payment-service:v1
        imagePullPolicy: IfNotPresent
        env:
        - name: RABBITMQ_HOST
          value: "rabbitmq"
        - name: RABBITMQ_USER
          value: "admin"
        - name: RABBITMQ_PASS
          value: "admin123"
EOF
```

### 7.2 Deploy Services

```bash
# Deploy all services
kubectl apply -f k8s/

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all --timeout=300s

# Verify deployments
kubectl get pods
kubectl get services

# Check Istio sidecars are injected
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'

# You should see 2 containers per pod: your app + istio-proxy
```

---

## 🎯 Step 8: Configure Istio

### 8.1 Create Istio Gateway

```bash
# Create k8s/05-istio-gateway.yaml
cat > k8s/05-istio-gateway.yaml <<'EOF'
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: ecommerce-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend
spec:
  hosts:
  - "*"
  gateways:
  - ecommerce-gateway
  http:
  - match:
    - uri:
        prefix: "/"
    route:
    - destination:
        host: frontend
        port:
          number: 8080
EOF

# Apply Istio configuration
kubectl apply -f k8s/05-istio-gateway.yaml
```

### 8.2 Configure Traffic Management

```bash
# Create k8s/06-istio-traffic.yaml
cat > k8s/06-istio-traffic.yaml <<'EOF'
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: api-gateway
spec:
  host: api-gateway
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-gateway
spec:
  hosts:
  - api-gateway
  http:
  - route:
    - destination:
        host: api-gateway
    retries:
      attempts: 3
      perTryTimeout: 2s
      retryOn: 5xx,reset,connect-failure
    timeout: 10s
EOF

# Apply traffic rules
kubectl apply -f k8s/06-istio-traffic.yaml
```

---

## 🚀 Step 9: Configure KEDA Autoscaling

```bash
# Create k8s/07-keda-scaledobject.yaml
cat > k8s/07-keda-scaledobject.yaml <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-secret
type: Opaque
stringData:
  host: amqp://admin:admin123@rabbitmq.default.svc.cluster.local:5672
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: rabbitmq-trigger-auth
spec:
  secretTargetRef:
  - parameter: host
    name: rabbitmq-secret
    key: host
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: payment-service-scaler
spec:
  scaleTargetRef:
    name: payment-service
  minReplicaCount: 0
  maxReplicaCount: 10
  pollingInterval: 15
  cooldownPeriod: 60
  triggers:
  - type: rabbitmq
    metadata:
      queueName: payment-queue
      mode: QueueLength
      value: "5"
    authenticationRef:
      name: rabbitmq-trigger-auth
EOF

# Apply KEDA configuration
kubectl apply -f k8s/07-keda-scaledobject.yaml

# Verify ScaledObject
kubectl get scaledobject
kubectl describe scaledobject payment-service-scaler
```

---

## 🧪 Step 10: Test the System

### 10.1 Access the Application

```bash
# Get Istio Ingress Gateway URL
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

# For Minikube
minikube tunnel  # Run in separate terminal
export GATEWAY_URL=$(minikube ip):$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

echo "Application URL: http://$GATEWAY_URL"

# Open in browser
open http://$GATEWAY_URL  # macOS
xdg-open http://$GATEWAY_URL  # Linux
```

### 10.2 Generate Load to Test KEDA

```bash
# Create load generator script
cat > load-test.sh <<'EOF'
#!/bin/bash

GATEWAY_URL=${1:-"http://localhost"}
NUM_REQUESTS=${2:-100}

echo "Sending $NUM_REQUESTS orders to $GATEWAY_URL"

for i in $(seq 1 $NUM_REQUESTS); do
  curl -X POST "$GATEWAY_URL/api/orders" \
    -H "Content-Type: application/json" \
    -d "{\"product\":\"Product-$i\",\"quantity\":$((RANDOM % 10 + 1)),\"price\":$((RANDOM % 100 + 10))}" \
    &
  
  if [ $((i % 10)) -eq 0 ]; then
    echo "Sent $i requests..."
    sleep 1
  fi
done

wait
echo "All requests sent!"
EOF

chmod +x load-test.sh

# Run load test
./load-test.sh http://$GATEWAY_URL 100

# Watch KEDA scaling in action
watch kubectl get pods -l app=payment-service

# Check RabbitMQ queue
kubectl port-forward svc/rabbitmq 15672:15672
# Open http://localhost:15672 (admin/admin123)
```

### 10.3 Monitor Scaling

```bash
# Watch pods scaling
kubectl get pods -l app=payment-service -w

# Check HPA created by KEDA
kubectl get hpa

# View KEDA metrics
kubectl get --raw /apis/external.metrics.k8s.io/v1beta1 | jq .

# Check scaling events
kubectl get events --sort-by='.lastTimestamp' | grep payment-service
```

---

## 📊 Step 11: Access Observability Tools

### 11.1 Kiali (Service Mesh Visualization)

```bash
# Port forward Kiali
kubectl port-forward svc/kiali -n istio-system 20001:20001

# Open browser
open http://localhost:20001

# Login: admin/admin (default)

# What to see:
# - Service graph
# - Traffic flow
# - Request rates
# - Error rates
# - Response times
```

### 11.2 Grafana (Metrics Dashboard)

```bash
# Port forward Grafana
kubectl port-forward svc/grafana -n istio-system 3000:3000

# Open browser
open http://localhost:3000

# Explore dashboards:
# - Istio Service Dashboard
# - Istio Workload Dashboard
# - Istio Performance Dashboard
```

### 11.3 Jaeger (Distributed Tracing)

```bash
# Port forward Jaeger
kubectl port-forward svc/tracing -n istio-system 16686:16686

# Open browser
open http://localhost:16686

# What to see:
# - End-to-end request traces
# - Service dependencies
# - Latency breakdown
# - Error traces
```

### 11.4 Prometheus (Metrics)

```bash
# Port forward Prometheus
kubectl port-forward svc/prometheus -n istio-system 9090:9090

# Open browser
open http://localhost:9090

# Example queries:
# - istio_requests_total
# - istio_request_duration_milliseconds
# - keda_scaler_metrics_value
```

---

## 🎯 Step 12: Verify Everything Works

### Checklist

```bash
# 1. All pods running
kubectl get pods
# Expected: All pods in Running state with 2/2 containers

# 2. Istio sidecars injected
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
# Expected: Each pod has app container + istio-proxy

# 3. Services accessible
kubectl get svc
# Expected: All services have ClusterIP

# 4. Istio gateway working
kubectl get gateway
kubectl get virtualservice
# Expected: Gateway and VirtualServices created

# 5. KEDA installed
kubectl get scaledobject
# Expected: payment-service-scaler present

# 6. RabbitMQ running
kubectl get pods -l app=rabbitmq
# Expected: rabbitmq pod running

# 7. Application accessible
curl http://$GATEWAY_URL
# Expected: HTML response from frontend

# 8. Can create orders
curl -X POST http://$GATEWAY_URL/api/orders \
  -H "Content-Type: application/json" \
  -d '{"product":"Test","quantity":1,"price":10}'
# Expected: JSON response with order_id

# 9. KEDA scaling works
./load-test.sh http://$GATEWAY_URL 50
kubectl get pods -l app=payment-service -w
# Expected: Payment service scales up

# 10. Observability tools accessible
kubectl get pods -n istio-system
# Expected: kiali, grafana, jaeger, prometheus running
```

---

## 🎓 What You've Accomplished

Congratulations! You've built a complete production-grade microservices system with:

✅ **Microservices Architecture**

- Frontend, API Gateway, Order Service, Payment Service
- Message queue (RabbitMQ)
- Proper service separation

✅ **Istio Service Mesh**

- Automatic sidecar injection
- Traffic management (retries, timeouts, circuit breaking)
- Secure service-to-service communication
- Complete observability

✅ **KEDA Autoscaling**

- Event-driven scaling based on queue depth
- Scale to zero capability
- Automatic scaling up/down

✅ **Observability**

- Service mesh visualization (Kiali)
- Metrics and dashboards (Grafana)
- Distributed tracing (Jaeger)
- Metrics storage (Prometheus)

✅ **Production-Ready Features**

- High availability
- Auto-scaling
- Circuit breaking
- Retry logic
- Monitoring and alerting

---

## 🚀 Next Steps

Continue learning with:

- [Advanced Istio Features](./16-traffic-management.md)
- [KEDA Advanced Scalers](./21-rabbitmq-scaler.md)
- [Production Best Practices](./29-best-practices.md)
- [Interview Questions](./30-interview-questions.md)

---

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/
kubectl delete namespace keda
istioctl uninstall --purge -y
kubectl delete namespace istio-system

# Stop Minikube
minikube stop
minikube delete
```

**Congratulations!** You've completed the full KEDA + Istio implementation! 🎉
