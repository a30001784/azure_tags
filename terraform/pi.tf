# pi server

resource "azurerm_network_interface" "pi" {
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-app.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_app}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_managed_disk" "pi1" {
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi}-datadisk0${count.index + 1}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "127"

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_managed_disk" "pi2" {
    count                             = "${var.data_disk_count_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi}-datadisk${count.index + 2 < 10 ? "0" : ""}${count.index + 2}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "${var.data_disk_size_pi}"

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_virtual_machine" "pi" {
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.pi.id}"]
    vm_size                           = "${var.vm_size_pi}"
    depends_on                        = ["azurerm_network_interface.pi","azurerm_managed_disk.pi1","azurerm_managed_disk.pi2"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2012-R2-Datacenter"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = "127"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.pi1.name}"
        managed_disk_id               = "${azurerm_managed_disk.pi1.id}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${azurerm_managed_disk.pi1.disk_size_gb}"
        caching                       = "ReadOnly"
    }

    // Count is not supported for storage_data_disk...
    storage_data_disk {
        name                          = "${azurerm_managed_disk.pi2.*.name[0]}"
        managed_disk_id               = "${azurerm_managed_disk.pi2.*.id[0]}"
        create_option                 = "Attach"
        lun                           = 1
        disk_size_gb                  = "${var.data_disk_size_pi}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.pi2.*.name[1]}"
        managed_disk_id               = "${azurerm_managed_disk.pi2.*.id[1]}"
        create_option                 = "Attach"
        lun                           = 2
        disk_size_gb                  = "${var.data_disk_size_pi}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.pi2.*.name[2]}"
        managed_disk_id               = "${azurerm_managed_disk.pi2.*.id[2]}"
        create_option                 = "Attach"
        lun                           = 3
        disk_size_gb                  = "${var.data_disk_size_pi}"
        caching                       = "ReadOnly"

    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi}"
        admin_username                = "${var.host_username}"
        admin_password                = "${var.host_password}"
    }

    os_profile_windows_config {
        provision_vm_agent            = true
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_virtual_machine_extension" "powershell_winrm_pi" {
    name                              = "powershell_winrm_pi"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    virtual_machine_name              = "${var.hostname_prefix}${var.hostname_suffix_start_range_pi}"
    publisher                         = "Microsoft.Compute"
    type                              = "CustomScriptExtension"
    type_handler_version              = "1.8"
    depends_on                        = ["azurerm_virtual_machine.pi"]

    settings                          = <<SETTINGS
    {
        "commandToExecute":             "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1",
        "fileUris":                     ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS
}