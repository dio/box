# VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"

  # TODO(dio): Ability to controll the following:
  # - instance_tenancy
  # - assign_generated_ipv6_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

# TODO(dio): Add more IPv4 CIDR blocks (secondary CIDR blocks) to the VPC via
# aws_vpc_ipv4_cidr_block_association.

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-internet-gateway"
    Environment = "${var.environment}"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = "${length(var.internal_subnets)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.external.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.main"]

  tags {
    Name        = "${var.name}-${format("nat-gateway-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

# External Subnet
resource "aws_subnet" "external" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.external_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${length(var.external_subnets)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.name}-${format("external-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

# Internal Subnet
resource "aws_subnet" "internal" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.internal_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${length(var.internal_subnets)}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.name}-${format("internal-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

# NAT IP
resource "aws_eip" "nat" {
  vpc   = true
  count = "${length(var.internal_subnets)}"

  tags {
    Name        = "${var.name}-${format("nat-eip-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

# Routes
resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-external-001"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "external" {
  route_table_id         = "${aws_route_table.external.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "internal" {
  count  = "${length(var.internal_subnets)}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-${format("internal-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "internal" {
  count                  = "${length(compact(var.internal_subnets))}"
  route_table_id         = "${element(aws_route_table.internal.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

# Route associations
resource "aws_route_table_association" "internal" {
  count          = "${length(var.internal_subnets)}"
  subnet_id      = "${element(aws_subnet.internal.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
}

resource "aws_route_table_association" "external" {
  count          = "${length(var.external_subnets)}"
  subnet_id      = "${element(aws_subnet.external.*.id, count.index)}"
  route_table_id = "${aws_route_table.external.id}"
}
