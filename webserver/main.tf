terraform {
  backend "s3" {
    bucket = "s3-dev-line"
    key    = "terraform/webserver/state" # Spezifischer Pfad im S3-Bucket
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web_server" {
  ami                    = "ami-01e444924a2233b07"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id           # Übergeben von Variable oder ID direkt
  vpc_security_group_ids = [var.security_group_id] # Übergeben von Variable oder ID direkt

  tags = {
    Name = "web-server"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install -y apache2
                echo "Hello Andrea 😎" | sudo tee /var/www/html/index.html
                sudo systemctl restart apache2
                EOF
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
}

variable "security_group_id" {
  description = "The security group ID for the EC2 instance"
}
  