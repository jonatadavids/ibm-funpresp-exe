# VPC principal do ambiente.
resource "ibm_is_vpc" "vpc" {
  name = "${local.basename}-vpc"
  tags = local.common_tags
}
