terraform {
  backend "s3" {
    bucket = "s3-dev-line"     # mein S3-Bucket-Name
    key    = "terraform/state" # Der Pfad im S3-Bucket, in dem der Zustand gespeichert wird
    region = "eu-central-1"    # Die AWS-Region des S3-Buckets
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Importiere VPC-Konfiguration
module "vpc" {
  source = "./vpc"
}

# Importiere Subnetze
module "subnets" {
  source = "./subnets"
  vpc_id = module.vpc.vpc_id
}

# Importiere Sicherheitsgruppen
module "security_group" {
  source = "./security_group"
  vpc_id = module.vpc.vpc_id
}

# Importiere EC2-Instanz
module "ec2" {
  source            = "./ec2"
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.security_group.security_group_id
  subnet_id         = module.subnets.public_subnet_ids[0]
}
