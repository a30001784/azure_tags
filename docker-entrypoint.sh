#!/usr/bin/env bash

set -e

## Global variables ##
terraform_dir="/working/terraform" # Terraform directory.
ansible_dir="/working/ansible" # Ansble directory.
extra_vars="" # Extra variables for Ansible playbook runs.
roles=( "app" "data" "ascs" )
sub_roles=( "crm" "isu" "nwgw" "pi" "xi" )
playbooks=( "configure-all" )
inventory_file="/tmp/inventory_master"

echo "[INFO] Beginning Terraform section..."

# Validate all Terraform variables have been set.
declare -A TF_VARS=( \
    ["ARM_ACCESS_KEY"]="${ARM_ACCESS_KEY}" \
    ["ARM_ACCESS_SA"]="${ARM_ACCESS_SA}" \
    ["TF_VAR_availability_set_name_app_crm"]="${TF_VAR_availability_set_name_app_crm}" \
    ["TF_VAR_availability_set_name_app_isu"]="${TF_VAR_availability_set_name_app_isu}" \
    ["TF_VAR_availability_set_name_app_nwgw"]="${TF_VAR_availability_set_name_app_nwgw}" \
    ["TF_VAR_availability_set_name_ascs_pi"]="${TF_VAR_availability_set_name_ascs_pi}" \
    ["TF_VAR_client_id"]="${TF_VAR_client_id}" \
    ["TF_VAR_client_secret"]="${TF_VAR_client_secret}" \
    ["TF_VAR_data_disk_count_db_crm"]="${TF_VAR_data_disk_count_db_crm}" \
    ["TF_VAR_data_disk_count_db_isu"]="${TF_VAR_data_disk_count_db_isu}" \
    ["TF_VAR_data_disk_count_db_nwgw"]="${TF_VAR_data_disk_count_db_nwgw}" \
    ["TF_VAR_data_disk_count_db_pi"]="${TF_VAR_data_disk_count_db_pi}" \
    ["TF_VAR_data_disk_count_db_xi"]="${TF_VAR_data_disk_count_db_xi}" \
    ["TF_VAR_data_disk_size_ascs"]="${TF_VAR_data_disk_size_ascs}" \
    ["TF_VAR_data_disk_size_ascs_pi"]="${TF_VAR_data_disk_size_ascs_pi}" \
    ["TF_VAR_data_disk_size_ascs_xi"]="${TF_VAR_data_disk_size_ascs_xi}" \
    ["TF_VAR_data_disk_size_db"]="${TF_VAR_data_disk_size_db}" \
    ["TF_VAR_host_password"]="${TF_VAR_host_password}" \
    ["TF_VAR_host_username"]="${TF_VAR_host_username}" \
    ["TF_VAR_hostname_prefix"]="${TF_VAR_hostname_prefix}" \
    ["TF_VAR_hostname_suffix_start_range_app_crm"]="${TF_VAR_hostname_suffix_start_range_app_crm}" \
    ["TF_VAR_hostname_suffix_start_range_app_isu"]="${TF_VAR_hostname_suffix_start_range_app_isu}" \
    ["TF_VAR_hostname_suffix_start_range_app_nwgw"]="${TF_VAR_hostname_suffix_start_range_app_nwgw}" \
    ["TF_VAR_hostname_suffix_start_range_app_swd"]="${TF_VAR_hostname_suffix_start_range_app_swd}" \
    ["TF_VAR_hostname_suffix_start_range_app_xi"]="${TF_VAR_hostname_suffix_start_range_app_xi}" \
    ["TF_VAR_hostname_suffix_start_range_ascs"]="${TF_VAR_hostname_suffix_start_range_ascs}" \
    ["TF_VAR_hostname_suffix_start_range_ascs_pi"]="${TF_VAR_hostname_suffix_start_range_ascs_pi}" \
    ["TF_VAR_hostname_suffix_start_range_ascs_xi"]="${TF_VAR_hostname_suffix_start_range_ascs_xi}" \
    ["TF_VAR_hostname_suffix_start_range_db_crm"]="${TF_VAR_hostname_suffix_start_range_db_crm}" \
    ["TF_VAR_hostname_suffix_start_range_db_isu"]="${TF_VAR_hostname_suffix_start_range_db_isu}" \
    ["TF_VAR_hostname_suffix_start_range_db_nwgw"]="${TF_VAR_hostname_suffix_start_range_db_nwgw}" \
    ["TF_VAR_hostname_suffix_start_range_db_pi"]="${TF_VAR_hostname_suffix_start_range_db_pi}" \
    ["TF_VAR_hostname_suffix_start_range_db_xi"]="${TF_VAR_hostname_suffix_start_range_db_xi}" \
    ["TF_VAR_location"]="${TF_VAR_location}" \
    ["TF_VAR_network_security_group_app"]="${TF_VAR_network_security_group_app}" \
    ["TF_VAR_network_security_group_data"]="${TF_VAR_network_security_group_data}" \
    ["TF_VAR_node_count_app_crm"]="${TF_VAR_node_count_app_crm}" \
    ["TF_VAR_node_count_app_isu"]="${TF_VAR_node_count_app_isu}" \
    ["TF_VAR_node_count_app_nwgw"]="${TF_VAR_node_count_app_nwgw}" \
    ["TF_VAR_node_count_app_swd"]="${TF_VAR_node_count_app_swd}" \
    ["TF_VAR_node_count_app_xi"]="${TF_VAR_node_count_app_xi}" \
    ["TF_VAR_node_count_ascs"]="${TF_VAR_node_count_ascs}" \
    ["TF_VAR_node_count_ascs_pi"]="${TF_VAR_node_count_ascs_pi}" \
    ["TF_VAR_node_count_ascs_xi"]="${TF_VAR_node_count_ascs_xi}" \
    ["TF_VAR_node_count_db_crm"]="${TF_VAR_node_count_db_crm}" \
    ["TF_VAR_node_count_db_isu"]="${TF_VAR_node_count_db_isu}" \
    ["TF_VAR_node_count_db_nwgw"]="${TF_VAR_node_count_db_nwgw}" \
    ["TF_VAR_node_count_db_pi"]="${TF_VAR_node_count_db_pi}" \
    ["TF_VAR_node_count_db_xi"]="${TF_VAR_node_count_db_xi}" \
    ["TF_VAR_resource_group_name"]="${TF_VAR_resource_group_name}" \
    ["TF_VAR_subnet_id_app"]="${TF_VAR_subnet_id_app}" \
    ["TF_VAR_subnet_id_data"]="${TF_VAR_subnet_id_data}" \
    ["TF_VAR_subscription_id"]="${TF_VAR_subscription_id}" \
    ["TF_VAR_tag_business_owner"]="${TF_VAR_tag_business_owner}" \
    ["TF_VAR_tag_cost_code"]="${TF_VAR_tag_cost_code}" \
    ["TF_VAR_tag_technical_owner"]="${TF_VAR_tag_technical_owner}" \
    ["TF_VAR_tenant_id"]="${TF_VAR_tenant_id}" \
    ["TF_VAR_vm_size_app"]="${TF_VAR_vm_size_app}" \
    ["TF_VAR_vm_size_app_nwgw"]="${TF_VAR_vm_size_app_nwgw}" \
    ["TF_VAR_vm_size_app_swd"]="${TF_VAR_vm_size_app_swd}" \
    ["TF_VAR_vm_size_app_xi"]="${TF_VAR_vm_size_app_xi}" \
    ["TF_VAR_vm_size_ascs"]="${TF_VAR_vm_size_ascs}" \
    ["TF_VAR_vm_size_ascs_pi"]="${TF_VAR_vm_size_ascs_pi}" \
    ["TF_VAR_vm_size_ascs_xi"]="${TF_VAR_vm_size_ascs_xi}" \
    ["TF_VAR_vm_size_db"]="${TF_VAR_vm_size_db}" \
    ["TF_VAR_vm_size_db_nwgw"]="${TF_VAR_vm_size_db_nwgw}" \
    ["TF_VAR_vm_size_db_pi"]="${TF_VAR_vm_size_db_pi}" \
    ["TF_VAR_vm_size_db_xi"]="${TF_VAR_vm_size_db_xi}" \
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
sed -i "s#STORAGE_ACCOUNT_NAME#${TF_VARS['ARM_ACCESS_SA']}#g" "${terraform_dir}/backend.tf"
sed -i "s#RESOURCE_GROUP_NAME#${TF_VARS['TF_VAR_resource_group_name']}#g" "${terraform_dir}/backend.tf"

cd "${terraform_dir}" && \
    terraform init && \
    terraform plan && \
    terraform apply --auto-approve

if [ $? -ne "0" ]; then
    echo "[ERROR] Fatal error encountered in Terraform run"
    echo "Exiting..."
    exit 1002
fi

# The Windows 2008 servers may not yet be ready for Ansible. So we wait.
echo "[INFO] Sleeping for 5 minutes..."
#sleep 300
echo "[INFO] Finished sleeping."
echo "[INFO] Beginning Ansible section..."

# Validate all Ansible variables have been set.
declare -A ANSIBLE_VARS=( \
    ["ansible_user"]="${TF_VAR_host_username}" \
    ["ansible_password"]="${TF_VAR_host_password}" \
    ["dns_domain_name"]="${dns_domain_name}" \
    ["domain_admin_group"]="${domain_admin_group}" \
    ["domain_join_username"]="${domain_join_username}" \
    ["domain_join_password"]="${domain_join_password}" \
    ["domain_ou_path"]="${domain_ou_path}" \
    ["has_backup_disk_crm"]="${has_backup_disk_crm}" \
    ["has_backup_disk_isu"]="${has_backup_disk_isu}" \
    ["has_backup_disk_nwgw"]="${has_backup_disk_nwgw}" \
    ["has_backup_disk_pi"]="${has_backup_disk_pi}" \
    ["has_backup_disk_xi"]="${has_backup_disk_xi}" \
    ["num_pooled_disks_data_crm"]="${num_pooled_disks_data_crm}" \
    ["num_pooled_disks_data_isu"]="${num_pooled_disks_data_isu}" \
    ["num_pooled_disks_data_nwgw"]="${num_pooled_disks_data_nwgw}" \
    ["num_pooled_disks_data_pi"]="${num_pooled_disks_data_pi}" \
    ["num_pooled_disks_data_xi"]="${num_pooled_disks_data_xi}" \
)

echo "[INFO] Checking Ansible variables..."

# Check if all required Ansible variables are set.
for var in "${!ANSIBLE_VARS[@]}"; do
    if [[ -z "${ANSIBLE_VARS[$var]}" ]]; then
        echo "[ERROR] Environment variable not set: ${var}"
        echo "Exiting..."
        exit 1003
    else
        echo "[INFO] Environment variable set: ${var}"

        # When variable is set, append to extra vars.
        extra_vars="${extra_vars} ${var}='${ANSIBLE_VARS[$var]}'"
    fi
done

echo "[INFO] Generating Ansible inventory file..."

## Construct inventory file
for role in "${roles[@]}"; do
    children=()

    for sub_role in "${sub_roles[@]}"; do
        echo "[${role}-${sub_role}]" >> "${inventory_file}"
        children+=( "${role}-${sub_role}" )

        for ip in $(terraform output "ip_addresses_${role}-${sub_role}" | tr "," "\n"); do
            vars=""
            if [[ "${role}" = "data" ]]; then
                npd="num_pooled_disks_data_${sub_role}"
                bkp="has_backup_disk_${sub_role}"
                vars="num_pooled_disks=${!npd} has_backup_disk=${!bkp} install_odbc_driver=false"
            else
                vars="install_odbc_driver=true"
            fi

            echo "${ip} ${vars}" >> "${inventory_file}"
        done

        echo >> "${inventory_file}"
    done

    # Parent role
    echo "[${role}:children]" >> "${inventory_file}"

    # Children
    for child in "${children[@]}"; do
        echo "${child}" >> "${inventory_file}"
    done

    echo >> "${inventory_file}"

    if [[ "${role}" != "app" ]]; then
        playbooks+=( "configure-${role}" )
    fi
done

echo "[INFO] Beginning Ansible playbooks..."

cat "${inventory_file}"

cd "${ansible_dir}"
for playbook in "${playbooks[@]}"; do
    ansible-playbook "${playbook}.yaml" \
        --inventory-file "${inventory_file}" \
        --extra-vars "${extra_vars}" -vvv
done