provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "example" {
  ami                         = "ami-0e872aee57663ae2d"
  instance_type               = "t2.micro"
  key_name                    = "web02"
  vpc_security_group_ids      = [aws_security_group.instance.id]
	
  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
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


output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "Public address server:"
}
