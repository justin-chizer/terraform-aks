# terraform-aks
Upskilling in Terraform and GitHub Actions


## Goals of this repo
 - Two peered VNets
 - One VNet containing AKS
 - One VNet with a Debian VM
 - Set up Azure Bastion to connect to the Debian VM
 - Demonstrate the Debian VM is able to reach a node in AKS
 - Infrastructure is set up using Terraform 0.12.24, azurerm provider 2.6.0, and Azure CLI 2.4.0
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

### Azure CLI using apt

```bash
# Update
az --version
sudo apt-get update && sudo apt-get upgrade
```

```bash
# Install
# This script is only verified for Ubuntu 16.04+ and Debian 8+
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## GitHub Actions

Create a Service Principal for Actions to use and store the JSON output as a secret in the repo as AZURE_CREDENTIALS

```bash
az ad sp create-for-rbac
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "azure-cli-2020-00-00-00-00-00",
  "name": "http://azure-cli-2020-00-00-00-00-00",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}