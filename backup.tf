## Create a resource group for backup vault

resource "azurerm_resource_group" "rgrv01" {
  name     = "we-recovery_vault"
  location = "westeurope"
}

resource "azurerm_recovery_services_vault" "arsv" {
  name                = "recovery-vaultwe"
  location            = azurerm_resource_group.rgrv01.location
  resource_group_name = azurerm_resource_group.rgrv01.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "bp01" {
  name                = "tfex-recovery-vault-policy"
  resource_group_name = azurerm_resource_group.rgrv01.name
  recovery_vault_name = azurerm_recovery_services_vault.arsv.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }
}

