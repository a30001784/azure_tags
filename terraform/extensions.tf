resource "azurerm_virtual_machine_extension" "prepare_winrm_2008" {
    count                 = "${var.node_count_app_isu + var.node_count_app_crm}"
    name                  = "${element(concat(azurerm_virtual_machine.app-isu.*.name, azurerm_virtual_machine.app-crm.*.name),count.index)}-prepare_winrm_2008"
    location              = "${var.location}"
    resource_group_name   = "${var.resource_group_name}"
    virtual_machine_name  = "${element(concat(azurerm_virtual_machine.app-isu.*.name, azurerm_virtual_machine.app-crm.*.name),count.index)}"
    publisher             = "Microsoft.Compute"
    type                  = "CustomScriptExtension"
    type_handler_version  = "1.8"
    depends_on            = ["azurerm_virtual_machine.app-isu","azurerm_virtual_machine.app-crm"]

    settings              = <<SETTINGS
    {
        "commandToExecute": "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File Prepare-WS2008R2.ps1",
        "fileUris":         ["https://saptestsatf01.blob.core.windows.net/scripts/Prepare-WS2008R2.ps1"]
    }
SETTINGS
}

// resource "azurerm_virtual_machine_extension" "prepare_winrm_2012" {
//     count                 = 2
//     name                  = "${element(concat(azurerm_virtual_machine.db-isu.*.name, azurerm_virtual_machine.db-crm.*.name),count.index)}-prepare_winrm_2012"
//     location              = "${var.location}"
//     resource_group_name   = "${var.resource_group_name}"
//     virtual_machine_name  = "${element(concat(azurerm_virtual_machine.db-isu.*.name, azurerm_virtual_machine.db-crm.*.name),count.index)}"
//     publisher             = "Microsoft.Compute"
//     type                  = "CustomScriptExtension"
//     type_handler_version  = "1.8"
//     depends_on            = ["azurerm_virtual_machine.db-crm", "azurerm_virtual_machine.db-isu"]

//     settings              = <<SETTINGS
//     {
//         "commandToExecute": "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1",
//         "fileUris":         ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
//     }
// SETTINGS
// }