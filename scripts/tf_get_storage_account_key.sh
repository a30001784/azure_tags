#!/usr/bin/env bash

# Arguments check.
if [ $# -ne 2 ]; then
    # Log to stderr.
    (>&2 echo "[ERROR] Invalid arguments!")
    
    echo "[INFO] Usage: $(basename $0) <account_name> <resource_group> <location> <sku>"
    echo "Exiting..."
    exit 1
fi

storage_account_name=$1
resource_group=$2

# Retrieve storage account key.
storage_account_key=$(az storage account keys list \
    --account-name "${storage_account_name}" \
    --resource-group "${resource_group}" \
    --query "[?keyName=='key1'].value" \
    --output tsv)

# Store key in variable for VSTS to use in future tasks.
echo "##vso[task.setvariable variable=tf_state_storage_account_key;issecret=true]${storage_account_key}"