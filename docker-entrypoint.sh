#!/usr/bin/env bash

playbooks=( "all" "ascs" "app" "data" )

cd /working/ansible 

for playbook in "${playbooks[@]}"; do
    ansible-playbook "/working/ansible/configure-${playbook}.yaml" \
        --inventory-file "${inventory_file}" -vvv \
        -e "ansible_user='${HOST_USERNAME}'" \
        -e "ansible_password='${HOST_PASSWORD}'" \
        -e "storage_account_name='${INSTALL_FILES_STORAGE_ACCOUNT_NAME}'" \
        -e "storage_account_key='${INSTALL_FILES_STORAGE_ACCOUNT_KEY}'" \
        -e "file_share_uri='${INSTALL_FILES_FILE_SHARE_URI}'" \
        -e "dns_domain_name='${DNS_DOMAIN_NAME}'" \
        -e "domain_join_username='${DOMAIN_JOIN_USERNAME}'" \
        -e "domain_join_password='${DOMAIN_JOIN_PASSWORD}'" \
        -e "domain_ou_path='${DOMAIN_OU_PATH}'" \
        -e "domain_admin_group='${DOMAIN_ADMIN_GROUP}'" --check
done