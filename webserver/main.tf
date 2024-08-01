provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "webserver" {
  ami                    = "ami-01e444924a2233b07" # Ersetze dies mit deiner AMI-ID
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "webserver-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "echo 'Hello Andrea 😎' | sudo tee /var/www/html/index.html"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"              # Ersetze dies mit dem richtigen Benutzernamen
      private_key = file("~/.ssh/id_rsa") # Pfad zum privaten Schlüssel
      host        = self.public_ip
    }
  }
}

