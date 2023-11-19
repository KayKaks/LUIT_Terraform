# Create default VPC and subnets
resource "aws_default_vpc" "default" {}
 
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_default_vpc.default.id
  availability_zone       = "us-east-1a" # Set your desired availability zone
  cidr_block              = "10.0.1.0/25" # Set your desired CIDR block
}
 
resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_default_vpc.default.id
  availability_zone       = "us-east-1b" # Set your desired availability zone
  cidr_block              = "10.0.1.128/25" # Set your desired CIDR block
}
 
# Create security group
resource "aws_security_group" "luit_sg" {
  name        = "luit_sg"
  description = "Allow inbound traffic for web servers"
 
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
# Create launch configuration
resource "aws_launch_configuration" "luit_lc" {
  name = "luit_lc"
  image_id = "ami-0230bd60aa48260c6" # Set your desired AMI ID
  instance_type = "t2.micro" # Set your desired instance type
 
  lifecycle {
    create_before_destroy = true
  }
 
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd.x86_64
              systemctl start httpd.service
              systemctl enable httpd.service
              amazon-linux-extras install epel -y
              yum install stress -y
              echo "<html><body><h1>WE ARE LEVELING UP IN TERRAFORM!!</h1></body></html>" > /var/www/html/index.html
            EOF
 
  security_groups = [aws_security_group.luit_sg.id] # Corrected security group reference
}
 
# Create Auto Scaling Group
resource "aws_launch_template" "luit_sg" {
  name_prefix   = "luit_sg"
  image_id      = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
}
 
resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
 
  launch_template {
    id      = aws_launch_template.luit_sg.id
    version = "$Latest"
  }
}
