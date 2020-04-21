#Creates VNet and Subnet
resource "azurerm_virtual_network" "virtual_network" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  ddos_protection_plan {
    id     = var.ddos_protection_plan_id
    enable = true
  }

  tags = {
    environment = var.environment
  }
}

# Create the AKS Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefix       = var.address_prefix
}