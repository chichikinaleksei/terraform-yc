resource "yandex_dns_zone" "private_zone" {
  name             = "example-zone-alt"
  zone             = "alt.example.com."
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
  name    = "k8s-master.${var.domain_suffix}."
  type    = "A"
  ttl     = 300
  data    = [module.k8s_hosts.master_ip]
}

resource "yandex_dns_recordset" "worker" {
  zone_id = yandex_dns_zone.private_zone.id
  name    = "k8s-worker.${var.domain_suffix}."
  type    = "A"
  ttl     = 300
  data    = [module.k8s_hosts.worker_ip]
}

resource "yandex_dns_recordset" "ingress" {
  zone_id = yandex_dns_zone.private_zone.id
  name    = "k8s-ingress.${var.domain_suffix}."
  type    = "A"
  ttl     = 300
  data    = [module.k8s_hosts.ingress_ip]
}
