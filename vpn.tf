# VPN Site-to-Site (policy-based) entre IBM Cloud e ambiente on-prem.
resource "ibm_is_ike_policy" "vpn" {
  count                    = var.vpn_enabled ? 1 : 0
  name                     = "${local.basename}-ike"
  authentication_algorithm = var.vpn_ike_authentication_algorithm
  encryption_algorithm     = var.vpn_ike_encryption_algorithm
  dh_group                 = var.vpn_ike_dh_group
  ike_version              = 2
  key_lifetime             = var.vpn_ike_key_lifetime
}

resource "ibm_is_ipsec_policy" "vpn" {
  count                    = var.vpn_enabled ? 1 : 0
  name                     = "${local.basename}-ipsec"
  authentication_algorithm = var.vpn_ipsec_authentication_algorithm
  encryption_algorithm     = var.vpn_ipsec_encryption_algorithm
  pfs                      = var.vpn_ipsec_pfs
  key_lifetime             = var.vpn_ipsec_key_lifetime
}

resource "ibm_is_vpn_gateway" "s2s" {
  count  = var.vpn_enabled ? 1 : 0
  name   = "${local.basename}-${var.vpn_name}"
  subnet = ibm_is_subnet.subnet_public.id
  mode   = var.vpn_mode
  tags   = local.common_tags
}

resource "ibm_is_vpn_gateway_connection" "peer" {
  for_each = var.vpn_enabled ? var.vpn_peer_gateways : {}

  name          = "${local.basename}-vpn-${lower(each.key)}"
  vpn_gateway   = ibm_is_vpn_gateway.s2s[0].id
  preshared_key = lookup(var.vpn_preshared_keys, each.key, "CHANGE_ME_PSK")
  ike_policy    = ibm_is_ike_policy.vpn[0].id
  ipsec_policy  = ibm_is_ipsec_policy.vpn[0].id

  peer {
    address = each.value
    cidrs   = [var.vpn_remote_cidr]
  }

  local {
    cidrs = [var.vpn_local_cidr]
  }
}
