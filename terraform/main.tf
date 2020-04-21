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

# #Creates VNet and Subnet
# resource "azurerm_virtual_network" "aks" {
#   name                = "aksvnet"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name
#   address_space       = ["10.0.0.0/16"]

#   ddos_protection_plan {
#     id     = azurerm_network_ddos_protection_plan.aks.id
#     enable = true
#   }

#   tags = {
#     environment = "Production"
#   }
# }

# # Create the AKS Subnet
# resource "azurerm_subnet" "aks" {
#   name                 = "akssubnet"
#   resource_group_name  = azurerm_resource_group.aks.name
#   virtual_network_name = azurerm_virtual_network.aks.name
#   address_prefix       = "10.0.0.0/22"
# }



module "VNet-aks" {
  source                  = "./modules/azure-vnet"
  location                = azurerm_resource_group.aks.location
  resource_group_name     = azurerm_resource_group.aks.name
  vnet_name               = "AKSVNet"
  address_space           = ["10.0.0.0/16"]
  ddos_protection_plan_id = azurerm_network_ddos_protection_plan.aks.id
  subnet_name             = "AKSsubnet"
  address_prefix          = "10.0.0.0/22"
  environment             = "prod"
}


# Create AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "disneyaks2"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "disneyaksdns"
  kubernetes_version  = "1.16.7"


  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "192.168.0.0/16"
    dns_service_ip     = "192.168.0.10"
    load_balancer_sku  = "Standard"
  }

  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_pods            = 50
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id      = module.VNet-aks.subnet_id
    min_count           = 1
    max_count           = 10
    node_count          = 3

  }
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }

  identity {
    type = "SystemAssigned"
  }
}

############################################################################



#Creates VNet for VM
resource "azurerm_virtual_network" "vm" {
  name                = "vmvnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.1.0.0/16"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.aks.id
    enable = true
  }

  tags = {
    environment = "Production"
  }
}

# Create the VM Subnet
resource "azurerm_subnet" "vm" {
  name                 = "vmsubnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefix       = "10.1.0.0/24"
}

resource "azurerm_network_interface" "vm" {
  name                = "vm-nic"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                = "debianvm"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    #public_key = file("~/.ssh/id_rsa.pub")
    admin_password = "Password!23"
  }

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
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefix       = "10.1.1.0/27"
}


resource "azurerm_public_ip" "bastion" {
  name                = "vmpip"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "debionbastion"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}


# Peer the VNets
resource "azurerm_virtual_network_peering" "aks" {
  name                      = "akstovm"
  resource_group_name       = azurerm_resource_group.aks.name
  virtual_network_name      = module.VNet-aks.virtual_network_name
  remote_virtual_network_id = azurerm_virtual_network.vm.id
}

resource "azurerm_virtual_network_peering" "vm" {
  name                      = "vmtoaks"
  resource_group_name       = azurerm_resource_group.aks.name
  virtual_network_name      = azurerm_virtual_network.vm.name
  remote_virtual_network_id = module.VNet-aks.virtual_network_id
}