<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scalable E-commerce Platform</title>
</head>
<body>
    <h1>Scalable E-commerce Platform</h1>
    
    <h2>Introduction</h2>
    <p>This project implements a highly scalable and secure e-commerce platform using a 3-tier architecture in AWS. The architecture is designed to ensure high availability, security, and cost efficiency by separating the application into three distinct layers: Presentation, Application, and Database.</p>
    
    <h3>Key Features:</h3>
    <ul>
        <li><strong>High Availability</strong>: Utilizes an Application Load Balancer (ALB) and Auto Scaling Groups (ASG) for redundancy and fault tolerance.</li>
        <li><strong>Scalability</strong>: Automatically adjusts resources based on demand using ASG.</li>
        <li><strong>Security</strong>: Implements private subnets for backend components, IAM policies for access control, and security groups for network restrictions.</li>
        <li><strong>Cost Optimization</strong>: Resources dynamically scale to reduce unnecessary expenses.</li>
    </ul>
    
    <hr>
    
    <h2>Deployment Steps</h2>
    
    <h3>Step 1: Create VPC and Subnets</h3>
    <ul>
        <li>Set up a Virtual Private Cloud (VPC) with public and private subnets.</li>
        <li>Configure an Internet Gateway (IGW) and a NAT Gateway for external access control.</li>
        <li>Define route tables to manage network traffic.</li>
    </ul>
    
    <h3>Step 2: Launch EC2 Instance and Create AMI</h3>
    <ul>
        <li>Deploy an EC2 instance for the backend application.</li>
        <li>Install necessary dependencies and create an Amazon Machine Image (AMI) for Auto Scaling.</li>
    </ul>
    
    <h3>Step 3: Configure Security Groups</h3>
    <ul>
        <li><strong>ALB Security Group</strong>: Allows HTTP traffic on port 80.</li>
        <li><strong>EC2 Security Group</strong>: Accepts traffic only from ALB.</li>
        <li><strong>RDS Security Group</strong>: Accepts traffic only from EC2 instances.</li>
    </ul>
    
    <h3>Step 4: Set Up IAM Roles for EC2</h3>
    <ul>
        <li>Assign an IAM role to EC2 instances to enable interaction with AWS services.</li>
        <li>Attach necessary policies for scaling and load balancing.</li>
    </ul>
    
    <h3>Step 5: Deploy Load Balancer (ALB)</h3>
    <ul>
        <li>Create an Application Load Balancer (ALB) in the public subnet.</li>
        <li>Define a target group to distribute traffic among EC2 instances.</li>
        <li>Configure health checks for automatic instance monitoring.</li>
    </ul>
    
    <h3>Step 6: Configure Auto Scaling</h3>
    <ul>
        <li>Define an Auto Scaling Group (ASG) using the previously created AMI.</li>
        <li>Set up scaling policies with a minimum of 2 and a maximum of 5 instances.</li>
        <li>Register EC2 instances with the ALB target group.</li>
    </ul>
    
    <h3>Step 7: Deploy Database (RDS)</h3>
    <ul>
        <li>Configure an Amazon RDS (MySQL) instance in private subnets.</li>
        <li>Set up database security groups to restrict unauthorized access.</li>
        <li>Create a read replica for better scalability and redundancy.</li>
    </ul>
    
    <h3>Step 8: Set Up Jenkins CI/CD</h3>
    <ul>
        <li>Install and configure Jenkins on an EC2 instance.</li>
        <li>Install Terraform and AWS credentials plugins in Jenkins.</li>
        <li>Set up a pipeline to automate deployment using Terraform scripts.</li>
    </ul>
    
    <hr>
    
    <h2>Conclusion</h2>
    <p>This scalable e-commerce platform ensures high performance, security, and cost-effectiveness by leveraging AWS cloud infrastructure. The implementation of Auto Scaling, ALB, and RDS replication enhances reliability and availability. Continuous deployment through Jenkins further optimizes development and deployment workflows.</p>
    
    
    <hr>
</body>
</html>

