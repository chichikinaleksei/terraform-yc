output "internal_ips" {
  description = "Internal IPs of Kubernetes hosts"
  value = {
    for name, instance in yandex_compute_instance.k8s_nodes :
    name => instance.network_interface[0].ip_address
  }
}


output "k8s_sg_id" {
  value = yandex_vpc_security_group.k8s_sg.id
}

output "hostnames" {
  description = "FQDNs of Kubernetes hosts"
  value = {
    for name, instance in yandex_compute_instance.k8s_nodes :
    name => instance.fqdn
  }
}

output "master_ip" {
  value = yandex_compute_instance.k8s_nodes["k8s-master"].network_interface[0].ip_address
}

output "worker_ip" {
  value = yandex_compute_instance.k8s_nodes["k8s-worker"].network_interface[0].ip_address
}

output "ingress_ip" {
  value = yandex_compute_instance.k8s_nodes["k8s-ingress"].network_interface[0].ip_address
}
