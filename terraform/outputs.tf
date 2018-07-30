output "ip_addresses_app" { 
    value = "${concat(azurerm_network_interface.app-crm.*.private_ip_address,azurerm_network_interface.app-isu.*.private_ip_address)}"
}

// output "ip_addresses_ascs" { 
//     value = ["${azurerm_network_interface.ascs.*.private_ip_address}"]
// }

// output "ip_addresses_data" { 
//     value = ["${azurerm_network_interface.db-isu.private_ip_address}","${azurerm_network_interface.db-crm.private_ip_address}"]
// }

// output "ip_addresses_db-isu" { 
//     value = ["${azurerm_network_interface.db-isu.private_ip_address}"]
// }

output "ip_addresses_db-crm" { 
    value = ["${azurerm_network_interface.db-crm.private_ip_address}"]
}

// output "ip_addresses_pi" {
//     value = ["${azurerm_network_interface.pi.*.private_ip_address}"]
// }