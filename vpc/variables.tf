# TODO(dio): create a tags map.
variable "name" {
  description = "Name tag, e.g. box"
  default     = "box"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "availability_zones" {
  description = "AZs"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "external_subnets" {
  description = "CIDRs of external subnets, needs to have as many elements as AZs"

  # TODO(dio): probably can be generated?
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "internal_subnets" {
  description = "CIDRs of internal subnets, needs to have as many elements as AZs"

  # TODO(dio): probably can be generated?
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
