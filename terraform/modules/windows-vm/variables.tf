variable "resource_group" {
    description = "Resource group in which the VM should be created"
}
variable "location" {
    description = "Azure data center location in which the VM should be created"
}
variable "count" {
    description = "Number of virtual machines to create"
}
variable "hostname_prefix" {
    description = "Hostname prefix"
}
variable "hostname_suffix_start_range" {
    description = "Hostname suffix start range"
}
variable "subnet_id" {
    description = "Id of the subnet which the VM should be added to"
}
variable "host_username" {
    default = "azureadmin"
    description = "Local administrator username for the host"
}
variable "host_password" {
    description = "Local administrator password for the host"
}
variable "vm_size" {
    default     = "Standard_DS1_V2"
    description = "Size of the Virtual Machine to create"
}

variable "os_disk_size" {
    default     = 256
    description = "Size of the Operating System disk"
}

variable "network_security_group_id" {}

variable "data_disk_size_primary" {
    default = 256
}

variable "data_disk_size_secondary" {
    default = 512
}

variable "data_disk_count_secondary" {
    default = 0
}

// variable "tags" {
//   type        = "map"
//   description = "A map of the tags to use on the resources that are deployed with this module."
// }