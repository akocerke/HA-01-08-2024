variable "subnet_id" {
  description = "The ID of the subnet where the webserver will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the webserver"
  type        = string
}
