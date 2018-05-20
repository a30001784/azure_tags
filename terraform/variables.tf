## ==== Provider =========================================================== ##

variable "tenant_id" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

## ==== Shared ============================================================= ##

variable "resource_group_name" {}
variable "location" { default = "australiaeast" }
variable "host_username" {}
variable "host_password" {}
variable "hostname_prefix" {}
variable "dns_domain_name" {}
variable "domain_join_username" {}
variable "domain_join_password" {}
variable "domain_ou_path" {}


# ==== App ================================================================= ##

variable "vm_size_app" {}
variable "network_security_group_app" {}
variable "subnet_id_app" {}
variable "ip_range_app" {}

# ==== App CRM ============================================================= ##

variable "availability_set_name" {}
variable "node_count_app_crm" {}
variable "hostname_suffix_start_range_app_crm" {}
variable "ip_start_range_app_crm" {}
variable "load_balancer_name_app_crm" {}
variable "load_balancer_ip_address_app_crm" {}
variable "load_balancer_backend_pool_name_app_crm" {}
variable "load_balancer_frontend_config_name_app_crm" {}
variable "load_balancer_probe_prefix_app_crm" {}
variable "load_balancer_rule_name_app_crm" {}

# ==== App ISU ============================================================= ##

variable "node_count_app_isu" {}
variable "hostname_suffix_start_range_app_isu" {}
variable "ip_start_range_app_isu" {}

# ==== DB ================================================================== ##

variable "vm_size_db" {}
variable "network_security_group_data" {}
variable "subnet_id_data" {}
variable "ip_range_data" {}
variable "data_disk_size_db" {}

# ==== DB ISU ============================================================== ##

variable "hostname_suffix_start_range_db_isu" {}
variable "ip_start_range_db_isu" {}
variable "data_disk_count_db_isu" {}

# ==== DB CRM ============================================================== ##

variable "hostname_suffix_start_range_db_crm" {}
variable "ip_start_range_db_crm" {}
variable "data_disk_count_db_crm" {}

# ==== ASCS ================================================================ ##

variable "node_count_ascs" {}
variable "vm_size_ascs" {} 
variable "hostname_suffix_start_range_ascs" {}
variable "ip_start_range_ascs" {}
variable "data_disk_size_ascs" {}

# ==== PI ================================================================== ##

variable "vm_size_pi" {}
variable "hostname_suffix_start_range_pi" {}
variable "ip_start_range_pi" {}
variable "data_disk_count_pi" {}
variable "data_disk_size_pi" {}