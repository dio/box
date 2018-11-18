output "name" {
  value = "${var.name}"
}

output "zone_id" {
  value = "${aws_route53_zone.main.zone_id}"
}

output "name_servers" {
  value = "${join(",",aws_route53_zone.main.name_servers)}"
}
