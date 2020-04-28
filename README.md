![Terraform GitHub Actions](https://github.com/justin-chizer/terraform-aks/workflows/Terraform%20GitHub%20Actions/badge.svg?branch=master)
# terraform-aks
Upskilling in Terraform and GitHub Actions


## Goals of this repo
 - [x] Infrastructure is set up using Terraform 0.12.24, azurerm provider 2.7.0, and Azure CLI 2.4.0.
 - [x] Create two VNets with their own subnet. (Make sure the cidr range does not overlap).
 - [x] Deploy an AKS cluster into one of the VNets.
 - [x] Deploy a Debian VM into the other VNet.
 - [x] Set up Azure Bastion to connect to the Debian VM.
 - [x] Demonstrate the Debian VM is able to reach a node in AKS.
 - [x] Have GitHub Actions deploy the infrastructure with statefiles in the appropriate backend Azure Storage Account.
 - [ ] Find the best way to store Azure Credentials. Azure KeyVault or GitHub Secrets?
 - [ ] Use Terraform Modules as much as possible to simplify main.tf
 - [ ] Have a full dev to prod process with GitHub Actions and seperate statefiles.
 - [ ] Verify our infrastructure has been deployed with the AZ CLI
 - [ ] Improve the README.



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

## Create an Azure Storage Contianer

Our storage account will store the Terraform state file for our deployment. 

The [Create a Container](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container) tutorial will show you how to do this. Capture the values and place them in `./terraform/backend.tf`

## GitHub Actions

build.yml currently goes through a terraform fmt, init, validate, plan, and apply. 

Create a Service Principal for Actions to use and store the JSON output as a GitHub Secret in the repo as AZURE_CREDENTIALS

```bash
az account list -o table # To find your subscription id
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID"
{
    "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "clientSecret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Also store each of the following as their own GitHub Secret:
- CLIENT_ID
- CLIENT_SECRET
- SUBSCRIPTION_ID 
- TENANT_ID 
