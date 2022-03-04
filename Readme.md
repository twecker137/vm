# Azure Virtual Machine Module

## Linux Example

```hcl
module "test_linux_vm001" {
  source                             = "es-tf-modules/vm"
  name                               = "vmhubtest001"
  location                           = ""
  resource_group_name                = ""
  size                               = "Standard_DS3_v2"
  vm_os_type                         = "linux"
  vm_os_simple                       = "RHEL-8-4-gen2"
  backup                             = false
  disk_config = [{
    disk_number               = 1
    disk_storage_account_type = "Standard_LRS"
    disk_size_gb              = "30"
    data_disk_cache           = "ReadWrite"
  }]
  key_vault_id = ""
  nic_config = [{
    nic_number = 1
    subnet_id  = ""
  }]
  admin_username = "akmeadmin"
  admin_ssh_key = [{
    username   = ""
    public_key = "ssh-rsa "
  }]
  disable_password_authentication = true
  public_ip_config = [1]
}
```