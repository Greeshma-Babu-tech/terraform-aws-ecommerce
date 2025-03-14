terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

#################  step 1: Create VPC and Subnets ###################

#Create VPC
resource "aws_vpc" "ecom-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ecom-vpc"
  }
}
#Create Public Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.ecom-vpc.id
  count             = length(var.ecom_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.ecom-vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.ecom_availability_zones, count.index)
  tags = {
    name = "ecom public subnet ${count.index + 1}"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "ecom-igw" {
  vpc_id = aws_vpc.ecom-vpc.id
  tags = {
    name = "ecom-IGW"
  }
}

#Create private subnets for EC2
resource "aws_subnet" "private_subnet_ec2" {
  vpc_id            = aws_vpc.ecom-vpc.id
  count             = length(var.ecom_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.ecom-vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.ecom_availability_zones, count.index)
  tags = {
    name = "ecom private subnet ec2 ${count.index + 1}"
  }
}
#Create Elatic IPs for NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.ecom_availability_zones)

  tags = {
    Name = "ecom-nat-eip-${count.index + 1}"
  }
}
#Create NAT Gateways in both AZ (public subnet)
resource "aws_nat_gateway" "ecom_nat" {
  count         = length(var.ecom_availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "ecom-nat-gateway-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.ecom-igw]
}

#Create Public Route Table
resource "aws_route_table" "ecom_route_table_public" {
  vpc_id = aws_vpc.ecom-vpc.id
  count  = length(var.ecom_availability_zones)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecom-igw.id
  }

  tags = {
    name = "public subnet Route Table ${count.index + 1}"
  }
}

#Public Subnet Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.ecom_route_table_public[count.index].id
  count          = length(var.ecom_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}

# Create Private Route Table for ec2
resource "aws_route_table" "ecom_route_table_private_ec2" {
  count  = length(var.ecom_availability_zones)
  vpc_id = aws_vpc.ecom-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecom_nat[count.index].id
  }

  tags = {
    Name = "private subnet Route Table ${count.index + 1}"
  }
}
# Private Subnet Route Table Association for ec2
resource "aws_route_table_association" "private_subnet_association_ec2" {
  count          = length(var.ecom_availability_zones)
  subnet_id      = aws_subnet.private_subnet_ec2[count.index].id
  route_table_id = aws_route_table.ecom_route_table_private_ec2[count.index].id
}
# private subnet for rds
resource "aws_subnet" "private_subnet_rds" {
  vpc_id            = aws_vpc.ecom-vpc.id
  count             = length(var.ecom_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.ecom-vpc.cidr_block, 8, count.index + 5)
  availability_zone = element(var.ecom_availability_zones, count.index)
  tags = {
    name = "ecom private subnet rds${count.index + 1}"
  }
}

# Create Private Route Table for rds
resource "aws_route_table" "ecom_route_table_private_rds" {
  count  = length(var.ecom_availability_zones)
  vpc_id = aws_vpc.ecom-vpc.id

  tags = {
    Name = "private subnet Route Table rds${count.index + 1}"
  }
}
# Private Subnet Route Table Association for RdS
resource "aws_route_table_association" "private_subnet_association_rds" {
  count          = length(var.ecom_availability_zones)
  subnet_id      = aws_subnet.private_subnet_rds[count.index].id
  route_table_id = aws_route_table.ecom_route_table_private_rds[count.index].id
}
###################### Step 2 Create Necessary Security Groups
# Securty Group for ALB
resource "aws_security_group" "ecom-alb-sg" {
  vpc_id = aws_vpc.ecom-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#security Group for Ec2 servers
resource "aws_security_group" "ecom-ec2-sg" {
  vpc_id = aws_vpc.ecom-vpc.id
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.ecom-alb-sg.id]
    //source_security_group_id = aws_security_group.ecom-alb-sg.id
    //cidr_blocks = [aws_security_group.ecom-alb-sg.id] #Allow only ALB
  }
  # Allow outbound traffic for application responses
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security group for RDS
resource "aws_security_group" "ecom-rds-sg" {
  vpc_id = aws_vpc.ecom-vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecom-ec2-sg.id]
    //cidr_blocks = [aws_security_group.ecom-ec2-sg.id] #Allow only Ec2 SG
  }
}
#########step 3 Necessary IAM Role 
#IAM Role & Instance Profile to allow EC2 instances to interact with ALB
resource "aws_iam_role" "ecom_ec2_role" {
  name = "ecom-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

#Policy for ALB Registration
resource "aws_iam_policy" "ecom_ec2_policy" {
  name        = "ecom-ec2-policy"
  description = "Policy for EC2 instances to register with ALB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetHealth"
        ]
        Resource = aws_lb_target_group.ecom-alb-tg.arn
      },
      {
        Effect   = "Allow"
        Action   = "ec2:DescribeInstances"
        Resource = "*"
      }
    ]
  })
}

#Attach the Policy to IAM Role
resource "aws_iam_role_policy_attachment" "ecom_ec2_role_attach" {
  role       = aws_iam_role.ecom_ec2_role.name
  policy_arn = aws_iam_policy.ecom_ec2_policy.arn
}
#Create Instance Profile for EC2
resource "aws_iam_instance_profile" "ecom_instance_profile" {
  name = "ecom-instance-profile"
  role = aws_iam_role.ecom_ec2_role.name
}


############################## step 4 :set up load balancer

# Create ALB (Application Load Balancer)
resource "aws_lb" "ecom-lb" {
  name                       = "ecom-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = [aws_security_group.ecom-alb-sg.id]
  subnets                    = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false

  tags = {
    name = "ecom-alb"
  }
}

#Create target group
resource "aws_lb_target_group" "ecom-alb-tg" {
  name     = "ecom-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecom-vpc.id

  health_check {
    path                = "/"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

#Create ALB Listener
resource "aws_lb_listener" "ecom-alb-listener" {
  load_balancer_arn = aws_lb.ecom-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecom-alb-tg.arn
  }

}

###################### Step 5: Set Up Autoscaling

# Create Launch Template
resource "aws_launch_template" "ecom-launch-temp" {
  name_prefix   = "ecom-template"
  image_id      = "ami-0076370f75a86e62a" #e-commerce-ami v1.03
  instance_type = "t2.micro"
  key_name      = "my-key" # Specify the RSA key pair name here
  #Attach IAM Role to Launch Template
  iam_instance_profile {
    name = aws_iam_instance_profile.ecom_instance_profile.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.ecom-ec2-sg.id]
    associate_public_ip_address = false
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecom-app-server"
    }
  }

}
resource "aws_autoscaling_group" "ecom-asg" {
  vpc_zone_identifier = aws_subnet.private_subnet_ec2[*].id
  desired_capacity    = 2
  min_size            = 2
  max_size            = 5

  launch_template {
    id      = aws_launch_template.ecom-launch-temp.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.ecom-alb-tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 600

  tag {
    key                 = "Name"
    value               = "ecom-app-instance"
    propagate_at_launch = true
  }

}

##### step 6 DataBase Configurations
#  Create RDS Subnet Group
resource "aws_db_subnet_group" "ecom_db_subnet_group" {
  name       = "ecom-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet_rds[*].id

  tags = {
    Name = "ecom-db-subnet-group"
  }
}

#  Create RDS Instance
resource "aws_db_instance" "ecom_rds" {
  identifier             = "ecom-rds"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.medium"
  username               = "admin"
  password               = "password1234"
  db_subnet_group_name   = aws_db_subnet_group.ecom_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.ecom-rds-sg.id]
  skip_final_snapshot    = true
  multi_az = true #for high availability
  backup_retention_period = 7 #Required to enable read replicas

  tags = {
    Name = "ecom-rds"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.ecom_rds.endpoint
}

# Create Read Replicas
resource "aws_db_instance" "ecom_rds_replica" {
  identifier             = "ecom-rds-replica"
  instance_class         = "db.t3.medium"
  replicate_source_db    = aws_db_instance.ecom_rds.identifier  # Link to primary DB
  availability_zone      = "us-east-1a"  # Change based on your region
  vpc_security_group_ids = [aws_security_group.ecom-rds-sg.id]
  backup_retention_period      = 7

  tags = {
    Name = "ecom-rds-replica"
  }
}

#output file
resource "null_resource" "write_outputs" {
  provisioner "local-exec" {
    command = <<EOT
      echo "RDS Endpoint: ${aws_db_instance.ecom_rds.endpoint}" > terraform-outputs.txt
      echo "Load Balancer DNS: ${aws_lb.ecom-lb.dns_name}" >> terraform-outputs.txt
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

