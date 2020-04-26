# Create a resource group
resource "azurerm_resource_group" "demo" {
  name     = var.rg
  location = var.region
}

# Upgrades to Standard Ddos protection
resource "azurerm_network_ddos_protection_plan" "demo" {
  name                = "ddospplan1"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
}

#Creates VNet and Subnet
module "VNet-aks" {
  source                  = "./modules/azure-vnet"
  location                = azurerm_resource_group.demo.location
  resource_group_name     = azurerm_resource_group.demo.name
  vnet_name               = "AKSVNet"
  address_space           = ["10.0.0.0/16"]
  ddos_protection_plan_id = azurerm_network_ddos_protection_plan.demo.id
  subnet_name             = "AKSsubnet"
  address_prefix          = "10.0.0.0/22"
  environment             = "prod"
}


# Create AKS
module "aks-1" {
  source                       = "./modules/aks"
  aks_name                     = "aksdemoapril"
  location                     = azurerm_resource_group.demo.location
  resource_group_name          = azurerm_resource_group.demo.name
  kubernetes_version           = "1.16.7"
  network_plugin               = "azure"
  network_policy               = "azure"
  service_cidr                 = "192.168.0.0/16"
  dns_service_ip               = "192.168.0.10"
  vnet_subnet_id               = module.VNet-aks.subnet_id
  default_node_pool_max_pods   = 50
  default_node_pool_vm_size    = "Standard_D2s_v3"
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 10
  default_node_pool_node_count = 3
}


############################################################################

#Creates VNet and Subnet
module "VNet-vm" {
  source                  = "./modules/azure-vnet"
  location                = azurerm_resource_group.demo.location
  resource_group_name     = azurerm_resource_group.demo.name
  vnet_name               = "vmvnet"
  address_space           = ["10.1.0.0/16"]
  ddos_protection_plan_id = azurerm_network_ddos_protection_plan.demo.id
  subnet_name             = "vmsubnet"
  address_prefix          = "10.1.0.0/24"
  environment             = "prod"
}

# Create the Debian
resource "azurerm_network_interface" "vm" {
  name                = "vm-nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.VNet-vm.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "debianvm"
  resource_group_name             = azurerm_resource_group.demo.name
  location                        = azurerm_resource_group.demo.location
  size                            = "Standard_D2S_v3"
  admin_username                  = "adminuser"
  admin_password                  = "Password!23"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  # admin_ssh_key {
  #   username = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }
}



resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = module.VNet-vm.virtual_network_name
  address_prefix       = "10.1.1.0/27"
}


resource "azurerm_public_ip" "bastion" {
  name                = "vmpip"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "debionbastion"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# Peer the VNets
resource "azurerm_virtual_network_peering" "aks" {
  name                      = "akstovm"
  resource_group_name       = azurerm_resource_group.demo.name
  virtual_network_name      = module.VNet-aks.virtual_network_name
  remote_virtual_network_id = module.VNet-vm.virtual_network_id
}

resource "azurerm_virtual_network_peering" "vm" {
  name                      = "vmtoaks"
  resource_group_name       = azurerm_resource_group.demo.name
  virtual_network_name      = module.VNet-vm.virtual_network_name
  remote_virtual_network_id = module.VNet-aks.virtual_network_id
}