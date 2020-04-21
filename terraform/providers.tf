# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.6.0" #~>: pessimistic constraint operator, constraining both the oldest and newest version allowed. For example, ~> 0.9 is equivalent to >= 0.9, < 1.0, and ~> 0.8.4, is equivalent to >= 0.8.4, < 0.9
  features{} #Required
}

# Configure Azure AD Provider
# provider "azuread" {
#  version = "~>0.8.0"
#}