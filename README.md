# terraform-aks
Upskilling in Terraform and Azure DevOps


## Goals of this repo
 - Two peered VNets
 - One VNet containing AKS
 - One VNet with a Debian VM
 - Set up Azure Bastion to connect to the Debian VM
 - Demonstrate the Debian VM is able to reach a node in AKS
 - Infrastructure is set up using Terraform 0.12.24 and azurerm provider 2.6.0
 - Have a DevOps Release Pipline deploy Terraform with statefiles in appropriate storage account



## Installing Terrfaorm on Linux
```bash
sudo apt-get install unzip
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

Check for the latest [azurerm provider version](https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/CHANGELOG.md)

