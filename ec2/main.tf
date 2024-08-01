variable "vpc_id" {}
variable "security_group_id" {}
variable "subnet_id" {}

resource "aws_instance" "web" {
  ami           = "ami-01e444924a2233b07"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "laugenstange"
  }
}

output "instance_id" {
  value = aws_instance.web.id
}
