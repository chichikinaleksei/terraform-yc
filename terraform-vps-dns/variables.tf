variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "network_name" {
  type    = string
  default = "vpc-net"
}

variable "subnets" {
  type = map(object({
    zone       = string
    cidr_block = string
  }))
}

variable "dns_zone_name" {
  type    = string
  default = "example.com."
}

variable "bastion_instance_count" {
  description = "Number of bastion hosts to create"
  type        = number
  default     = 1
}

# variable "bastion_public_ssh_key" {
#   description = "Public SSH key for accessing bastion host"
#   type        = string
# }

variable "create_bastion" {
  description = "Создавать ли bastion-хост"
  type        = bool
  default     = true
}
