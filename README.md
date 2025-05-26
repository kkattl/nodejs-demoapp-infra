# DemoApp Terraform Infrastructure

This repository contains Terraform configurations, user data scripts, and load testing setup to deploy the **Node.js DemoApp** (https://github.com/benc-uk/nodejs-demoapp) on AWS using:

-- **VPC** (public & private subnets, route tables, igw) via terraform-aws-modules/vpc  
- **Application Load Balancer** (ALB) with Target Group (port 3000)  
- **EC2 Auto Scaling Group** (ASG) running Docker containers via a Launch Template  
- **Amazon DocumentDB** cluster (with subnet group and Secrets Manager for credentials)  
- **AWS Security Groups** to lock down ALB, EC2 and DocumentDB traffic  
- **IAM Roles & Policies** (EC2 instance profile + custom policy allowing SSM, SecretsManager, RDS-DB connect & DocDB Describe permissions)  
- **CloudWatch** alarm and **SNS** notifications for scaling & high-traffic events  
- **AWS Inspector** automatic security assessments on EC2 instances  
- **Locust** load test scenario

---

## ⚙️ Prerequisites

- **Terraform >= 1.5**  
- **AWS CLI** configured (profile or env vars)  
- **AWS IAM** user with permissions for:
  - VPC, EC2, ELB, AutoScaling, IAM (role/profile), CloudWatch, SNS  
  - SecretsManager, DocumentDB (rds:CreateDBSubnetGroup, docdb:Describe*, rds-db:connect), Inspector2  
- Internet access (for NAT Gateway) in private subnets or VPC endpoints for SSM

---

## 🛠️ Setup & Configuration

1. **Clone** this repo:
   ```bash
   git clone https://github.com/kkattl/nodejs-demoapp-infra.git
   cd nodejs-demoapp-infra
   ```
2. Configure AWS credentials:
   ```bash
   aws configure --profile tf-demo #you can choose another one
   # Access Key ID: …
   # Secret Access Key: …
   # Default region: us-east-1
   # Default output: json
   ```

3. Change `infrastructure/env/dev.tfvars.example` on `infrastructure/env/dev.tfvars` and edit with your's data

---

## 🚀 Deploying (Dev)
  ```bash
  cd infrastructure/dev
  terraform init
  terraform plan   -var-file=../env/dev.tfvars
  terraform apply  -var-file=../env/dev.tfvars
  ```

**Outputs:**

  - alb_dns – DNS name of the public ALB
  - asg_name – name of the Auto Scaling Group

**Verify:**

  ```bash
  curl -I http://$(terraform output -raw alb_dns)/ #enter yours dns-alb
  ```
## 🧪 Load Testing with Artillery

1. Ensure ALB DNS is healthy and returns HTTP 200. (you have to wait few minutes)

2. Run the Artillery scenario:
   ```bash
   #maybe firstly you have to install locust
   pip install locust
   locust -f locustfile.py --headless -u 800 -r 100 -t 10m --host http://<ALB-DNS>
   ```

## ⚠️ Destroying Infrastructure

To clean up everything created by Terraform:

   ```bash
   cd infrastructure/dev
terraform destroy -var-file=../env/dev.tfvars -auto-approve
   ``
