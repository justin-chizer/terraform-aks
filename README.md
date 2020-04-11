# terraform-aks
Upskilling in Terraform and Azure DevOps


## Goals of this repo
 - Two peered VNets
 - One VNet containing AKS
 - One VNet with a Debian VM
 - Set up Azure Bastion to connect to the Debian VM
 - Demonstrate the Debian VM is able to reach a pod in AKS
 - Infrastructure is set up using Terraform 0.12.24 and azurerm provider 2.5.0
 - Have a DevOps Release Pipline deploy Terraform with statefiles in appropriate storage account
 


 ## Steps

1. Create a Azure Storage Account and a Container
2. 