provider "aws" {
  region = "eu-central-1"
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0e872aee57663ae2d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data       = <<-EOF
		    #!/bin/bash
		    sudo apt update
		    sudo apt install apache2 wget unzip -y
		    sudo sed -i 's/80/${var.server_port}/g' /etc/apache2/ports.conf
        sudo sed -i 's/:80/:${var.server_port}/g' /etc/apache2/sites-available/000-default.conf
		    wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
		    unzip 2135_mini_finance.zip
		    sudo cp -r 2135_mini_finance/* /var/www/html/
		    sudo systemctl restart apache2
		    EOF	
  lifecycle {
    create_before_destroy = true
  }        	
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["178.235.242.60/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["178.235.242.60/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size = 1
  max_size = 3
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "Public address server:"
}
