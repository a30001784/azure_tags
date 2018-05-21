# ascs

resource "azurerm_network_interface" "ascs" {
    count                             = "${var.node_count_ascs}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-app.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_app}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "RE-DT01-C03-FN"
        TechnicalOwner                = "Ruschal Alphonso"
        BusinessOwner                 = "Nirusha Dissanayake"
    }
}

resource "azurerm_managed_disk" "ascs1" {
    count                             = "${var.node_count_ascs}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}-datadisk01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "127"

    tags {
        CostCode                      = "RE-DT01-C03-FN"
        TechnicalOwner                = "Ruschal Alphonso"
        BusinessOwner                 = "Nirusha Dissanayake"
    }
}

resource "azurerm_managed_disk" "ascs2" {
    count                             = "${var.node_count_ascs}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}-datadisk02"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "${var.data_disk_size_ascs}"

    tags {
        CostCode                      = "RE-DT01-C03-FN"
        TechnicalOwner                = "Ruschal Alphonso"
        BusinessOwner                 = "Nirusha Dissanayake"
    }
}

resource "azurerm_virtual_machine" "ascs" {
    count                             = "${var.node_count_ascs}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.ascs.*.id[count.index]}"]
    vm_size                           = "${var.vm_size_ascs}"
    depends_on                        = ["azurerm_network_interface.ascs","azurerm_managed_disk.ascs1","azurerm_managed_disk.ascs2"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2012-R2-Datacenter"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = "127"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.ascs1.*.name[count.index]}"
        managed_disk_id               = "${azurerm_managed_disk.ascs1.*.id[count.index]}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${azurerm_managed_disk.ascs1.*.disk_size_gb[count.index]}"

    }
    
    storage_data_disk {
        name                          = "${azurerm_managed_disk.ascs2.*.name[count.index]}"
        managed_disk_id               = "${azurerm_managed_disk.ascs2.*.id[count.index]}"
        create_option                 = "Attach"
        lun                           = 1
        disk_size_gb                  = "${var.data_disk_size_ascs}"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}"
        admin_username                = "${var.host_username}"
        admin_password                = "${var.host_password}"
    }

    os_profile_windows_config {
        provision_vm_agent            = true
    }

    tags {
        CostCode                      = "RE-DT01-C03-FN"
        TechnicalOwner                = "Ruschal Alphonso"
        BusinessOwner                 = "Nirusha Dissanayake"
    }
}

resource "azurerm_virtual_machine_extension" "powershell_winrm_ascs" {
    count                             = "${var.node_count_ascs}"
    name                              = "powershell_winrm_ascs"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    virtual_machine_name              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs + count.index}"
    publisher                         = "Microsoft.Compute"
    type                              = "CustomScriptExtension"
    type_handler_version              = "1.8"
    depends_on                        = ["azurerm_virtual_machine.ascs"]

    settings                          = <<SETTINGS
    {
        "commandToExecute":             "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1",
        "fileUris":                     ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS
}