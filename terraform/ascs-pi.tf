# ascs-pi

resource "azurerm_availability_set" "ascs-pi" {
    name                              = "${var.availability_set_name_ascs_pi}"
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

resource "azurerm_network_interface" "ascs-pi" {
    count                             = "${var.node_count_ascs_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_pi + count.index}-nic01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_security_group_id         = "${azurerm_network_security_group.nsg-app.id}"
    enable_accelerated_networking     = true

    ip_configuration {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_pi + count.index}-nic01-ipconfig"
        subnet_id                     = "${var.subnet_id_app}"
        private_ip_address_allocation = "dynamic"
    }

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_managed_disk" "ascs-pi" {
    count                             = "${var.node_count_ascs_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_pi + count.index}-datadisk01"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    storage_account_type              = "Premium_LRS"
    create_option                     = "Empty"
    disk_size_gb                      = "${var.data_disk_size_ascs_pi}"

    tags {
        CostCode                      = "${var.tag_cost_code}"
        TechnicalOwner                = "${var.tag_technical_owner}"
        BusinessOwner                 = "${var.tag_business_owner}"
    }
}

resource "azurerm_virtual_machine" "ascs-pi" {
    count                             = "${var.node_count_ascs_pi}"
    name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_pi + count.index}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"
    network_interface_ids             = ["${azurerm_network_interface.ascs-pi.*.id[count.index]}"]
    vm_size                           = "${var.vm_size_ascs_pi}"
    availability_set_id               = "${azurerm_availability_set.ascs-pi.id}"
    depends_on                        = ["azurerm_network_interface.ascs-pi","azurerm_managed_disk.ascs-pi"]

    delete_os_disk_on_termination     = true
    delete_data_disks_on_termination  = true

    storage_image_reference {
        publisher                     = "MicrosoftWindowsServer"
        offer                         = "WindowsServer"
        sku                           = "2012-R2-Datacenter"
        version                       = "latest"
    }

    storage_os_disk {
        name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_pi + count.index}-osdisk"
        caching                       = "ReadWrite"
        create_option                 = "FromImage"
        managed_disk_type             = "Premium_LRS"
        disk_size_gb                  = 256
    }
    
    storage_data_disk {
        name                          = "${azurerm_managed_disk.ascs-pi.*.name[count.index]}"
        managed_disk_id               = "${azurerm_managed_disk.ascs-pi.*.id[count.index]}"
        create_option                 = "Attach"
        lun                           = 0
        disk_size_gb                  = "${azurerm_managed_disk.ascs-pi.*.disk_size_gb[count.index]}"
    }

    os_profile {
        computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_ascs_pi + count.index}"
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