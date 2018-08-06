## ==== Provider =========================================================== ##

variable "tenant_id" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

## ==== Tags =============================================================== ## 

variable "tag_business_owner" {}
variable "tag_cost_code" {}
variable "tag_technical_owner" {}

## ==== Shared ============================================================= ##

variable "resource_group_name" {}
variable "location" {}
variable "host_username" {}
variable "host_password" {}
variable "hostname_prefix" {}

## ==== App ================================================================ ##

variable "vm_size_app" {}
variable "network_security_group_app" {}
variable "subnet_id_app" {}

## ==== App CRM ============================================================ ##

variable "availability_set_name_app_crm" {}
variable "hostname_suffix_start_range_app_crm" {}
variable "node_count_app_crm" {}

## ==== App ISU ============================================================ ##

variable "availability_set_name_app_isu" {}
variable "hostname_suffix_start_range_app_isu" {}
variable "node_count_app_isu" {}

## ==== APP NWGW =========================================================== ##

variable "availability_set_name_app_nwgw" {}
variable "hostname_suffix_start_range_app_nwgw" {}
variable "node_count_app_nwgw" {}
variable "vm_size_app_nwgw" {} 

## ==== APP XI ============================================================== ##

variable "availability_set_name_app_xi" {}
variable "hostname_suffix_start_range_app_xi" {}
variable "node_count_app_xi" {}
variable "vm_size_app_xi" {} 

## ==== DB ================================================================= ##

variable "vm_size_db" {}
variable "network_security_group_data" {}
variable "subnet_id_data" {}
variable "data_disk_size_db" {}

## ==== DB ISU ============================================================= ##

variable "hostname_suffix_start_range_db_isu" {}
variable "data_disk_count_db_isu" {}
variable "node_count_db_isu" {}

## ==== DB CRM ============================================================= ##

variable "hostname_suffix_start_range_db_crm" {}
variable "data_disk_count_db_crm" {}
variable "node_count_db_crm" {}

## ==== DB NWGW ============================================================= ##

variable "hostname_suffix_start_range_db_nwgw" {}
variable "data_disk_count_db_nwgw" {}
variable "vm_size_db_nwgw" {}
variable "node_count_db_nwgw" {}

## ==== DB PI =============================================================== ##

variable "hostname_suffix_start_range_db_pi" {}
variable "data_disk_count_db_pi" {}
variable "vm_size_db_pi" {}
variable "node_count_db_pi" {}

## ==== DB XI =============================================================== ##

variable "hostname_suffix_start_range_db_xi" {}
variable "data_disk_count_db_xi" {}
variable "vm_size_db_xi" {}
variable "node_count_db_xi" {}

## ==== ASCS CRM/ISU ======================================================== ##

variable "node_count_ascs" {}
variable "vm_size_ascs" {} 
variable "hostname_suffix_start_range_ascs" {}
variable "data_disk_size_ascs" {}

## ==== ASCS PI ============================================================= ##

variable "availability_set_name_ascs_pi" {}
variable "data_disk_size_ascs_pi" {}
variable "hostname_suffix_start_range_ascs_pi" {}
variable "node_count_ascs_pi" {}
variable "vm_size_ascs_pi" {} 

## ==== ASCS XI ============================================================= ##

variable "node_count_ascs_xi" {}
variable "vm_size_ascs_xi" {} 
variable "hostname_suffix_start_range_ascs_xi" {}
variable "data_disk_size_ascs_xi" {}