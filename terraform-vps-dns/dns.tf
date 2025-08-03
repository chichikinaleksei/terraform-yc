resource "yandex_dns_zone" "private_zone" {
  name             = "example-zone"
  zone             = "example.com."
  description      = "Private DNS zone for Kubernetes nodes"
  folder_id        = var.folder_id
  public           = false
  private_networks = [yandex_vpc_network.default.id]

  labels = {
    environment = "dev"
  }
}

resource "yandex_dns_recordset" "master" {
  zone_id = yandex_dns_zone.private_zone.id
  name    = "k8s-master"
  type    = "A"
  ttl     = 300
  data    = ["10.20.0.32"]  # ✅ master
}

resource "yandex_dns_recordset" "worker" {
  zone_id = yandex_dns_zone.private_zone.id
  name    = "k8s-worker"
  type    = "A"
  ttl     = 300
  data    = ["10.20.0.9"]   # ✅ worker
}

resource "yandex_dns_recordset" "ingress" {
  zone_id = yandex_dns_zone.private_zone.id
  name    = "k8s-ingress"
  type    = "A"
  ttl     = 300
  data    = ["10.20.0.12"]  # ✅ ingress
}
