# 🔧 OpenShift Troubleshooting Guide

## Complete Problem-Solving Reference

---

## 📋 **OVERVIEW**

This guide covers:

- ✅ Common OpenShift issues and solutions
- ✅ Debugging techniques
- ✅ Performance problems
- ✅ Network troubleshooting
- ✅ Storage issues
- ✅ Application crashes
- ✅ Best practices for prevention

---

## 🎯 **TROUBLESHOOTING METHODOLOGY**

### **The 5-Step Approach:**

```
1. IDENTIFY → What's the problem?
2. GATHER → Collect information
3. ANALYZE → Find the root cause
4. FIX → Apply solution
5. VERIFY → Confirm it works
```

### **Essential Commands:**

```bash
# Quick health check
oc get pods                    # Pod status
oc get events --sort-by='.lastTimestamp'  # Recent events
oc describe pod <pod-name>     # Detailed pod info
oc logs <pod-name>             # Application logs
oc get all                     # All resources

# Advanced debugging
oc debug pod/<pod-name>        # Debug container
oc rsh <pod-name>              # Shell into pod
oc port-forward <pod> 8080:8080  # Port forwarding
oc adm top pods                # Resource usage
```

---

## 🐛 **SECTION 1: POD ISSUES**

### **Issue 1.1: Pod Stuck in Pending**

**Symptoms:**

```bash
$ oc get pods
NAME                    READY   STATUS    RESTARTS   AGE
my-app-xxxxx-xxxxx      0/1     Pending   0          5m
```

**Diagnosis:**

```bash
# Check pod details
oc describe pod my-app-xxxxx-xxxxx

# Look for events at the bottom
# Common messages:
# - "Insufficient cpu"
# - "Insufficient memory"
# - "No nodes available"
```

**Common Causes & Solutions:**

**A. Insufficient Resources**

```bash
# Problem: Not enough CPU/memory on nodes
# Solution 1: Reduce resource requests
oc set resources deployment my-app \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=500m,memory=512Mi

# Solution 2: Scale down other apps
oc scale deployment other-app --replicas=0

# Solution 3: Add more nodes (production)
```

**B. Node Selector Mismatch**

```bash
# Problem: Pod requires specific node labels
# Check node selector
oc get pod my-app-xxxxx-xxxxx -o yaml | grep -A 5 nodeSelector

# Solution: Remove node selector or add label to nodes
oc patch deployment my-app -p '{"spec":{"template":{"spec":{"nodeSelector":null}}}}'
```

**C. Persistent Volume Not Available**

```bash
# Problem: PVC not bound
oc get pvc

# Solution: Check PV availability
oc get pv
# Create PV if needed or fix PVC configuration
```

---

### **Issue 1.2: Pod in CrashLoopBackOff**

**Symptoms:**

```bash
$ oc get pods
NAME                    READY   STATUS             RESTARTS   AGE
my-app-xxxxx-xxxxx      0/1     CrashLoopBackOff   5          5m
```

**Diagnosis:**

```bash
# Check current logs
oc logs my-app-xxxxx-xxxxx

# Check previous logs (from crashed container)
oc logs my-app-xxxxx-xxxxx --previous

# Check events
oc describe pod my-app-xxxxx-xxxxx
```

**Common Causes & Solutions:**

**A. Application Error**

```bash
# Problem: App crashes on startup
# Check logs for error messages
oc logs my-app-xxxxx-xxxxx --previous

# Common errors:
# - "Cannot find module"
# - "Connection refused"
# - "Port already in use"

# Solution: Fix application code or configuration
```

**B. Missing Environment Variables**

```bash
# Problem: Required env vars not set
# Check current env vars
oc set env deployment/my-app --list

# Solution: Add missing variables
oc set env deployment/my-app \
  DATABASE_URL=postgresql://db:5432/mydb \
  API_KEY=your-api-key
```

**C. Wrong Command/Entrypoint**

```bash
# Problem: Container starts with wrong command
# Check current command
oc get deployment my-app -o yaml | grep -A 5 command

# Solution: Fix command
oc set env deployment/my-app COMMAND='["node", "server.js"]'
```

**D. Health Check Failures**

```bash
# Problem: Liveness/readiness probes failing
# Check probe configuration
oc describe pod my-app-xxxxx-xxxxx | grep -A 10 Liveness

# Solution: Adjust probe settings
oc set probe deployment/my-app \
  --liveness --initial-delay-seconds=60 \
  --period-seconds=10 \
  --timeout-seconds=5
```

---

### **Issue 1.3: Pod in ImagePullBackOff**

**Symptoms:**

```bash
$ oc get pods
NAME                    READY   STATUS             RESTARTS   AGE
my-app-xxxxx-xxxxx      0/1     ImagePullBackOff   0          2m
```

**Diagnosis:**

```bash
# Check events
oc describe pod my-app-xxxxx-xxxxx

# Look for:
# - "Failed to pull image"
# - "manifest unknown"
# - "unauthorized"
```

**Common Causes & Solutions:**

**A. Image Doesn't Exist**

```bash
# Problem: Wrong image name or tag
# Check current image
oc get deployment my-app -o yaml | grep image:

# Solution: Use correct image
oc set image deployment/my-app my-app=nginx:latest
```

**B. Authentication Required**

```bash
# Problem: Private registry needs credentials
# Solution: Create image pull secret
oc create secret docker-registry my-registry-secret \
  --docker-server=registry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com

# Link secret to service account
oc secrets link default my-registry-secret --for=pull
```

**C. Network Issues**

```bash
# Problem: Cannot reach registry
# Check network connectivity
oc debug node/<node-name>
# Inside debug pod:
curl -I https://registry.example.com

# Solution: Fix network/firewall rules
```

---

### **Issue 1.4: Pod Running but Not Ready**

**Symptoms:**

```bash
$ oc get pods
NAME                    READY   STATUS    RESTARTS   AGE
my-app-xxxxx-xxxxx      0/1     Running   0          5m
```

**Diagnosis:**

```bash
# Check readiness probe
oc describe pod my-app-xxxxx-xxxxx | grep -A 10 Readiness

# Check logs
oc logs my-app-xxxxx-xxxxx
```

**Solutions:**

**A. Readiness Probe Failing**

```bash
# Test the readiness endpoint manually
oc port-forward my-app-xxxxx-xxxxx 8080:8080
curl http://localhost:8080/health

# If endpoint is slow, increase timeout
oc set probe deployment/my-app \
  --readiness --initial-delay-seconds=30 \
  --timeout-seconds=10

# If endpoint doesn't exist, remove probe temporarily
oc set probe deployment/my-app --readiness --remove
```

**B. Application Still Starting**

```bash
# Problem: App takes long to start
# Solution: Increase initial delay
oc set probe deployment/my-app \
  --readiness --initial-delay-seconds=60
```

---

## 🌐 **SECTION 2: NETWORKING ISSUES**

### **Issue 2.1: Cannot Access Application**

**Symptoms:**

```bash
$ curl http://my-app-myproject.apps-crc.testing
curl: (7) Failed to connect to my-app-myproject.apps-crc.testing
```

**Diagnosis Checklist:**

```bash
# 1. Check if pods are running
oc get pods
# All pods should be Running and Ready (1/1)

# 2. Check if service exists
oc get service my-app
# Should show ClusterIP and port

# 3. Check if route exists
oc get route my-app
# Should show hostname

# 4. Test service internally
oc run test-pod --image=busybox --rm -it --restart=Never -- \
  wget -O- http://my-app:8080

# 5. Check service endpoints
oc get endpoints my-app
# Should list pod IPs
```

**Common Causes & Solutions:**

**A. Route Not Created**

```bash
# Problem: No route exists
oc get route

# Solution: Create route
oc expose service my-app
oc get route my-app
```

**B. Service Selector Mismatch**

```bash
# Problem: Service not finding pods
# Check service selector
oc get service my-app -o yaml | grep -A 3 selector

# Check pod labels
oc get pods --show-labels

# Solution: Fix selector or labels
oc patch service my-app -p '{"spec":{"selector":{"app":"my-app"}}}'
```

**C. Wrong Port Configuration**

```bash
# Problem: Service pointing to wrong port
# Check service ports
oc get service my-app -o yaml | grep -A 5 ports

# Check container ports
oc get deployment my-app -o yaml | grep -A 5 containerPort

# Solution: Fix service port
oc patch service my-app -p '{"spec":{"ports":[{"port":80,"targetPort":8080}]}}'
```

**D. Firewall/Network Policy**

```bash
# Problem: Network policy blocking traffic
# Check network policies
oc get networkpolicy

# Solution: Create allow policy
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}
  egress:
  - {}
EOF
```

---

### **Issue 2.2: Service-to-Service Communication Fails**

**Symptoms:**

```bash
# Frontend can't reach backend
# Logs show: "Connection refused" or "Name resolution failed"
```

**Diagnosis:**

```bash
# Test DNS resolution
oc rsh frontend-pod
# Inside pod:
nslookup backend-service
ping backend-service

# Test connectivity
curl http://backend-service:8080/health
```

**Solutions:**

**A. DNS Not Working**

```bash
# Problem: DNS resolution fails
# Check DNS pods
oc get pods -n openshift-dns

# Restart DNS if needed
oc delete pod -n openshift-dns -l dns.operator.openshift.io/daemonset-dns=default
```

**B. Wrong Service Name**

```bash
# Problem: Using wrong service name
# List all services
oc get services

# Use correct format:
# Same namespace: service-name
# Different namespace: service-name.namespace.svc.cluster.local

# Update application config
oc set env deployment/frontend \
  BACKEND_URL=http://backend-service:8080
```

**C. Network Policy Blocking**

```bash
# Problem: Network policy denying traffic
# Check policies
oc get networkpolicy

# Create allow policy for specific services
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
EOF
```

---

## 💾 **SECTION 3: STORAGE ISSUES**

### **Issue 3.1: PVC Stuck in Pending**

**Symptoms:**

```bash
$ oc get pvc
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-pvc      Pending                                                     5m
```

**Diagnosis:**

```bash
# Check PVC details
oc describe pvc my-pvc

# Check available PVs
oc get pv

# Check storage classes
oc get storageclass
```

**Solutions:**

**A. No Available PV**

```bash
# Problem: No PV matches PVC requirements
# Solution: Create PV or use dynamic provisioning

# For CRC, use hostPath PV
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /mnt/data
  persistentVolumeReclaimPolicy: Retain
EOF
```

**B. Storage Class Not Found**

```bash
# Problem: Specified storage class doesn't exist
# Check available storage classes
oc get storageclass

# Solution: Use existing storage class
oc patch pvc my-pvc -p '{"spec":{"storageClassName":"standard"}}'
```

---

### **Issue 3.2: Pod Can't Mount Volume**

**Symptoms:**

```bash
# Pod stuck in ContainerCreating
# Events show: "Unable to mount volumes"
```

**Diagnosis:**

```bash
# Check pod events
oc describe pod my-app-xxxxx-xxxxx

# Check PVC status
oc get pvc

# Check volume mounts
oc get pod my-app-xxxxx-xxxxx -o yaml | grep -A 10 volumeMounts
```

**Solutions:**

**A. PVC Not Bound**

```bash
# Problem: PVC still pending
# Solution: Fix PVC first (see Issue 3.1)
```

**B. Access Mode Mismatch**

```bash
# Problem: Multiple pods trying to mount ReadWriteOnce volume
# Solution: Use ReadWriteMany or scale to 1 replica
oc scale deployment my-app --replicas=1
```

**C. Permission Issues**

```bash
# Problem: Container can't write to volume
# Solution: Fix permissions or use fsGroup
oc patch deployment my-app -p '
{
  "spec": {
    "template": {
      "spec": {
        "securityContext": {
          "fsGroup": 1000
        }
      }
    }
  }
}'
```

---

## 🔥 **SECTION 4: PERFORMANCE ISSUES**

### **Issue 4.1: Application Slow/Unresponsive**

**Diagnosis:**

```bash
# Check resource usage
oc adm top pods

# Check pod events
oc get events --sort-by='.lastTimestamp'

# Check application logs
oc logs my-app-xxxxx-xxxxx --tail=100
```

**Common Causes & Solutions:**

**A. Resource Limits Too Low**

```bash
# Problem: CPU/memory throttling
# Check current limits
oc describe pod my-app-xxxxx-xxxxx | grep -A 5 Limits

# Solution: Increase limits
oc set resources deployment my-app \
  --limits=cpu=1000m,memory=1Gi \
  --requests=cpu=500m,memory=512Mi
```

**B. Too Many Requests**

```bash
# Problem: Single pod overloaded
# Solution: Scale up
oc scale deployment my-app --replicas=5

# Or enable autoscaling
oc autoscale deployment my-app \
  --min=2 --max=10 --cpu-percent=70
```

**C. Database Connection Issues**

```bash
# Problem: Database slow or connection pool exhausted
# Check database pod
oc logs database-pod --tail=100

# Solution: Scale database or increase connection pool
oc set env deployment/my-app \
  DB_POOL_SIZE=20 \
  DB_TIMEOUT=30000
```

---

### **Issue 4.2: Out of Memory (OOMKilled)**

**Symptoms:**

```bash
$ oc get pods
NAME                    READY   STATUS      RESTARTS   AGE
my-app-xxxxx-xxxxx      0/1     OOMKilled   5          10m
```

**Diagnosis:**

```bash
# Check pod events
oc describe pod my-app-xxxxx-xxxxx | grep -i oom

# Check memory usage before crash
oc adm top pod my-app-xxxxx-xxxxx
```

**Solutions:**

**A. Increase Memory Limit**

```bash
# Solution: Allocate more memory
oc set resources deployment my-app \
  --limits=memory=2Gi \
  --requests=memory=1Gi
```

**B. Fix Memory Leak**

```bash
# Problem: Application has memory leak
# Solution: Fix application code
# Temporary: Restart pods periodically
oc rollout restart deployment my-app
```

---

## 🔐 **SECTION 5: SECURITY & RBAC ISSUES**

### **Issue 5.1: Permission Denied**

**Symptoms:**

```bash
$ oc create deployment my-app --image=nginx
Error from server (Forbidden): deployments.apps is forbidden
```

**Diagnosis:**

```bash
# Check current user
oc whoami

# Check permissions
oc auth can-i create deployments
oc auth can-i create pods

# Check role bindings
oc get rolebindings
```

**Solutions:**

**A. Insufficient Permissions**

```bash
# Problem: User lacks required permissions
# Solution: Grant appropriate role (as admin)
oc adm policy add-role-to-user edit developer -n myproject
```

**B. Wrong Project/Namespace**

```bash
# Problem: User has permissions in different project
# Solution: Switch to correct project
oc project myproject
```

---

### **Issue 5.2: SCC (Security Context Constraints) Violations**

**Symptoms:**

```bash
# Pod fails to start
# Events show: "unable to validate against any security context constraint"
```

**Diagnosis:**

```bash
# Check pod security context
oc get pod my-app-xxxxx-xxxxx -o yaml | grep -A 10 securityContext

# Check available SCCs
oc get scc
```

**Solutions:**

**A. Running as Root**

```bash
# Problem: Container tries to run as root
# Solution: Use non-root user in Dockerfile
# Add to Dockerfile:
USER 1001

# Or grant anyuid SCC (not recommended for production)
oc adm policy add-scc-to-user anyuid -z default
```

**B. Privileged Container**

```bash
# Problem: Container needs privileged access
# Solution: Grant privileged SCC (use carefully)
oc adm policy add-scc-to-user privileged -z default
```

---

## 🛠️ **SECTION 6: BUILD & DEPLOYMENT ISSUES**

### **Issue 6.1: Build Fails**

**Symptoms:**

```bash
$ oc start-build my-app
# Build fails with error
```

**Diagnosis:**

```bash
# Check build logs
oc logs -f bc/my-app

# Check build status
oc get builds

# Describe build
oc describe build my-app-1
```

**Common Solutions:**

**A. Build Timeout**

```bash
# Problem: Build takes too long
# Solution: Increase timeout
oc patch bc/my-app -p '{"spec":{"completionDeadlineSeconds":1800}}'
```

**B. Insufficient Resources**

```bash
# Problem: Build pod OOMKilled
# Solution: Increase build resources
oc patch bc/my-app -p '
{
  "spec": {
    "resources": {
      "limits": {
        "memory": "2Gi",
        "cpu": "1"
      }
    }
  }
}'
```

---

## 📊 **SECTION 7: DEBUGGING TECHNIQUES**

### **7.1 Interactive Debugging**

```bash
# Get shell in running pod
oc rsh my-app-xxxxx-xxxxx

# Run debug container
oc debug pod/my-app-xxxxx-xxxxx

# Debug with different image
oc debug pod/my-app-xxxxx-xxxxx --image=busybox

# Debug node
oc debug node/<node-name>
```

### **7.2 Log Analysis**

```bash
# View logs
oc logs my-app-xxxxx-xxxxx

# Follow logs
oc logs -f my-app-xxxxx-xxxxx

# Previous container logs
oc logs my-app-xxxxx-xxxxx --previous

# Logs from all pods
oc logs -l app=my-app --all-containers=true

# Logs with timestamps
oc logs my-app-xxxxx-xxxxx --timestamps

# Last N lines
oc logs my-app-xxxxx-xxxxx --tail=100
```

### **7.3 Port Forwarding**

```bash
# Forward pod port to local
oc port-forward my-app-xxxxx-xxxxx 8080:8080

# Forward service port
oc port-forward service/my-app 8080:80

# Now access at http://localhost:8080
```

### **7.4 Resource Inspection**

```bash
# Get resource as YAML
oc get pod my-app-xxxxx-xxxxx -o yaml

# Get specific field
oc get pod my-app-xxxxx-xxxxx -o jsonpath='{.status.phase}'

# Watch resources
oc get pods -w

# Describe resource
oc describe pod my-app-xxxxx-xxxxx
```

---

## ✅ **PREVENTION BEST PRACTICES**

### **1. Resource Management**

```bash
# Always set resource requests and limits
oc set resources deployment my-app \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=500m,memory=512Mi
```

### **2. Health Checks**

```bash
# Configure liveness and readiness probes
oc set probe deployment my-app \
  --liveness --get-url=http://:8080/health \
  --initial-delay-seconds=30 \
  --period-seconds=10

oc set probe deployment my-app \
  --readiness --get-url=http://:8080/ready \
  --initial-delay-seconds=5 \
  --period-seconds=5
```

### **3. Logging**

```bash
# Use structured logging in applications
# Log to stdout/stderr (not files)
# Include correlation IDs
```

### **4. Monitoring**

```bash
# Set up monitoring and alerts
# Monitor resource usage
# Track error rates
# Set up dashboards
```

### **5. Testing**

```bash
# Test in staging before production
# Load test applications
# Test failure scenarios
# Verify rollback procedures
```

---

## 🎯 **QUICK REFERENCE CARD**

### **Pod Issues:**

```bash
Pending → Check resources, node selector, PVC
CrashLoopBackOff → Check logs, env vars, probes
ImagePullBackOff → Check image name, credentials
Not Ready → Check readiness probe, logs
```

### **Network Issues:**

```bash
Can't access → Check route, service, endpoints
Service-to-service fails → Check DNS, network policy
```

### **Storage Issues:**

```bash
PVC Pending → Check PV availability, storage class
Can't mount → Check PVC status, access mode
```

### **Performance Issues:**

```bash
Slow → Check resources, scale up, check logs
OOMKilled → Increase memory, fix memory leak
```

---

## 📚 **ADDITIONAL RESOURCES**

- **OpenShift Docs:** <https://docs.openshift.com/container-platform/latest/support/troubleshooting/troubleshooting-installations.html>
- **Kubernetes Troubleshooting:** <https://kubernetes.io/docs/tasks/debug/>
- **Community Forums:** <https://community.openshift.com>

---

**Remember: Most issues can be solved by checking logs, events, and resource status! 🔍**

**Keep this guide handy for quick reference! 📖**
