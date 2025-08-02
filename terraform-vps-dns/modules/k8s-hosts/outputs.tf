output "internal_ips" {
  description = "Internal IPs of Kubernetes hosts"
  value = {
    for name, instance in yandex_compute_instance.k8s_nodes :
    name => instance.network_interface[0].ip_address
  }
}

output "hostnames" {
  description = "FQDNs of Kubernetes hosts"
  value = {
    for name, instance in yandex_compute_instance.k8s_nodes :
    name => instance.fqdn
  }
}
