terraform {
  backend "s3" {
    bucket = "s3-dev-line"     # Mein S3-Bucket-Name
    key    = "terraform/state" # Der Pfad im S3-Bucket, in dem der Zustand gespeichert wird
    region = "eu-central-1"    # Die AWS-Region des S3-Buckets
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Datenquelle für Verfügbarkeitszonen
data "aws_availability_zones" "available" {}

# VPC erstellen
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Öffentliche Subnetze erstellen
resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Private Subnetze erstellen
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index + 3)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Sicherheitsgruppe
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for SSH, HTTP, and HTTPS access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2-Instanz erstellen
resource "aws_instance" "laugenstange" {
  ami           = "ami-01e444924a2233b07"
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.public[*].id, 0) # Beispiel für Verwendung des ersten öffentlichen Subnetzes

  tags = {
    Name = "instance-in-public-subnet"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

# Ausgabe: Öffentliche IP-Adresse der Instanz
output "instance_public_ip" {
  value = aws_instance.laugenstange.public_ip
}

# Ausgabe: Name der Sicherheitsgruppe
output "security_group_name" {
  value = aws_security_group.web_sg.name
}

# Ausgabe: Sicherheitsgruppenregeln
output "security_group_rule_arns" {
  value = [
    for rule in aws_security_group.web_sg.ingress : {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_blocks = rule.cidr_blocks
    }
  ]
}
