# db-isu

resource "azurerm_network_interface" "db-isu" {
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-data.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_data}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "RE-DT01-C03-FN"
        TechnicalOwner                = "Ruschal Alphonso"
        BusinessOwner                 = "Nirusha Dissanayake"
    }
}

resource "azurerm_managed_disk" "db-isu1" {
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}-datadisk0${count.index + 1}"
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

resource "azurerm_managed_disk" "db-isu2" {
    count                             = "${var.data_disk_count_db_isu}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}-datadisk${count.index + 2 < 10 ? "0" : ""}${count.index + 2}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "${var.data_disk_size_db}"

    tags {
        CostCode                      = "RE-DT01-C03-FN"
        TechnicalOwner                = "Ruschal Alphonso"
        BusinessOwner                 = "Nirusha Dissanayake"
    }
}

resource "azurerm_virtual_machine" "db-isu" {
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.db-isu.id}"]
    vm_size                           = "${var.vm_size_db}"
    depends_on                        = ["azurerm_network_interface.db-isu","azurerm_managed_disk.db-isu1","azurerm_managed_disk.db-isu2"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2012-R2-Datacenter"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = "127"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu1.name}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu1.id}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${azurerm_managed_disk.db-isu1.disk_size_gb}"
        caching                       = "ReadOnly"
    }

    // Count is not supported for storage_data_disk...
    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[0]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[0]}"
        create_option                 = "Attach"
        lun                           = 1
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[1]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[1]}"
        create_option                 = "Attach"
        lun                           = 2
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"

    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[2]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[2]}"
        create_option                 = "Attach"
        lun                           = 3
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"

    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[3]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[3]}"
        create_option                 = "Attach"
        lun                           = 4
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[4]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[4]}"
        create_option                 = "Attach"
        lun                           = 5
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[5]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[5]}"
        create_option                 = "Attach"
        lun                           = 6
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[6]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[6]}"
        create_option                 = "Attach"
        lun                           = 7
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[7]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[7]}"
        create_option                 = "Attach"
        lun                           = 8
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[8]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[8]}"
        create_option                 = "Attach"
        lun                           = 9
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[9]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[9]}"
        create_option                 = "Attach"
        lun                           = 10
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[10]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[10]}"
        create_option                 = "Attach"
        lun                           = 11
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[11]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[11]}"
        create_option                 = "Attach"
        lun                           = 12
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[12]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[12]}"
        create_option                 = "Attach"
        lun                           = 13
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-isu2.*.name[13]}"
        managed_disk_id               = "${azurerm_managed_disk.db-isu2.*.id[13]}"
        create_option                 = "Attach"
        lun                           = 14
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}"
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