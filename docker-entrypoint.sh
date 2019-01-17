#!/usr/bin/env bash

set -e

## Global variables ##
terraform_dir="/working/terraform" # Terraform directory.
ansible_dir="/working/ansible" # Ansble directory.
extra_vars="" # Extra variables for Ansible playbook runs.
roles=( "data" "ascs" "app" )
sub_roles=( "crm" "isu" ) #"nwgw" "swd" "pi" "xi" )
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

cd "${terraform_dir}"

terraform init \
    -backend-config="access_key=${TF_VARS['ARM_ACCESS_KEY']}" \
    -backend-config="storage_account_name=${TF_VARS['ARM_ACCESS_SA']}" \
    -backend-config="resource_group_name=${TF_VARS['TF_VAR_resource_group_name']}"

terraform plan

terraform apply --auto-approve

if [ $? -ne "0" ]; then
    echo "[ERROR] Fatal error encountered in Terraform run"
    echo "Exiting..."
    exit 1002
fi

# The Windows 2008 servers may not yet be ready for Ansible. So we wait.
echo "[INFO] Sleeping for 5 minutes..."
sleep 300
echo "[INFO] Finished sleeping."
echo "[INFO] Beginning Ansible section..."

# Validate all Ansible variables have been set.
declare -A ANSIBLE_VARS=( \
    ["ansible_user"]="${TF_VAR_host_username}" \
    ["ansible_password"]="${TF_VAR_host_password}" \
    ["datacentre"]="${datacentre}" \
    ["dns_domain_name"]="${dns_domain_name}" \
    ["domain_name"]="${domain_name}" \
    ["domain_admin_group"]="${domain_admin_group}" \
    ["domain_join_username"]="${domain_join_username}" \
    ["domain_join_password"]="${domain_join_password}" \
    ["domain_ou_path"]="${domain_ou_path}" \
    ["environment_instance_count"]="${environment_instance_count}" \
    ["file_share_uri"]="${install_files_file_share_uri}" \
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
    ["pas_ddic_password"]="${pas_ddic_password}" \
    ["sap_install_username"]="${sap_install_username}" \
    ["sap_install_password"]="${sap_install_password}" \
    ["sap_master_password_base"]="${sap_master_password_base}" \
    ["storage_account_name"]="${install_files_storage_account_name}" \
    ["storage_account_key"]="${install_files_storage_account_key}" \
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
        count=0

        for ip in $(terraform output "ip_addresses_${role}-${sub_role}" | tr "," "\n"); do
            vars=""
            case "${role}" in
                data)
                    npd="num_pooled_disks_data_${sub_role}"
                    bkp="has_backup_disk_${sub_role}"
                    vars="num_pooled_disks=${!npd} has_backup_disk=${!bkp}"
                    ;;
                app)
                    if [[ $count -eq 0 ]]; then
                        vars="pas=true"
                    else
                        vars="pas=false"
                    fi
                    ;;
                *)
                    echo "Nothing to do for role: ${role}"
            esac

            echo "${ip} ${vars}" >> "${inventory_file}"
            count=$((count+1))
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

    playbooks+=( "configure-${role}" )
done

## This section writes the `group_vars` and `sub role children` to the inventory file.
## For example:

## [crm:children]
## app-crm
## data-crm
## ascs-crm

## [crm:vars]
## ascs_host=10.230.97.45
## db_host=10.230.97.137
## instance_type=C

## [isu:children]
## app-isu
## data-isu
## ascs-isu

## [isu:vars]
## ascs_host=10.230.97.30
## db_host=10.230.97.136
## instance_type=I

for sr in ${sub_roles[@]}; do
    echo "[${sr}:children]" >> "${inventory_file}"

    for r in ${roles[@]}; do
        echo "${r}-${sr}" >> "${inventory_file}"
    done

    echo >> "${inventory_file}"

    echo "[${sr}:vars]" >> "${inventory_file}"
    echo "ascs_host=$(terraform output ip_addresses_ascs-${sr})" >> "${inventory_file}"
    echo "db_host=$(terraform output ip_addresses_data-${sr})" >> "${inventory_file}"
    # Get first character of sub role - e.g. crm = C
    echo "instance_type=$(echo ${sr} | head -c1 | awk '{print toupper($0)}')" >> "${inventory_file}"
    echo >> "${inventory_file}"
done

echo "[INFO] Beginning Ansible playbooks..."

cat "${inventory_file}"

cd "${ansible_dir}"
for playbook in "${playbooks[@]}"; do
    ansible-playbook "${playbook}.yaml" \
        --inventory-file "${inventory_file}" \
        --extra-vars "${extra_vars}" -vvv
done