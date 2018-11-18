resource "aws_route53_zone" "main" {
  name = "${var.name}"

  // TODO(dio): To support multiple VPCs
  vpc = {
    vpc_id = "${var.vpc_id}"
  }

  comment = ""
}
