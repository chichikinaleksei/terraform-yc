terraform {
  backend "s3" {
    bucket                      = "chichikin-terraform-state-bucket"
    key                         = "terraform-vps-dns/terraform.tfstate"
    region                      = "us-east-1"
    endpoints                   = { s3 = "https://storage.yandexcloud.net" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

