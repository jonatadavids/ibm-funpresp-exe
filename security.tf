# Security Groups e regras de trafego do ambiente.
# -----------------------
# Security Groups
# -----------------------

# Equivalente ao sg_coinf (administrativo/legado).
resource "ibm_is_security_group" "sg_admin" {
  name = "${local.basename}-sg-admin"
  vpc  = ibm_is_vpc.vpc.id
  tags = local.common_tags
}

# Equivalente ao SG da aplicacao.
resource "ibm_is_security_group" "sg_app" {
  name = "${local.basename}-sg-app"
  vpc  = ibm_is_vpc.vpc.id
  tags = local.common_tags
}

# Equivalente ao SG do Solr.
resource "ibm_is_security_group" "sg_solr" {
  name = "${local.basename}-sg-solr"
  vpc  = ibm_is_vpc.vpc.id
  tags = local.common_tags
}

# Equivalente ao sg_dbs.
resource "ibm_is_security_group" "sg_db" {
  name = "${local.basename}-sg-db"
  vpc  = ibm_is_vpc.vpc.id
  tags = local.common_tags
}

# SG dedicado do Load Balancer (equivalente ao sg_internet).
resource "ibm_is_security_group" "sg_lb" {
  count = var.lb_enabled ? 1 : 0
  name  = "${local.basename}-sg-lb"
  vpc   = ibm_is_vpc.vpc.id
  tags  = local.common_tags
}

# -----------------------
# INBOUND rules - SG ADMIN
# -----------------------

resource "ibm_is_security_group_rule" "admin_in_ssh_vpn" {
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = var.admin_cidr

  protocol = "tcp"
  port_min = 22
  port_max = 22
}

resource "ibm_is_security_group_rule" "admin_in_rdp_vpn" {
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = var.admin_cidr

  protocol = "tcp"
  port_min = 3389
  port_max = 3389
}

resource "ibm_is_security_group_rule" "admin_in_rdp_extra" {
  for_each  = toset(var.admin_rdp_cidrs)
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = each.value

  protocol = "tcp"
  port_min = 3389
  port_max = 3389
}

resource "ibm_is_security_group_rule" "admin_in_all_protocol_tcp" {
  for_each  = toset(var.admin_all_protocol_cidrs)
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = each.value

  protocol = "tcp"
  port_min = 1
  port_max = 65535
}

resource "ibm_is_security_group_rule" "admin_in_all_protocol_udp" {
  for_each  = toset(var.admin_all_protocol_cidrs)
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = each.value

  protocol = "udp"
  port_min = 1
  port_max = 65535
}

resource "ibm_is_security_group_rule" "admin_in_all_protocol_icmp" {
  for_each  = toset(var.admin_all_protocol_cidrs)
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = each.value

  protocol = "icmp"
}

resource "ibm_is_security_group_rule" "admin_in_tcp_full" {
  for_each  = toset(var.admin_tcp_full_cidrs)
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = each.value

  protocol = "tcp"
  port_min = 1
  port_max = 65535
}

resource "ibm_is_security_group_rule" "admin_in_sql_1433" {
  for_each  = toset(var.admin_sql_1433_cidrs)
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = each.value

  protocol = "tcp"
  port_min = 1433
  port_max = 1433
}

resource "ibm_is_security_group_rule" "admin_in_wsus_8530" {
  count     = var.admin_wsus_cidr == null ? 0 : 1
  group     = ibm_is_security_group.sg_admin.id
  direction = "inbound"
  remote    = var.admin_wsus_cidr

  protocol = "tcp"
  port_min = 8530
  port_max = 8530
}

# -----------------------
# INBOUND rules - SGs de funcao
# -----------------------

# Aplicacao recebe 443 (na AWS havia sg_internet; aqui estamos mantendo via rede administrativa).
resource "ibm_is_security_group_rule" "app_in_https_admin" {
  group     = ibm_is_security_group.sg_app.id
  direction = "inbound"
  remote    = var.admin_cidr

  protocol = "tcp"
  port_min = var.app_port
  port_max = var.app_port
}

# Aplicacao recebe HTTPS do Load Balancer.
resource "ibm_is_security_group_rule" "app_in_https_lb" {
  count     = var.lb_enabled ? 1 : 0
  group     = ibm_is_security_group.sg_app.id
  direction = "inbound"
  remote    = ibm_is_security_group.sg_lb[0].id

  protocol = "tcp"
  port_min = var.app_port
  port_max = var.app_port
}

# Solr recebe trafego apenas da aplicacao.
resource "ibm_is_security_group_rule" "solr_in_from_app" {
  group     = ibm_is_security_group.sg_solr.id
  direction = "inbound"
  remote    = ibm_is_security_group.sg_app.id

  protocol = "tcp"
  port_min = var.solr_port
  port_max = var.solr_port
}

# MariaDB recebe trafego apenas da aplicacao.
resource "ibm_is_security_group_rule" "db_in_from_app" {
  group     = ibm_is_security_group.sg_db.id
  direction = "inbound"
  remote    = ibm_is_security_group.sg_app.id

  protocol = "tcp"
  port_min = var.db_port
  port_max = var.db_port
}

# -----------------------
# OUTBOUND rules
# -----------------------

# Paridade com sg_coinf/sg_internet: egress aberto.
resource "ibm_is_security_group_rule" "admin_out_all_tcp" {
  group     = ibm_is_security_group.sg_admin.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  protocol = "tcp"
  port_min = 1
  port_max = 65535
}

resource "ibm_is_security_group_rule" "admin_out_all_udp" {
  group     = ibm_is_security_group.sg_admin.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  protocol = "udp"
  port_min = 1
  port_max = 65535
}

resource "ibm_is_security_group_rule" "admin_out_all_icmp" {
  group     = ibm_is_security_group.sg_admin.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  protocol = "icmp"
}

# Aplicacao pode consultar MariaDB.
resource "ibm_is_security_group_rule" "app_out_db" {
  group     = ibm_is_security_group.sg_app.id
  direction = "outbound"
  remote    = ibm_is_security_group.sg_db.id

  protocol = "tcp"
  port_min = var.db_port
  port_max = var.db_port
}

# Aplicacao pode consultar Solr.
resource "ibm_is_security_group_rule" "app_out_solr" {
  group     = ibm_is_security_group.sg_app.id
  direction = "outbound"
  remote    = ibm_is_security_group.sg_solr.id

  protocol = "tcp"
  port_min = var.solr_port
  port_max = var.solr_port
}

# Paridade com sg_dbs: egress TCP para VPC.
resource "ibm_is_security_group_rule" "db_out_vpc_tcp" {
  group     = ibm_is_security_group.sg_db.id
  direction = "outbound"
  remote    = var.vpc_cidr

  protocol = "tcp"
  port_min = 1
  port_max = 65535
}

# Paridade com sg_dbs: egress TCP para SG administrativo.
resource "ibm_is_security_group_rule" "db_out_admin_tcp" {
  group     = ibm_is_security_group.sg_db.id
  direction = "outbound"
  remote    = ibm_is_security_group.sg_admin.id

  protocol = "tcp"
  port_min = 1
  port_max = 65535
}

# -----------------------
# LB rules
# -----------------------

resource "ibm_is_security_group_rule" "lb_in_http_public" {
  count     = var.lb_enabled ? 1 : 0
  group     = ibm_is_security_group.sg_lb[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  protocol = "tcp"
  port_min = var.lb_listener_http_port
  port_max = var.lb_listener_http_port
}

resource "ibm_is_security_group_rule" "lb_in_https_public" {
  count     = var.lb_enabled ? 1 : 0
  group     = ibm_is_security_group.sg_lb[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  protocol = "tcp"
  port_min = var.lb_listener_https_port
  port_max = var.lb_listener_https_port
}

resource "ibm_is_security_group_rule" "lb_out_to_app_https" {
  count     = var.lb_enabled ? 1 : 0
  group     = ibm_is_security_group.sg_lb[0].id
  direction = "outbound"
  remote    = ibm_is_security_group.sg_app.id

  protocol = "tcp"
  port_min = var.app_port
  port_max = var.app_port
}
