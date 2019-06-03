variable "tenant_id" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "resource_group_name" {}
variable "location" {}

variable "host_password" {}

variable "hostname_prefix" {}
variable "hostname_suffix_start_range" {}

variable "tags" {
    type = "map"
    default = {
        BusinessOwner = "James Vincent"
        TechnicalOwner = "Ruschal Alphonso"
        CostCode = "C-INF-000027-01"
        Application = "SAP"
        scheduleType = "AlwaysOn_24_7"
        scheduleExemption = "False"
    }
}

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

variable "tag_crm_app" {
    default = {
        Component = "CRM"
        Service = "APP"
        Sid = ""
    }
}

variable "tag_crm_ascs" {
    default = {
        Component = "CRM"
        Service = "ascs"
        Sid = ""
    }
}

variable "tag_crm_db" {
    default = {
        Component = "CRM"
        Service = "db"
        Sid = ""
    }
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

variable "tag_isu_app" {
    default = {
        Component = "ISU"
        Service = "app"
        Sid = ""
    }
}

variable "tag_isu_ascs" {
    default = {
        Component = "ISU"
        Service = "ascs"
        Sid = ""
    }
}

variable "tag_isu_db" {
    default = {
        Component = "ISU"
        Service = "db"
        Sid = ""
    }
}

variable "vm_size_crm_app" {}
variable "vm_size_crm_ascs" {}
variable "vm_size_crm_db" {}

variable "vm_size_isu_app" {}
variable "vm_size_isu_ascs" {}
variable "vm_size_isu_db" {}

variable "data_disk_size_crm_app" {
    default = 512
}
variable "data_disk_count_crm_app" {
    default = 0
}
variable "data_disk_size_crm_ascs" {
    default = 512
}
variable "data_disk_count_crm_ascs" {
    default = 0
}
variable "data_disk_size_crm_db" {
    default = 512
}
variable "data_disk_count_crm_db" {
    default = 0
}

variable "data_disk_size_isu_app" {
    default = 512
}
variable "data_disk_count_isu_app" {
    default = 0
}
variable "data_disk_size_isu_ascs" {
    default = 512
}
variable "data_disk_count_isu_ascs" {
    default = 0
}
variable "data_disk_size_isu_db" {
    default = 512
}
variable "data_disk_count_isu_db" {
    default = 0
}