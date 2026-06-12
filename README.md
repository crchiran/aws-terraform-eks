# AWS EKS Development Environment with Terraform

This repository contains Terraform configurations for provisioning an AWS EKS development environment.

## Repository Structure

```text
.
├── eks.tf
├── iam.tf
├── main.tf
├── outputs.tf
└── var.tf
```

### Files Description

| File         | Description                                              |
| ------------ | -------------------------------------------------------- |
| `main.tf`    | Core infrastructure resources and provider configuration |
| `eks.tf`     | Amazon EKS cluster and node group configuration          |
| `iam.tf`     | IAM roles and policies required by EKS                   |
| `var.tf`     | Terraform input variables                                |
| `outputs.tf` | Terraform outputs                                        |

---

## Environment

This repository is intended for:

```text
Development Environment
```

Configuration values, sizing, and settings are optimized for development and learning purposes.

---

## Prerequisites

### Install Terraform

Required version:

```text
Terraform >= 1.6
```

Verify installation:

```bash
terraform version
```

### Install AWS CLI

Verify installation:

```bash
aws --version
```

### Configure AWS Credentials

```bash
aws configure
```

Verify access:

```bash
aws sts get-caller-identity
```

---

## Deployment

### Initialize Terraform

```bash
terraform init
```

### Review Changes

```bash
terraform plan
```

### Create Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

## Remote Backend (Recommended)

For remote state management, configure an S3 backend and DynamoDB locking.

Example:

```hcl
terraform {
  backend "s3" {
    bucket         = "hudai-terraform-state"
    key            = "dev/eks/cluster.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

## Production Environment

This repository is intended for development and learning purposes only and should not be used as-is for production workloads.

For production deployments, use the dedicated production repository:

```text
https://github.com/crchiran/aws-terraform-eks-prod.git
```

Clone the production repository:

```bash
git clone https://github.com/crchiran/aws-terraform-eks-prod.git
```

The production repository includes additional enterprise-grade architecture, security hardening, operational controls, and best practices required for running Amazon EKS in production environments.

Key production features include:

* Private worker nodes with no public IP addresses
* Restricted or private Kubernetes API endpoint
* Dedicated VPC design with public, private, and isolated subnets
* NAT Gateway or VPC endpoints for controlled outbound access
* Least-privilege IAM roles and policies
* IAM Roles for Service Accounts (IRSA)
* Kubernetes RBAC with minimal permissions
* Default-deny NetworkPolicies for ingress and egress
* Pod Security Standards for workload hardening
* Secure secret management using AWS Secrets Manager, AWS Systems Manager Parameter Store, or External Secrets Operator
* Encryption at rest and in transit
* Centralized logging, monitoring, and alerting
* EKS control plane logging and AWS CloudTrail integration
* Container image scanning and vulnerability management
* Admission policies using Kyverno or OPA Gatekeeper
* Backup and disaster recovery planning
* GitOps-based change management workflows
* Separate development, staging, and production environments
* Production-ready operational and security best practices

---

## Useful Commands

### Format Terraform

```bash
terraform fmt -recursive
```

### Validate Configuration

```bash
terraform validate
```

### Show Current State

```bash
terraform show
```

### List Managed Resources

```bash
terraform state list
```

### View Outputs

```bash
terraform output
```

---

## Notes

* This repository is designed for development and learning purposes only.
* Review all Terraform plans before applying infrastructure changes.
* Store Terraform state remotely using Amazon S3 and DynamoDB.
* Do not commit secrets, credentials, access keys, or sensitive `.tfvars` files to Git.
* Use separate state files and environments for development and production workloads.
* Follow AWS security best practices and the principle of least privilege.
* Test infrastructure changes in development before deploying to production environments.

---

## License

This project is provided for educational and development purposes.