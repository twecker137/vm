output "nic_config" {
  value = azurerm_network_interface.nic
}

output "vm_msi_id" {
  value = var.vm_os_type == "Windows" ? azurerm_windows_virtual_machine.vm[0].identity : azurerm_linux_virtual_machine.vm[0].identity
}


output "virtual_machine_id" {
  value = var.vm_os_type == "Windows" ? azurerm_windows_virtual_machine.vm[0].id : azurerm_linux_virtual_machine.vm[0].id
}

output "virtual_machine_name" {
  value = var.vm_os_type == "Windows" ? azurerm_windows_virtual_machine.vm[0].name : azurerm_linux_virtual_machine.vm[0].name
}