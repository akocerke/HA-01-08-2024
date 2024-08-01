variable "vpc_id" {}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet("10.0.0.0/16", 3, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
