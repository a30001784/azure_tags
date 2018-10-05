# db-xi

resource "azurerm_network_interface" "db-xi" {
    count                             = "${var.node_count_db_xi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_xi + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-data.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_xi + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_data}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_managed_disk" "db-xi" {
    count                             = "${var.node_count_db_xi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_xi + count.index}-datadisk01"
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

resource "azurerm_virtual_machine" "db-xi" {
    count                             = "${var.node_count_db_xi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_xi + count.index}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.db-xi.*.id[count.index]}"]
    vm_size                           = "${var.vm_size_db_xi}"
    depends_on                        = ["azurerm_network_interface.db-xi","azurerm_managed_disk.db-xi"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2008-R2-SP1"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_xi + count.index}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = "256"
    }

    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-xi.*.name[count.index]}"
        managed_disk_id               = "${azurerm_managed_disk.db-xi.*.id[count.index]}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${azurerm_managed_disk.db-xi.*.disk_size_gb[count.index]}"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_xi + count.index}"
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