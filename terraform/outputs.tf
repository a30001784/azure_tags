output "ip_addresses_crm-app" { 
    value = "${module.crm-app.private_ip_addresses}"
}

output "ip_addresses_crm-ascs" { 
    value = "${module.crm-ascs.private_ip_addresses}"
}

output "ip_addresses_crm-data" { 
    value = "${module.crm-db.private_ip_addresses}"
}

output "ip_addresses_isu-app" { 
    value = "${module.isu-app.private_ip_addresses}"
}

output "ip_addresses_isu-ascs" { 
    value = "${module.isu-ascs.private_ip_addresses}"
}

output "ip_addresses_isu-data" { 
    value = "${module.isu-db.private_ip_addresses}"
}

output "hostname_crm-pas" { 
    value = "${element(module.crm-app.hostnames, 0)}"
}

output "hostname_crm-aas" { 
    value = "${element(module.crm-app.hostnames, 1)}"
}

output "hostname_crm-ascs" { 
    value = "${element(module.crm-ascs-hostnames, 0)}"
}

output "hostname_crm-data" { 
    value = "${element(module.crm-db.hostnames, 0)}"
}

output "hostname_isu-pas" { 
    value = "${element(module.isu-app.hostnames, 0)}"
}

output "hostname_crm-ascs" { 
    value = "${element(module.crm-ascs-hostnames, 0)}"
}

output "hostname_isu-data" { 
    value = "${element(module.isu-db.hostnames, 0)}"
}