# 📚 Ansible Basics - Core Concepts

## 📖 WHAT: What Will We Learn?

This guide covers the fundamental building blocks of Ansible:

- Inventory (list of servers)
- Modules (tools to do tasks)
- Playbooks (automation scripts)
- Tasks (individual actions)
- Variables (dynamic values)
- Facts (system information)

## 🎯 Core Components

### 1. Inventory - Your Server List

**WHAT**: A file listing all servers you want to manage  
**WHY**: Ansible needs to know which servers to configure  
**FORMAT**: INI or YAML

#### Simple Inventory Example (INI Format)

```ini
# File: inventory/hosts

# Single server
web1.example.com

# Group of servers
[webservers]
web1.example.com
web2.example.com
web3.example.com

[databases]
db1.example.com
db2.example.com

# Group of groups
[production:children]
webservers
databases
```

**Understanding the syntax**:

```ini
[webservers]              # Group name in brackets
web1.example.com          # Server hostname or IP
web2.example.com ansible_user=admin  # With custom SSH user
web3.example.com ansible_port=2222   # With custom SSH port
```

#### Inventory with Variables

```ini
# File: inventory/hosts

[webservers]
web1.example.com
web2.example.com

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
http_port=80
```

**WHAT each line does**:

- `[webservers:vars]` - Variables for webservers group
- `ansible_user=ubuntu` - SSH username
- `ansible_ssh_private_key_file` - SSH key location
- `http_port=80` - Custom variable

#### Using Localhost

```ini
# File: inventory/hosts

[local]
localhost ansible_connection=local

# WHAT: localhost means your own computer
# WHY: Practice without needing remote servers
# ansible_connection=local: Don't use SSH, run locally
```

### 2. Modules - Ansible's Tools

**WHAT**: Pre-built functions to perform specific tasks  
**WHY**: Don't reinvent the wheel - use tested modules  
**HOW**: Call modules with parameters

#### Common Modules

| Module | Purpose | Example Use |
|--------|---------|-------------|
| `ping` | Test connection | Check if server is reachable |
| `command` | Run commands | Execute shell commands |
| `shell` | Run shell commands | Commands with pipes/redirects |
| `apt` | Manage packages (Debian/Ubuntu) | Install/remove software |
| `yum` | Manage packages (RedHat/CentOS) | Install/remove software |
| `copy` | Copy files | Deploy configuration files |
| `file` | Manage files/directories | Create, delete, set permissions |
| `service` | Manage services | Start/stop/restart services |
| `user` | Manage users | Create/delete users |
| `git` | Git operations | Clone repositories |

#### Using Modules (Ad-Hoc Commands)

**Format**: `ansible <hosts> -m <module> -a "<arguments>"`

**Example 1: Ping Module**

```bash
ansible localhost -m ping

# WHAT: Tests connection to localhost
# WHY: Verify Ansible is working
# -m ping: Use ping module
# Expected output: localhost | SUCCESS => {"ping": "pong"}
```

**Example 2: Command Module**

```bash
ansible localhost -m command -a "date"

# WHAT: Runs 'date' command on localhost
# WHY: Execute shell commands
# -m command: Use command module
# -a "date": Argument (command to run)
# Output: Shows current date and time
```

**Example 3: File Module**

```bash
ansible localhost -m file -a "path=/tmp/test.txt state=touch"

# WHAT: Creates empty file /tmp/test.txt
# WHY: Manage files
# state=touch: Create file if doesn't exist
```

**Example 4: Copy Module**

```bash
ansible localhost -m copy -a "content='Hello Ansible' dest=/tmp/hello.txt"

# WHAT: Creates file with content
# WHY: Deploy files
# content='Hello Ansible': File content
# dest=/tmp/hello.txt: Destination path
```

### 3. Playbooks - Automation Scripts

**WHAT**: YAML files containing automation instructions  
**WHY**: Reusable, version-controlled automation  
**FORMAT**: YAML (human-readable)

#### Basic Playbook Structure

```yaml
---
# File: playbook.yml

- name: My First Playbook
  hosts: localhost
  tasks:
    - name: Print message
      debug:
        msg: "Hello from Ansible!"
```

**Understanding each part**:

```yaml
---                           # YAML document start (optional but recommended)

- name: My First Playbook     # Play name (descriptive)
  hosts: localhost            # Which servers to run on
  tasks:                      # List of tasks to execute
    - name: Print message     # Task name (descriptive)
      debug:                  # Module to use
        msg: "Hello!"         # Module parameters
```

#### Running a Playbook

```bash
ansible-playbook playbook.yml

# WHAT: Executes the playbook
# WHY: Run automation
# Output: Shows each task's result
```

### 4. Tasks - Individual Actions

**WHAT**: Single action in a playbook  
**WHY**: Break automation into steps  
**FORMAT**: YAML dictionary

#### Task Anatomy

```yaml
- name: Install nginx                    # Task description
  apt:                                   # Module name
    name: nginx                          # Module parameter
    state: present                       # Module parameter
    update_cache: yes                    # Module parameter
```

**Parameters explained**:

- `name: nginx` - Package to install
- `state: present` - Ensure it's installed
- `update_cache: yes` - Run apt-get update first

#### Multiple Tasks Example

```yaml
---
- name: Setup web server
  hosts: localhost
  become: yes                            # Run as sudo
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    
    - name: Install nginx
      apt:
        name: nginx
        state: present
    
    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
```

**Understanding `become`**:

```yaml
become: yes                    # WHAT: Run with sudo privileges
                              # WHY: Installing packages needs root
                              # HOW: Ansible uses sudo automatically
```

### 5. Variables - Dynamic Values

**WHAT**: Named values that can change  
**WHY**: Make playbooks reusable and flexible  
**WHERE**: Defined in multiple places

#### Defining Variables

**Method 1: In Playbook**

```yaml
---
- name: Use variables
  hosts: localhost
  vars:
    package_name: nginx
    service_name: nginx
  tasks:
    - name: Install package
      apt:
        name: "{{ package_name }}"
        state: present
```

**Understanding variable syntax**:

```yaml
vars:                          # Variables section
  package_name: nginx          # Variable definition
  
"{{ package_name }}"          # Variable usage (Jinja2 syntax)
                              # MUST be quoted when starting with {{
```

**Method 2: In Separate File**

```yaml
# File: vars/main.yml
---
package_name: nginx
service_name: nginx
http_port: 80
```

```yaml
# File: playbook.yml
---
- name: Use variables from file
  hosts: localhost
  vars_files:
    - vars/main.yml
  tasks:
    - name: Install {{ package_name }}
      apt:
        name: "{{ package_name }}"
        state: present
```

**Method 3: Command Line**

```bash
ansible-playbook playbook.yml -e "package_name=apache2"

# WHAT: Pass variables via command line
# WHY: Override default values
# -e: Extra variables flag
```

#### Variable Types

```yaml
# String
name: "John"

# Number
port: 80

# Boolean
enabled: yes          # or true
disabled: no          # or false

# List
packages:
  - nginx
  - git
  - curl

# Dictionary
user:
  name: john
  uid: 1000
  shell: /bin/bash
```

### 6. Facts - System Information

**WHAT**: Automatically gathered system information  
**WHY**: Make decisions based on system state  
**HOW**: Ansible collects facts automatically

#### Viewing Facts

```bash
# Gather facts about localhost
ansible localhost -m setup

# WHAT: Shows all system facts
# WHY: See available information
# Output: JSON with system details
```

**Common Facts**:

```yaml
ansible_os_family          # "Debian", "RedHat", etc.
ansible_distribution       # "Ubuntu", "CentOS", etc.
ansible_hostname           # Server hostname
ansible_default_ipv4.address  # IP address
ansible_processor_cores    # Number of CPU cores
ansible_memtotal_mb        # Total RAM in MB
```

#### Using Facts in Playbooks

```yaml
---
- name: Use system facts
  hosts: localhost
  tasks:
    - name: Show OS family
      debug:
        msg: "This is {{ ansible_os_family }}"
    
    - name: Install package based on OS
      apt:
        name: nginx
        state: present
      when: ansible_os_family == "Debian"
```

**Understanding `when`**:

```yaml
when: ansible_os_family == "Debian"    # WHAT: Conditional execution
                                       # WHY: Different OS need different commands
                                       # HOW: Only runs if condition is true
```

### 7. Handlers - Triggered Tasks

**WHAT**: Tasks that run only when notified  
**WHY**: Avoid unnecessary restarts  
**WHEN**: Typically used for service restarts

#### Handler Example

```yaml
---
- name: Configure web server
  hosts: localhost
  become: yes
  tasks:
    - name: Copy nginx config
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: Restart nginx              # Triggers handler
    
  handlers:
    - name: Restart nginx                # Handler definition
      service:
        name: nginx
        state: restarted
```

**How it works**:

```
1. Copy config file
2. If file changed → notify handler
3. Handler runs at end of play
4. If file didn't change → handler doesn't run
```

### 8. Loops - Repeat Tasks

**WHAT**: Execute task multiple times  
**WHY**: Avoid repeating similar tasks  
**HOW**: Use `loop` keyword

#### Loop Example

```yaml
---
- name: Create multiple users
  hosts: localhost
  become: yes
  tasks:
    - name: Create users
      user:
        name: "{{ item }}"
        state: present
      loop:
        - alice
        - bob
        - charlie
```

**Understanding loops**:

```yaml
loop:                        # WHAT: List of items to iterate
  - alice                    # WHY: Create multiple users
  - bob                      # HOW: Task runs once per item
  - charlie
  
"{{ item }}"                # Current item in loop
```

#### Loop with Dictionary

```yaml
---
- name: Create users with details
  hosts: localhost
  become: yes
  tasks:
    - name: Create users
      user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        shell: "{{ item.shell }}"
      loop:
        - { name: 'alice', uid: 1001, shell: '/bin/bash' }
        - { name: 'bob', uid: 1002, shell: '/bin/zsh' }
```

### 9. Conditionals - Make Decisions

**WHAT**: Run tasks based on conditions  
**WHY**: Different actions for different situations  
**HOW**: Use `when` keyword

#### Conditional Examples

```yaml
---
- name: Conditional tasks
  hosts: localhost
  tasks:
    - name: Install on Debian
      apt:
        name: nginx
        state: present
      when: ansible_os_family == "Debian"
    
    - name: Install on RedHat
      yum:
        name: nginx
        state: present
      when: ansible_os_family == "RedHat"
```

**Common Conditions**:

```yaml
when: ansible_os_family == "Debian"           # OS check
when: ansible_distribution_version == "20.04"  # Version check
when: ansible_memtotal_mb > 4096              # Memory check
when: my_variable is defined                   # Variable exists
when: my_variable == "production"              # Variable value
```

### 10. Tags - Selective Execution

**WHAT**: Labels for tasks  
**WHY**: Run only specific parts of playbook  
**HOW**: Add `tags` to tasks

#### Tags Example

```yaml
---
- name: Full server setup
  hosts: localhost
  become: yes
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
      tags:
        - install
        - webserver
    
    - name: Configure nginx
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
      tags:
        - configure
        - webserver
    
    - name: Install database
      apt:
        name: postgresql
        state: present
      tags:
        - install
        - database
```

**Running with tags**:

```bash
# Run only install tasks
ansible-playbook playbook.yml --tags install

# Run only webserver tasks
ansible-playbook playbook.yml --tags webserver

# Skip database tasks
ansible-playbook playbook.yml --skip-tags database

# WHAT: Selective execution
# WHY: Faster, targeted runs
# HOW: Filter by tags
```

## 🎯 Putting It All Together

### Complete Example Playbook

```yaml
---
# File: webserver-setup.yml
# Purpose: Setup and configure nginx web server

- name: Setup Web Server
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    max_clients: 200
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
      tags: setup
    
    - name: Install nginx
      apt:
        name: nginx
        state: present
      tags: setup
      notify: Start nginx
    
    - name: Copy nginx configuration
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      tags: configure
      notify: Restart nginx
    
    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
      tags: service
  
  handlers:
    - name: Start nginx
      service:
        name: nginx
        state: started
    
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

**Running this playbook**:

```bash
# Full run
ansible-playbook -i inventory/hosts webserver-setup.yml

# Only setup tasks
ansible-playbook -i inventory/hosts webserver-setup.yml --tags setup

# Check what would change (dry-run)
ansible-playbook -i inventory/hosts webserver-setup.yml --check

# Verbose output
ansible-playbook -i inventory/hosts webserver-setup.yml -v
```

## 📊 Ansible Execution Flow

```
1. Read playbook
   ↓
2. Read inventory
   ↓
3. Gather facts from hosts
   ↓
4. Execute tasks in order
   ↓
5. If task changes something → notify handlers
   ↓
6. Run handlers at end
   ↓
7. Report results
```

## ✅ Best Practices

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

### 2. Use Descriptive Variable Names

```yaml
# ❌ Bad
p: 80

# ✅ Good
http_port: 80
```

### 3. Organize Files

```
project/
├── inventory/
│   └── hosts
├── playbooks/
│   └── webserver.yml
├── vars/
│   └── main.yml
└── ansible.cfg
```

### 4. Use Version Control

```bash
git init
git add .
git commit -m "Initial Ansible setup"
```

### 5. Test Before Production

```bash
# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run
ansible-playbook playbook.yml --check

# Run on test servers first
ansible-playbook -i inventory/test playbook.yml
```

## 🎓 Quick Reference

### Common Commands

```bash
# Ad-hoc commands
ansible <host> -m <module> -a "<args>"

# Run playbook
ansible-playbook playbook.yml

# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run
ansible-playbook playbook.yml --check

# Verbose output
ansible-playbook playbook.yml -v    # -vv, -vvv for more detail

# List hosts
ansible-playbook playbook.yml --list-hosts

# List tasks
ansible-playbook playbook.yml --list-tasks

# With tags
ansible-playbook playbook.yml --tags "install,configure"

# Skip tags
ansible-playbook playbook.yml --skip-tags "database"
```

### Playbook Structure

```yaml
---
- name: Play name
  hosts: target_hosts
  become: yes/no
  vars:
    variable: value
  vars_files:
    - vars/file.yml
  tasks:
    - name: Task name
      module:
        parameter: value
      when: condition
      loop: list
      tags: tag_name
      notify: handler_name
  handlers:
    - name: Handler name
      module:
        parameter: value
```

## 🚀 Next Step

Now that you understand Ansible basics, let's write your first playbook!

👉 Go to [`04-FIRST-PLAYBOOK.md`](04-FIRST-PLAYBOOK.md)

---

## 💡 Pro Tips

1. **Start Simple**: Begin with localhost, then move to remote servers
2. **Use --check**: Always dry-run before actual execution
3. **Read Errors**: Ansible errors are descriptive, read them carefully
4. **Use ansible-doc**: Built-in documentation is excellent

   ```bash
   ansible-doc apt        # Module documentation
   ansible-doc -l         # List all modules
   ```

5. **Practice Idempotency**: Run playbooks multiple times, should be safe
