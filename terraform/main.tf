terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Create subnet (since none exist)
resource "aws_subnet" "app_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = "172.31.100.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-app-subnet"
  }
}

resource "aws_security_group" "app_sg" {
  name   = "jenkins-app-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

resource "aws_instance" "app_server" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.app_subnet.id

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "jenkins-docker-app"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "jenkins-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jenkins-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
