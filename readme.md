# NVSummit 2021 

## Content
This repo consists of some scripts and Terraform examples to showcase the different security and governance features within Microsoft Azure and M365.
If using the built-in examples that are defined the Azure deployment will deploy the following components

* Log Analytics Workspace
* Azure Automation
* Virtual Network
* NSG Flow Logs and Traffic Analysis
* Backup Vault and Backup Policy
* Azure Policies
* Windows VM with Public IP address (NOTE: THE VM IS PUBLICALY AVAILABLE WITH NO FIREWALL for demonstration purposes)
* Azure Web Application Gateway with Custom Firewall Rules
* Azure Sentinel
* Azure Update Management

NOTE: Since this is only for demonstration purposes it deploys a VM with public facing IP and should only be used for demo or educational purposes (and or inspiration)

## Getting started

Since most of the examples are either using Terraform/PowerShell scripts I recommend reading up on Terraform and how to create a service principal/using Managed Identity or Key Vault with defined secrets which are used during runtime.

So the use of these script require that you define a service principal to use against the different API's

Some useful tools and powershell modules

# Install PowerShell modules used 

Install-Module Microsoft.Graph
Update-Module Microsoft.Graph
Install-Module AzureAD
Install-Module AzureADPreview
Install-Module Az
az config set extension.use_dynamic_install=yes_prompt
Install-Module MCAS
Install-Module ExchangeOnlineManagement
Install-Module MicrosoftTeams
Install-Module MicrosoftGraphSecurity
Install-Module Az.ResourceGraph

# Configure Chocolatey and install Terraform and VSCode

Set-ExecutionPolicy Bypass -Scope Process -Force; `
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install vscode
Choco install Terraform

# Should be run after VS Code is installed
code --install-extension hashicorp.terraform
code --install-extension ms-vscode.azure-account
code --install-extension msazurermtools.azurerm-vscode-tools
code --install-extension ms-vscode.azurecli
code --install-extension AzurePolicy.azurepolicyextension

# Terraform
When downloading the Terraform examples they have hardcoded resource names (didn't have time to define it more modular.. coming later)
Download the content locally and open CLI

terraform plan
terraform apply

