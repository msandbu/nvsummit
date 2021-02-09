## Define a Azure Sentinel Security Incident Based upon Cloud App Security

resource "azurerm_sentinel_alert_rule_ms_security_incident" "azsen_mcas" {
  name                       = "mcas-incident-alert-rule"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.mainrg-la.id
  product_filter             = "Microsoft Cloud App Security"
  display_name               = "MCAS Incidents"
  severity_filter            = ["High"]
}

## Define a Azure Sentinel Incident based upon custom Kusto Query. Predefined Log Analytics Workspace

resource "azurerm_sentinel_alert_rule_scheduled" "alert_ad_audit" {
  name                       = "alert_ad_audit"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.mainrg-la.id
  display_name               = "Check AD Audit Logs for Failed Logon"
  severity                   = "High"
  query                      = <<QUERY
AzureActivity |
  where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
  where ActivityStatus == "Succeeded" |
  make-series dcount(ResourceId) default=0 on EventSubmissionTimestamp in range(ago(7d), now(), 1d) by Caller
QUERY
}

