variable "vm_os_simple" {
  default = ""
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default = {
    "RHEL-7-5"              = "RedHat,RHEL,7.5"
    "RHEL-8"                = "RedHat,RHEL,8"       // LVM
    "RHEL-8-gen2"           = "RedHat,RHEL,8-gen2"  // LVM
    "RHEL-8-4"              = "RedHat,RHEL,84"      // Extended Update Support / LVM
    "RHEL-8-4-gen2"         = "RedHat,RHEL,84-gen2" // Extended Update Support / LVM
    "RHEL-8-5"              = "RedHat,RHEL,85"      // Extended Update Support / LVM
    "RHEL-8-5-gen2"         = "RedHat,RHEL,85-gen2" // Extended Update Support / LVM
    "CentOS-7-6"            = "OpenLogic,CentOS,7.6"
    "CentOS-7-7"            = "OpenLogic,CentOS,7.7"
    "CentOS-8-3"            = "OpenLogic,CentOS,8_3"
    "CentOS-8-3-gen2"       = "OpenLogic,CentOS,8_3-gen2"
    "CentOS-8-lvm"          = "OpenLogic,CentOS-LVM,8-lvm"
    "CentOS-8-lvm-gen2"     = "OpenLogic,CentOS-LVM,8-lvm-gen2"
    "SLES-15-SP1-gen1"      = "SUSE,sles-15-sp1,gen1"
    "SLES-15-SP1-gen2"      = "SUSE,sles-15-sp1,gen2"
    "SLES4SAP-15-SP1-gen1"  = "SUSE,sles-sap-15-sp1,gen1"
    "SLES4SAP-15-SP1-gen2"  = "SUSE,sles-sap-15-sp1,gen2"
    "Debian-9"              = "credativ,Debian,9"
    "Debian-10"             = "Debian,debian-10,10"
    "Ubuntu-20_04-lts"      = "Canonical,0001-com-ubuntu-server-focal,20_04-lts"      // without LVM
    "Ubuntu-20_04-lts-gen2" = "Canonical,0001-com-ubuntu-server-focal,20_04-lts-gen2" // without LVM
    "WindowsServer2008"     = "MicrosoftWindowsServer,WindowsServer,2008-R2-SP1"
    "WindowsServer2012"     = "MicrosoftWindowsServer,WindowsServer,2012-R2-Datacenter"
    "WindowsServer2016"     = "MicrosoftWindowsServer,WindowsServer,2016-Datacenter"
    "WindowsServer2019"     = "MicrosoftWindowsServer,WindowsServer,2019-Datacenter"
    "SQL2019DEV-WS2019"     = "MicrosoftSQLServer,sql2019-ws2019,sqldev"
    "SQL2019EE-WS2019-BYOL" = "MicrosoftSQLServer,sql2019-ws2019-byol,enterprise"
  }
}
