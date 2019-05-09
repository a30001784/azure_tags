cd ../terraform 

echo "***Initialising Terraform***"
terraform init \
    -backend-config="access_key=${ARM_ACCESS_KEY}" \
    -backend-config="storage_account_name=${ARM_ACCESS_SA}" \
    -backend-config="resource_group_name=${RESOURCE_GROUP}"

echo "***Running terraform command***"
if [ "$1" == "plan" ]; then
    terraform plan
elif [ "$1" == "apply" ]; then
    terraform apply -auto-approve
fi

exit $?