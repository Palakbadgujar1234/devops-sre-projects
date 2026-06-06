# 🛡️ Security Fundamentals for DevOps

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [CIA Triad](#cia-triad)
3. [Authentication vs Authorization](#authentication-vs-authorization)
4. [Encryption Basics](#encryption-basics)
5. [Common Security Threats](#common-security-threats)
6. [Security Best Practices](#security-best-practices)
7. [DevSecOps Culture](#devsecops-culture)

---

## 🎯 Introduction

### WHAT is Security?

**Security** is protecting systems, data, and resources from unauthorized access, use, disclosure, disruption, modification, or destruction.

### WHY Security Matters?

```
Real-World Impact:

2023 Data Breaches:
- Average cost: $4.45 million
- Average time to identify: 277 days
- Average time to contain: 70 days

Common Causes:
- 80% involve compromised credentials
- 45% cloud-based
- 82% involve human element
```

### HOW to Think About Security?

**Security Mindset:**

```
1. Assume breach will happen
2. Defense in depth (layers)
3. Least privilege principle
4. Zero trust architecture
5. Continuous monitoring
```

---

## 🔒 CIA Triad

### The Foundation of Security

```
        Confidentiality
              /\
             /  \
            /    \
           /      \
          /        \
         /          \
        /            \
       /______________\
  Integrity      Availability
```

### 1. Confidentiality

**WHAT:** Ensuring information is accessible only to authorized parties

**WHY:** Protect sensitive data from unauthorized disclosure

**HOW:**

```yaml
Methods:
- Encryption (at rest and in transit)
- Access controls
- Authentication
- Data classification

Example:
# Encrypt sensitive data
openssl enc -aes-256-cbc -salt -in secret.txt -out secret.enc

# Only authorized users can decrypt
openssl enc -d -aes-256-cbc -in secret.enc -out secret.txt
```

**Real-World Example:**

```
Healthcare:
- Patient records encrypted
- Only doctors/nurses with credentials can access
- Audit logs track all access
- HIPAA compliance
```

### 2. Integrity

**WHAT:** Ensuring data hasn't been tampered with

**WHY:** Trust that data is accurate and unmodified

**HOW:**

```yaml
Methods:
- Checksums/Hashes
- Digital signatures
- Version control
- Audit logs

Example:
# Create checksum
sha256sum file.txt > file.txt.sha256

# Verify integrity
sha256sum -c file.txt.sha256
# Output: file.txt: OK
```

**Real-World Example:**

```
Software Updates:
- Download: app-v1.0.tar.gz
- Verify: sha256sum matches published hash
- If match: Safe to install
- If mismatch: File corrupted or tampered!
```

### 3. Availability

**WHAT:** Ensuring systems and data are accessible when needed

**WHY:** Business continuity and user satisfaction

**HOW:**

```yaml
Methods:
- Redundancy (multiple servers)
- Load balancing
- Backups
- DDoS protection
- Disaster recovery

Example:
# High availability setup
Frontend (3 replicas) → Load Balancer
Backend (3 replicas) → Database (Primary + Replica)
```

**Real-World Example:**

```
E-commerce Site:
- Multiple servers across regions
- If one fails, others handle traffic
- 99.9% uptime guarantee
- Revenue protected
```

---

## 🔑 Authentication vs Authorization

### Authentication (AuthN)

**WHAT:** Verifying WHO you are

**WHY:** Ensure users are who they claim to be

**HOW:**

```yaml
Methods:
1. Something you know (password)
2. Something you have (token, phone)
3. Something you are (biometric)

Multi-Factor Authentication (MFA):
- Combine 2+ methods
- Much more secure
```

**Example:**

```bash
# Login with username/password
Username: alice
Password: ********

# Then MFA code from phone
MFA Code: 123456

# Authenticated! ✅
```

### Authorization (AuthZ)

**WHAT:** Determining WHAT you can do

**WHY:** Control access to resources

**HOW:**

```yaml
Models:
1. Role-Based Access Control (RBAC)
   - Users → Roles → Permissions
   
2. Attribute-Based Access Control (ABAC)
   - Based on attributes (time, location, etc.)

3. Policy-Based Access Control (PBAC)
   - Complex rules and policies
```

**Example:**

```yaml
# RBAC Example
Users:
  alice:
    role: admin
    permissions:
      - read
      - write
      - delete
  
  bob:
    role: developer
    permissions:
      - read
      - write
  
  charlie:
    role: viewer
    permissions:
      - read

# Alice can delete, Bob can't
```

### Real-World Flow

```
1. Authentication: "Who are you?"
   User: "I'm Alice"
   System: "Prove it" (password + MFA)
   User: Provides credentials
   System: "Verified! You are Alice" ✅

2. Authorization: "What can you do?"
   Alice: "I want to delete this file"
   System: Checks Alice's permissions
   System: "Alice is admin, has delete permission" ✅
   System: "Delete allowed"
```

---

## 🔐 Encryption Basics

### Symmetric Encryption

**WHAT:** Same key for encryption and decryption

**WHY:** Fast, efficient for large data

**HOW:**

```bash
# Encrypt
openssl enc -aes-256-cbc -salt \
  -in plaintext.txt \
  -out encrypted.bin \
  -k "secret-key"

# Decrypt
openssl enc -d -aes-256-cbc \
  -in encrypted.bin \
  -out plaintext.txt \
  -k "secret-key"
```

**Pros:**

- ✅ Fast
- ✅ Efficient

**Cons:**

- ⚠️ Key distribution problem
- ⚠️ If key compromised, all data exposed

### Asymmetric Encryption

**WHAT:** Public key encrypts, private key decrypts

**WHY:** Solve key distribution problem

**HOW:**

```bash
# Generate key pair
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem

# Encrypt with public key
openssl rsautl -encrypt \
  -pubin -inkey public.pem \
  -in plaintext.txt \
  -out encrypted.bin

# Decrypt with private key
openssl rsautl -decrypt \
  -inkey private.pem \
  -in encrypted.bin \
  -out plaintext.txt
```

**Pros:**

- ✅ Secure key exchange
- ✅ Digital signatures

**Cons:**

- ⚠️ Slower than symmetric
- ⚠️ Limited data size

### Hashing

**WHAT:** One-way function, cannot be reversed

**WHY:** Verify integrity, store passwords

**HOW:**

```bash
# Create hash
echo "password123" | sha256sum
# Output: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92

# Same input = same hash (deterministic)
echo "password123" | sha256sum
# Output: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92

# Different input = different hash
echo "password124" | sha256sum
# Output: completely different hash
```

**Use Cases:**

```yaml
Password Storage:
- Never store plain passwords
- Store hash instead
- Compare hashes during login

File Integrity:
- Create hash of file
- Distribute hash separately
- Users verify file hasn't changed

Digital Signatures:
- Hash document
- Encrypt hash with private key
- Others verify with public key
```

---

## ⚠️ Common Security Threats

### 1. Credential Compromise

**WHAT:** Stolen usernames/passwords

**HOW IT HAPPENS:**

```
- Phishing emails
- Weak passwords
- Password reuse
- Unencrypted storage
- Keyloggers
```

**PREVENTION:**

```yaml
✅ Use strong, unique passwords
✅ Enable MFA
✅ Use password manager
✅ Never store passwords in code
✅ Rotate credentials regularly
```

### 2. Injection Attacks

**WHAT:** Malicious code injected into application

**EXAMPLE - SQL Injection:**

```python
# ❌ VULNERABLE CODE
username = request.get('username')
query = f"SELECT * FROM users WHERE username = '{username}'"
# Attacker inputs: ' OR '1'='1
# Query becomes: SELECT * FROM users WHERE username = '' OR '1'='1'
# Returns ALL users!

# ✅ SAFE CODE
username = request.get('username')
query = "SELECT * FROM users WHERE username = ?"
cursor.execute(query, (username,))  # Parameterized query
```

**PREVENTION:**

```yaml
✅ Use parameterized queries
✅ Input validation
✅ Escape special characters
✅ Principle of least privilege
```

### 3. Man-in-the-Middle (MITM)

**WHAT:** Attacker intercepts communication

**HOW IT HAPPENS:**

```
User → [Attacker] → Server

Attacker can:
- Read all data
- Modify data
- Steal credentials
```

**PREVENTION:**

```yaml
✅ Use HTTPS/TLS
✅ Certificate validation
✅ VPN for sensitive connections
✅ Avoid public WiFi for sensitive operations
```

### 4. Denial of Service (DoS)

**WHAT:** Overwhelm system to make it unavailable

**TYPES:**

```yaml
Volume-Based:
- Flood with traffic
- Consume bandwidth

Protocol-Based:
- Exploit protocol weaknesses
- SYN flood

Application-Based:
- Target application logic
- Expensive operations
```

**PREVENTION:**

```yaml
✅ Rate limiting
✅ Load balancing
✅ CDN usage
✅ DDoS protection services
✅ Monitoring and alerting
```

### 5. Privilege Escalation

**WHAT:** Gain higher privileges than authorized

**EXAMPLE:**

```bash
# User should only read files
# But finds vulnerability to execute commands
# Gains root access
# Can now do anything!
```

**PREVENTION:**

```yaml
✅ Principle of least privilege
✅ Regular security audits
✅ Patch management
✅ Input validation
✅ Secure coding practices
```

---

## 🏆 Security Best Practices

### 1. Principle of Least Privilege

**WHAT:** Give minimum permissions needed

**WHY:** Limit damage if compromised

**HOW:**

```yaml
# ❌ BAD: Everyone is admin
users:
  alice: admin
  bob: admin
  charlie: admin

# ✅ GOOD: Minimal permissions
users:
  alice: admin        # Needs admin
  bob: developer      # Needs read/write
  charlie: viewer     # Needs read only
```

### 2. Defense in Depth

**WHAT:** Multiple layers of security

**WHY:** If one layer fails, others protect

**LAYERS:**

```
Layer 1: Network (Firewall)
Layer 2: Host (OS hardening)
Layer 3: Application (Input validation)
Layer 4: Data (Encryption)
Layer 5: User (MFA)
```

### 3. Zero Trust

**WHAT:** Never trust, always verify

**WHY:** Assume breach has occurred

**PRINCIPLES:**

```yaml
1. Verify explicitly
   - Always authenticate
   - Always authorize

2. Least privilege access
   - Just-in-time access
   - Just-enough access

3. Assume breach
   - Minimize blast radius
   - Segment access
   - Verify end-to-end
```

### 4. Security by Design

**WHAT:** Build security from the start

**WHY:** Cheaper and more effective

**APPROACH:**

```yaml
Planning:
- Threat modeling
- Security requirements

Development:
- Secure coding practices
- Code reviews
- Static analysis

Testing:
- Security testing
- Penetration testing
- Vulnerability scanning

Deployment:
- Secure configuration
- Monitoring
- Incident response
```

### 5. Regular Updates

**WHAT:** Keep systems patched

**WHY:** Fix known vulnerabilities

**PROCESS:**

```bash
# Check for updates
apt update

# Review updates
apt list --upgradable

# Apply updates
apt upgrade

# Reboot if needed
reboot
```

---

## 🔄 DevSecOps Culture

### What is DevSecOps?

**Traditional:**

```
Dev → Ops → Security (at the end)

Problems:
- Security as afterthought
- Slow feedback
- Expensive fixes
```

**DevSecOps:**

```
Dev + Security + Ops (integrated)

Benefits:
- Security from start
- Fast feedback
- Cheaper fixes
- Shared responsibility
```

### Shift Left Security

**WHAT:** Move security earlier in development

**WHY:** Find issues sooner, fix cheaper

**HOW:**

```yaml
Code:
- Secure coding training
- IDE security plugins
- Pre-commit hooks

Build:
- SAST (Static Analysis)
- Dependency scanning
- License checking

Test:
- DAST (Dynamic Analysis)
- Penetration testing
- Security test cases

Deploy:
- Container scanning
- Infrastructure scanning
- Configuration validation

Run:
- Runtime protection
- Monitoring
- Incident response
```

### Security as Code

**WHAT:** Automate security controls

**WHY:** Consistent, repeatable, auditable

**EXAMPLES:**

```yaml
# Policy as Code
policy "require-mfa" {
  rule = user.mfa_enabled == true
}

# Infrastructure as Code with security
resource "aws_s3_bucket" "data" {
  bucket = "my-data"
  
  # Security: Encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  # Security: Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

## 🎯 Key Takeaways

### Remember These Points

1. **CIA Triad**: Confidentiality, Integrity, Availability
2. **Authentication**: WHO you are
3. **Authorization**: WHAT you can do
4. **Encryption**: Protect data at rest and in transit
5. **Least Privilege**: Minimum permissions needed
6. **Defense in Depth**: Multiple security layers
7. **Zero Trust**: Never trust, always verify
8. **DevSecOps**: Security integrated from start

### Security Checklist

```yaml
✅ Use strong authentication (MFA)
✅ Encrypt sensitive data
✅ Apply least privilege
✅ Keep systems updated
✅ Monitor and log everything
✅ Have incident response plan
✅ Regular security audits
✅ Security training for team
✅ Automate security checks
✅ Test disaster recovery
```

---

## 🚀 Next Steps

Now that you understand security fundamentals, let's learn about HashiCorp Vault!

**Next Guide:** [`02-VAULT-INSTALLATION.md`](02-VAULT-INSTALLATION.md)

You'll learn:

- What is Vault
- How to install Vault
- Basic Vault operations
- Production setup

---

**Remember:** Security is everyone's responsibility! It's not just the security team's job - it's yours too! 🛡️

**Pro Tip:** Think like an attacker. How would you break your own system? Then fix those vulnerabilities! 🔐
