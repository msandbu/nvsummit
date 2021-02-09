resource "azurerm_resource_group" "main" {
  name     = "main"
  location = "westeurope"
}

resource "azurerm_monitor_action_group" "acgrp" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "critical"
}
resource "azurerm_monitor_action_rule_action_group" "example" {
  name                = "example-amar"
  resource_group_name = azurerm_resource_group.main.name
  action_group_id     = azurerm_monitor_action_group.acgrp.id

  scope {
    type         = "ResourceGroup"
    resource_ids = [azurerm_resource_group.main.id]
  }
}
# Example: Alerting Action with result count trigger
resource "azurerm_monitor_scheduled_query_rules_alert" "example" {
  name                = "query2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  action {
    action_group = [azurerm_monitor_action_rule_action_group.example.id]
  }
  data_source_id = azurerm_log_analytics_workspace.mainrg-la.id
  description    = "Alert when caller IP from known source"
  enabled        = true
  # Count all requests with server error result code grouped into 5-minute bins
  query       = <<-QUERY
AzureActivity 
| where TimeGenerated > ago(24h) 
| where CallerIpAddress == "94.102.41.133"
  QUERY
  severity    = 1
  frequency   = 5
  time_window = 30
  trigger {
    operator  = "GreaterThan"
    threshold = 3
  }
}