# 🌐 Multi-Cloud Auto Deployment Using Terraform (AWS + GCP Free Tier)

## 📌 Objective
Provision infrastructure on **AWS** and **GCP** using **Terraform**, deploy **NGINX** web servers in each cloud, and simulate **failover routing** using **DNSMasq** — all with a **single Terraform command**.

---

## 🧰 Tools & Technologies
- **Terraform**
- **AWS Free Tier** (EC2, Security Groups)
- **GCP Free Tier** (Compute Engine, VPC)
- **NGINX**
- **DNSMasq** (for local DNS simulation)
- **Linux (Amazon Linux, Debian)**

---

## 🚀 Infrastructure Overview
- AWS: 
  - Custom VPC, Subnet, Security Group
  - 3 EC2 Instances (Dev, QA, XY)
  - NGINX installed on Dev & QA
- GCP:
  - Custom VPC, Subnet, Firewall Rules
  - 3 Compute Instances (Dev, QA, XY)
  - NGINX installed on all instances
- DNSMasq: Local DNS routing to simulate failover.

---

## ✅ Project Steps

### 1. AWS Setup (Amazon Linux)

#### Launch EC2 Manually (for Terraform Setup)
- Go to **AWS Console → EC2 → Launch Instance**.
- Choose **Amazon Linux 2023** AMI.
- Select **t2.micro** (Free Tier).
- Create or select a **Key Pair**.
- Allow **SSH (22)** and **HTTP (80)** in Security Group.
- Launch the instance.

#### Install Terraform
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
```

#### Project Setup
```bash
mkdir project
cd project
vi aws.tf
```
> **Add AWS Terraform script inside `aws.tf`.**

#### AWS Terraform Script Overview
- **Provider**: AWS Mumbai Region (`ap-south-1`).
- **VPC**: 10.10.0.0/16.
- **Subnet**: 10.10.1.0/24.
- **Security Group**: SSH, HTTP, Custom HTTP(8080), ICMP.
- **EC2 Instances**: 
  - Dev: NGINX installed, custom hostname.
  - QA: NGINX installed, custom hostname.
  - XY: Simple HTML page.
- **Outputs**: Dev, QA, XY Public IPs.

#### Deploy Infrastructure
```bash
terraform init
terraform apply --auto-approve
```

---

### 2. Setup DNSMasq on AWS XY Machine
```bash
sudo -i
yum install dnsmasq -y
```

Edit `/etc/dnsmasq.conf`:
```bash
address=/dev.pradnya.local/PRIVATE_IP
address=/qa.pradnya.local/PRIVATE_IP
listen-address=127.0.0.1
```

Edit `/etc/resolv.conf`:
```bash
options timeout:2 attempts:5
search ap-south-1.compute.internal
nameserver 127.0.0.1
```

Restart DNSMasq:
```bash
sudo systemctl restart dnsmasq
```

Test DNS:
```bash
ping dev.pradnya.local
ping qa.pradnya.local
```

---

### 3. Validate AWS NGINX Installation
Login to Dev and QA instances:
```bash
nginx -v
```
Check web page:
- `http://<Dev_PUBLIC_IP>`
- `http://<QA_PUBLIC_IP>`

---

### 4. GCP Setup (Debian Machine)

#### Create GCP Project
- Go to **GCP Console** → **Select Project → New Project** → Create.

#### Enable APIs
- Enable:
  - Compute Engine API
  - IAM API

#### Create Service Account
- Roles: Editor, Compute Admin, Service Account User.
- Download **JSON Key**.

#### Add GCP Terraform Script
```bash
vi gcp.tf
```
> **Add GCP Terraform script inside `gcp.tf`.**

#### GCP Terraform Script Overview
- **Provider**: GCP Asia South1 (Mumbai).
- **VPC**: 10.10.1.0/24.
- **Firewall Rules**: Allow SSH, HTTP, ICMP.
- **Compute Instances**:
  - Dev, QA, XY with NGINX installed via startup script.
- **Outputs**: Public IPs of instances.

#### Deploy GCP Infrastructure
```bash
terraform init
terraform apply --auto-approve
```

---

### 5. Setup DNSMasq on GCP XY Machine
```bash
sudo -i
apt install dnsmasq -y
```

Edit `/etc/dnsmasq.conf`:
```bash
address=/dev.pradnya.local/PRIVATE_IP
address=/qa.pradnya.local/PRIVATE_IP
listen-address=127.0.0.1
```

Edit `/etc/resolv.conf`:
```bash
options timeout:2 attempts:5
search asia-south1-a.compute.internal
nameserver 127.0.0.1
```

Restart DNSMasq:
```bash
sudo systemctl restart dnsmasq
```

Test DNS:
```bash
ping dev.pradnya.local
ping qa.pradnya.local
```

---

### 6. Validate GCP NGINX Installation
Login to Dev and QA instances:
```bash
nginx -v
```
Check web page:
- `http://<Dev_PUBLIC_IP>`
- `http://<QA_PUBLIC_IP>`

---

## 📈 Result

✅ Infrastructure deployed successfully across AWS and GCP.  
✅ NGINX Web servers accessible via browser.  
✅ Local DNS routing tested with DNSMasq.

---

## 📢 Notes
- Always secure your Service Account JSON key.
- Destroy infrastructure after testing to avoid free tier limits.
- For real failover, configure external DNS providers or use advanced GCP/AWS services.

---
# 📂 Project Structure - Multi-Cloud Auto Deployment (AWS + GCP)

This project provisions infrastructure on **AWS** and **GCP** simultaneously using **Terraform**.  
Below is the organized project folder structure and explanation for each file and folder.

---

## 🗂️ Folder Structure

```
multi-cloud-auto-deployment/
├── README.md
├── aws/
│   ├── aws.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
├── gcp/
│   ├── gcp.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
├── credentials/
│   └── gcp-service-account.json
├── terraform.tfvars
├── .gitignore
```

---

## 📄 File and Folder Description

### 1. `README.md`
- Full project documentation, setup steps, and explanation.
- How to deploy on AWS and GCP using Terraform.

### 2. `aws/`
- Contains all AWS-specific Terraform files.
  - **provider.tf**: AWS provider configuration (region, credentials).
  - **aws.tf**: Main AWS infrastructure (VPC, EC2, Security Groups, etc.).
  - **variables.tf**: AWS input variables (AMI ID, instance type, etc.).
  - **outputs.tf**: Displays AWS public IPs after deployment.

### 3. `gcp/`
- Contains all GCP-specific Terraform files.
  - **provider.tf**: GCP provider configuration (project, credentials).
  - **gcp.tf**: Main GCP infrastructure (VPC, Instances, Firewall rules).
  - **variables.tf**: GCP

