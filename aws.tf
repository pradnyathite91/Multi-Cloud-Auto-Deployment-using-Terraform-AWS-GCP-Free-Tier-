provider "aws" {
  region     = "ap-south-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
}

# VPC
resource "aws_vpc" "custom-vpc" {
  cidr_block = "10.10.0.0/16"
  tags = { Name = "my-vpc-1" }
}

# Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "Subnet-1" }
}

# Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.custom-vpc.id
  tags = { Name = "igw-1" }
}

# Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.custom-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = { Name = "my-rt" }
}

# Associate Route Table
resource "aws_route_table_association" "rt-association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

# Security Group
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.custom-vpc.id
  description = "Security group for Dev, QA and XY"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "my-security-group" }
}

# EC2 Instances

resource "aws_instance" "dev-instance" {
  ami                    = "ami-091dccf4e2d272bae"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "mumbai-kp"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras enable nginx1
    yum clean metadata
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Dev" > /etc/hostname
    hostnamectl set-hostname Dev
    echo "<h1>Welcome to Dev Server</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = { Name = "Dev-1" }
}

resource "aws_instance" "qa-instance" {
  ami                    = "ami-091dccf4e2d272bae"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "mumbai-kp"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras enable nginx1
    yum clean metadata
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "QA" > /etc/hostname
    hostnamectl set-hostname QA
    echo "<h1>Welcome to QA Server</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = { Name = "QA-1" }
}

resource "aws_instance" "xy-instance" {
  ami                    = "ami-091dccf4e2d272bae"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = "mumbai-kp"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo "XY" > /etc/hostname
    hostnamectl set-hostname XY
    echo "<h1>Welcome to XY Server</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = { Name = "XY-1" }
}

# Outputs
output "dev_instance_ip" {
  value = aws_instance.dev-instance.public_ip
}

output "qa_instance_ip" {
  value = aws_instance.qa-instance.public_ip
}

output "xy_instance_ip" {
  value = aws_instance.xy-instance.public_ip
}
