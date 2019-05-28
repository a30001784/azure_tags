output "private_ip_addresses" { 
    value = ["${azurerm_network_interface.main.*.private_ip_address}"]
}

output "hostnames" { 
    value = ["${azurerm_virtual_machine.main.*.name}"]
}