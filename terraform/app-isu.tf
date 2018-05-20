# app-isu

resource "azurerm_network_interface" "app-isu" {
    count                                       = "${var.node_count_app_isu}"
    name                                        = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_isu + count.index}-nic1"
    location                                    = "${var.location}"
    resource_group_name                         = "${var.resource_group_name}"
    network_security_group_id                   = "${azurerm_network_security_group.nsg-app.id}"

    ip_configuration {
        name                                    = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_isu + count.index}-nic1-ipconfig"
        subnet_id                               = "${var.subnet_id_app}"
        private_ip_address_allocation           = "static"
        private_ip_address                      = "${cidrhost(var.ip_range_app, var.ip_start_range_app_isu + count.index)}"
    }

    tags {
        CostCode = "RE-DT01-C03-FN"
        TechnicalOwner = "Ruschal Alphonso"
        BusinessOwner = "Nirusha Dissanayake"
    }
}

resource "azurerm_managed_disk" "app-isu" {
    count                                       = "${var.node_count_app_isu}"
    name                                        = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_isu + count.index}-datadisk01"
    location                                    = "${var.location}"
    resource_group_name                         = "${var.resource_group_name}"
    storage_account_type                        = "Premium_LRS"
    create_option                               = "Empty"
    disk_size_gb                                = "128"

    tags {
        CostCode = "RE-DT01-C03-FN"
        TechnicalOwner = "Ruschal Alphonso"
        BusinessOwner = "Nirusha Dissanayake"
    }
}

resource "azurerm_virtual_machine" "app-isu" {
    count                                       = "${var.node_count_app_isu}"
    name                                        = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_isu + count.index}"
    location                                    = "${var.location}"
    resource_group_name                         = "${var.resource_group_name}"
    network_interface_ids                       = ["${azurerm_network_interface.app-isu.*.id[count.index]}"]
    vm_size                                     = "${var.vm_size_app}"
    depends_on                                  = ["azurerm_network_interface.app-isu","azurerm_managed_disk.app-isu"]

    delete_os_disk_on_termination               = true
    delete_data_disks_on_termination            = true

    storage_image_reference {
        publisher                               = "MicrosoftWindowsServer"
        offer                                   = "WindowsServer"
        sku                                     = "2008-R2-SP1"
        version                                 = "latest"
    }

    storage_os_disk {
        name                                    = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_isu + count.index}-osdisk"
        caching                                 = "ReadWrite"
        create_option                           = "FromImage"
        managed_disk_type                       = "Premium_LRS"
        disk_size_gb                            = "128"
    }

    storage_data_disk {
        name                                    = "${azurerm_managed_disk.app-isu.*.name[count.index]}"
        managed_disk_id                         = "${azurerm_managed_disk.app-isu.*.id[count.index]}"
        create_option                           = "Attach"
        lun                                     = 0
        disk_size_gb                            = "${azurerm_managed_disk.app-isu.*.disk_size_gb[count.index]}"
    }

    os_profile {
        computer_name                           = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_isu + count.index}"
        admin_username                          = "${var.host_username}"
        admin_password                          = "${var.host_password}"
    }

    os_profile_windows_config {
        provision_vm_agent                      = true
    }

    tags {
        CostCode = "RE-DT01-C03-FN"
        TechnicalOwner = "Ruschal Alphonso"
        BusinessOwner = "Nirusha Dissanayake"
    }
}