# 🚀 AWS EKS Development Environment with Terraform

This repository contains Terraform configurations for provisioning a complete Amazon EKS development environment on AWS.

The infrastructure includes:

* Amazon EKS Cluster
* Managed Node Groups
* IAM Roles and Policies
* EKS OIDC Provider
* AWS EBS CSI Driver
* Kubernetes Storage Integration
* Networking Components
* Terraform Outputs

This repository is designed for learning, development, testing, and proof-of-concept environments.

---

# 📖 Architecture Overview

```text
Developer
    │
    ▼
Terraform
    │
    ▼
AWS Account
    │
    ▼
Amazon EKS Cluster
    ├── Managed Node Group
    ├── IAM Roles
    ├── OIDC Provider
    ├── EBS CSI Driver
    └── Kubernetes Workloads
```

---

# 📁 Repository Structure

```text
.
├── README.md
├── ebs-csi.tf
├── eks.tf
├── iam.tf
├── main.tf
├── outputs.tf
└── var.tf
```

---

# 📄 File Description

| File         | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `main.tf`    | AWS provider and common Terraform configuration                |
| `eks.tf`     | Amazon EKS cluster and managed node group configuration        |
| `iam.tf`     | IAM roles, policies, trust relationships, and OIDC integration |
| `ebs-csi.tf` | AWS EBS CSI Driver installation and IAM permissions            |
| `var.tf`     | Input variables                                                |
| `outputs.tf` | Terraform outputs and cluster connection information           |
| `README.md`  | Project documentation                                          |

---

# 🎯 Environment Purpose

This repository is intended for:

```text
Development
Testing
Learning
Proof of Concept
Lab Environment
```

It is not intended for production workloads.

---

# 💻 Minimum Requirements

## Local Workstation

| Component        | Minimum               |
| ---------------- | --------------------- |
| CPU              | 2 vCPU                |
| Memory           | 4 GB                  |
| Storage          | 10 GB Free Space      |
| Operating System | Linux, macOS, Windows |
| Internet         | Required              |

---

# ☁️ AWS Requirements

Required AWS permissions:

```text
Amazon EKS
IAM
EC2
VPC
Auto Scaling
CloudWatch
EBS
STS
```

Recommended AWS account:

```text
AWS Sandbox
Development Account
Learning Account
```

---

# 🔧 Prerequisites

## Terraform

Required version:

```text
Terraform >= 1.6
```

Verify:

```bash
terraform version
```

---

## AWS CLI

Verify installation:

```bash
aws --version
```

---

## kubectl

Verify installation:

```bash
kubectl version --client
```

---

## Configure AWS Credentials

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/admin"
}
```

---

# ⚙️ Deployment Workflow

## 1. Initialize Terraform

```bash
terraform init
```

---

## 2. Validate Configuration

```bash
terraform validate
```

---

## 3. Review Infrastructure Changes

```bash
terraform plan
```

---

## 4. Deploy Infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

when prompted.

---

## 5. Configure kubectl

After deployment:

```bash
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name <cluster-name>
```

Verify:

```bash
kubectl get nodes
```

Example:

```text
NAME                           STATUS   ROLES    AGE
ip-10-0-1-10                   Ready    <none>   5m
ip-10-0-2-20                   Ready    <none>   5m
```

---

# 💾 AWS EBS CSI Driver

This repository installs and configures:

```text
AWS EBS CSI Driver
```

Benefits:

* Dynamic Persistent Volume provisioning
* Persistent storage for Kubernetes workloads
* Support for StatefulSets
* Integration with AWS EBS

Verify:

```bash
kubectl get pods -n kube-system | grep ebs
```

---

# 🔐 Remote Backend (Recommended)

Use remote state storage.

Example:

```hcl
terraform {
  backend "s3" {
    bucket         = "hudai-terraform-state"
    key            = "dev/eks/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Benefits:

* Centralized state management
* State locking
* Team collaboration
* Backup and recovery

---

# 📤 Terraform Outputs

View outputs:

```bash
terraform output
```

Show specific output:

```bash
terraform output cluster_name
```

---

# 🔍 Verification

## Verify Cluster

```bash
kubectl cluster-info
```

---

## Verify Nodes

```bash
kubectl get nodes
```

---

## Verify System Pods

```bash
kubectl get pods -A
```

---

## Verify Storage Classes

```bash
kubectl get storageclass
```

---

## Verify EBS CSI Driver

```bash
kubectl get pods -n kube-system | grep ebs
```

---

# 🧹 Destroy Infrastructure

Destroy resources:

```bash
terraform destroy
```

Review carefully before confirming.

---

# 🚨 Production Notice

This repository is intended for:

```text
Development
Testing
Learning
Proof of Concept
```

Do not use this repository as-is for production environments.

For production workloads, use a dedicated production repository with:

* Private Worker Nodes
* Restricted Kubernetes API Access
* Multi-AZ Architecture
* IRSA
* RBAC Hardening
* Network Policies
* Secrets Management
* Monitoring and Alerting
* Backup and Disaster Recovery
* GitOps Deployment
* Security Scanning
* Compliance Controls

---

# Useful Terraform Commands

## Format Code

```bash
terraform fmt -recursive
```

## Validate

```bash
terraform validate
```

## Show State

```bash
terraform show
```

## List Resources

```bash
terraform state list
```

## Refresh State

```bash
terraform refresh
```

## View Outputs

```bash
terraform output
```

---

# Security Best Practices

✅ Use remote Terraform state

✅ Enable state locking

✅ Use least-privilege IAM policies

✅ Enable EBS encryption

✅ Use IAM Roles for Service Accounts (IRSA)

✅ Rotate credentials regularly

✅ Review Terraform plans before applying

✅ Protect Terraform state files

❌ Do not commit:

```text
terraform.tfstate
terraform.tfstate.backup
*.tfvars
.env
AWS Access Keys
Private Keys
Secrets
```

---

