# Outputs usados para validação pós-provisionamento e operação.
output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "subnet_app_id" {
  value = ibm_is_subnet.subnet_prod_app.id
}

output "subnet_db_id" {
  value = ibm_is_subnet.subnet_prod_db.id
}

output "subnet_public_id" {
  value = ibm_is_subnet.subnet_public.id
}

output "sei_private_ip" {
  value = ibm_is_instance.sei.primary_network_interface[0].primary_ip[0].address
}

output "solr_private_ip" {
  value = ibm_is_instance.solr.primary_network_interface[0].primary_ip[0].address
}

output "mariadb_private_ip" {
  value = ibm_is_instance.mariadb.primary_network_interface[0].primary_ip[0].address
}

output "bastion_private_ip" {
  value = var.bastion_enabled ? ibm_is_instance.bastion[0].primary_network_interface[0].primary_ip[0].address : null
}

output "bastion_public_ip" {
  value = var.bastion_enabled ? ibm_is_floating_ip.bastion[0].address : null
}

output "lb_hostname" {
  value = var.lb_enabled ? ibm_is_lb.sei[0].hostname : null
}

output "lb_public_ips" {
  value = var.lb_enabled ? ibm_is_lb.sei[0].public_ips : []
}

output "vpn_gateway_id" {
  value = var.vpn_enabled ? ibm_is_vpn_gateway.s2s[0].id : null
}

output "vpn_connection_ids" {
  value = var.vpn_enabled ? { for k, v in ibm_is_vpn_gateway_connection.peer : k => v.id } : {}
}
