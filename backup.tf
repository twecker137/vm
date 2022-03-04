locals {
  source_vm_id   = var.vm_os_type == "linux" ? try(azurerm_linux_virtual_machine.vm[0].id, null) : try(azurerm_windows_virtual_machine.vm[0].id, null)
}

resource "azurerm_backup_protected_vm" "backup" {
  count = var.backup == false ? 0 : 1
  resource_group_name = var.recovery_vault_resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_vm_id        = local.source_vm_id
  backup_policy_id    = var.backup_policy_id
}