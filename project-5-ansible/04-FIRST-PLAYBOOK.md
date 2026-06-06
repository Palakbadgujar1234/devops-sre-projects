# 🚀 Your First Ansible Playbook

## 📖 WHAT: What Are We Building?

We're going to write and run your first Ansible playbook! You'll learn by doing:

1. Create a simple playbook
2. Run it on localhost
3. Understand the output
4. Build progressively complex examples

## 🎯 WHY: Why Start With Localhost?

- ✅ No need for remote servers
- ✅ Safe to experiment
- ✅ Instant feedback
- ✅ Learn without risk

## 🏗️ Project Setup

### Step 1: Create Project Directory

```bash
# Create project directory
mkdir ~/ansible-practice
cd ~/ansible-practice

# Create subdirectories
mkdir playbooks inventory

# WHAT: Organized structure for Ansible files
# WHY: Keep everything organized
# HOW: Standard Ansible project layout
```

### Step 2: Create Inventory File

```bash
# Create inventory file
cat > inventory/hosts << 'EOF'
[local]
localhost ansible_connection=local
EOF

# WHAT: Defines localhost as a target
# WHY: Ansible needs to know where to run
# ansible_connection=local: Don't use SSH, run locally
```

**Verify inventory**:

```bash
ansible -i inventory/hosts local -m ping

# Expected output:
# localhost | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }

# WHAT: Tests connection to localhost
# WHY: Verify setup is correct
# -i inventory/hosts: Use this inventory file
# local: Target the 'local' group
# -m ping: Use ping module
```

---

## 📝 Playbook 1: Hello World

### Create the Playbook

```bash
cat > playbooks/01-hello-world.yml << 'EOF'
---
# My First Ansible Playbook
# Purpose: Print a simple message

- name: Hello World Playbook
  hosts: local
  tasks:
    - name: Print hello message
      debug:
        msg: "Hello from Ansible! 🎉"
EOF
```

**Understanding each line**:

```yaml
---                                    # YAML document start
# My First Ansible Playbook           # Comment (ignored by Ansible)

- name: Hello World Playbook           # Play name (descriptive)
  hosts: local                         # Run on 'local' group from inventory
  tasks:                               # List of tasks to execute
    - name: Print hello message        # Task name (descriptive)
      debug:                           # Module to use (debug = print)
        msg: "Hello from Ansible! 🎉"  # Message to print
```

### Run the Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/01-hello-world.yml

# WHAT: Executes the playbook
# WHY: Run our automation
# -i inventory/hosts: Use this inventory
# playbooks/01-hello-world.yml: Playbook to run
```

**Expected Output**:

```
PLAY [Hello World Playbook] ****************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Print hello message] *****************************************************
ok: [localhost] => {
    "msg": "Hello from Ansible! 🎉"
}

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0
```

**Understanding the output**:

```
PLAY [Hello World Playbook]     # Starting the play
TASK [Gathering Facts]          # Ansible collects system info (automatic)
TASK [Print hello message]      # Our task running
PLAY RECAP                      # Summary of results
  ok=2                          # 2 tasks succeeded
  changed=0                     # 0 tasks made changes
  failed=0                      # 0 tasks failed
```

---

## 📝 Playbook 2: System Information

### Create the Playbook

```yaml
---
# File: playbooks/02-system-info.yml
# Purpose: Display system information using facts

- name: Display System Information
  hosts: local
  tasks:
    - name: Show operating system
      debug:
        msg: "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
    
    - name: Show hostname
      debug:
        msg: "Hostname: {{ ansible_hostname }}"
    
    - name: Show IP address
      debug:
        msg: "IP: {{ ansible_default_ipv4.address }}"
    
    - name: Show CPU cores
      debug:
        msg: "CPU Cores: {{ ansible_processor_cores }}"
    
    - name: Show total memory
      debug:
        msg: "Memory: {{ ansible_memtotal_mb }} MB"
```

**Understanding variables**:

```yaml
{{ ansible_distribution }}        # WHAT: OS name (Ubuntu, CentOS, etc.)
                                  # WHY: Ansible collects this automatically
                                  # HOW: Facts gathered at start

{{ ansible_default_ipv4.address }} # WHAT: IP address
                                   # WHY: Nested variable (dictionary)
                                   # HOW: Use dot notation
```

### Run It

```bash
ansible-playbook -i inventory/hosts playbooks/02-system-info.yml
```

**You'll see**:

- Your operating system
- Computer hostname
- IP address
- Number of CPU cores
- Total RAM

---

## 📝 Playbook 3: File Management

### Create the Playbook

```yaml
---
# File: playbooks/03-file-management.yml
# Purpose: Create files and directories

- name: File Management
  hosts: local
  tasks:
    - name: Create a directory
      file:
        path: /tmp/ansible-test
        state: directory
        mode: '0755'
    
    - name: Create a file
      file:
        path: /tmp/ansible-test/hello.txt
        state: touch
        mode: '0644'
    
    - name: Write content to file
      copy:
        content: |
          Hello from Ansible!
          This file was created automatically.
          Date: {{ ansible_date_time.date }}
        dest: /tmp/ansible-test/hello.txt
    
    - name: Verify file exists
      stat:
        path: /tmp/ansible-test/hello.txt
      register: file_info
    
    - name: Show file information
      debug:
        msg: "File exists: {{ file_info.stat.exists }}, Size: {{ file_info.stat.size }} bytes"
```

**New concepts explained**:

```yaml
state: directory                   # WHAT: Ensure it's a directory
                                  # WHY: Create if doesn't exist
                                  # HOW: Ansible checks and creates

mode: '0755'                      # WHAT: File permissions
                                  # WHY: Control who can read/write
                                  # HOW: Unix permission format
                                  # 0755 = rwxr-xr-x

content: |                        # WHAT: Multi-line string
                                  # WHY: Write multiple lines
                                  # HOW: Pipe (|) for multi-line

register: file_info               # WHAT: Save task output to variable
                                  # WHY: Use result in next task
                                  # HOW: Creates variable 'file_info'

{{ file_info.stat.exists }}       # WHAT: Access registered variable
                                  # WHY: Use previous task's result
                                  # HOW: Dot notation for nested data
```

### Run and Verify

```bash
# Run playbook
ansible-playbook -i inventory/hosts playbooks/03-file-management.yml

# Verify files were created
ls -la /tmp/ansible-test/
cat /tmp/ansible-test/hello.txt

# WHAT: Check if files exist
# WHY: Verify playbook worked
# HOW: Standard Linux commands
```

---

## 📝 Playbook 4: Package Management

### Create the Playbook

```yaml
---
# File: playbooks/04-package-management.yml
# Purpose: Install and manage packages

- name: Package Management
  hosts: local
  become: yes                      # Run with sudo
  tasks:
    - name: Update apt cache (Debian/Ubuntu)
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"
    
    - name: Install packages
      package:
        name:
          - curl
          - wget
          - git
        state: present
    
    - name: Check if package is installed
      command: which curl
      register: curl_path
      changed_when: false           # Don't report as changed
    
    - name: Show curl location
      debug:
        msg: "curl is installed at: {{ curl_path.stdout }}"
```

**New concepts**:

```yaml
become: yes                        # WHAT: Run with sudo/root privileges
                                  # WHY: Installing packages needs root
                                  # HOW: Ansible uses sudo automatically

when: ansible_os_family == "Debian"  # WHAT: Conditional execution
                                     # WHY: Different OS need different commands
                                     # HOW: Only runs if condition is true

package:                          # WHAT: Generic package module
                                  # WHY: Works on any OS (apt, yum, etc.)
                                  # HOW: Ansible detects OS and uses right tool

name:                             # WHAT: List of packages
  - curl                          # WHY: Install multiple at once
  - wget                          # HOW: YAML list format
  - git

changed_when: false               # WHAT: Don't mark as changed
                                  # WHY: Just checking, not modifying
                                  # HOW: Override default behavior
```

### Run It

```bash
ansible-playbook -i inventory/hosts playbooks/04-package-management.yml

# WHAT: Installs packages
# WHY: Practice package management
# NOTE: Will ask for sudo password
```

---

## 📝 Playbook 5: Variables and Loops

### Create the Playbook

```yaml
---
# File: playbooks/05-variables-loops.yml
# Purpose: Use variables and loops

- name: Variables and Loops
  hosts: local
  vars:
    greeting: "Hello"
    users:
      - alice
      - bob
      - charlie
    packages:
      - name: curl
        description: "Command line tool for transferring data"
      - name: git
        description: "Version control system"
  
  tasks:
    - name: Print greeting
      debug:
        msg: "{{ greeting }}, World!"
    
    - name: Create users (simulation)
      debug:
        msg: "Would create user: {{ item }}"
      loop: "{{ users }}"
    
    - name: Show package info
      debug:
        msg: "Package: {{ item.name }} - {{ item.description }}"
      loop: "{{ packages }}"
    
    - name: Use loop with index
      debug:
        msg: "User #{{ index }}: {{ item }}"
      loop: "{{ users }}"
      loop_control:
        index_var: index
```

**Understanding loops**:

```yaml
loop: "{{ users }}"               # WHAT: Iterate over list
                                  # WHY: Repeat task for each item
                                  # HOW: {{ item }} is current item

loop: "{{ packages }}"            # WHAT: Loop over list of dictionaries
{{ item.name }}                   # WHY: Access dictionary values
{{ item.description }}            # HOW: Dot notation

loop_control:                     # WHAT: Control loop behavior
  index_var: index                # WHY: Get current index (0, 1, 2...)
                                  # HOW: Creates variable 'index'
```

### Run It

```bash
ansible-playbook -i inventory/hosts playbooks/05-variables-loops.yml
```

---

## 📝 Playbook 6: Conditionals

### Create the Playbook

```yaml
---
# File: playbooks/06-conditionals.yml
# Purpose: Use conditional logic

- name: Conditional Execution
  hosts: local
  vars:
    environment: "development"
    enable_debug: true
    memory_threshold: 4096
  
  tasks:
    - name: Development message
      debug:
        msg: "Running in DEVELOPMENT mode"
      when: environment == "development"
    
    - name: Production message
      debug:
        msg: "Running in PRODUCTION mode"
      when: environment == "production"
    
    - name: Debug enabled message
      debug:
        msg: "Debug mode is ENABLED"
      when: enable_debug
    
    - name: Check memory
      debug:
        msg: "System has enough memory: {{ ansible_memtotal_mb }} MB"
      when: ansible_memtotal_mb >= memory_threshold
    
    - name: Low memory warning
      debug:
        msg: "WARNING: Low memory: {{ ansible_memtotal_mb }} MB"
      when: ansible_memtotal_mb < memory_threshold
    
    - name: Multiple conditions (AND)
      debug:
        msg: "Development with debug enabled"
      when:
        - environment == "development"
        - enable_debug
    
    - name: Multiple conditions (OR)
      debug:
        msg: "Either development OR debug enabled"
      when: environment == "development" or enable_debug
```

**Understanding conditionals**:

```yaml
when: environment == "development"    # WHAT: Simple equality check
                                      # WHY: Run only if true
                                      # HOW: Boolean expression

when: enable_debug                    # WHAT: Boolean variable
                                      # WHY: Simpler than == true
                                      # HOW: Truthy evaluation

when: ansible_memtotal_mb >= 4096     # WHAT: Numeric comparison
                                      # WHY: Check system resources
                                      # HOW: Standard operators (>=, <=, >, <)

when:                                 # WHAT: Multiple conditions (AND)
  - condition1                        # WHY: All must be true
  - condition2                        # HOW: List format

when: cond1 or cond2                  # WHAT: OR condition
                                      # WHY: Any can be true
                                      # HOW: Use 'or' keyword
```

### Run It

```bash
ansible-playbook -i inventory/hosts playbooks/06-conditionals.yml

# Try changing variables:
ansible-playbook -i inventory/hosts playbooks/06-conditionals.yml -e "environment=production"
ansible-playbook -i inventory/hosts playbooks/06-conditionals.yml -e "enable_debug=false"
```

---

## 📝 Playbook 7: Handlers

### Create the Playbook

```yaml
---
# File: playbooks/07-handlers.yml
# Purpose: Use handlers for service management

- name: Handlers Example
  hosts: local
  tasks:
    - name: Create config file
      copy:
        content: |
          # Configuration file
          setting1=value1
          setting2=value2
        dest: /tmp/app.conf
      notify: Restart application
    
    - name: Update config file
      lineinfile:
        path: /tmp/app.conf
        line: "setting3=value3"
      notify: Restart application
    
    - name: Another task (no notification)
      debug:
        msg: "This task doesn't trigger handlers"
  
  handlers:
    - name: Restart application
      debug:
        msg: "Application would be restarted here"
```

**Understanding handlers**:

```yaml
notify: Restart application       # WHAT: Trigger handler if task changes
                                  # WHY: Restart only when needed
                                  # HOW: Handler runs at end of play

handlers:                         # WHAT: Special tasks
  - name: Restart application     # WHY: Run only when notified
                                  # HOW: Matches notify name
```

**Handler behavior**:

```
1. Task runs and makes a change
2. Task notifies handler
3. Play continues with other tasks
4. At end of play, handler runs ONCE
5. If task didn't change anything, handler doesn't run
```

### Run It

```bash
# First run - creates file, handler runs
ansible-playbook -i inventory/hosts playbooks/07-handlers.yml

# Second run - file exists, handler doesn't run
ansible-playbook -i inventory/hosts playbooks/07-handlers.yml
```

---

## 📝 Playbook 8: Complete Example

### Create the Playbook

```yaml
---
# File: playbooks/08-complete-example.yml
# Purpose: Comprehensive example combining all concepts

- name: Complete Ansible Example
  hosts: local
  become: yes
  vars:
    app_name: "myapp"
    app_port: 8080
    app_users:
      - developer
      - tester
  
  tasks:
    - name: Display start message
      debug:
        msg: "Starting setup for {{ app_name }}"
      tags: always
    
    - name: Create application directory
      file:
        path: "/opt/{{ app_name }}"
        state: directory
        mode: '0755'
      tags: setup
    
    - name: Create application users
      user:
        name: "{{ item }}"
        comment: "{{ app_name }} user"
        create_home: yes
      loop: "{{ app_users }}"
      tags: users
    
    - name: Install required packages
      package:
        name:
          - python3
          - python3-pip
        state: present
      when: ansible_os_family == "Debian"
      tags: packages
    
    - name: Create application config
      copy:
        content: |
          # {{ app_name }} Configuration
          APP_NAME={{ app_name }}
          APP_PORT={{ app_port }}
          ENVIRONMENT={{ environment | default('development') }}
        dest: "/opt/{{ app_name }}/config.env"
      notify: Reload application
      tags: config
    
    - name: Display completion message
      debug:
        msg: "Setup complete for {{ app_name }} on port {{ app_port }}"
      tags: always
  
  handlers:
    - name: Reload application
      debug:
        msg: "Application {{ app_name }} would be reloaded here"
```

**All concepts combined**:

- ✅ Variables
- ✅ Loops
- ✅ Conditionals
- ✅ Handlers
- ✅ Tags
- ✅ become (sudo)
- ✅ Multiple tasks
- ✅ File management
- ✅ User management
- ✅ Package management

### Run It

```bash
# Full run
ansible-playbook -i inventory/hosts playbooks/08-complete-example.yml

# Only setup tasks
ansible-playbook -i inventory/hosts playbooks/08-complete-example.yml --tags setup

# Only user creation
ansible-playbook -i inventory/hosts playbooks/08-complete-example.yml --tags users

# Dry run (check mode)
ansible-playbook -i inventory/hosts playbooks/08-complete-example.yml --check

# With custom variable
ansible-playbook -i inventory/hosts playbooks/08-complete-example.yml -e "environment=production"
```

---

## 🎯 Playbook Best Practices

### 1. Always Name Your Tasks

```yaml
# ❌ Bad
- apt:
    name: nginx

# ✅ Good
- name: Install nginx web server
  apt:
    name: nginx
```

### 2. Use Comments

```yaml
---
# Purpose: Setup web server
# Author: Your Name
# Date: 2026-06-05

- name: Web Server Setup
  hosts: webservers
```

### 3. Check Syntax Before Running

```bash
ansible-playbook playbook.yml --syntax-check
```

### 4. Use Dry Run First

```bash
ansible-playbook playbook.yml --check
```

### 5. Use Tags for Large Playbooks

```yaml
tasks:
  - name: Install packages
    apt:
      name: nginx
    tags: install
  
  - name: Configure nginx
    copy:
      src: nginx.conf
      dest: /etc/nginx/
    tags: configure
```

### 6. Handle Errors Gracefully

```yaml
- name: Task that might fail
  command: /path/to/command
  ignore_errors: yes

- name: Task with custom error handling
  command: /path/to/command
  register: result
  failed_when: result.rc != 0 and result.rc != 2
```

---

## 🐛 Debugging Playbooks

### Verbose Output

```bash
# Level 1 - Basic
ansible-playbook playbook.yml -v

# Level 2 - More details
ansible-playbook playbook.yml -vv

# Level 3 - Debug level
ansible-playbook playbook.yml -vvv

# Level 4 - Connection debugging
ansible-playbook playbook.yml -vvvv
```

### Debug Module

```yaml
- name: Debug variable
  debug:
    var: my_variable

- name: Debug message
  debug:
    msg: "Value is {{ my_variable }}"

- name: Debug with verbosity
  debug:
    msg: "Only shown with -v"
    verbosity: 1
```

### Check Mode (Dry Run)

```bash
# See what would change
ansible-playbook playbook.yml --check

# See differences
ansible-playbook playbook.yml --check --diff
```

---

## ✅ Practice Exercises

### Exercise 1: Personal Info Playbook

Create a playbook that:

- Prints your name
- Shows your OS
- Lists your home directory contents

### Exercise 2: File Backup Playbook

Create a playbook that:

- Creates a backup directory
- Copies important files to backup
- Shows backup completion message

### Exercise 3: System Check Playbook

Create a playbook that:

- Checks disk space
- Checks memory
- Warns if resources are low

---

## 🚀 Next Step

Now that you can write playbooks, let's see real-world examples!

👉 Go to [`05-REAL-WORLD-EXAMPLES.md`](05-REAL-WORLD-EXAMPLES.md)

---

## 💡 Pro Tips

1. **Start Simple**: Begin with debug tasks, add complexity gradually
2. **Test Locally**: Use localhost before remote servers
3. **Use --check**: Always dry-run before actual execution
4. **Read Errors**: Ansible errors are descriptive
5. **Use ansible-doc**: `ansible-doc module_name` for help
6. **Version Control**: Keep playbooks in Git
7. **Comment Your Code**: Future you will thank you
