# Chave SSH importada para acesso administrativo as VSIs.
resource "ibm_is_ssh_key" "workload_key" {
  name       = "${local.basename}-ssh-key"
  public_key = file(var.ssh_public_key_path)
  tags       = local.common_tags
}

# Volume adicional para dados do MariaDB.
resource "ibm_is_volume" "mariadb_data" {
  name     = "${local.basename}-mariadb-data"
  profile  = "10iops-tier"
  zone     = local.zone
  capacity = var.db_data_volume_size_gb
  tags     = local.common_tags
}

# VSI SEI (prod-app)
resource "ibm_is_instance" "sei" {
  name    = "${local.basename}-sei"
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.zone
  keys    = [ibm_is_ssh_key.workload_key.id]
  image   = var.image_id_app
  profile = var.app_profile
  tags    = local.common_tags

  primary_network_interface {
    subnet = ibm_is_subnet.subnet_prod_app.id
    security_groups = [
      ibm_is_security_group.sg_admin.id,
      ibm_is_security_group.sg_app.id
    ]
  }
}

# VSI SOLR (prod-app)
resource "ibm_is_instance" "solr" {
  name    = "${local.basename}-solr"
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.zone
  keys    = [ibm_is_ssh_key.workload_key.id]
  image   = var.image_id_solr
  profile = var.app_profile
  tags    = local.common_tags

  primary_network_interface {
    subnet = ibm_is_subnet.subnet_prod_app.id
    security_groups = [
      ibm_is_security_group.sg_admin.id,
      ibm_is_security_group.sg_solr.id
    ]
  }
}

# VSI MariaDB (prod-db)
resource "ibm_is_instance" "mariadb" {
  name    = "${local.basename}-mariadb"
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.zone
  keys    = [ibm_is_ssh_key.workload_key.id]
  image   = var.image_id_db
  profile = var.db_profile
  tags    = local.common_tags

  primary_network_interface {
    subnet = ibm_is_subnet.subnet_prod_db.id
    security_groups = [
      ibm_is_security_group.sg_admin.id,
      ibm_is_security_group.sg_db.id
    ]
  }
}

resource "ibm_is_instance_volume_attachment" "mariadb_data" {
  instance                         = ibm_is_instance.mariadb.id
  volume                           = ibm_is_volume.mariadb_data.id
  name                             = "${local.basename}-mariadb-data-att"
  delete_volume_on_instance_delete = false
}

# VSI Bastion em subnet publica para acesso administrativo SSH.
resource "ibm_is_instance" "bastion" {
  count   = var.bastion_enabled ? 1 : 0
  name    = "${local.basename}-bastion"
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.zone
  keys    = [ibm_is_ssh_key.workload_key.id]
  image   = var.image_id_app
  profile = var.bastion_profile
  tags    = local.common_tags

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet_public.id
    security_groups = [ibm_is_security_group.sg_bastion[0].id]
  }
}

resource "ibm_is_floating_ip" "bastion" {
  count  = var.bastion_enabled ? 1 : 0
  name   = "${local.basename}-bastion-fip"
  target = ibm_is_instance.bastion[0].primary_network_interface[0].id
  tags   = local.common_tags
}
