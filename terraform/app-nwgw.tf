# app-nwgw

resource "azurerm_availability_set" "app-nwgw" {
    name                              = "${var.availability_set_name_app_nwgw}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    managed                           = true
    platform_fault_domain_count       = 2

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_network_interface" "app-nwgw" {
    count                             = "${var.node_count_app_nwgw}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_nwgw + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-app.id}"
    enable_accelerated_networking     = true
    // depends_on                        = ["azurerm_lb.ilb-app-nwgw"]

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_nwgw + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_app}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_virtual_machine" "app-nwgw" {
    count                             = "${var.node_count_app_nwgw}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_nwgw + count.index}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.app-nwgw.*.id[count.index]}"]
    vm_size                           = "${var.vm_size_app_nwgw}"
    availability_set_id               = "${azurerm_availability_set.app-nwgw.id}"
    depends_on                        = ["azurerm_network_interface.app-nwgw"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2008-R2-SP1"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_nwgw + count.index}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = "256"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_nwgw + count.index}"
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