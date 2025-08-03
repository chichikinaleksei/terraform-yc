terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.147"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
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


# Security Group для bastion-хоста (SSH)
resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-ssh-sg"
  network_id = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group_rule" "bastion_allow_icmp_from_k8s" {
  direction              = "ingress"
  protocol               = "ICMP"
  description            = "Allow ICMP from k8s subnet"
  v4_cidr_blocks         = ["10.20.0.0/24"]
  security_group_binding = yandex_vpc_security_group.bastion_sg.id
}



locals {
  ssh_key_file = "~/.ssh/id_ed25519.pub"
  ssh_key      = fileexists(pathexpand(local.ssh_key_file)) ? file(pathexpand(local.ssh_key_file)) : ""
}

resource "yandex_compute_instance" "bastion" {
  count       = var.create_bastion ? 1 : 0
  name        = "bastion-host"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd842fimj1jg6vmfee6r" # Ubuntu 22.04 LTS
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets["subnet-a"].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}

module "k8s_hosts" {
  source     = "./modules/k8s-hosts"
  subnet_id  = yandex_vpc_subnet.subnets["subnet-b"].id
  network_id = yandex_vpc_network.default.id
  ssh_key    = local.ssh_key


  vm_nodes = {
    "k8s-master" = {
      fqdn = "k8s-master.example.com"
      role = "master"
      zone = "ru-central1-b"
    }
    "k8s-worker" = {
      fqdn = "k8s-worker.example.com"
      role = "worker"
      zone = "ru-central1-b"
    }
    "k8s-ingress" = {
      fqdn = "k8s-ingress.example.com"
      role = "ingress"
      zone = "ru-central1-b"
    }
  }
}

