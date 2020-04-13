# Using multiple workspaces:
terraform {
  backend "azurerm" {
    resource_group_name  = "terraformsa"
    storage_account_name = "chizerterraform"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    # use_msi              = true
    # subscription_id      = "191f97dd-acdd-423c-aad7-b966e3511182"
    # tenant_id            = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  }
}
