terraform {
  required_providers {
    azurerm = {
      version = ">= 2.86.0"
    }
  }
}

module "os" {
  #this module is part of the original compute module from the terraform registry and wasn't changed
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

locals {
  nic_config = { for nic_config in flatten([
    for nic in var.nic_config : {
      nic_number                    = nic.nic_number
      subnet_id                     = nic.subnet_id
      private_ip_address            = try(nic.private_ip_address, false)
      network_security_group_id     = try(nic.network_security_group_id, false)
      assign_network_security_group = try(nic.assign_network_security_group, false)
    }
  ]) : nic_config.nic_number => nic_config }


  disk_config = flatten([
    for disk in var.disk_config : {
      disk_number               = disk.disk_number
      disk_storage_account_type = disk.disk_storage_account_type
      disk_size_gb              = disk.disk_size_gb
      data_disk_cache           = disk.data_disk_cache
    }
  ])
  source_image_reference = var.vm_os_id == "" ? [] : [{
    publisher = coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher)
    offer     = coalesce(var.vm_os_offer, module.os.calculated_value_os_offer)
    sku       = coalesce(var.vm_os_sku, module.os.calculated_value_os_sku)
    version   = var.vm_os_version
  }]
  boot_diagnostics = var.storage_account_uri == null ? [] : [{
    storage_account_uri = var.storage_account_uri
  }]
  identity = var.identity == null ? [] : [{
    type         = var.identity["type"]
    identity_ids = var.identity["identity_ids"]
  }]
  plan = var.plan == null ? [] : [{
    name      = var.plan["name"]
    product   = var.plan["product"]
    publisher = var.plan["publisher"]
  }]
  winrm_listener = var.winrm_listener == null ? [] : [{
    protocol        = var.winrm_listener["protocol"]
    certificate_url = var.winrm_listener["certificate_url"]
  }]
  secret_block = var.create_dsc_cert == false ? [] : [{
    key_vault_id = var.key_vault_id
  }]
}

resource "random_password" "admin_password" {
  length      = 20
  special     = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.name}-${var.admin_username}"
  value        = random_password.admin_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_public_ip" "pip" {
  for_each = {
    for pip in var.public_ip_config : pip => pip
  }
  name                = "pip-${var.name}-${format("%03d", each.value)}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  for_each            = local.nic_config
  name                = "nic-${var.name}-${format("%03d", each.value.nic_number)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_servers = var.dns_servers
  ip_configuration {
    name                          = "nic${format("%03d", each.value.nic_number)}-ipconfig"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = (each.value.private_ip_address != false) ? "Static" : "Dynamic"
    private_ip_address            = (each.value.private_ip_address != false) ? each.value.private_ip_address : null
    public_ip_address_id          = contains(var.public_ip_config, each.value.nic_number) ? azurerm_public_ip.pip[each.value.nic_number].id : null
  }
  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic" {
  for_each                  = { for k, v in local.nic_config : k => v if try(v.assign_network_security_group, false) }
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = each.value.network_security_group_id
}

resource "azurerm_managed_disk" "disk" {
  for_each = {
    for disk_config in local.disk_config : disk_config.disk_number => disk_config
  }
  name                   = "disk-${var.name}-${format("%03d", each.value.disk_number)}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = each.value.disk_storage_account_type
  zone                   = var.zone
  create_option          = "Empty"
  disk_size_gb           = each.value.disk_size_gb
  tags                   = var.tags
  disk_encryption_set_id = var.enable_disk_encryption_set == true ? azurerm_disk_encryption_set.des[0].id : null

  lifecycle {
    ignore_changes = [
      create_option,
      source_resource_id,
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-disk" {
  for_each = {
    for disk_config in local.disk_config : disk_config.disk_number => disk_config
  }
  managed_disk_id           = azurerm_managed_disk.disk[each.value.disk_number].id
  virtual_machine_id        = var.vm_os_type == "Windows" ? azurerm_windows_virtual_machine.vm[0].id : azurerm_linux_virtual_machine.vm[0].id
  lun                       = 10 + each.value.disk_number
  caching                   = each.value.data_disk_cache
  write_accelerator_enabled = var.write_accelerator_enabled
}

resource "azurerm_key_vault_key" "des-key" {
  count        = var.enable_disk_encryption_set == true ? 1 : 0
  name         = "des-${var.name}-encryption-key"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "des" {
  count               = var.enable_disk_encryption_set == true ? 1 : 0
  name                = "des-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.des-key[0].id
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [encryption_type]
  }
}

resource "azurerm_key_vault_access_policy" "kvap-disk" {
  count        = var.enable_disk_encryption_set == true ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_disk_encryption_set.des[0].identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.des[0].identity.0.principal_id

  key_permissions = [
    "Get",
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
  ]
}
