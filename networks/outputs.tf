output "vpc_name" {
  value = "${module.vpc.name}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "azs" {
  value = "${module.vpc.azs}"
}

output "cidr_block" {
  value = "${module.vpc.vpc_cidr_block}"
}

output "vpc_arn" {
  value = "${module.vpc.vpc_arn}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}
