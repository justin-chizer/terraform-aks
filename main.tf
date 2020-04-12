# Create a resource group
resource "azurerm_resource_group" "aks" {
  name     = var.rg
  location = var.region
}

# Upgrades to Standard Ddos protection
resource "azurerm_network_ddos_protection_plan" "aks" {
  name                = "ddospplan1"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

#Creates VNet and Subnet
resource "azurerm_virtual_network" "aks" {
  name                = "aksvnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.0.0.0/16"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.aks.id
    enable = true
  }

  tags = {
    environment = "Production"
  }
}

# Create the AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "akssubnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefix       = "10.0.0.0/22"
}

# Create AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "disneyaks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "disneyaksdns"
  kubernetes_version  = "1.16.7"


  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr      = "192.168.0.0/16"
    dns_service_ip    = "192.168.0.10"
    load_balancer_sku = "Standard"
  }

  default_node_pool {
    name       = "default"
    type       = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_pods   = 50
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
    min_count  = 1
    max_count  = 10
    node_count = 3

  }

  identity {
    type = "SystemAssigned"
  }
}