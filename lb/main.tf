variable "name" {}
variable "environment" {}

variable "security_groups" {}

variable "subnets" {
  type    = "list"
  default = []
}

variable "vpc_id" {}

variable "type" {
  default = "application"
}

variable "dns_name" {
  description = "Route53 record name"
}

variable "zone_id" {
  description = "Route53 zone ID to use for dns_name"
}

resource "aws_lb" "main" {
  name               = "nlb-${var.name}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${var.subnets}"]
}

resource "aws_lb_target_group" "main" {
  name     = "nlb-${var.name}-target-group"
  port     = "80"
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  depends_on = ["aws_lb.main"]
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.id}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_route53_record" "main" {
  zone_id = "${var.zone_id}"
  name    = "${var.dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.main.dns_name}"
    zone_id                = "${aws_lb.main.zone_id}"
    evaluate_target_health = false
  }
}

output "name" {
  value = "${aws_lb.main.name}"
}

output "id" {
  value = "${aws_lb.main.id}"
}

output "dns" {
  value = "${aws_lb.main.dns_name}"
}

output "fqdn" {
  value = "${aws_route53_record.main.fqdn}"
}

output "zone_id" {
  value = "${aws_lb.main.zone_id}"
}

output "target_group_arn" {
  value = "${aws_lb_target_group.main.arn}"
}
