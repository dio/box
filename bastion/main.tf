data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.bastion.id}"
  source_dest_check      = false
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${split(",",var.security_groups)}"]
  monitoring             = true
  user_data              = "${file(format("%s/user_data.sh", path.module))}"

  tags {
    Name        = "bastion"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true

  tags {
    Name        = "${var.name}-bastion-eip"
    Environment = "${var.environment}"
  }
}
