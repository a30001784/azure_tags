output "ip_addresses_app-crm" { 
    value = "${azurerm_network_interface.app-crm.*.private_ip_address}"
}

output "ip_addresses_app-isu" { 
    value = "${azurerm_network_interface.app-isu.*.private_ip_address}"
}

output "ip_addresses_app-nwgw" { 
    value = "${azurerm_network_interface.app-nwgw.*.private_ip_address}"
}

output "ip_addresses_app-xi" { 
    value = "${azurerm_network_interface.app-xi.*.private_ip_address}"
}

output "ip_addresses_ascs-crm" { 
    value = "${element(azurerm_network_interface.ascs.*.private_ip_address, 0)}"
}

output "ip_addresses_ascs-isu" {
    value = "${element(azurerm_network_interface.ascs.*.private_ip_address, 1)}"
}

output "ip_addresses_ascs-pi" {
    value = ["${azurerm_network_interface.ascs-pi.*.private_ip_address}"]
}

output "ip_addresses_ascs-xi" {
    value = ["${azurerm_network_interface.ascs-xi.*.private_ip_address}"]
}

// output "ip_addresses_data" { 
//     value = ["${azurerm_network_interface.db-isu.private_ip_address}","${azurerm_network_interface.db-crm.private_ip_address}"]
// }

output "ip_addresses_data-crm" { 
    value = ["${azurerm_network_interface.db-crm.private_ip_address}"]
}

// output "ip_addresses_data-isu" { 
//     value = ["${azurerm_network_interface.db-isu.private_ip_address}"]
// }

output "ip_addresses_data-nwgw" { 
    value = ["${azurerm_network_interface.db-nwgw.*.private_ip_address}"]
} 

output "ip_addresses_data-pi" { 
    value = ["${azurerm_network_interface.db-pi.*.private_ip_address}"]
}

output "ip_addresses_data-xi" {
    value = ["${azurerm_network_interface.db-xi.*.private_ip_address}"]
}

// output "ip_addresses_pi" {
//     value = ["${azurerm_network_interface.pi.*.private_ip_address}"]
// }

// output "ip_addresses_data" { 
//     value = {
        
//     }
// }