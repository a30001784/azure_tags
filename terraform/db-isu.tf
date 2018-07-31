// # db-isu

// resource "azurerm_network_interface" "db-isu" {
//     name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu + count.index}-nic01"
//     location                          = "${var.location}"
//     resource_group_name               = "${var.resource_group_name}"
//     network_security_group_id         = "${azurerm_network_security_group.nsg-data.id}"
//     enable_accelerated_networking     = true

//     ip_configuration {
//         name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu + count.index}-nic01-ipconfig"
//         subnet_id                     = "${var.subnet_id_data}"
//         private_ip_address_allocation = "dynamic"
//     }

//     tags {
//         CostCode                      = "${var.tag_cost_code}"
//         TechnicalOwner                = "${var.tag_technical_owner}"
//         BusinessOwner                 = "${var.tag_business_owner}"
//     }
// }

// resource "azurerm_managed_disk" "db-isu" {
//     count                             = "${var.data_disk_count_db_isu}"
//     name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}-datadisk${count.index + 1 < 10 ? "0" : ""}${count.index + 1}"
//     location                          = "${var.location}"
//     resource_group_name               = "${var.resource_group_name}"
//     storage_account_type              = "Premium_LRS"
//     create_option                     = "Empty"
//     disk_size_gb                      = "${var.data_disk_size_db}"

//     tags {
//         CostCode                      = "${var.tag_cost_code}"
//         TechnicalOwner                = "${var.tag_technical_owner}"
//         BusinessOwner                 = "${var.tag_business_owner}"
//     }
// }

// resource "azurerm_virtual_machine" "db-isu" {
//     name                              = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}"
//     location                          = "${var.location}"
//     resource_group_name               = "${var.resource_group_name}"
//     network_interface_ids             = ["${azurerm_network_interface.db-isu.id}"]
//     vm_size                           = "${var.vm_size_db}"
//     depends_on                        = ["azurerm_network_interface.db-isu","azurerm_managed_disk.db-isu"]

//     delete_os_disk_on_termination     = true
//     delete_data_disks_on_termination  = true

//     storage_image_reference {
//         publisher                     = "MicrosoftWindowsServer"
//         offer                         = "WindowsServer"
//         sku                           = "2016-Datacenter"
//         version                       = "latest"
//     }

//     storage_os_disk {
//         name                          = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}-osdisk"
//         caching                       = "ReadWrite"
//         create_option                 = "FromImage"
//         managed_disk_type             = "Premium_LRS"
//         disk_size_gb                  = "256"
//     }

//     // Count is not supported for storage_data_disk...
//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[0]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[0]}"
//         create_option                 = "Attach"
//         lun                           = 0
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[1]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[1]}"
//         create_option                 = "Attach"
//         lun                           = 1
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[2]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[2]}"
//         create_option                 = "Attach"
//         lun                           = 2
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[3]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[3]}"
//         create_option                 = "Attach"
//         lun                           = 3
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[4]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[4]}"
//         create_option                 = "Attach"
//         lun                           = 4
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[5]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[5]}"
//         create_option                 = "Attach"
//         lun                           = 5
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[6]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[6]}"
//         create_option                 = "Attach"
//         lun                           = 6
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[7]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[7]}"
//         create_option                 = "Attach"
//         lun                           = 7
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[8]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[8]}"
//         create_option                 = "Attach"
//         lun                           = 8
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[9]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[9]}"
//         create_option                 = "Attach"
//         lun                           = 9
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[10]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[10]}"
//         create_option                 = "Attach"
//         lun                           = 10
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[11]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[11]}"
//         create_option                 = "Attach"
//         lun                           = 11
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[12]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[12]}"
//         create_option                 = "Attach"
//         lun                           = 12
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[13]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[13]}"
//         create_option                 = "Attach"
//         lun                           = 13
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[14]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[14]}"
//         create_option                 = "Attach"
//         lun                           = 14
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[15]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[15]}"
//         create_option                 = "Attach"
//         lun                           = 15
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[16]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[16]}"
//         create_option                 = "Attach"
//         lun                           = 16
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[17]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[17]}"
//         create_option                 = "Attach"
//         lun                           = 17
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[18]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[18]}"
//         create_option                 = "Attach"
//         lun                           = 18
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[19]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[19]}"
//         create_option                 = "Attach"
//         lun                           = 19
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[20]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[20]}"
//         create_option                 = "Attach"
//         lun                           = 20
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[21]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[21]}"
//         create_option                 = "Attach"
//         lun                           = 21
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[22]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[22]}"
//         create_option                 = "Attach"
//         lun                           = 22
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[23]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[23]}"
//         create_option                 = "Attach"
//         lun                           = 23
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[24]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[24]}"
//         create_option                 = "Attach"
//         lun                           = 24
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[25]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[25]}"
//         create_option                 = "Attach"
//         lun                           = 25
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }

//     storage_data_disk {
//         name                          = "${azurerm_managed_disk.db-isu.*.name[26]}"
//         managed_disk_id               = "${azurerm_managed_disk.db-isu.*.id[26]}"
//         create_option                 = "Attach"
//         lun                           = 26
//         disk_size_gb                  = "${var.data_disk_size_db}"
//         caching                       = "ReadOnly"
//     }
//     // The code contained within these comments is rubbish. To be fixed in Terraform 0.12

//     os_profile {
//         computer_name                 = "${var.hostname_prefix}${var.hostname_suffix_start_range_db_isu}"
//         admin_username                = "${var.host_username}"
//         admin_password                = "${var.host_password}"
//     }

//     os_profile_windows_config {
//         provision_vm_agent            = true
//     }

//     tags {
//         CostCode                      = "${var.tag_cost_code}"
//         TechnicalOwner                = "${var.tag_technical_owner}"
//         BusinessOwner                 = "${var.tag_business_owner}"
//     }
// }