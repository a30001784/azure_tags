# nsg-app.tf

# TODO:                              confirm if NSG should be created in NetworkWatcherRG
resource "azurerm_network_security_group" "nsg-app" {
    name                           = "${var.network_security_group_app}"
    location                       = "${var.location}"
    resource_group_name            = "${var.resource_group_name}"
    //depends_on                   = ["azurerm_resource_group.rg"]

    security_rule {
        name                       = "RDP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WinRM"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5985-5986"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        CostCode                   = "${var.tag_cost_code}"
        TechnicalOwner             = "${var.tag_technical_owner}"
        BusinessOwner              = "${var.tag_business_owner}"
    }
}