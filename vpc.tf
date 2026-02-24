# VPC principal do ambiente.
resource "ibm_is_vpc" "vpc" {
  name                      = "${local.basename}-vpc"
  address_prefix_management = "manual"
  tags                      = local.common_tags
}

# Prefixo de endereço da VPC para a zona alvo.
resource "ibm_is_vpc_address_prefix" "prefix_primary_zone" {
  name = "${local.basename}-prefix-${replace(local.zone, "-", "")}"
  vpc  = ibm_is_vpc.vpc.id
  zone = local.zone
  cidr = var.vpc_cidr
}
