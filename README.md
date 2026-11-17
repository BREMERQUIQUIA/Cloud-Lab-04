# Cloud-Lab-04

## AWS Infrastructure Automation with Terraform, Auto Scaling, RDS, ALB, CloudWatch and Ansible

Cloud-Lab-04 is an AWS infrastructure automation learning project built with Terraform and Ansible.

The project demonstrates how to provision, configure, monitor, and validate a highly available web application environment across multiple Availability Zones.

It follows production-inspired architectural and operational practices while remaining a learning laboratory.

## Project Architecture

The infrastructure was deployed in the AWS `us-east-1` region across two Availability Zones.

Main components:

- Amazon VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Application Load Balancer
- EC2 Launch Template
- Auto Scaling Group
- Amazon RDS for MySQL
- IAM roles and instance profiles
- AWS Systems Manager for instance administration
- Amazon CloudWatch dashboards and alarms
- Amazon SNS notifications
- Amazon S3 storage bucket
- Remote Terraform state backend hosted in Amazon S3

## Architecture Diagram

```text
                              Internet
                                  |
                           Internet Gateway
                                  |
                       Application Load Balancer
                                  |
                    +-------------+-------------+
                    |                           |
              Availability Zone A        Availability Zone B
                    |                           |
                Public Subnet              Public Subnet
                    |                           |
                    +-------------+-------------+
                                  |
                              NAT Gateway
                                  |
                    +-------------+-------------+
                    |                           |
              Private App Subnet          Private App Subnet
                    |                           |
                EC2 Instance               EC2 Instance
                    |                           |
                    +-------------+-------------+
                                  |
                         Private DB Subnets
                                  |
                              Amazon RDS
                               MySQL

       AWS Systems Manager | IAM | CloudWatch | Amazon SNS

       Amazon S3:
       - Terraform remote state backend
       - Laboratory application storage bucket
```

## Repository Structure

```text
Cloud-Lab-04/
|-- ansible/
|   |-- apply-app.yml
|   |-- validate.yml
|   `-- roles/
|       |-- application/
|       |-- cloudwatch/
|       |-- common/
|       |-- hardening/
|       `-- validation/
|-- bootstrap/
|-- scripts/
|   |-- bootstrap-backend.sh
|   |-- deploy.sh
|   |-- destroy.sh
|   `-- validate.sh
|-- terraform/
|   |-- environments/
|   |   `-- dev/
|   `-- modules/
|       |-- alb/
|       |-- autoscaling/
|       |-- launch-template/
|       |-- monitoring/
|       |-- rds/
|       |-- security/
|       |-- sns/
|       |-- storage/
|       `-- vpc/
|-- .gitignore
`-- README.md
```

## Technologies

- AWS
- Terraform
- Ansible
- AWS CLI
- Amazon EC2
- Amazon VPC
- Application Load Balancer
- EC2 Auto Scaling
- Amazon RDS for MySQL
- Amazon S3
- AWS Systems Manager
- Amazon CloudWatch
- Amazon SNS
- IAM
- Linux
- Bash

## Key Features

- Modular Terraform infrastructure
- Remote Terraform state stored in Amazon S3
- Multi-AZ network architecture
- Public and private subnet segmentation
- Application Load Balancer for HTTP traffic distribution
- EC2 Auto Scaling with target tracking
- Managed MySQL database in private subnets
- Systems Manager administration without direct SSH access
- CloudWatch monitoring and alarms
- SNS notification integration
- Ansible-based configuration and validation
- Bash deployment, validation, and cleanup scripts

## Deployment Workflow

The following commands describe the laboratory workflow. Run them from a compatible Bash environment with the required AWS credentials and Terraform and Ansible dependencies configured.

### 1. Bootstrap the Remote Backend

```bash
./scripts/bootstrap-backend.sh
```

### 2. Deploy the Infrastructure

```bash
./scripts/deploy.sh
```

### 3. Configure and Validate

```bash
./scripts/validate.sh
```

### 4. Destroy the Laboratory Infrastructure

```bash
./scripts/destroy.sh
```

**Important:** Review the Terraform plan before applying or destroying resources. The deployment can create AWS resources that incur charges.

## Validation and Test Results

The laboratory was deployed and tested. The following results were observed:

| Test | Result |
|---|---|
| HTTP traffic through the Application Load Balancer | Successful |
| Traffic distribution across EC2 instances in two Availability Zones | Verified |
| CPU load test using `stress-ng` | Executed at approximately 90% CPU for 300 seconds |
| Auto Scaling scale-out | Desired capacity increased from 2 to 3 |
| Auto Scaling scale-in | Desired capacity returned from 3 to 2 |
| Unhealthy EC2 instance replacement | Verified |
| CloudWatch alarm state | Transitioned to `ALARM` and subsequently returned to `OK` |
| AWS Systems Manager connectivity | Validated |
| RDS connectivity | Validated |

These results document the tests performed during the laboratory deployment.

## Security Considerations

The implementation included the following controls and configurations:

- Private subnets for application and database resources
- IAM roles and instance profiles for AWS access
- EC2 Instance Metadata Service Version 2 (IMDSv2)
- Encrypted EBS volumes
- Security Groups for network access control
- AWS Systems Manager Session Manager for instance administration
- No direct SSH administration in the tested workflow
- RDS master password managed through AWS Secrets Manager integration

## Terraform State and S3 Storage

This project uses two separate S3 purposes:

1. **Terraform remote state backend:** Stores the Terraform state file and is retained independently of the laboratory infrastructure.
2. **Laboratory storage bucket:** Created by the Terraform `storage` module and removed when the laboratory infrastructure was destroyed.

Do not delete the remote state backend while it is still required by the Terraform configuration.

## Infrastructure Cleanup and Current Status

The laboratory infrastructure was successfully deployed, validated, and subsequently destroyed.

The Terraform destroy operation reported:

```text
Apply complete! Resources: 0 added, 0 changed, 51 destroyed.
```

The Terraform state was checked after cleanup and contained no managed resources.

The following items were retained:

- Terraform and Ansible source code
- Git repository and project documentation
- Remote Terraform state backend in S3
- Final RDS snapshot: `cloud-lab-04-dev-mysql-final`

The retained S3 backend and RDS snapshot may continue to incur AWS charges. Review them in the AWS Console and remove them only when they are no longer needed.

**Project status:** Infrastructure deployment, validation, and cleanup completed. Source code remains available for review and future deployments.

## Skills Demonstrated

- AWS infrastructure provisioning
- Terraform modules and Infrastructure as Code
- AWS networking and subnet segmentation
- High availability and multi-AZ architecture
- EC2 Auto Scaling
- Application Load Balancing
- RDS administration and connectivity validation
- IAM and Systems Manager
- CloudWatch monitoring and alarms
- SNS notifications
- Ansible configuration management
- Bash automation
- Infrastructure testing and cleanup

## Future Improvements

Potential extensions for future iterations:

- GitHub Actions CI/CD
- Terraform static analysis and security scanning
- Ansible linting
- AWS WAF
- HTTPS listener and ACM certificates
- Route 53 integration
- Centralized logging
- VPC Flow Logs
- AWS CloudTrail and Config
- AWS GuardDuty
- Container deployment with ECS
- Multi-region disaster recovery

## License

This repository is provided for educational purposes and as a reference for AWS infrastructure automation.

## Author

**Bremer Quiquia**

AWS | Linux | Terraform | Ansible | Cloud Infrastructure | DevOps