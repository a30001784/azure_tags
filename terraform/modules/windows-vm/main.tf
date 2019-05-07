locals {
  total_data_disks                 = "${var.data_disk_count_secondary * var.count}"
}

resource "azurerm_network_interface" "main" {
  count                            = "${var.count}"
  name                             = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + count.index)}-nic"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  network_security_group_id        = "${var.network_security_group_id}"
  enable_accelerated_networking    = true

  ip_configuration {
    name                           = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + count.index)}-ipconfig"
    subnet_id                      = "${var.subnet_id}"
    private_ip_address_allocation  = "Dynamic"
  }
}

resource "azurerm_managed_disk" "primary" {
  count                            = "${var.count}"
  name                             = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + count.index)}-datadisk-01"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  storage_account_type             = "Premium_LRS"
  create_option                    = "Empty"
  disk_size_gb                     = "${var.data_disk_size_primary}"
//   tags                          = "${var.tags}"
}

resource "azurerm_managed_disk" "secondary" {
  count                            = "${local.total_data_disks}"
  name                             = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + (count.index / var.data_disk_count_secondary))}-datadisk-${format("%02d", (count.index % var.data_disk_count_secondary + 2))}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  storage_account_type             = "Premium_LRS"
  create_option                    = "Empty"
  disk_size_gb                     = "${var.data_disk_size_secondary}"
//   tags                          = "${var.tags}"
}

resource "azurerm_virtual_machine" "main" {
  count                            = "${var.count}"
  name                             = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + count.index)}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  network_interface_ids            = ["${azurerm_network_interface.main.*.id[count.index]}"]
  vm_size                          = "${var.vm_size}"
  depends_on                       = ["azurerm_network_interface.main"]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher                      = "MicrosoftWindowsServer"
    offer                          = "WindowsServer"
    sku                            = "2016-Datacenter"
    version                        = "latest"
  }

  storage_os_disk {
    name                           = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + count.index)}-osdisk"
    caching                        = "ReadWrite"
    create_option                  = "FromImage"
    managed_disk_type              = "Premium_LRS"
    disk_size_gb                   = "${var.os_disk_size}"
  }

  os_profile {
    computer_name                  = "${format("${var.hostname_prefix}%04d", var.hostname_suffix_start_range + count.index)}"
    admin_username                 = "${var.host_username}"
    admin_password                 = "${var.host_password}"
  }

  os_profile_windows_config {
    provision_vm_agent             = true
  }

//   tags                          = "${var.tags}"
}

resource "azurerm_virtual_machine_data_disk_attachment" "primary" {
  count                            = "${var.count}"
  virtual_machine_id               = "${azurerm_virtual_machine.main.*.id[count.index]}"
  managed_disk_id                  = "${azurerm_managed_disk.primary.*.id[count.index]}"
  lun                              = 0  
  caching                          = "ReadOnly"
  depends_on                       = ["azurerm_network_interface.main", "azurerm_managed_disk.primary"]
}

resource "azurerm_virtual_machine_data_disk_attachment" "secondary" {
  count                            = "${local.total_data_disks}"
  virtual_machine_id               = "${azurerm_virtual_machine.main.*.id[count.index / var.data_disk_count_secondary]}"
  managed_disk_id                  = "${azurerm_managed_disk.secondary.*.id[count.index]}"
  lun                              = "${count.index % var.data_disk_count_secondary + 1}"
  caching                          = "ReadOnly"
  depends_on                       = ["azurerm_network_interface.main", "azurerm_managed_disk.secondary"]
}

resource "azurerm_virtual_machine_extension" "main" {
  count                            = "${var.count}"
  name                             = "${azurerm_virtual_machine.main.*.name[count.index]}_configure_remoting_for_ansible"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  virtual_machine_name             = "${azurerm_virtual_machine.main.*.name[count.index]}"
  publisher                        = "Microsoft.Compute"
  type                             = "CustomScriptExtension"
  type_handler_version             = "1.8"
  depends_on                       = ["azurerm_virtual_machine.main", "azurerm_virtual_machine_data_disk_attachment.primary", "azurerm_virtual_machine_data_disk_attachment.secondary" ]

  settings                         = <<SETTINGS
    {
        "commandToExecute":          "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1",
        "fileUris":                  ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS
}