## Main Resource Group for Network Service

resource "azurerm_resource_group" "vnetprodrg" {
  name     = "vnet-we-prod-rg"
  location = "westeurope"
}

## NSG rule with all traffic open attached to frontend VNET. 

resource "azurerm_network_security_group" "vnetprod-nsg" {
  name                = "vnet-frontend-nsg"
  location            = azurerm_resource_group.vnetprodrg.location
  resource_group_name = azurerm_resource_group.vnetprodrg.name

  security_rule {
    name                       = "honeypot"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


## Enable Network Watcher


resource "azurerm_network_watcher" "nw" {
  name                = "nw-we"
  location            = azurerm_resource_group.vnetprodrg.location
  resource_group_name = azurerm_resource_group.vnetprodrg.name
}

## Enable storage account for NSG flow logs

resource "azurerm_storage_account" "sa-we" {
  name                = "saweta"
  resource_group_name = azurerm_resource_group.vnetprodrg.name
  location            = azurerm_resource_group.vnetprodrg.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

## Enable network watcher
## collecting data into Log Analytics

resource "azurerm_network_watcher_flow_log" "nwfl" {
  network_watcher_name = azurerm_network_watcher.nw.name
  resource_group_name  = azurerm_resource_group.vnetprodrg.name

  network_security_group_id = azurerm_network_security_group.vnetprod-nsg.id
  storage_account_id        = azurerm_storage_account.sa-we.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }



  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.mainrg-la.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.mainrg-la.location
    workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
    interval_in_minutes   = 10
  }
}

## main network resource

resource "azurerm_virtual_network" "vnetprod" {
  name                = "vnet-we-prod"
  location            = azurerm_resource_group.vnetprodrg.location
  resource_group_name = azurerm_resource_group.vnetprodrg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "management-sn" {
  name                 = "management"
  resource_group_name  = azurerm_resource_group.vnetprodrg.name
  virtual_network_name = azurerm_virtual_network.vnetprod.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "backend-sn" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.vnetprodrg.name
  virtual_network_name = azurerm_virtual_network.vnetprod.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "frontend-sn" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.vnetprodrg.name
  virtual_network_name = azurerm_virtual_network.vnetprod.name
  address_prefixes     = ["10.0.3.0/24"]
}

## attaching tne NSG to the management subnet

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.management-sn.id
  network_security_group_id = azurerm_network_security_group.vnetprod-nsg.id
}

