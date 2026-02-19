# Convenções locais de nome e tags.
locals {
  basename    = var.basename
  zone        = var.zone
  common_tags = concat(var.resource_tags, ["workload:sei"])
}
