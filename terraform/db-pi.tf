# db-pi

resource "azurerm_network_interface" "db-pi" {
    count                             = "${var.node_count_db_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_pi + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-data.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_pi + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_data}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_managed_disk" "db-pi" {
    count                             = "${var.data_disk_count_db_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_pi}-datadisk${count.index + 1 < 10 ? "0" : ""}${count.index + 1}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "${var.data_disk_size_db}"

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_virtual_machine" "db-pi" {
    count                             = "${var.node_count_db_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_pi}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.db-pi.id}"]
    vm_size                           = "${var.vm_size_db_pi}"
    depends_on                        = ["azurerm_network_interface.db-pi","azurerm_managed_disk.db-pi"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2012-R2-Datacenter"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_pi}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = "256"
    }

    // Count is not supported for storage_data_disk...
    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-pi.*.name[0]}"
        managed_disk_id               = "${azurerm_managed_disk.db-pi.*.id[0]}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-pi.*.name[1]}"
        managed_disk_id               = "${azurerm_managed_disk.db-pi.*.id[1]}"
        create_option                 = "Attach"
        lun                           = 1
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-pi.*.name[2]}"
        managed_disk_id               = "${azurerm_managed_disk.db-pi.*.id[2]}"
        create_option                 = "Attach"
        lun                           = 2
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-pi.*.name[3]}"
        managed_disk_id               = "${azurerm_managed_disk.db-pi.*.id[3]}"
        create_option                 = "Attach"
        lun                           = 3
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-pi.*.name[4]}"
        managed_disk_id               = "${azurerm_managed_disk.db-pi.*.id[4]}"
        create_option                 = "Attach"
        lun                           = 4
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_pi}"
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