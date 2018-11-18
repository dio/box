variable "vpc_id" {}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "image" {
  description = "The docker image name, e.g nginx"
}

variable "name" {
  description = "The service name, if empty the service name is defaulted to the image name"
  default     = ""
}

variable "version" {
  description = "The docker image version"
  default     = "latest"
}

variable "subnet_ids" {
  description = "Comma separated list of subnet IDs that will be passed to the LB module"
  type        = "list"
  default     = []
}

variable "security_groups" {
  description = "Comma separated list of security group IDs that will be passed to the LB module"
}

variable "port" {
  description = "The container host port"
  default = 0
}

variable "cluster" {
  description = "The cluster name or ARN"
}

variable "dns_name" {
  description = "The DNS name to use, e.g nginx"
  default     = ""
}

/**
 * Options.
 */

variable "healthcheck" {
  description = "Path to a healthcheck endpoint"
  default     = "/"
}

variable "container_port" {
  description = "The container port"
  default     = 80
}

variable "command" {
  description = "The raw json of the task command"
  default     = "[]"
}

variable "env_vars" {
  description = "The raw json of the task env vars"
  default     = "[]"
}

variable "desired_count" {
  description = "The desired count"
  default     = 2
}

variable "memory" {
  description = "The number of MiB of memory to reserve for the container"
  default     = 512
}

variable "cpu" {
  description = "The number of cpu units to reserve for the container"
  default     = 64
}

variable "protocol" {
  description = "The ELB protocol, HTTP or TCP"
  default     = "HTTP"
}

variable "iam_role" {
  description = "IAM Role ARN to use"
}

variable "zone_id" {
  description = "The zone ID to create the record in"
}

variable "deployment_minimum_healthy_percent" {
  description = "lower limit (% of desired_count) of # of running tasks during a deployment"
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "upper limit (% of desired_count) of # of running tasks during a deployment"
  default     = 200
}

resource "aws_ecs_service" "main" {
  name            = "${module.task.name}"
  cluster         = "${var.cluster}"
  task_definition = "${module.task.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.iam_role}"

  load_balancer {
    target_group_arn = "${module.lb.target_group_arn}"
    container_name   = "${module.task.name}"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "task" {
  source = "../task"

  name          = "${coalesce(var.name, replace(var.image, "/", "-"))}"
  image         = "${var.image}"
  image_version = "${var.version}"
  command       = "${var.command}"
  env_vars      = "${var.env_vars}"
  memory        = "${var.memory}"
  cpu           = "${var.cpu}"

  ports = <<EOF
  [
    {
      "containerPort": ${var.container_port},
      "hostPort": ${var.port}
    }
  ]
EOF
}

module "lb" {
  source          = "../lb"
  name            = "${module.task.name}"
  environment     = "${var.environment}"
  subnets         = "${var.subnet_ids}"
  security_groups = "${var.security_groups}"
  dns_name        = "${coalesce(var.dns_name, module.task.name)}"
  zone_id         = "${var.zone_id}"
  vpc_id          = "${var.vpc_id}"
}

output "name" {
  value = "${module.lb.name}"
}

output "dns" {
  value = "${module.lb.dns}"
}

output "lb" {
  value = "${module.lb.id}"
}

output "zone_id" {
  value = "${module.lb.zone_id}"
}

output "fqdn" {
  value = "${module.lb.fqdn}"
}
