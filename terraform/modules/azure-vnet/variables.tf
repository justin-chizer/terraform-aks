variable "location" {
  default = "westus2"
}

variable "resource_group_name" {
  
}

variable "vnet_name" {
  description = "Name of the Vnet"
}

variable "address_space" {
  default = ["10.0.0.0/16"]
}


variable "subnet_name" {
  
}

variable "address_prefix" {
  default = "10.0.0.0/22"
}

variable "environment" {
  
}

variable "ddos_protection_plan_id" {
  
}
