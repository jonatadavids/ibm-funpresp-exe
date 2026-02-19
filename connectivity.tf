# Conectividade de saida para subnets privadas via Public Gateway.
resource "ibm_is_public_gateway" "pgw" {
  count = var.create_public_gateway ? 1 : 0
  name  = "${local.basename}-pgw"
  vpc   = ibm_is_vpc.vpc.id
  zone  = local.zone
  tags  = local.common_tags
}

resource "ibm_is_subnet_public_gateway_attachment" "app" {
  count          = var.create_public_gateway && var.attach_public_gateway_to_app_subnet ? 1 : 0
  subnet         = ibm_is_subnet.subnet_prod_app.id
  public_gateway = ibm_is_public_gateway.pgw[0].id
}

resource "ibm_is_subnet_public_gateway_attachment" "db" {
  count          = var.create_public_gateway && var.attach_public_gateway_to_db_subnet ? 1 : 0
  subnet         = ibm_is_subnet.subnet_prod_db.id
  public_gateway = ibm_is_public_gateway.pgw[0].id
}
