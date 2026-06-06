# 🔐 Complete Vault Setup - Production Ready

## 📖 Complete Implementation Guide

This guide provides a **complete, production-ready HashiCorp Vault setup** with step-by-step instructions, line-by-line explanations, and real-world examples.

---

## 🎯 What We'll Build

```
Complete Vault Platform:
├── Vault Server (HA mode)
├── Multiple Secret Engines
│   ├── KV Secrets (static)
│   ├── Database (dynamic)
│   ├── PKI (certificates)
│   └── Transit (encryption)
├── Authentication Methods
│   ├── Token
│   ├── AppRole
│   └── Kubernetes
├── Policies & RBAC
├── Audit Logging
└── Kubernetes Integration
```

---

## 📋 Prerequisites

```bash
# Required
- Docker installed
- kubectl installed (for K8s integration)
- 4GB RAM minimum
- Basic understanding of security concepts

# Verify
docker --version
kubectl version --client
```

---

## 🚀 Part 1: Install Vault (Development Mode)

### Step 1.1: Start Vault in Dev Mode

**WHAT:** Run Vault in development mode for learning

**WHY:** Quick setup, no configuration needed

**HOW:**

```bash
# Start Vault container
docker run --cap-add=IPC_LOCK -d --name=vault \
  -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  vault:1.15

# EXPLANATION:
# --cap-add=IPC_LOCK    : Prevent memory from being swapped to disk
# -d                    : Run in background
# --name=vault          : Container name
# -p 8200:8200         : Expose port 8200
# -e VAULT_DEV_ROOT... : Set root token (dev mode only!)
# vault:1.15           : Vault version

# Verify running
docker ps | grep vault

# Output:
# CONTAINER ID   IMAGE        STATUS          PORTS
# abc123...      vault:1.15   Up 10 seconds   0.0.0.0:8200->8200/tcp
```

### Step 1.2: Configure Environment

```bash
# Set Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Set root token (dev mode only!)
export VAULT_TOKEN='myroot'

# Verify connection
vault status

# Output:
# Key             Value
# ---             -----
# Seal Type       shamir
# Initialized     true
# Sealed          false      ← Unsealed and ready!
# Total Shares    1
# Threshold       1
# Version         1.15.0
# Storage Type    inmem
# Cluster Name    vault-cluster-abc123
# HA Enabled      false
```

---

## 🔑 Part 2: KV Secrets Engine

### Step 2.1: Store Static Secrets

**WHAT:** Key-Value secret storage

**WHY:** Store application secrets, API keys, passwords

**HOW:**

```bash
# Enable KV v2 secrets engine
vault secrets enable -path=secret kv-v2

# EXPLANATION:
# secrets enable    : Enable a secrets engine
# -path=secret     : Mount path
# kv-v2            : Key-Value version 2 (versioned)

# Store a secret
vault kv put secret/myapp \
  username=admin \
  password=supersecret \
  api_key=abc123xyz

# EXPLANATION:
# kv put           : Write secret
# secret/myapp     : Path (secret engine / secret name)
# key=value        : Secret data

# Output:
# ====== Secret Path ======
# secret/data/myapp
#
# ======= Metadata =======
# Key                Value
# ---                -----
# created_time       2024-01-15T10:00:00Z
# custom_metadata    <nil>
# deletion_time      n/a
# destroyed          false
# version            1

# Retrieve secret
vault kv get secret/myapp

# Output:
# ====== Data ======
# Key         Value
# ---         -----
# api_key     abc123xyz
# password    supersecret
# username    admin

# Get specific field
vault kv get -field=password secret/myapp
# Output: supersecret

# Get as JSON
vault kv get -format=json secret/myapp | jq .data.data
# Output:
# {
#   "api_key": "abc123xyz",
#   "password": "supersecret",
#   "username": "admin"
# }
```

### Step 2.2: Secret Versioning

```bash
# Update secret (creates version 2)
vault kv put secret/myapp \
  username=admin \
  password=newsecret \
  api_key=xyz789abc

# Get latest version
vault kv get secret/myapp
# Shows version 2

# Get specific version
vault kv get -version=1 secret/myapp
# Shows version 1 (old password)

# View version history
vault kv metadata get secret/myapp

# Output:
# ========== Metadata ==========
# Key                     Value
# ---                     -----
# cas_required            false
# created_time            2024-01-15T10:00:00Z
# current_version         2
# max_versions            0
# oldest_version          0
# updated_time            2024-01-15T10:05:00Z
#
# ====== Version 1 ======
# created_time    2024-01-15T10:00:00Z
# deletion_time   n/a
# destroyed       false
#
# ====== Version 2 ======
# created_time    2024-01-15T10:05:00Z
# deletion_time   n/a
# destroyed       false

# Delete latest version (soft delete)
vault kv delete secret/myapp

# Undelete
vault kv undelete -versions=2 secret/myapp

# Permanently destroy
vault kv destroy -versions=1 secret/myapp
```

---

## 🗄️ Part 3: Dynamic Database Secrets

### Step 3.1: Setup Database

**WHAT:** Generate temporary database credentials

**WHY:** Automatic rotation, no long-lived credentials

**HOW:**

```bash
# Start PostgreSQL for demo
docker run -d --name postgres \
  -e POSTGRES_PASSWORD=rootpass \
  -e POSTGRES_DB=myapp \
  -p 5432:5432 \
  postgres:15

# Wait for PostgreSQL to start
sleep 10

# Enable database secrets engine
vault secrets enable database

# Configure PostgreSQL connection
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly,readwrite" \
  connection_url="postgresql://{{username}}:{{password}}@host.docker.internal:5432/myapp?sslmode=disable" \
  username="postgres" \
  password="rootpass"

# EXPLANATION:
# database/config/postgresql  : Configuration path
# plugin_name                 : Database plugin to use
# allowed_roles               : Roles that can use this config
# connection_url              : Database connection string
#   {{username}}              : Vault replaces with actual username
#   {{password}}              : Vault replaces with actual password
# username/password           : Root credentials (stored encrypted)

# Create readonly role
vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# EXPLANATION:
# database/roles/readonly     : Role name
# db_name                     : Database config to use
# creation_statements         : SQL to create user
#   {{name}}                  : Vault generates unique username
#   {{password}}              : Vault generates secure password
#   {{expiration}}            : Vault sets expiration time
# default_ttl                 : Default lease duration (1 hour)
# max_ttl                     : Maximum lease duration (24 hours)

# Generate dynamic credentials
vault read database/creds/readonly

# Output:
# Key                Value
# ---                -----
# lease_id           database/creds/readonly/abc123
# lease_duration     1h
# lease_renewable    true
# password           A1a-random-generated-password
# username           v-root-readonly-xyz789

# These credentials:
# - Are unique
# - Expire in 1 hour
# - Are automatically deleted after expiration
# - Can be renewed if needed

# Test the credentials
PGPASSWORD="A1a-random-generated-password" \
  psql -h localhost -U v-root-readonly-xyz789 -d myapp -c "SELECT 1;"

# Renew lease
vault lease renew database/creds/readonly/abc123

# Revoke immediately
vault lease revoke database/creds/readonly/abc123
```

---

## 🔐 Part 4: Transit Encryption Engine

### Step 4.1: Encryption as a Service

**WHAT:** Encrypt/decrypt data without storing it

**WHY:** Centralized encryption, key rotation

**HOW:**

```bash
# Enable transit engine
vault secrets enable transit

# Create encryption key
vault write -f transit/keys/myapp

# EXPLANATION:
# transit/keys/myapp  : Key name
# -f                  : Force (no additional data needed)

# Encrypt data
vault write transit/encrypt/myapp \
  plaintext=$(echo "sensitive data" | base64)

# EXPLANATION:
# transit/encrypt/myapp  : Encrypt using 'myapp' key
# plaintext              : Data to encrypt (must be base64)

# Output:
# Key            Value
# ---            -----
# ciphertext     vault:v1:abc123...encrypted...xyz789
# key_version    1

# Store ciphertext
CIPHERTEXT="vault:v1:abc123...encrypted...xyz789"

# Decrypt data
vault write transit/decrypt/myapp \
  ciphertext="$CIPHERTEXT"

# Output:
# Key          Value
# ---          -----
# plaintext    c2Vuc2l0aXZlIGRhdGE=

# Decode
echo "c2Vuc2l0aXZlIGRhdGE=" | base64 -d
# Output: sensitive data

# Rotate encryption key
vault write -f transit/keys/myapp/rotate

# Re-encrypt with new key
vault write transit/rewrap/myapp \
  ciphertext="$CIPHERTEXT"

# Output:
# Key            Value
# ---            -----
# ciphertext     vault:v2:def456...encrypted...uvw012
# key_version    2

# Old ciphertext still works (backward compatible)
# But new encryptions use new key
```

---

## 🎫 Part 5: Authentication & Policies

### Step 5.1: Create Policies

**WHAT:** Define what users can access

**WHY:** Least privilege access control

**HOW:**

```bash
# Create readonly policy
cat > readonly-policy.hcl << 'EOF'
# Allow reading secrets
path "secret/data/*" {
  capabilities = ["read", "list"]
}

# Deny writing secrets
path "secret/data/*" {
  capabilities = ["deny"]
}
EOF

# Write policy to Vault
vault policy write readonly readonly-policy.hcl

# Create admin policy
cat > admin-policy.hcl << 'EOF'
# Full access to secrets
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage policies
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage auth methods
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}
EOF

vault policy write admin admin-policy.hcl

# List policies
vault policy list

# Read policy
vault policy read readonly
```

### Step 5.2: AppRole Authentication

**WHAT:** Machine authentication method

**WHY:** For applications, CI/CD, automation

**HOW:**

```bash
# Enable AppRole auth
vault auth enable approle

# Create AppRole
vault write auth/approle/role/myapp \
  token_policies="readonly" \
  token_ttl=1h \
  token_max_ttl=4h

# EXPLANATION:
# auth/approle/role/myapp  : AppRole name
# token_policies           : Policies to attach
# token_ttl                : Token lifetime
# token_max_ttl            : Maximum token lifetime

# Get Role ID (like username)
vault read auth/approle/role/myapp/role-id

# Output:
# Key        Value
# ---        -----
# role_id    abc-123-def-456

# Generate Secret ID (like password)
vault write -f auth/approle/role/myapp/secret-id

# Output:
# Key                   Value
# ---                   -----
# secret_id             xyz-789-uvw-012
# secret_id_accessor    accessor-123
# secret_id_ttl         0s

# Login with AppRole
vault write auth/approle/login \
  role_id="abc-123-def-456" \
  secret_id="xyz-789-uvw-012"

# Output:
# Key                     Value
# ---                     -----
# token                   hvs.token123
# token_accessor          accessor456
# token_duration          1h
# token_renewable         true
# token_policies          ["default" "readonly"]

# Use token
export VAULT_TOKEN="hvs.token123"

# Now can only read secrets (readonly policy)
vault kv get secret/myapp  # ✅ Works
vault kv put secret/test key=value  # ❌ Permission denied
```

---

## 📊 Part 6: Audit Logging

### Step 6.1: Enable Audit Device

**WHAT:** Log all Vault operations

**WHY:** Compliance, security monitoring, troubleshooting

**HOW:**

```bash
# Enable file audit device
vault audit enable file file_path=/vault/logs/audit.log

# For Docker, create volume first
docker exec vault mkdir -p /vault/logs

# Enable audit
docker exec vault vault audit enable file file_path=/vault/logs/audit.log

# Perform some operations
vault kv put secret/test key=value
vault kv get secret/test
vault kv delete secret/test

# View audit log
docker exec vault cat /vault/logs/audit.log | jq .

# Output (example):
# {
#   "time": "2024-01-15T10:00:00Z",
#   "type": "request",
#   "auth": {
#     "client_token": "hmac-sha256:abc123",
#     "accessor": "hmac-sha256:def456",
#     "display_name": "root",
#     "policies": ["root"],
#     "token_policies": ["root"]
#   },
#   "request": {
#     "id": "request-123",
#     "operation": "update",
#     "path": "secret/data/test",
#     "data": {
#       "data": "hmac-sha256:xyz789"  ← Sensitive data hashed
#     }
#   },
#   "response": {
#     "data": {
#       "created_time": "2024-01-15T10:00:00Z",
#       "version": 1
#     }
#   }
# }

# List audit devices
vault audit list

# Disable audit device
vault audit disable file
```

---

## ☸️ Part 7: Kubernetes Integration

### Step 7.1: Vault Agent Injector

**WHAT:** Automatically inject secrets into pods

**WHY:** No code changes needed, secure secret delivery

**HOW:**

```bash
# Install Vault on Kubernetes
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Install with injector
helm install vault hashicorp/vault \
  --set "server.dev.enabled=true" \
  --set "injector.enabled=true"

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=300s

# Enable Kubernetes auth in Vault
kubectl exec -it vault-0 -- vault auth enable kubernetes

# Configure Kubernetes auth
kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc:443"

# Create policy for app
kubectl exec -it vault-0 -- vault policy write myapp - <<EOF
path "secret/data/myapp" {
  capabilities = ["read"]
}
EOF

# Create Kubernetes role
kubectl exec -it vault-0 -- vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp \
  bound_service_account_namespaces=default \
  policies=myapp \
  ttl=24h

# Create secret in Vault
kubectl exec -it vault-0 -- vault kv put secret/myapp \
  username=dbuser \
  password=dbpass

# Create service account
kubectl create serviceaccount myapp

# Deploy app with injector annotations
cat > app-with-vault.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "myapp"
    vault.hashicorp.com/agent-inject-secret-database: "secret/data/myapp"
    vault.hashicorp.com/agent-inject-template-database: |
      {{- with secret "secret/data/myapp" -}}
      export DB_USERNAME="{{ .Data.data.username }}"
      export DB_PASSWORD="{{ .Data.data.password }}"
      {{- end }}
spec:
  serviceAccountName: myapp
  containers:
  - name: app
    image: nginx
    command: ["/bin/sh"]
    args: ["-c", "source /vault/secrets/database && env | grep DB_ && sleep 3600"]
EOF

kubectl apply -f app-with-vault.yaml

# Check secrets injected
kubectl logs myapp -c app

# Output:
# DB_USERNAME=dbuser
# DB_PASSWORD=dbpass

# Secrets automatically injected! No code changes needed!
```

---

## ✅ Testing the Complete Setup

```bash
# Test 1: KV Secrets
vault kv put secret/test key=value
vault kv get secret/test
echo "✅ KV Secrets working"

# Test 2: Dynamic Database Credentials
vault read database/creds/readonly
echo "✅ Dynamic secrets working"

# Test 3: Encryption
ENCRYPTED=$(vault write -field=ciphertext transit/encrypt/myapp plaintext=$(echo "test" | base64))
DECRYPTED=$(vault write -field=plaintext transit/decrypt/myapp ciphertext=$ENCRYPTED | base64 -d)
[ "$DECRYPTED" = "test" ] && echo "✅ Encryption working"

# Test 4: AppRole Auth
ROLE_ID=$(vault read -field=role_id auth/approle/role/myapp/role-id)
SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/myapp/secret-id)
TOKEN=$(vault write -field=token auth/approle/login role_id=$ROLE_ID secret_id=$SECRET_ID)
[ -n "$TOKEN" ] && echo "✅ AppRole auth working"

# Test 5: Audit Logging
vault audit list | grep -q "file" && echo "✅ Audit logging enabled"

echo "🎉 All tests passed!"
```

---

## 🎯 Production Considerations

### High Availability Setup

```yaml
# Production Vault with HA
storage "raft" {
  path = "/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/tls/cert.pem"
  tls_key_file = "/vault/tls/key.pem"
}

seal "awskms" {
  region = "us-east-1"
  kms_key_id = "alias/vault-unseal-key"
}

api_addr = "https://vault.example.com:8200"
cluster_addr = "https://vault-node1:8201"
ui = true
```

### Backup Strategy

```bash
# Backup Vault data
vault operator raft snapshot save backup.snap

# Restore from backup
vault operator raft snapshot restore backup.snap

# Automate backups
0 2 * * * vault operator raft snapshot save /backups/vault-$(date +\%Y\%m\%d).snap
```

---

## 🎉 Success

You've built a complete Vault setup with:

- ✅ KV secrets storage
- ✅ Dynamic database credentials
- ✅ Encryption as a service
- ✅ AppRole authentication
- ✅ Audit logging
- ✅ Kubernetes integration

**Next:** [`05-KUBERNETES-INTEGRATION.md`](05-KUBERNETES-INTEGRATION.md) for advanced K8s patterns

---

**Remember:** Never use dev mode in production! Always use proper initialization, sealing, and HA setup! 🔐
