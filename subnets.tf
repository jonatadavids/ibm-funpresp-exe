# Subnets segmentadas por funcao (app, db, public).
resource "ibm_is_subnet" "subnet_prod_app" {
  name            = "${local.basename}-prod-app"
  vpc             = ibm_is_vpc.vpc.id
  zone            = local.zone
  ipv4_cidr_block = var.subnet_app_cidr
  tags            = local.common_tags
  depends_on      = [ibm_is_vpc_address_prefix.prefix_primary_zone]
}

resource "ibm_is_subnet" "subnet_prod_db" {
  name            = "${local.basename}-prod-db"
  vpc             = ibm_is_vpc.vpc.id
  zone            = local.zone
  ipv4_cidr_block = var.subnet_db_cidr
  tags            = local.common_tags
  depends_on      = [ibm_is_vpc_address_prefix.prefix_primary_zone]
}

resource "ibm_is_subnet" "subnet_public" {
  name            = "${local.basename}-public"
  vpc             = ibm_is_vpc.vpc.id
  zone            = local.zone
  ipv4_cidr_block = var.subnet_public_cidr
  tags            = local.common_tags
  depends_on      = [ibm_is_vpc_address_prefix.prefix_primary_zone]
}
