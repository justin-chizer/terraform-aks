# Using multiple workspaces:
terraform {
  backend "azurerm" {
    resource_group_name  = "terraformsa"
    storage_account_name = "chizerterraform"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
  }
}
