terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.147"
    }
  }
}

provider "yandex" {
  cloud_id               = var.cloud_id
  folder_id              = var.folder_id
  service_account_key_file = "${path.module}/generated-key.json"
}


# Создание VPC
resource "yandex_vpc_network" "default" {
  name = var.network_name
}

# Создание подсетей с помощью for_each
resource "yandex_vpc_subnet" "subnets" {
  for_each       = var.subnets
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = [each.value.cidr_block]
}

# Приватная DNS-зона
resource "yandex_dns_zone" "private_zone" {
  name        = "private-zone"
  zone        = var.dns_zone_name
  public      = false
  folder_id   = var.folder_id
  description = "Private zone for internal resolution"
  private_networks = [
    yandex_vpc_network.default.id
  ]
}
