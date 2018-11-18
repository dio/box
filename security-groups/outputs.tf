output "external_ssh" {
  value = "${aws_security_group.external_ssh.id}"
}

output "internal_ssh" {
  value = "${aws_security_group.internal_ssh.id}"
}

output "internal_elb" {
  value = "${aws_security_group.internal_elb.id}"
}

output "external_elb" {
  value = "${aws_security_group.external_elb.id}"
}
