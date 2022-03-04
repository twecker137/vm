resource "azurerm_windows_virtual_machine" "vm" {
  count                 = var.vm_os_type == "Windows" ? 1 : 0
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = random_password.admin_password.result
  network_interface_ids = flatten(values(azurerm_network_interface.nic)[*].id)

  provision_vm_agent = true
  timezone           = var.timezone

  dynamic "winrm_listener" {
    for_each = local.winrm_listener
    content {
      protocol        = winrm_listener.value["protocol"]
      certificate_url = winrm_listener.value["certificate_url"]
    }
  }

  proximity_placement_group_id = var.proximity_placement_group_id
  availability_set_id          = var.availability_set_id

  zone         = var.zone
  license_type = var.vm_os_license


  os_disk {
    name                      = "osdisk-${var.name}"
    caching                   = var.os_disk_caching
    storage_account_type      = var.os_disk_storage_account_type
    write_accelerator_enabled = var.write_accelerator_enabled
    disk_encryption_set_id    = var.enable_disk_encryption_set == true ? azurerm_disk_encryption_set.des[0].id : null
  }

  dynamic "plan" {
    for_each = local.plan
    content {
      name      = plan.value["name"]
      product   = plan.value["product"]
      publisher = plan.value["publisher"]
    }
  }

  dynamic "identity" {
    for_each = local.identity
    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }

  dynamic "boot_diagnostics" {
    for_each = local.boot_diagnostics
    content {
      storage_account_uri = boot_diagnostics.value["storage_account_uri"]
    }
  }

  dynamic "secret" {
    for_each = local.secret_block
    content {
      certificate {
        store = "My"
        url   = azurerm_key_vault_certificate.vm-cert-dsc[0].secret_id
      }
      key_vault_id = var.key_vault_id
    }
  }

  source_image_id = var.vm_os_id != "" ? var.vm_os_id : null

  dynamic "source_image_reference" {
    for_each = local.source_image_reference
    content {
      publisher = source_image_reference.value["publisher"]
      offer     = source_image_reference.value["offer"]
      sku       = source_image_reference.value["sku"]
      version   = source_image_reference.value["version"]
    }
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "vm-domjoin" {
  count                = var.domain_join == true ? 1 : 0
  name                 = "DomainJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[0].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  settings             = <<SETTINGS
{
    "Name": "${var.domain_name}",
    "OUPath": "${var.ou_path}",
    "User": "${var.domain_netbios_name}\\${var.domain_join_user}",
    "Restart": "true",
    "Options": "3"
}
SETTINGS
  protected_settings   = <<PROTECTED_SETTINGS
{
  "Password": "${var.domain_join_password}"
}
PROTECTED_SETTINGS
  depends_on           = [azurerm_windows_virtual_machine.vm[0]]
}
