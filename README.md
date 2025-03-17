# Scalable E-commerce Platform

## Introduction
This project implements a highly scalable and secure e-commerce platform using a 3-tier architecture in AWS. The architecture is designed to ensure high availability, security, and cost efficiency by separating the application into three distinct layers: Presentation, Application, and Database.

## Key Features
- **High Availability**: Utilizes an Application Load Balancer (ALB) and Auto Scaling Groups (ASG) for redundancy and fault tolerance.
- **Scalability**: Automatically adjusts resources based on demand using ASG.
- **Security**: Implements private subnets for backend components, IAM policies for access control, and security groups for network restrictions.
- **Cost Optimization**: Resources dynamically scale to reduce unnecessary expenses.


---

## Deployment Steps

### Step 1: Create VPC and Subnets
- Set up a Virtual Private Cloud (VPC) with public and private subnets.
- Configure an Internet Gateway (IGW) and a NAT Gateway for external access control.
- Define route tables to manage network traffic.

### Step 2: Launch EC2 Instance and Create AMI (OR Use the Usedata in the Launch Template)
- Deploy an EC2 instance for the backend application.
- Install necessary dependencies and create an Amazon Machine Image (AMI) for Auto Scaling.

### Step 3: Configure Security Groups
- **ALB Security Group**: Allows HTTP traffic on port 80.
- **EC2 Security Group**: Accepts traffic only from ALB.
- **RDS Security Group**: Accepts traffic only from EC2 instances.

### Step 4: Set Up IAM Roles for EC2
- Assign an IAM role to EC2 instances to enable interaction with AWS services.
- Attach necessary policies for scaling and load balancing.

### Step 5: Deploy Load Balancer (ALB)
- Create an Application Load Balancer (ALB) in the public subnet.
- Define a target group to distribute traffic among EC2 instances.
- Configure health checks for automatic instance monitoring.

### Step 6: Configure Auto Scaling
- Define an Auto Scaling Group (ASG) using the previously created AMI.
- Set up scaling policies with a minimum of 2 and a maximum of 5 instances.
- Register EC2 instances with the ALB target group.

### Step 7: Deploy Database (RDS)
- Configure an Amazon RDS (MySQL) instance in private subnets.
- Set up database security groups to restrict unauthorized access.
- Create a read replica for better scalability and redundancy.

### Step 8: Set Up Jenkins CI/CD
- Install and configure Jenkins on an EC2 instance.
- Install Terraform and AWS credentials plugins in Jenkins.
- Set up a pipeline to automate deployment using Terraform scripts.

---

## Conclusion
This scalable e-commerce platform ensures high performance, security, and cost-effectiveness by leveraging AWS cloud infrastructure. The implementation of Auto Scaling, ALB, and RDS replication enhances reliability and availability. Continuous deployment through Jenkins further optimizes development and deployment workflows.

