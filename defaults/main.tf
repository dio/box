variable "cidr" {
  description = "The CIDR block to provision for the VPC"
}

output "domain_name_servers" {
  value = "${cidrhost(var.cidr, 2)}"
}
