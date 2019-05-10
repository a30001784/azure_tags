#!/usr/bin/env bash

set -e

# Get Terraform storage account key
echo "*** Authenticating to Azure with Service Principal: ${CLIENT_ID} ***"
az login --service-principal -u "${CLIENT_ID}" --password "${CLIENT_SECRET}" --tenant "${TENANT_ID}"

echo "*** Retrieving storage account key ***"
TF_STATE_STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --account-name "${TF_STATE_STORAGE_ACCOUNT_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --query "[?keyName=='key1'].value" \
    --output tsv)

### Terraform variables ###
export TF_VAR_client_id="${CLIENT_ID}"
export TF_VAR_client_secret="${CLIENT_SECRET}"
export TF_VAR_data_disk_count_crm_ascs="${DATA_DISK_COUNT_CRM_ASCS}"
export TF_VAR_data_disk_count_crm_db="${DATA_DISK_COUNT_CRM_DB}"
export TF_VAR_data_disk_count_isu_ascs="${DATA_DISK_COUNT_ISU_ASCS}"
export TF_VAR_data_disk_count_isu_db="${DATA_DISK_COUNT_ISU_DB}"
export TF_VAR_data_disk_size_crm_ascs="${DATA_DISK_SIZE_CRM_ASCS}"
export TF_VAR_data_disk_size_crm_db="${DATA_DISK_SIZE_CRM_DB}"
export TF_VAR_data_disk_size_isu_ascs="${DATA_DISK_SIZE_ISU_ASCS}"
export TF_VAR_data_disk_count_isu_db="${DATA_DISK_COUNT_ISU_DB}"
export TF_VAR_host_password="${HOST_PASSWORD}"
export TF_VAR_hostname_prefix="${HOSTNAME_PREFIX}"
export TF_VAR_hostname_suffix_start_range="${HOSTNAME_SUFFIX_START_RANGE}"
export TF_VAR_location="${LOCATION}"
export TF_VAR_network_security_group_app="${NETWORK_SECURITY_GROUP_APP}"
export TF_VAR_network_security_group_data="${NETWORK_SECURITY_GROUP_DATA}"
export TF_VAR_node_count_crm_app="${NODE_COUNT_CRM_APP}"
export TF_VAR_node_count_crm_ascs="${NODE_COUNT_CRM_ASCS}"
export TF_VAR_node_count_crm_db="${NODE_COUNT_CRM_DB}"
export TF_VAR_node_count_isu_app="${NODE_COUNT_ISU_APP}"
export TF_VAR_node_count_isu_ascs="${NODE_COUNT_ISU_ASCS}"
export TF_VAR_node_count_isu_db="${NODE_COUNT_ISU_DB}"
export TF_VAR_resource_group_name="${RESOURCE_GROUP_NAME}"
export TF_VAR_subnet_id_app="${SUBNET_ID_APP}"
export TF_VAR_subnet_id_data="${SUBNET_ID_DATA}"
export TF_VAR_subscription_id="${SUBSCRIPTION_ID}"
export TF_VAR_tenant_id="${TENANT_ID}"
export TF_VAR_vm_size_crm_app="${VM_SIZE_CRM_APP}"
export TF_VAR_vm_size_crm_ascs="${VM_SIZE_CRM_ASCS}"
export TF_VAR_vm_size_crm_db="${VM_SIZE_CRM_DB}"
export TF_VAR_vm_size_isu_app="${VM_SIZE_ISU_APP}"
export TF_VAR_vm_size_isu_ascs="${VM_SIZE_ISU_ASCS}"
export TF_VAR_vm_size_isu_db="${VM_SIZE_ISU_DB}"
### End Terraform variables ###

echo "*** Initialising Terraform ***"
terraform init \
    -backend-config="access_key=${TF_STATE_STORAGE_ACCOUNT_KEY}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}" \
    -backend-config="resource_group_name=${RESOURCE_GROUP_NAME}"

echo "*** Running terraform command ***"
if [ "$1" == "plan" ]; then
    terraform plan -input=false
elif [ "$1" == "apply" ]; then
    terraform apply -input=false -auto-approve
fi

exit $?