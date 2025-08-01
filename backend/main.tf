terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.99"
    }
  }

  backend "s3" {}  # Конфигурация загружается из backend.hcl
}

provider "yandex" {
  service_account_key_file = "${path.module}/generated-key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
}