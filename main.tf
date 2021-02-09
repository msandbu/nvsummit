resource "azurerm_resource_group" "mainrg" {
  name     = "we-rg-prod"
  location = "westeurope"
}

data "azurerm_client_config" "current" {}

## Create Log Analytics Workspace 

resource "azurerm_log_analytics_workspace" "mainrg-la" {
  name                = "nvsummit-workspace-demo"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  sku                 = "PerGB2018"
}

## Define Log Analytics Solutions

resource "azurerm_log_analytics_solution" "la_sentinel" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}

resource "azurerm_log_analytics_solution" "la_antimalware" {
  solution_name         = "AntiMalware"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AntiMalware"
  }
}

resource "azurerm_log_analytics_solution" "la_ct" {
  solution_name         = "ChangeTracking"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }
}

resource "azurerm_log_analytics_solution" "la_update" {
  solution_name         = "Updates"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

resource "azurerm_log_analytics_solution" "la_dns" {
  solution_name         = "DnsAnalytics"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/DnsAnalytics"
  }
}

resource "azurerm_log_analytics_solution" "la_ii" {
  solution_name         = "InfrastructureInsights"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/InfrastructureInsights"
  }
}

resource "azurerm_log_analytics_solution" "la_vi" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.mainrg.location
  resource_group_name   = azurerm_resource_group.mainrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  workspace_name        = azurerm_log_analytics_workspace.mainrg-la.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
}

## Setup Azure Security Center subscription limit

resource "azurerm_security_center_subscription_pricing" "asc_pricing" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "asc_pricing_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

## Define Azure Automation

resource "azurerm_automation_account" "aaa" {
  name                = "aaa-prod-we"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name

  sku_name = "Basic"

  tags = {
    environment = "development"
  }
}

## linking Log Analytics and Azure Automation

resource "azurerm_log_analytics_linked_service" "aaa-la-link" {
  resource_group_name = azurerm_resource_group.mainrg.name
  workspace_id        = azurerm_log_analytics_workspace.mainrg-la.id
  read_access_id      = azurerm_automation_account.aaa.id
}

## Define Security Center Workspace

resource "azurerm_security_center_workspace" "example" {
  scope        = "/subscriptions/e081f6b1-78ea-4640-baa6-c67dd1d71cf8"
  workspace_id = azurerm_log_analytics_workspace.mainrg-la.id
}

## Integrating Security Center with Log Analytics

resource "azurerm_security_center_automation" "asz_autoamtion" {
  name                = "asz_la_export"
  location            = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name

  action {
    type        = "LogAnalytics"
    resource_id = azurerm_log_analytics_workspace.mainrg-la.id
  }


  source {
    event_source = "Alerts"
    rule_set {
      rule {
        property_path  = "properties.metadata.severity"
        operator       = "Equals"
        expected_value = "High"
        property_type  = "String"
      }
    }
  }

  scopes = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
}