resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_os_type == "Windows" ? 0 : 1
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.disable_password_authentication == false ? random_password.admin_password.result : null

  disable_password_authentication = var.disable_password_authentication

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_key
    content {
      username   = admin_ssh_key.value["username"]
      public_key = admin_ssh_key.value["public_key"]
    }
  }

  network_interface_ids = flatten(values(azurerm_network_interface.nic)[*].id)

  provision_vm_agent           = true
  proximity_placement_group_id = var.proximity_placement_group_id
  availability_set_id          = var.availability_set_id
  zone                         = var.zone
  license_type                 = var.vm_os_license

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
