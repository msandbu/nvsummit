resource "azurerm_policy_assignment" "auditvms" {
  name                 = "Audit Disk without Managed Disks"
  scope                = "/subscriptions/e081f6b1-78ea-4640-baa6-c67dd1d71cf8"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  description          = "Shows all virtual machines not using managed disks"
  display_name         = "Audit VMs without managed disks Assignment"
}

resource "azurerm_policy_definition" "IaaSAntiMalwarePolicy" {
  name         = "IaaSAntiMalwarePolicy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Get antimalware checked"
  policy_rule  = <<POLICY_RULE
   {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "field": "Microsoft.Compute/imagePublisher",
            "equals": "MicrosoftWindowsServer"
          },
          {
            "field": "Microsoft.Compute/imageOffer",
            "equals": "WindowsServer"
          },
          {
            "field": "Microsoft.Compute/imageSKU",
            "in": [
              "2008-R2-SP1",
              "2008-R2-SP1-smalldisk",
              "2012-Datacenter",
              "2012-Datacenter-smalldisk",
              "2012-R2-Datacenter",
              "2012-R2-Datacenter-smalldisk",
              "2016-Datacenter",
              "2016-Datacenter-Server-Core",
              "2016-Datacenter-Server-Core-smalldisk",
              "2016-Datacenter-smalldisk",
              "2016-Datacenter-with-Containers",
              "2016-Datacenter-with-RDSH",
              "2019-Datacenter",
              "2019-Datacenter-Core",
              "2019-Datacenter-Core-smalldisk",
              "2019-Datacenter-Core-with-Containers",
              "2019-Datacenter-Core-with-Containers-smalldisk",
              "2019-Datacenter-smalldisk",
              "2019-Datacenter-with-Containers",
              "2019-Datacenter-with-Containers-smalldisk"
            ]
          }
        ]
      },
      "then": {
        "effect": "deployIfNotExists",
        "details": {
          "type": "Microsoft.Compute/virtualMachines/extensions",
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/type",
                "equals": "IaaSAntimalware"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
                "equals": "Microsoft.Azure.Security"
              }
            ]
          },
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
          ],
          "deployment": {
            "properties": {
              "mode": "incremental",
             "template": {
                "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  },
                  "ExclusionsPaths": {
                    "type": "string",
                    "defaultValue": "",
                    "metadata": {
                      "description": "Semicolon delimited list of file paths or locations to exclude from scanning"
                    }
                  },
                  "ExclusionsExtensions": {
                    "type": "string",
                    "defaultValue": "",
                    "metadata": {
                      "description": "Semicolon delimited list of file extensions to exclude from scanning"
                    }
                  },
                  "ExclusionsProcesses": {
                    "type": "string",
                    "defaultValue": "",
                    "metadata": {
                      "description": "Semicolon delimited list of process names to exclude from scanning"
                    }
                  },
                  "RealtimeProtectionEnabled": {
                    "type": "string",
                    "defaultValue": "true",
                    "metadata": {
                      "description": "Indicates whether or not real time protection is enabled (default is true)"
                    }
                 },
                  "ScheduledScanSettingsIsEnabled": {
                    "type": "string",
                    "defaultValue": "false",
                    "metadata": {
                      "description": "Indicates whether or not custom scheduled scan settings are enabled (default is false)"
                    }
                  },
                  "ScheduledScanSettingsScanType": {
                    "type": "string",
                    "defaultValue": "Quick",
                    "metadata": {
                      "description": "Indicates whether scheduled scan setting type is set to Quick or Full (default is Quick)"
                    }
                  },
                  "ScheduledScanSettingsDay": {
                    "type": "string",
                    "defaultValue": "7",
                    "metadata": {
                      "description": "Day of the week for scheduled scan (1-Sunday, 2-Monday, ..., 7-Saturday)"
                    }
                  },
                  "ScheduledScanSettingsTime": {
                    "type": "string",
                    "defaultValue": "120",
                    "metadata": {
                      "description": "When to perform the scheduled scan, measured in minutes from midnight (0-1440). For example: 0 = 12AM, 60 = 1AM, 120 = 2AM."
                    }

                 }
                },
                "resources": [
                  {
                    "name": "[concat(parameters('vmName'),'/IaaSAntimalware')]",
                    "type": "Microsoft.Compute/virtualMachines/extensions",
                    "location": "[parameters('location')]",
                   "apiVersion": "2017-12-01",
                    "properties": {
                      "publisher": "Microsoft.Azure.Security",
                      "type": "IaaSAntimalware",
                      "typeHandlerVersion": "1.3",
                      "autoUpgradeMinorVersion": true,
                      "settings": {
                        "AntimalwareEnabled": true,
                        "RealtimeProtectionEnabled": "[parameters('RealtimeProtectionEnabled')]",
                        "ScheduledScanSettings": {
                          "isEnabled": "[parameters('ScheduledScanSettingsIsEnabled')]",
                          "day": "[parameters('ScheduledScanSettingsDay')]",
                          "time": "[parameters('ScheduledScanSettingsTime')]",
                          "scanType": "[parameters('ScheduledScanSettingsScanType')]"
                        },
                        "Exclusions": {
                          "Extensions": "[parameters('ExclusionsExtensions')]",
                          "Paths": "[parameters('ExclusionsPaths')]",
                          "Processes": "[parameters('ExclusionsProcesses')]"
                        }
                      }
                    }
                  }
                ]
              },
              "parameters": {
               "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "RealtimeProtectionEnabled": {
                  "value": "true"
                },
                "ScheduledScanSettingsIsEnabled": {
                  "value": "true"
                }
              }
            }
          }

       }
      }
    }
POLICY_RULE
  parameters   = <<PARAMETERS
{
}   
PARAMETERS
}

resource "azurerm_policy_assignment" "IaaSAntiMalwarePolicyAssignment" {
  name                 = "IaaSAntiMalwarePolicyAssignment"
  scope                = "/subscriptions/00000000-0000-0000-000000000000"
  policy_definition_id = azurerm_policy_definition.IaaSAntiMalwarePolicy.id
  description          = "Check "
  display_name         = "IaaSAntiMalwarePolicyAssignment"


  parameters = <<PARAMETERS
{
}

PARAMETERS
  location   = "westeurope"
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_policy_remediation" "antimalware" {
  name                 = "remeditationforantimalwarepolicy"
  scope                = "/subscriptions/e081f6b1-78ea-4640-baa6-c67dd1d71cf8"
  policy_assignment_id = azurerm_policy_assignment.IaaSAntiMalwarePolicyAssignment.id
}