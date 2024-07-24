provider "aws" {
	region = "eu-central-1"
}

resource "aws_instance" "example" {
	ami = "ami-0e872aee57663ae2d"
	instance_type = "t2.micro"
	key_name = "web02"
	vpc_security_group_ids = [aws_security_group.instance.id]
	user_data = <<-EOF
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
	user_data_replace_on_change = true

	tags = {
		Name = "terraform-example"
	}
}

resource "aws_security_group" "instance" {
	name = "terraform-example-instance"
	
	ingress {
	from_port = var.server_port
	to_port = var.server_port
	protocol = "tcp"
	cidr_blocks = ["178.235.242.60/32"]
	}
	
	ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
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
	value = aws_instance.example.public_ip
	description = "Publiczny adres IP serwera WWW"
}
