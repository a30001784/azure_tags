variable "tenant_id" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "resource_group_name" {}
variable "location" {}

variable "host_password" {}

variable "hostname_prefix" {}
variable "hostname_suffix_start_range" {}

variable "subnet_id_app" {}
variable "subnet_id_data" {}

variable "network_security_group_name_app" {}
variable "network_security_group_name_data" {}

variable "node_count_crm_app" {
    default = 0
}
variable "node_count_crm_ascs" { 
    default = 0
}
variable "node_count_crm_db" { 
    default = 0
}

variable "node_count_isu_app" {
    default = 0
}
variable "node_count_isu_ascs" { 
    default = 0
}
variable "node_count_isu_db" { 
    default = 0
}

variable "vm_size_crm_app" {}
variable "vm_size_crm_ascs" {}
variable "vm_size_crm_db" {}

variable "vm_size_isu_app" {}
variable "vm_size_isu_ascs" {}
variable "vm_size_isu_db" {}

variable "data_disk_size_secondary_crm_app" {
    default = 512
}
variable "data_disk_count_secondary_crm_app" {
    default = 0
}
variable "data_disk_size_secondary_crm_ascs" {
    default = 512
}
variable "data_disk_count_secondary_crm_ascs" {
    default = 0
}
variable "data_disk_size_secondary_crm_db" {
    default = 512
}
variable "data_disk_count_secondary_crm_db" {
    default = 0
}

variable "data_disk_size_secondary_isu_app" {
    default = 512
}
variable "data_disk_count_secondary_isu_app" {
    default = 0
}
variable "data_disk_size_secondary_isu_ascs" {
    default = 512
}
variable "data_disk_count_secondary_isu_ascs" {
    default = 0
}
variable "data_disk_size_secondary_isu_db" {
    default = 512
}
variable "data_disk_count_secondary_isu_db" {
    default = 0
}