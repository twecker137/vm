variable "admin_ssh_key" {
  type = list(object(
    {
      username   = string
      public_key = string
    }
  ))
  default = null
}

variable "admin_username" {
  default = "azureuser"
  type    = string
}

variable "availability_set_id" {
  default = null
  type    = string
}

variable "backup" {
  default = true
  type    = bool
}

variable "backup_policy_id" {
  type    = string
  default = null
}

variable "delete_os_disk_on_termination" {
  type    = bool
  default = true
}

variable "disable_password_authentication" {
  type    = bool
  default = false
}

variable "disk_config" {
  type = list(object(
    {
      disk_number               = number
      disk_storage_account_type = string
      disk_size_gb              = string
      data_disk_cache           = string
    }
  ))
}

variable "dns_servers" {
  type    = list(string)
  default = null
}

variable "domain_join" {
  type    = bool
  default = false
}

variable "domain_join_user" {
  type    = string
  default = ""
}

variable "domain_join_password" {
  type    = string
  default = null
}

variable "domain_join_secret_name" {
  type    = string
  default = ""
}

variable "domain_netbios_name" {
  type    = string
  default = ""
}
variable "domain_name" {
  type    = string
  default = ""
}

variable "enable_disk_encryption_set" {
  type    = bool
  default = false
}

variable "identity" {
  type = object(
    {
      type         = string
      identity_ids = list(string)
    }
  )
  default = {
    type         = "SystemAssigned"
    identity_ids = null
  }
}

variable "key_vault_id" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "nic_config" {
  type = list(object(
    {
      nic_number = number
      subnet_id  = string
    }
  ))
}

variable "public_ip_config" {
  type    = list(number)
  default = []
}

variable "os_disk_caching" {
  type    = string
  default = "None"
}

variable "os_disk_storage_account_type" {
  type    = string
  default = "Premium_LRS"
}

variable "ou_path" {
  type    = string
  default = ""
}

variable "plan" {
  type = object(
    {
      name      = string
      product   = string
      publisher = string
    }
  )
  default = null
}

variable "winrm_listener" {
  type = list(object(
    {
      protocol        = string
      certificate_url = string
    }
  ))
  default = null
}

variable "proximity_placement_group_id" {
  type    = string
  default = null
}
variable "recovery_vault_resource_group_name" {
  type        = string
  default     = null
  description = "The name of the recovery vault resource group."
}
variable "recovery_vault_name" {
  type        = string
  default     = null
  description = "The name of the recovery vault"
}

variable "resource_group_name" {
  type = string
}

variable "size" {
  type = string
}

variable "storage_account_uri" {
  description = "Uri of the Boot Diagnostics Storage Account"
  default     = null
}
variable "tags" {
  type    = map(string)
  default = null
}

variable "timezone" {
  description = "The timezone of the virtual machine possible values: https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/"
  default     = "W. Europe Standard Time"
}

variable "vm_os_type" {
  type        = string
  description = "Valid values: Windows, Linux. This has become necessary due to the way the new provider handles Windows and Linux virtual machines."
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  default     = null
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_simple" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "latest"
}

variable "vm_os_license" {
  description = "Defaults to Standard, Possible values are None, Windows_Client and Windows_Server. Changing this forces a new resource to be created."
  default     = null
}
variable "write_accelerator_enabled" {
  type        = bool
  default     = false
  description = "Requires M-Series VMs and Premium Disk Caching set to none"
}

variable "zone" {
  type    = string
  default = null
}

variable "create_dsc_cert" {
  type    = bool
  default = false
}