terraform {
  backend "azurerm" {
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
    subscription_id                      = "${var.subscription_id}"
    client_id                            = "${var.client_id}"
    client_secret                        = "${var.client_secret}"
    tenant_id                            = "${var.tenant_id}"
}

locals {
    hostname_suffix_start_range_crm_app  = "${var.hostname_suffix_start_range}"
    hostname_suffix_start_range_crm_ascs = "${local.hostname_suffix_start_range_crm_app + var.node_count_crm_app}"
    hostname_suffix_start_range_crm_db   = "${local.hostname_suffix_start_range_crm_ascs + var.node_count_crm_ascs}"
}

module "nsg-app" { 
    source                               = "./modules/network-security-group"
    name                                 = "${var.nsg_name_app}"
    resource_group                       = "${var.resource_group_name}"
    location                             = "${var.location}"
}

module "nsg-data" { 
    source                               = "./modules/network-security-group"
    name                                 = "${var.nsg_name_data}"
    resource_group                       = "${var.resource_group_name}"
    location                             = "${var.location}"
}

module "crm-app" { 
    source                               = "./modules/windows-vm"
    resource_group                       = "${var.resource_group_name}"
    location                             = "${var.location}"
    count                                = "${var.node_count_crm_app}"
    hostname_prefix                      = "${var.hostname_prefix}"
    hostname_suffix_start_range          = "${local.hostname_suffix_start_range_crm_app}"
    subnet_id                            = "${var.subnet_id_app}"
    host_password                        = "${var.host_password}"
    vm_size                              = "${var.vm_size_crm_app}"
    network_security_group_id            = "${module.nsg-app.network_security_group_id}"
    data_disk_size_secondary             = "${var.data_disk_size_secondary_crm_app}"
    data_disk_count_secondary            = "${var.data_disk_count_secondary_crm_app}"
}

module "crm-ascs" {
    source                               = "./modules/windows-vm"
    resource_group                       = "${var.resource_group_name}"
    location                             = "${var.location}"
    count                                = "${var.node_count_crm_ascs}"
    hostname_prefix                      = "${var.hostname_prefix}"
    hostname_suffix_start_range          = "${local.hostname_suffix_start_range_crm_ascs}"
    subnet_id                            = "${var.subnet_id_app}"
    host_password                        = "${var.host_password}"
    vm_size                              = "${var.vm_size_crm_ascs}"
    network_security_group_id            = "${module.nsg-app.network_security_group_id}"
    data_disk_size_secondary             = "${var.data_disk_size_secondary_crm_ascs}"
    data_disk_count_secondary            = "${var.data_disk_count_secondary_crm_ascs}"
}

module "crm-db" {
    source                               = "./modules/windows-vm"
    resource_group                       = "${var.resource_group_name}"
    location                             = "${var.location}"
    count                                = "${var.node_count_crm_db}"
    hostname_prefix                      = "${var.hostname_prefix}"
    hostname_suffix_start_range          = "${local.hostname_suffix_start_range_crm_db}"
    subnet_id                            = "${var.subnet_id_data}"
    host_password                        = "${var.host_password}"
    vm_size                              = "${var.vm_size_crm_db}"
    network_security_group_id            = "${module.nsg-data.network_security_group_id}"
    data_disk_size_secondary             = "${var.data_disk_size_secondary_crm_db}"
    data_disk_count_secondary            = "${var.data_disk_count_secondary_crm_db}"
}