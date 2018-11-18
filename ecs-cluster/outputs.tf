output "name" {
  value = "${var.name}"
}

output "security_group_id" {
  value = "${aws_security_group.cluster.id}"
}
