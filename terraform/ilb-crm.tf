# ilb-crm

resource "azurerm_lb" "ilb-crm" {
    name                              = "${var.load_balancer_name_app_crm}"
    location                          = "${var.location}"
    resource_group_name               = "${var.resource_group_name}"

    frontend_ip_configuration {
        name                          = "${var.load_balancer_frontend_config_name_app_crm}"
        subnet_id                     = "${var.subnet_id_app}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_lb_backend_address_pool" "ilb-crm-be-pool" {
    name                              = "${var.load_balancer_backend_pool_name_app_crm}"
    resource_group_name               = "${var.resource_group_name}"
    loadbalancer_id                   = "${azurerm_lb.ilb-crm.id}"
    depends_on                        = ["azurerm_lb.ilb-crm"]
}

resource "azurerm_lb_probe" "ilb-crm-probe" {
    count                             = 2
    resource_group_name               = "${var.resource_group_name}"
    loadbalancer_id                   = "${azurerm_lb.ilb-crm.id}"
    name                              = "${var.load_balancer_probe_prefix_app_crm}80${count.index + 1}0"
    protocol                          = "Http"
    port                              = "80${count.index + 1}0"
    interval_in_seconds               = 5
    number_of_probes                  = 2
    depends_on                        = ["azurerm_lb.ilb-crm"]
}

resource "azurerm_lb_rule" "ilb-crm-rule" {
    count                             = 2
    name                              = "${var.load_balancer_rule_name_app_crm}-0${count.index + 1}"
    resource_group_name               = "${var.resource_group_name}"
    loadbalancer_id                   = "${azurerm_lb.ilb-crm.id}"
    protocol                          = "tcp"
    frontend_port                     = "80${count.index + 1}0"
    backend_port                      = "80${count.index + 1}0"
    idle_timeout_in_minutes           = 4
    load_distribution                 = "SourceIPProtocol"
    frontend_ip_configuration_name    = "${var.load_balancer_frontend_config_name_app_crm}"
    enable_floating_ip                = false
    probe_id                          = "${azurerm_lb_probe.ilb-crm-probe.*.id[count.index]}"
    backend_address_pool_id           = "${azurerm_lb_backend_address_pool.ilb-crm-be-pool.id}"
    depends_on                        = ["azurerm_lb_backend_address_pool.ilb-crm-be-pool","azurerm_lb_probe.ilb-crm-probe"]
}