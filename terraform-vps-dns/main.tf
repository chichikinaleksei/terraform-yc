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

  route_table_id = each.key == "subnet-b" ? yandex_vpc_route_table.k8s_private_rt.id : null

}


# Security Group для bastion-хоста (SSH)
resource "yandex_vpc_security_group" "bastion_sg" {
  count = var.create_bastion ? 1 : 0
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

# resource "yandex_vpc_security_group_rule" "bastion_allow_icmp_from_k8s" {
#   count = var.create_bastion ? 1 : 0
#   direction              = "ingress"
#   protocol               = "ICMP"
#   description            = "Allow ICMP from k8s subnet"
#   v4_cidr_blocks         = ["10.20.0.0/24"]
#   security_group_binding = yandex_vpc_security_group.bastion_sg[0].id
# }

resource "yandex_vpc_security_group_rule" "bastion_allow_icmp_from_k8s" {
  count              = var.create_bastion ? 1 : 0
  description        = "Allow ICMP from k8s subnet"
  direction          = "ingress"
  protocol           = "ICMP"
  v4_cidr_blocks     = ["10.20.0.0/24"]
  security_group_binding = yandex_vpc_security_group.bastion_sg[0].id


  lifecycle {
    ignore_changes = [security_group_id]
  }
}

locals {
  ssh_key_file = "/Users/chichikinaleksei/.ssh/id_ed25519.pub"
  ssh_key      = file(local.ssh_key_file)
}


# locals {
#   ssh_key_file = "/Users/chichikinaleksei/.ssh/id_ed25519.pub"
#   ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeXrvVSlJlp90oFVWAjh1rG56qZRuN1nb/ThmfMKfS8 chichikinaleksei@chichikin"
# }

resource "yandex_vpc_address" "bastion_static_ip" {
  count = var.create_bastion ? 1 : 0
  name  = "bastion-ip"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
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
    nat_ip_address     = yandex_vpc_address.bastion_static_ip[0].external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.bastion_sg[0].id]
  }


  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}

module "k8s_hosts" {
  source     = "./modules/k8s-hosts"
  subnet_id  = yandex_vpc_subnet.subnets["subnet-b"].id
  network_id = yandex_vpc_network.default.id
  security_group_ids = [module.k8s_hosts.k8s_sg_id]
  ssh_key    = local.ssh_key
  bastion_internal_ip = yandex_compute_instance.bastion[0].network_interface.0.ip_address


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

output "bastion_id" {
  value = var.create_bastion ? yandex_compute_instance.bastion[0].id : null
}

resource "yandex_storage_bucket" "tfstate" {
  bucket = "your-unique-bucket-name" # Use a globally unique name!
}

# NAT gateway for private subnets
resource "yandex_vpc_gateway" "nat" {
  name = "nat-gw"
}

# Route table that sends 0.0.0.0/0 to the NAT gateway
resource "yandex_vpc_route_table" "k8s_private_rt" {
  name       = "k8s-private-rt"
  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}