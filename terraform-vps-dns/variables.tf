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
    zone           = string
    cidr_block     = string
  }))
}

variable "dns_zone_name" {
  type    = string
  default = "example.com."
}
