// ARM_ACCESS_KEY must be set (storage account key)
// terraform {
//   backend "azurerm" {
//     storage_account_name = "STORAGE_ACCOUNT_NAME"
//     resource_group_name  = "RESOURCE_GROUP_NAME"
//     container_name       = "terraform-state"
//     key                  = "terraform.tfstate"
//   }
// }