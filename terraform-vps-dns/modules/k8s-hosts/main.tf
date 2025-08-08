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
    subnet_id          = var.subnet_id
    nat                = false
    security_group_ids = var.security_group_ids
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

resource "yandex_vpc_security_group" "k8s_sg" {
  name       = "k8s-sg"
  network_id = var.network_id
}

resource "yandex_vpc_security_group_rule" "k8s_ingress" {
  security_group_binding = yandex_vpc_security_group.k8s_sg.id
  direction              = "ingress"
  protocol               = "ANY"
  description            = "Allow all traffic from this SG"
  security_group_id      = yandex_vpc_security_group.k8s_sg.id
}

resource "yandex_vpc_security_group_rule" "k8s_egress" {
  security_group_binding = yandex_vpc_security_group.k8s_sg.id
  direction              = "egress"
  protocol               = "ANY"
  description            = "Allow all egress"
  v4_cidr_blocks         = ["0.0.0.0/0"]
}

resource "yandex_vpc_security_group_rule" "allow_ssh_from_bastion" {
  security_group_binding = yandex_vpc_security_group.k8s_sg.id
  direction              = "ingress"
  protocol               = "TCP"
  description            = "Allow SSH from bastion"
  port                   = 22
  v4_cidr_blocks = ["${var.bastion_internal_ip}/32"]
}