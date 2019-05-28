variable "name" {
    description = "Name of Network Security Group"    
}
variable "resource_group" {
    description = "Resource group in which the NSG should be created"
}
variable "location" {
    description = "Azure data center location in which the NSG should be created"
}