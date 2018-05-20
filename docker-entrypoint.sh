#!/usr/bin/env bash

# Validate all Terraform variables have been set.
declare -A TF_VARS=( \
    ["TF_VAR_subscription_id"]="${TF_VAR_subscription_id}" \
    ["TF_VAR_tenant_id"]="${TF_VAR_tenant_id}" \
    ["TF_VAR_client_id"]="${TF_VAR_client_id}" \
    ["TF_VAR_client_secret"]="${TF_VAR_client_secret}" \
    ["TF_VAR_resource_group_name"]="${TF_VAR_resource_group_name}" \
    ["TF_VAR_location"]="${TF_VAR_location}" \
    ["TF_VAR_host_username"]="${TF_VAR_host_username}" \
    ["TF_VAR_host_password"]="${TF_VAR_host_password}" \
    ["TF_VAR_vm_size_app"]="${TF_VAR_vm_size_app}" \
    ["TF_VAR_network_security_group_app"]="${TF_VAR_network_security_group_app}" \
    ["TF_VAR_subnet_id_app"]="${TF_VAR_subnet_id_app}" \
    ["TF_VAR_ip_range_app"]="${TF_VAR_ip_range_app}" \
    ["TF_VAR_availability_set_name"]="${TF_VAR_availability_set_name}" \
    ["TF_VAR_node_count_app_crm"]="${TF_VAR_node_count_app_crm}" \
    ["TF_VAR_hostname_prefix"]="${TF_VAR_hostname_prefix}" \
    ["TF_VAR_hostname_suffix_start_range_app_crm"]="${TF_VAR_hostname_suffix_start_range_app_crm}" \
    ["TF_VAR_ip_start_range_app_crm"]="${TF_VAR_ip_start_range_app_crm}" \
    ["TF_VAR_node_count_app_isu"]="${TF_VAR_node_count_app_isu}" \
    ["TF_VAR_hostname_suffix_start_range_app_isu"]="${TF_VAR_hostname_suffix_start_range_app_isu}" \
    ["TF_VAR_ip_start_range_app_isu"]="${TF_VAR_ip_start_range_app_isu}" \
    ["TF_VAR_vm_size_db"]="${TF_VAR_vm_size_db}" \
    ["TF_VAR_network_security_group_data"]="${TF_VAR_network_security_group_data}" \
    ["TF_VAR_subnet_id_data"]="${TF_VAR_subnet_id_data}" \
    ["TF_VAR_ip_range_data"]="${TF_VAR_ip_range_data}" \
    ["TF_VAR_data_disk_size_db"]="${TF_VAR_data_disk_size_db}" \
    ["TF_VAR_hostname_suffix_start_range_db_isu"]="${TF_VAR_hostname_suffix_start_range_db_isu}" \
    ["TF_VAR_ip_start_range_db_isu"]="${TF_VAR_ip_start_range_db_isu}" \
    ["TF_VAR_data_disk_count_db_isu"]="${TF_VAR_data_disk_count_db_isu}" \
    ["TF_VAR_hostname_suffix_start_range_db_crm"]="${TF_VAR_hostname_suffix_start_range_db_crm}" \
    ["TF_VAR_ip_start_range_db_crm"]="${TF_VAR_ip_start_range_db_crm}" \
    ["TF_VAR_data_disk_count_db_crm"]="${TF_VAR_data_disk_count_db_crm}" \
    ["TF_VAR_node_count_ascs"]="${TF_VAR_node_count_ascs}" \
    ["TF_VAR_vm_size_ascs"]="${TF_VAR_vm_size_ascs}" \
    ["TF_VAR_hostname_suffix_start_range_ascs"]="${TF_VAR_hostname_suffix_start_range_ascs}" \
    ["TF_VAR_ip_start_range_ascs"]="${TF_VAR_ip_start_range_ascs}" \
    ["TF_VAR_data_disk_size_ascs"]="${TF_VAR_data_disk_size_ascs}" \
    ["TF_VAR_vm_size_pi"]="${TF_VAR_vm_size_pi}" \
    ["TF_VAR_hostname_suffix_start_range_pi"]="${TF_VAR_hostname_suffix_start_range_pi}" \
    ["TF_VAR_ip_start_range_pi"]="${TF_VAR_ip_start_range_pi}" \
    ["TF_VAR_data_disk_count_pi"]="${TF_VAR_data_disk_count_pi}" \
    ["TF_VAR_data_disk_size_pi"]="${TF_VAR_data_disk_size_pi}" \
    ["ARM_ACCESS_SA"]="${ARM_ACCESS_SA}" \
    ["ARM_ACCESS_KEY"]="${ARM_ACCESS_KEY}" \
)

for var in "${!TF_VARS[@]}"; do
    if [[ -z "${TF_VARS[$var]}" ]]; then
        echo "[ERROR] Environment variable not set: ${var}"
        echo "Exiting..."
        exit 1001
    else
        echo "[INFO] Environment variable set: ${var}"
    fi
done

# Update backend file with relevant values. These values cannot be passed via environment variables. 
sed -i "s#STORAGE_ACCOUNT_NAME#${TF_VARS['ARM_ACCESS_SA']}#g" /working/terraform/backend.tf
sed -i "s#RESOURCE_GROUP_NAME#${TF_VARS['TF_VAR_resource_group_name']}#g" /working/terraform/backend.tf

cd /working/terraform && \
    terraform init && \
    terraform plan && \
    terraform apply

if [ $? -ne "0" ]; then
    echo "[ERROR] Fatal error encountered in Terraform run"
    echo "Exiting..."
    exit 1002
fi

# The Windows 2008 servers may not yet be ready for Ansible. So we wait. 
echo "[INFO] Sleeping for 5 minutes..."
sleep 300

roles=( "app" "ascs" "data" "pi" )

for role in "${roles[@]}"; do
    inventory_file="/tmp/inventory_${role}"
    playbook_name="configure-${role}"

    for ip in $(cd /working/terraform; terraform output ip_addresses_${role} | tr -d " " | tr "," "\n"); do
        echo $ip >> $inventory_file
    done

    cd /working/ansible && \
        ansible-playbook "${playbook_name}.yaml" \
            --inventory-file "${inventory_file}" \
            --extra-vars "ansible_password=${TF_VAR_host_password}" \
            --extra-vars "dns_domain_name=${TF_VAR_dns_domain_name}" \
            --extra-vars "domain_join_username=${TF_VAR_domain_join_username}" \
            --extra-vars "domain_join_password=${TF_VAR_domain_join_password}" \
            --extra-vars "domain_ou_path=${TF_VAR_domain_ou_path}" -vvv

    if [ $? -ne "0" ]; then
        echo "[ERROR] Fatal error encountered in Ansible playbook: ${playbook_name}"
        echo "Exiting..."
        exit 1003
    fi
done