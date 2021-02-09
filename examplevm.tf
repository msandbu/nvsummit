resource "azurerm_resource_group" "winvm01" {
  name     = "winvm01-rg"
  location = "westeurope"
}

# Creating Public IP for VM 

resource "azurerm_public_ip" "winvm01pip" {
  name                = "winvm01pip"
  resource_group_name = azurerm_resource_group.winvm01.name
  location            = azurerm_resource_group.winvm01.location
  allocation_method   = "Static"

  tags = {
    environment = "Public PIP for Honeypot"
  }
}

# Creating NIC and placing it in management network

resource "azurerm_network_interface" "winvm01nic" {
  name                = "winvm01nic-nic"
  location            = azurerm_resource_group.winvm01.location
  resource_group_name = azurerm_resource_group.winvm01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.management-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winvm01pip.id
  }
}

# Creating example VM with a custom password

resource "azurerm_windows_virtual_machine" "winvm01-vm" {
  name                = "winvm01"
  resource_group_name = azurerm_resource_group.winvm01.name
  location            = azurerm_resource_group.winvm01.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  boot_diagnostics {}
  patch_mode = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.winvm01nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

## attaching the backup policy to the VM 
 resource "azurerm_backup_protected_vm" "vm1" {
   resource_group_name = azurerm_resource_group.rgrv01.name
   recovery_vault_name = azurerm_recovery_services_vault.arsv.name
   source_vm_id        = azurerm_windows_virtual_machine.winvm01-vm.id
   backup_policy_id    = azurerm_backup_policy_vm.bp01.id
 }

# resource "azurerm_virtual_machine_extension" "monitor-DependencyAgent-agent" {
#   name                       = "vmext-monitorDepAgent"
#   virtual_machine_id         = azurerm_windows_virtual_machine.winvm01-vm.id
#   publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                       = "DependencyAgentWindows"
#   type_handler_version       = "9.5"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#         {
#           "workspaceId": "ffd3d30a-ec0e-403f-939e-9db4a91ab7df"
#         }
# SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#         {
#           "workspaceKey": "7pAcMJ+aLk4F84EI+bcUbQCz8VoLPj002q31c6JxjFzQ3PIbl/nekiINqv7XcE5f5D7nse9Ch2qcdRh3J6Z6LQ=="
#         }
# PROTECTED_SETTINGS
#   tags = {
#     environment = "production"
#     role        = "server"
#   }
# }

# resource "azurerm_virtual_machine_extension" "monitor-VMInsightHealth" {
#   name                       = "vmext-monitorDepAgent"
#   virtual_machine_id         = azurerm_windows_virtual_machine.winvm01-vm.id
#   publisher                  = "Microsoft.Azure.Monitor.VirtualMachines.GuestHealth"
#   type                       = "GuestHealthWindowsAgent"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
# }


