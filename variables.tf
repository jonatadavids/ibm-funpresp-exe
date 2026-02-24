# Variáveis de entrada do projeto.
variable "region" {
  type        = string
  description = "Regiao da IBM Cloud"
}

variable "zone" {
  type        = string
  description = "Zona da IBM Cloud"
}

variable "basename" {
  type        = string
  description = "Prefixo padrao para nomear recursos"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Caminho local para a chave publica SSH (.pub)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC"
}

variable "admin_cidr" {
  type        = string
  description = "CIDR da rede administrativa (VPN/On-prem)"
}

variable "admin_rdp_cidrs" {
  type        = list(string)
  description = "CIDRs com acesso RDP administrativo (3389)"
  default     = []
}

variable "admin_all_protocol_cidrs" {
  type        = list(string)
  description = "CIDRs legados com acesso all/all (paridade com ambiente AWS)"
  default     = []
}

variable "admin_tcp_full_cidrs" {
  type        = list(string)
  description = "CIDRs com acesso TCP 0-65535"
  default     = []
}

variable "admin_wsus_cidr" {
  type        = string
  description = "CIDR/host para WSUS (porta 8530)"
  default     = null
}

variable "admin_sql_1433_cidrs" {
  type        = list(string)
  description = "CIDRs legados com acesso SQL Server 1433"
  default     = []
}

variable "subnet_app_cidr" {
  type        = string
  description = "CIDR da subnet de aplicacoes"
}

variable "subnet_db_cidr" {
  type        = string
  description = "CIDR da subnet de banco"
}

variable "subnet_public_cidr" {
  type        = string
  description = "CIDR da subnet publica"
}

variable "app_profile" {
  type        = string
  description = "Profile IBM Cloud para servidor de aplicacao"
}

variable "db_profile" {
  type        = string
  description = "Profile IBM Cloud para servidor de banco"
}

variable "bastion_enabled" {
  type        = bool
  description = "Se deve criar servidor bastion para acesso administrativo"
  default     = false
}

variable "bastion_profile" {
  type        = string
  description = "Profile IBM Cloud para servidor bastion"
  default     = "bx2-2x4"
}

variable "image_id_app" {
  type        = string
  description = "ID da imagem IBM Cloud para o servidor SEI (app)"
}

variable "image_id_solr" {
  type        = string
  description = "ID da imagem IBM Cloud para o servidor Solr"
}

variable "image_id_db" {
  type        = string
  description = "ID da imagem IBM Cloud para o servidor MariaDB"
}

variable "app_port" {
  type        = number
  description = "Porta de entrada da aplicacao"
}

variable "solr_port" {
  type        = number
  description = "Porta de comunicacao com Solr"
}

variable "db_port" {
  type        = number
  description = "Porta de comunicacao com MariaDB"
}

variable "db_data_volume_size_gb" {
  type        = number
  description = "Tamanho do volume de dados do banco em GB"
}

variable "resource_tags" {
  type        = list(string)
  description = "Tags comuns para os recursos"
  default     = []
}

variable "resource_group_id" {
  type        = string
  description = "ID do resource group na IBM Cloud"
  default     = null
}

variable "create_public_gateway" {
  type        = bool
  description = "Se deve criar Public Gateway para saida de internet"
  default     = true
}

variable "attach_public_gateway_to_app_subnet" {
  type        = bool
  description = "Anexa Public Gateway na subnet de aplicacao"
  default     = true
}

variable "attach_public_gateway_to_db_subnet" {
  type        = bool
  description = "Anexa Public Gateway na subnet de banco"
  default     = false
}

variable "lb_enabled" {
  type        = bool
  description = "Se deve criar Load Balancer para o SEI"
  default     = true
}

variable "lb_name" {
  type        = string
  description = "Nome do Load Balancer"
  default     = "alb-sei-prd"
}

variable "lb_type" {
  type        = string
  description = "Tipo do Load Balancer (public, private ou private_path)"
  default     = "public"
}

variable "lb_listener_http_port" {
  type        = number
  description = "Porta HTTP do listener do LB"
  default     = 80
}

variable "lb_listener_https_port" {
  type        = number
  description = "Porta HTTPS do listener do LB"
  default     = 443
}

variable "lb_certificate_crn" {
  type        = string
  description = "CRN do certificado na IBM Cloud (Secrets Manager/Certificate Manager)"
  default     = null
}

variable "lb_health_path" {
  type        = string
  description = "Path de health check do pool"
  default     = "/"
}

variable "lb_health_delay" {
  type        = number
  description = "Intervalo de health check em segundos"
  default     = 30
}

variable "lb_health_timeout" {
  type        = number
  description = "Timeout de health check em segundos"
  default     = 5
}

variable "lb_health_retries" {
  type        = number
  description = "Numero de tentativas antes de marcar unhealthy"
  default     = 2
}

variable "vpn_enabled" {
  type        = bool
  description = "Se deve criar VPN site-to-site"
  default     = true
}

variable "vpn_name" {
  type        = string
  description = "Nome do VPN Gateway"
  default     = "vpn-funpresp-ibm"
}

variable "vpn_mode" {
  type        = string
  description = "Modo do VPN Gateway (policy ou route)"
  default     = "policy"
}

variable "vpn_local_cidr" {
  type        = string
  description = "CIDR local da nuvem na VPN"
  default     = "10.60.0.0/16"
}

variable "vpn_remote_cidr" {
  type        = string
  description = "CIDR remoto on-prem na VPN"
  default     = "10.1.0.0/16"
}

variable "vpn_peer_gateways" {
  type        = map(string)
  description = "Mapa nome -> IP publico dos peers on-prem"
  default = {
    CLICKNET = "190.103.170.82"
    ALLREDE  = "131.100.149.18"
    NWI      = "189.85.93.174"
  }
}

variable "vpn_preshared_keys" {
  type        = map(string)
  description = "Mapa nome -> PSK para cada peer VPN"
  default     = {}
  sensitive   = true
}

variable "vpn_ike_encryption_algorithm" {
  type        = string
  description = "Algoritmo de criptografia IKE"
  default     = "aes256"
}

variable "vpn_ike_authentication_algorithm" {
  type        = string
  description = "Algoritmo de autenticacao IKE"
  default     = "sha256"
}

variable "vpn_ike_dh_group" {
  type        = number
  description = "Grupo DH do IKE"
  default     = 14
}

variable "vpn_ike_key_lifetime" {
  type        = number
  description = "Lifetime IKE em segundos"
  default     = 28800
}

variable "vpn_ipsec_encryption_algorithm" {
  type        = string
  description = "Algoritmo de criptografia IPsec"
  default     = "aes256"
}

variable "vpn_ipsec_authentication_algorithm" {
  type        = string
  description = "Algoritmo de autenticacao IPsec"
  default     = "sha256"
}

variable "vpn_ipsec_pfs" {
  type        = string
  description = "PFS do IPsec"
  default     = "group_14"
}

variable "vpn_ipsec_key_lifetime" {
  type        = number
  description = "Lifetime IPsec em segundos"
  default     = 3600
}
