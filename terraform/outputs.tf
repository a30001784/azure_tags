output "ip_addresses_app-crm" { 
    value = "${slice(azurerm_network_interface.app.*.private_ip_address, 0, var.node_count_app_crm)}"
}

output "ip_addresses_app-isu" { 
    value = "${slice(azurerm_network_interface.app.*.private_ip_address, var.node_count_app_crm, length(azurerm_network_interface.app.*.private_ip_address))}"
}

output "ip_addresses_app-nwgw" { 
    value = "${azurerm_network_interface.app-nwgw.*.private_ip_address}"
}

output "ip_addresses_app-swd" { 
    value = "${azurerm_network_interface.app-swd.*.private_ip_address}"
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

output "ip_addresses_data-crm" { 
    value = "${azurerm_network_interface.db-crm.private_ip_address}"
}

output "ip_addresses_data-isu" { 
    value = "${azurerm_network_interface.db-isu.private_ip_address}"
}

output "ip_addresses_data-nwgw" { 
    value = ["${azurerm_network_interface.db-nwgw.*.private_ip_address}"]
} 

output "ip_addresses_data-pi" { 
    value = ["${azurerm_network_interface.db-pi.*.private_ip_address}"]
}

output "ip_addresses_data-xi" {
    value = ["${azurerm_network_interface.db-xi.*.private_ip_address}"]
}

// output "hostnames_app-crm" { 
//     value = "${slice(azurerm_virtual_machine.app.*.name, 0, var.node_count_app_crm)}"
// }

// output "hostnames_app-isu" { 
//     value = "${slice(azurerm_virtual_machine.app.*.name, var.node_count_app_crm, length(azurerm_virtual_machine.app.*.name))}"
// }

// output "hostnames_app-nwgw" { 
//     value = "${azurerm_virtual_machine.app-nwgw.*.name}"
// }

// output "hostnames_app-swd" { 
//     value = "${azurerm_virtual_machine.app-swd.*.name}"
// }

// output "hostnames_app-xi" { 
//     value = "${azurerm_virtual_machine.app-xi.*.name}"
// }

// output "hostnames_ascs-crm" { 
//     value = "${element(azurerm_virtual_machine.ascs.*.name, 0)}"
// }

// output "hostnames_ascs-isu" {
//     value = "${element(azurerm_virtual_machine.ascs.*.name, 1)}"
// }

// output "hostnames_ascs-pi" {
//     value = ["${azurerm_virtual_machine.ascs-pi.*.name}"]
// }

// output "hostnames_ascs-xi" {
//     value = ["${azurerm_virtual_machine.ascs-xi.*.name}"]
// }

// output "hostnames_data-crm" { 
//     value = ["${azurerm_virtual_machine.db-crm.name}"]
// }

// output "hostnames_data-isu" { 
//     value = ["${azurerm_virtual_machine.db-isu.name}"]
// }

// output "hostnames_data-nwgw" { 
//     value = ["${azurerm_virtual_machine.db-nwgw.*.name}"]
// } 

// output "hostnames_data-pi" { 
//     value = ["${azurerm_virtual_machine.db-pi.*.name}"]
// }

// output "hostnames_data-xi" {
//     value = ["${azurerm_virtual_machine.db-xi.*.name}"]
// }