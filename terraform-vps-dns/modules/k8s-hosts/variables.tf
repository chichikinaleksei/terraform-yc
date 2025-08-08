variable "vm_nodes" {
  description = "Map of VM node configurations"
  type = map(object({
    fqdn = string
    role = string
    zone = string
  }))
}

variable "subnet_id" {
  description = "Subnet ID for the Kubernetes nodes"
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "ssh_key" {
  description = "SSH public key for access"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to each VM"
  type        = list(string)
}

variable "bastion_internal_ip" {
  type        = string
  description = "Internal IP of the bastion host"
}
