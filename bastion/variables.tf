variable "name" {
  default = "box"
}

variable "instance_type" {
  description = "Instance type, see a list at: https://aws.amazon.com/ec2/instance-types/"
  default     = "t2.micro"
}

variable "region" {
  description = "AWS Region, e.g ap-southeast-1"
  default     = "ap-southeast-1"
}

variable "security_groups" {
  description = "a comma separated lists of security group IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "key_name" {
  description = "The SSH key pair, key name"
}

variable "subnet_id" {
  description = "A external subnet id"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}
