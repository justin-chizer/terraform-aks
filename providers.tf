# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.5.0" #~>: pessimistic constraint operator, constraining both the oldest and newest version allowed. For example, ~> 0.9 is equivalent to >= 0.9, < 1.0, and ~> 0.8.4, is equivalent to >= 0.8.4, < 0.9
  use_msi = true
  features{} #Required

# Configure backend storage for the state file
  backend "azurerm" {
    storage_account_name = "chizerterraform" # Must be unique
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    subscription_id      = "191f97dd-acdd-423c-aad7-b966e3511182" # az account list
    tenant_id            = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  }
}

