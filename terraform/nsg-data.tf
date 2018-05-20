# nsg-data.tf

# TODO: confirm if NSG should be created in NetworkWatcherRG
resource "azurerm_network_security_group" "nsg-data" {
    name                           = "${var.network_security_group_data}"
    location                       = "${var.location}"
    resource_group_name            = "${var.resource_group_name}"
    //depends_on                     = ["azurerm_resource_group.rg"]

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
        CostCode = "RE-DT01-C03-FN"
        TechnicalOwner = "Ruschal Alphonso"
        BusinessOwner = "Nirusha Dissanayake"
    }
}