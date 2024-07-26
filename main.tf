locals {
  ssh_user         = "ubuntu"
  private_key_path = "~/.ssh/web02.pem"
}

provider "aws" {
  region = "eu-central-1"
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

resource "aws_instance" "WEB-toople" {
  ami                    = "ami-0e872aee57663ae2d"
  instance_type          = "t2.micro"
  key_name               = "web02"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }

  user_data = <<-EOF
              #!/bin/bash

              # Function to check and wait for the dpkg lock to be released
              wait_for_dpkg_lock() {
              while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
                echo "Waiting for other apt-get processes to finish..."
                sleep 5
              done
              while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 ; do
                echo "Waiting for other apt-get processes to finish..."
                sleep 5
              done
              }

              # Wait for dpkg lock to be released
              wait_for_dpkg_lock

              # Update package list and install Python3 and pip3
              sudo apt update
              wait_for_dpkg_lock
              sudo apt install -y python3 python3-pip

              # Install Python packages
              pip3 install six requests
              EOF

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)

      host = aws_instance.WEB-toople.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.WEB-toople.public_ip}, --private-key ${local.private_key_path} site.yml"
  }
}


output "public_ip" {
  value       = aws_instance.WEB-toople.public_ip
  description = "Public address server:"
}
