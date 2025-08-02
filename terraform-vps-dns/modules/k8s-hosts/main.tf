# modules/k8s-hosts/main.tf
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.147"
    }
  }
}

resource "yandex_compute_instance" "k8s_nodes" {
  for_each    = var.vm_nodes
  name        = each.key
  hostname    = "${each.key}.example.com"
  platform_id = "standard-v1"
  zone        = each.value.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd842fimj1jg6vmfee6r"  # Ubuntu 22.04 LTS
    }
  }

  network_interface {
    subnet_id           = var.subnet_id
    nat                 = false
    security_group_ids  = [yandex_vpc_security_group.k8s_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

resource "yandex_vpc_security_group" "k8s_sg" {
  name       = "k8s-nodes-sg"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from bastion"
    port           = 22
    v4_cidr_blocks = ["10.10.0.0/24"]  # подсеть bastion
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
