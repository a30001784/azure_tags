# app-crm

resource "azurerm_availability_set" "app-crm" {
    name                                          = "${var.availability_set_name}"
    location                                      = "${var.location}"
    resource_group_name                           = "${var.resource_group_name}"
    managed                                       = true
    platform_fault_domain_count                   = 2

    tags {
        CostCode                                  = "RE-DT01-C03-FN"
        TechnicalOwner                            = "Ruschal Alphonso"
        BusinessOwner                             = "Nirusha Dissanayake"
    }
}

resource "azurerm_network_interface" "app-crm" {
    count                                         = "${var.node_count_app_crm}"
    name                                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_crm + count.index}-nic1"
    location                                      = "${var.location}"
    resource_group_name                           = "${var.resource_group_name}"
    network_security_group_id                     = "${azurerm_network_security_group.nsg-app.id}"
    //depends_on                                  = ["azurerm_lb.ilb-app-crm"]

    ip_configuration {
        name                                      = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_crm + count.index}-nic1-ipconfig"
        subnet_id                                 = "${var.subnet_id_app}"
        private_ip_address_allocation             = "static"
        private_ip_address                        = "${cidrhost(var.ip_range_app, var.ip_start_range_app_crm + count.index)}"
        //load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.ilb-crm-be-pool.id}"]
    }

    tags {
        CostCode                                  = "RE-DT01-C03-FN"
        TechnicalOwner                            = "Ruschal Alphonso"
        BusinessOwner                             = "Nirusha Dissanayake"
    }
}

resource "azurerm_managed_disk" "app-crm" {
    count                                         = "${var.node_count_app_crm}"
    name                                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_crm + count.index}-datadisk01"
    location                                      = "${var.location}"
    resource_group_name                           = "${var.resource_group_name}"
    storage_account_type                          = "Premium_LRS"
    create_option                                 = "Empty"
    disk_size_gb                                  = "127"

    tags {
        CostCode                                  = "RE-DT01-C03-FN"
        TechnicalOwner                            = "Ruschal Alphonso"
        BusinessOwner                             = "Nirusha Dissanayake"
    }
}

resource "azurerm_virtual_machine" "app-crm" {
    count                                         = "${var.node_count_app_crm}"
    name                                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_crm + count.index}"
    location                                      = "${var.location}"
    resource_group_name                           = "${var.resource_group_name}"
    network_interface_ids                         = ["${azurerm_network_interface.app-crm.*.id[count.index]}"]
    vm_size                                       = "${var.vm_size_app}"
    availability_set_id                           = "${azurerm_availability_set.app-crm.id}"
    depends_on                                    = ["azurerm_network_interface.app-crm","azurerm_managed_disk.app-crm"]

    delete_os_disk_on_termination                 = true
    delete_data_disks_on_termination              = true

    storage_image_reference {
        publisher                                 = "MicrosoftWindowsServer"
        offer                                     = "WindowsServer"
        sku                                       = "2008-R2-SP1"
        version                                   = "latest"
    }

    storage_os_disk {
        name                                      = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_crm + count.index}-osdisk"
        caching                                   = "ReadWrite"
        create_option                             = "FromImage"
        managed_disk_type                         = "Premium_LRS"
        disk_size_gb                              = "127"
    }

    storage_data_disk {
        name                                      = "${azurerm_managed_disk.app-crm.*.name[count.index]}"
        managed_disk_id                           = "${azurerm_managed_disk.app-crm.*.id[count.index]}"
        create_option                             = "Attach"
        lun                                       = 0
        disk_size_gb                              = "${azurerm_managed_disk.app-crm.*.disk_size_gb[count.index]}"
    }

    os_profile {
        computer_name                             = "${var.hostname_prefix}${var.hostname_suffix_start_range_app_crm + count.index}"
        admin_username                            = "${var.host_username}"
        admin_password                            = "${var.host_password}"
    }

    os_profile_windows_config {
        provision_vm_agent                        = true
    }

    tags {
        CostCode                                  = "RE-DT01-C03-FN"
        TechnicalOwner                            = "Ruschal Alphonso"
        BusinessOwner                             = "Nirusha Dissanayake"
    }
}