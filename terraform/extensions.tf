locals { 
    ws2008_virtual_machines_count = "${var.node_count_app_nwgw + var.node_count_app_xi + var.node_count_ascs_xi + var.node_count_db_nwgw + var.node_count_db_xi}"
    ws2008_virtual_machines_names = "${concat(concat(concat(concat(azurerm_virtual_machine.app-nwgw.*.name, azurerm_virtual_machine.app-xi.*.name), azurerm_virtual_machine.ascs-xi.*.name), azurerm_virtual_machine.db-nwgw.*.name), azurerm_virtual_machine.db-xi.*.name)}"
    #app-xi, db-xi, ascs-xi, app-nwgw, db-nwgw

}

locals { 
    ws2012_virtual_machines_count = "${var.node_count_ascs_pi + var.node_count_db_pi}"
    ws2012_virtual_machines_names = "${concat(azurerm_virtual_machine.ascs-pi.*.name, azurerm_virtual_machine.db-pi.*.name)}"
    #ascs-pi, db-pi
}

locals {
    ws2016_virtual_machines_count = "${var.node_count_app_crm + var.node_count_app_isu + var.node_count_db_crm + var.node_count_ascs}"
    ws2016_virtual_machines_names = "${concat(concat(concat(azurerm_virtual_machine.app-crm.*.name, azurerm_virtual_machine.app-isu.*.name), azurerm_virtual_machine.db-crm.*.name), azurerm_virtual_machine.ascs.*.name)}"
    #app-crm, app-isu, db-crm, db-isu, ascs, app-swd
}

resource "azurerm_virtual_machine_extension" "prepare_winrm_2008" {
    count                 = "${local.ws2008_virtual_machines_count}"
    name                  = "${element(local.ws2008_virtual_machines_names, count.index)}-prepare_winrm_2008"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    virtual_machine_name  = "${element(local.ws2008_virtual_machines_names, count.index)}"
    publisher             = "Microsoft.Compute"
    type                  = "CustomScriptExtension"
    type_handler_version  = "1.8"
    depends_on            = ["azurerm_virtual_machine.app-nwgw","azurerm_virtual_machine.app-xi","azurerm_virtual_machine.ascs-xi","azurerm_virtual_machine.db-nwgw","azurerm_virtual_machine.db-xi",]

    settings              = <<SETTINGS
    {
        "commandToExecute": "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File Prepare-WS2008R2.ps1",
        "fileUris":         ["https://saptestsatf01.blob.core.windows.net/scripts/Prepare-WS2008R2.ps1"]
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "prepare_winrm_2012" {
    count                 = "${local.ws2012_virtual_machines_count}"
    name                  = "${element(local.ws2012_virtual_machines_names, count.index)}-prepare_winrm_2012"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    virtual_machine_name  = "${element(local.ws2012_virtual_machines_names, count.index)}"
    publisher             = "Microsoft.Compute"
    type                  = "CustomScriptExtension"
    type_handler_version  = "1.8"
    depends_on            = ["azurerm_virtual_machine.ascs-pi","azurerm_virtual_machine.db-pi"]

    settings              = <<SETTINGS
    {
        "commandToExecute": "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1",
        "fileUris":         ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "prepare_winrm_2016" {
    count                 = "${local.ws2016_virtual_machines_count}"
    name                  = "${element(local.ws2016_virtual_machines_names, count.index)}-prepare_winrm_2016"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    virtual_machine_name  = "${element(local.ws2016_virtual_machines_names, count.index)}"
    publisher             = "Microsoft.Compute"
    type                  = "CustomScriptExtension"
    type_handler_version  = "1.8"
    depends_on            = ["azurerm_virtual_machine.app-crm","azurerm_virtual_machine.app-isu","azurerm_virtual_machine.ascs","azurerm_virtual_machine.db-crm"]

    settings              = <<SETTINGS
    {
        "commandToExecute": "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1",
        "fileUris":         ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS
}