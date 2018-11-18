provider "aws" {}

variable "region" {
  default = "ap-southeast-1"
}

variable "name" {
  default = "box"
}

variable "environment" {
  default = "dev"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "key_name" {
  default = "box"
}

variable "domain_name_servers" {
  default = ""
}

variable "domain_name" {
  default = "box.local"
}

variable "ecs_cluster_name" {
  description = "the name of the cluster, if not specified the variable name will be used"
  default     = ""
}

variable "ecs_instance_type" {
  description = "the instance type to use for your default ecs cluster"
  default     = "t2.medium"
}

variable "ecs_instance_ebs_optimized" {
  description = "use EBS - not all instance types support EBS"
  default     = true
}

variable "ecs_min_size" {
  description = "the minimum number of instances to use in the default ecs cluster"

  // create 3 instances in our cluster by default
  // 2 instances to run our service with high-availability
  // 1 extra instance so we can deploy without port collisions
  default = 3
}

variable "ecs_max_size" {
  description = "the maximum number of instances to use in the default ecs cluster"
  default     = 10
}

variable "ecs_desired_capacity" {
  description = "the desired number of instances to use in the default ecs cluster"
  default     = 3
}

variable "ecs_root_volume_size" {
  description = "the size of the ecs instance root volume"
  default     = 25
}

variable "ecs_docker_volume_size" {
  description = "the size of the ecs instance docker volume"
  default     = 25
}

variable "ecs_docker_auth_type" {
  description = "The docker auth type, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the possible values"
  default     = ""
}

variable "ecs_docker_auth_data" {
  description = "A JSON object providing the docker auth data, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the supported formats"
  default     = ""
}

variable "ecs_security_groups" {
  description = "A comma separated list of security groups from which ingest traffic will be allowed on the ECS cluster, it defaults to allowing ingress traffic on port 22 and coming grom the ELBs"
  default     = ""
}

variable "ecs_ami" {
  description = "The AMI that will be used to launch EC2 instances in the ECS cluster"
  default     = ""
}

variable "extra_cloud_config_type" {
  description = "Extra cloud config type"
  default     = "text/cloud-config"
}

variable "extra_cloud_config_content" {
  description = "Extra cloud config content"
  default     = ""
}
