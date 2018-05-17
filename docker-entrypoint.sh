#!/usr/bin/env bash

# Validate all Terraform variables have been set.
TF_REQUIRED_VARS=( \
    "${TF_VAR_subscription_id}" \
    "${TF_VAR_tenant_id}" \
    "${TF_VAR_client_id}" \
    "${TF_VAR_client_secret}" \
    "${TF_VAR_resource_group_name}" \
    "${ARM_ACCESS_SA}" \
    "${ARM_ACCESS_KEY}" \
)

for var in "${TF_REQUIRED_VARS[@]}"; do
    echo "${var}"
    if [ -z "${var}" ]; then
        echo "Error! One or more required variables are not set."
        echo "Exiting..."
        exit 1001
    fi
done

# Update backend file with relevant values. These valuses cannot be passed via environment variables. 
sed -i "s#STORAGE_ACCOUNT_NAME#${ARM_ACCESS_SA}#g" /working/terraform/backend.tf
sed -i "s#RESOURCE_GROUP_NAME#${TF_VAR_resource_group}#g" /working/terraform/backend.tf

cd /working/terraform &&
    terraform init && \
    terraform plan