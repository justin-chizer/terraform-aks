# Create AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_name}-dns" #String Interpolation example
  kubernetes_version  = var.kubernetes_version


  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    docker_bridge_cidr = var.docker_bridge_cidr
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    load_balancer_sku  = "Standard"
  }

  default_node_pool {
    name                = var.default_node_pool_name
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_pods            = var.default_node_pool_max_pods
    vm_size             = var.default_node_pool_vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    min_count           = var.default_node_pool_min_count
    max_count           = var.default_node_pool_max_count
    node_count          = var.default_node_pool_node_count

  }
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }

  identity {
    type = "SystemAssigned"
  }
}