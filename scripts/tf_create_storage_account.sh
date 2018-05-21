#!/usr/bin/env bash

# Arguments check.
if [ $# -ne 4 ]; then
    # Log to stderr.
    (>&2 echo "[ERROR] Invalid arguments!")
    
    echo "[INFO] Usage: $(basename $0) <account_name> <resource_group> <location> <sku>"
    echo "Exiting..."
    exit 1
fi

account_name=$1
resource_group=$2
location=$3
sku=$4

storage_account_name=$(az storage account show --name "${1}" --resource-group ${2})

if [ -z "${storage_account_name}" ]; then
    az storage account create \
        --name "${account_name}" \
        --resource-group "${resource_group}" \
        --location "${location}" \
        --sku "${sku}"
else
    echo "[INFO] Storage account already exists..."
fi