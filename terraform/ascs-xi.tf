# ascs-xi

resource "azurerm_network_interface" "ascs-xi" {
    count                             = "${var.node_count_ascs_xi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_xi + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-app.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_xi + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_app}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_managed_disk" "ascs-xi" {
    count                             = "${var.node_count_ascs_xi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_xi + count.index}-datadisk${count.index + 1 < 10 ? "0" : ""}${count.index + 1}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "${var.data_disk_size_ascs_xi}"

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_virtual_machine" "ascs-xi" {
    count                             = "${var.node_count_ascs_xi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_xi + count.index}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.ascs-xi.*.id[count.index]}"]
    vm_size                           = "${var.vm_size_ascs_xi}"
    depends_on                        = ["azurerm_network_interface.ascs-xi","azurerm_managed_disk.ascs-xi"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2008-R2-SP1"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_xi + count.index}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = 256
    }
    
    storage_data_disk {
        name                          = "${azurerm_managed_disk.ascs-xi.*.name[count.index]}"
        managed_disk_id               = "${azurerm_managed_disk.ascs-xi.*.id[count.index]}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${azurerm_managed_disk.ascs-xi.*.disk_size_gb[count.index]}"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_xi + count.index}"
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