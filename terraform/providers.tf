# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.7.0" #~>: pessimistic constraint operator, constraining both the oldest and newest version allowed. For example, ~> 0.9 is equivalent to >= 0.9, < 1.0, and ~> 0.8.4, is equivalent to >= 0.8.4, < 0.9
  features {}          #Required
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Configure Azure AD Provider
# provider "azuread" {
#  version = "~>0.8.0"
#}