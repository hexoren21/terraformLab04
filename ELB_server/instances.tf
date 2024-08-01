resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = "ami-0e872aee57663ae2d"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install apache2 wget unzip -y
    #sudo sed -i 's/80/${var.server_port}/g' /etc/apache2/ports.conf
    #sudo sed -i 's/:80/:${var.server_port}/g' /etc/apache2/sites-available/000-default.conf
    wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
    unzip 2135_mini_finance.zip
    sudo cp -r 2135_mini_finance/* /var/www/html/
    sudo systemctl restart apache2
  EOF

  tags = {
    Name = "WebServer-${count.index}"
  }
}
