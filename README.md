# Cloud-Lab-04

## Enterprise AWS Infrastructure with Terraform, Auto Scaling, RDS, ALB, CloudWatch and Ansible

Cloud-Lab-04 is a production-oriented Infrastructure as Code project built on AWS using Terraform and Ansible.

The objective of this laboratory is to simulate a highly available web application architecture following AWS Well-Architected Framework principles.

The project provisions the complete infrastructure automatically and validates every component after deployment.

---

# Architecture

The environment includes:

- Amazon VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Application Load Balancer
- Auto Scaling Group
- Launch Template
- Amazon EC2
- Amazon RDS MySQL
- IAM Roles
- Systems Manager
- CloudWatch Dashboard
- CloudWatch Alarms
- SNS Notifications

---

# Repository Structure

```
Cloud-Lab-04
│
├── ansible/
│
├── bootstrap/
│
├── docs/
│
├── scripts/
│
└── terraform/
```

---

# Technologies

- Terraform
- AWS CLI
- Ansible
- Amazon EC2
- Amazon VPC
- Auto Scaling
- Application Load Balancer
- Amazon RDS
- Amazon CloudWatch
- Amazon SNS
- AWS Systems Manager
- IAM

---

# Features

- Modular Terraform architecture
- Remote State Backend
- Private Networking
- NAT Gateway
- Auto Scaling
- Application Load Balancing
- MySQL Database
- CloudWatch Monitoring
- SNS Notifications
- Systems Manager administration
- Bash automation scripts
- Infrastructure validation

---

# Infrastructure Diagram

```text
                    Internet
                        │
                Internet Gateway
                        │
              ┌───────────────────┐
              │ Public Subnet      │
              │                    │
              │  Application Load  │
              │      Balancer      │
              └─────────┬──────────┘
                        │
             ┌──────────┴──────────┐
             │                     │
     Private Subnet A      Private Subnet B
             │                     │
      EC2 Instance 1        EC2 Instance 2
             │                     │
             └──────────┬──────────┘
                        │
                  Amazon RDS MySQL
                        │
                  Private Networking

          Systems Manager
          CloudWatch
          SNS Notifications
```

---

# Deployment

## Bootstrap Remote Backend

```bash
./scripts/bootstrap-backend.sh
```

---

## Deploy Infrastructure

```bash
./scripts/deploy.sh
```

---

## Validate Infrastructure

```bash
./scripts/validate.sh
```

---

## Destroy Infrastructure

```bash
./scripts/destroy.sh
```

---

# Validation

The validation process verifies:

- Terraform deployment
- ALB availability
- HTTP response
- Auto Scaling Group health
- EC2 registration
- Systems Manager connectivity
- Database connectivity
- CloudWatch configuration

---

# Security

This project follows security best practices including:

- Private subnets
- IAM Roles
- Instance Profiles
- IMDSv2 enabled
- Encrypted EBS volumes
- Security Groups
- No direct SSH administration
- Systems Manager Session Manager
- Principle of Least Privilege

---

# Skills Demonstrated

- Infrastructure as Code
- Terraform Modules
- AWS Networking
- High Availability
- Auto Scaling
- Cloud Security
- Linux Administration
- Systems Manager
- CloudWatch Monitoring
- Bash Automation
- Ansible Automation
- AWS CLI

---

# Estimated Cost

This laboratory is intended for learning purposes.

To avoid unnecessary AWS charges, destroy all resources after completing the validation.

Approximate services used:

| Service | Purpose |
|----------|---------|
| VPC | Networking |
| Public / Private Subnets | Segmentation |
| Internet Gateway | Internet Access |
| NAT Gateway | Outbound Internet |
| Application Load Balancer | Traffic Distribution |
| Auto Scaling Group | High Availability |
| EC2 | Web Application |
| Amazon RDS | Database |
| CloudWatch | Monitoring |
| SNS | Notifications |
| Systems Manager | Administration |

---

# Future Improvements

Future versions of this project may include:

- AWS WAF
- AWS Shield
- Route53
- ACM TLS Certificates
- HTTPS Listener
- CodePipeline
- CodeBuild
- Blue / Green Deployments
- ECS
- EKS
- Secrets Manager
- Parameter Store integration
- CloudTrail
- AWS Config
- GuardDuty
- VPC Flow Logs
- Centralized Logging
- Multi-Region Architecture
- Disaster Recovery
- GitHub Actions CI/CD

---

# Screenshots

Suggested screenshots for the repository:

- AWS Architecture
- Terraform Apply
- Auto Scaling Group
- Application Load Balancer
- CloudWatch Dashboard
- CloudWatch Alarms
- Systems Manager Fleet Manager
- Systems Manager Session Manager
- Amazon RDS
- SNS Subscription
- Validation Script
- Destroy Script

---

# Learning Objectives

This project demonstrates practical experience with:

- AWS Infrastructure as Code
- Enterprise Networking
- High Availability Architectures
- Production-ready Terraform Modules
- Infrastructure Automation
- Bash Scripting
- Configuration Management
- Monitoring and Observability
- Security Best Practices
- Infrastructure Validation

---

# License

This repository is provided for educational purposes.

Feel free to use it as a reference for learning Infrastructure as Code and AWS architecture.

---

# Author

**Bremer Quiquia**

AWS • Linux • Terraform • Ansible • Cloud Infrastructure • DevOps

---

# Project Status

**Completed**

Cloud-Lab-04 has been successfully designed, deployed, validated, automated, and documented following production-oriented best practices.