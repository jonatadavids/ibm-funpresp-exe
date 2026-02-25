terraform {
  backend "s3" {
    bucket = "terraform-state-funpresp"
    key    = "funpresp/foundational/terraform.tfstate"
    region = "br-sao"

    # IBM COS (S3 compatible)
    endpoints = {
      s3 = "https://s3.br-sao.cloud-object-storage.appdomain.cloud"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.88.3"
    }
  }
}

# Provider IBM Cloud para todos os recursos deste projeto.
provider "ibm" {
  # pega automaticamente do env var IC_API_KEY
  region = var.region
}
