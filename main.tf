module "defaults" {
  source = "./defaults"
  cidr   = "${var.cidr}"
}

module "vpc" {
  source      = "./vpc"
  cidr        = "${var.cidr}"
  name        = "${var.name}"
  environment = "${var.environment}"
}

module "security_groups" {
  source      = "./security-groups"
  vpc_id      = "${module.vpc.id}"
  cidr        = "${var.cidr}"
  name        = "${var.name}"
  environment = "${var.environment}"
}

module "bastion" {
  source          = "./bastion"
  vpc_id          = "${module.vpc.id}"
  security_groups = "${module.security_groups.external_ssh},${module.security_groups.internal_ssh}"
  subnet_id       = "${element(module.vpc.external_subnets, 0)}"
  key_name        = "${var.key_name}"
  name            = "${var.name}"
  environment     = "${var.environment}"
}

module "dns" {
  source = "./dns"
  vpc_id = "${module.vpc.id}"
  name   = "${var.domain_name}"
}

module "dhcp" {
  source  = "./dhcp"
  vpc_id  = "${module.vpc.id}"
  servers = "${coalesce(var.domain_name_servers, module.defaults.domain_name_servers)}"
  name    = "${module.dns.name}"
}

module "iam_role" {
  source      = "./iam-role"
  name        = "${var.name}"
  environment = "${var.environment}"
}

module "ecs_cluster" {
  source                     = "./ecs-cluster"
  name                       = "${coalesce(var.ecs_cluster_name, var.name)}"
  environment                = "${var.environment}"
  vpc_id                     = "${module.vpc.id}"
  image_id                   = "ami-050865a806e0dae53"                                                                                                                                                   // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
  subnet_ids                 = "${module.vpc.internal_subnets}"
  key_name                   = "${var.key_name}"
  instance_type              = "${var.ecs_instance_type}"
  instance_ebs_optimized     = false
  iam_instance_profile       = "${module.iam_role.profile}"
  min_size                   = "${var.ecs_min_size}"
  max_size                   = "${var.ecs_max_size}"
  desired_capacity           = "${var.ecs_desired_capacity}"
  region                     = "${var.region}"
  root_volume_size           = "${var.ecs_root_volume_size}"
  docker_volume_size         = "${var.ecs_docker_volume_size}"
  docker_auth_type           = "${var.ecs_docker_auth_type}"
  docker_auth_data           = "${var.ecs_docker_auth_data}"
  security_groups            = "${coalesce(var.ecs_security_groups, format("%s,%s,%s", module.security_groups.internal_ssh, module.security_groups.internal_elb, module.security_groups.external_elb))}"
  extra_cloud_config_type    = "${var.extra_cloud_config_type}"
  extra_cloud_config_content = "${var.extra_cloud_config_content}"
}

output "bastion_external_ip" {
  value = "${module.bastion.external_ip}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "zone_id" {
  value = "${module.dns.zone_id}"
}

output "cluster" {
  value = "${module.ecs_cluster.name}"
}

output "environment" {
  value = "${var.environment}"
}

output "internal_elb" {
  value = "${module.security_groups.internal_elb}"
}

output "external_elb" {
  value = "${module.security_groups.external_elb}"
}

output "internal_subnets" {
  value = "${module.vpc.internal_subnets}"
}

output "external_subnets" {
  value = "${module.vpc.external_subnets}"
}

output "iam_role" {
  value = "${module.iam_role.arn}"
}

output "iam_role_default_ecs_role_id" {
  value = "${module.iam_role.default_ecs_role_id}"
}
