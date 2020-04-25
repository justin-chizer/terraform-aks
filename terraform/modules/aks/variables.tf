variable "aks_name" {

}

variable "location" {

}

variable "resource_group_name" {

}

variable "kubernetes_version" {

}

variable "network_plugin" {

}

variable "network_policy" {

}

variable "docker_bridge_cidr" {
  default = "172.17.0.1/16"
}

variable "service_cidr" {

}

variable "dns_service_ip" {

}

variable "default_node_pool_name" {
  default = "default"
}

variable "default_node_pool_max_pods" {
  type = number
}

variable "default_node_pool_vm_size" {

}

variable "default_node_pool_min_count" {

}

variable "default_node_pool_max_count" {
  type = number
}

variable "default_node_pool_node_count" {
  type = number
}

variable "vnet_subnet_id" {

}
