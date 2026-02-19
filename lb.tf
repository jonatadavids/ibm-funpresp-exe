# Load Balancer publico para terminação TLS e encaminhamento ao SEI.
resource "ibm_is_lb" "sei" {
  count           = var.lb_enabled ? 1 : 0
  name            = "${local.basename}-${var.lb_name}"
  subnets         = [ibm_is_subnet.subnet_public.id]
  profile         = "network-fixed"
  type            = var.lb_type
  security_groups = [ibm_is_security_group.sg_lb[0].id]
  tags            = local.common_tags
}

resource "ibm_is_lb_pool" "sei_https" {
  count              = var.lb_enabled ? 1 : 0
  lb                 = ibm_is_lb.sei[0].id
  name               = "${local.basename}-tg-sei-prd-https"
  algorithm          = "round_robin"
  protocol           = "https"
  health_type        = "https"
  health_monitor_url = var.lb_health_path
  health_delay       = var.lb_health_delay
  health_timeout     = var.lb_health_timeout
  health_retries     = var.lb_health_retries
}

resource "ibm_is_lb_pool_member" "sei" {
  count          = var.lb_enabled ? 1 : 0
  lb             = ibm_is_lb.sei[0].id
  pool           = ibm_is_lb_pool.sei_https[0].id
  port           = var.app_port
  target_address = ibm_is_instance.sei.primary_network_interface[0].primary_ip[0].address
}

resource "ibm_is_lb_listener" "https" {
  count                = var.lb_enabled ? 1 : 0
  lb                   = ibm_is_lb.sei[0].id
  protocol             = "https"
  port                 = var.lb_listener_https_port
  default_pool         = ibm_is_lb_pool.sei_https[0].id
  certificate_instance = var.lb_certificate_crn
}

resource "ibm_is_lb_listener" "http" {
  count    = var.lb_enabled ? 1 : 0
  lb       = ibm_is_lb.sei[0].id
  protocol = "http"
  port     = var.lb_listener_http_port

  https_redirect {
    http_status_code = 301

    listener {
      id = ibm_is_lb_listener.https[0].listener_id
    }
  }
}
