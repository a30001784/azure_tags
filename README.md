# AGL.AAA.SAP.Infra
This project contains the code used to deploy the infrastructure for the AGL SAP Performance Testing environment, and potentially others, in future.
## Usage
There is a deployment pipeline in VSTS with the same name as this repository.
* [Build](https://aglenergydev.visualstudio.com/AAA/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=71)
* [Release](https://aglenergydev.visualstudio.com/AAA/_releaseDefinition?definitionId=1&_a=environments-editor-preview)

It is worth noting that if the number of data disks for either DB server or PI server is increased (via environment variables passed to the deployment container), the managed disk will be created but it will not be attached to the VM. This is because Terraform does not support the `count` variable to configure data disks in the [azurerm_virtual_machine](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html) module. Therefore the following block must be added manually with the relevant parameters.
```
    storage_data_disk {
        name                          = "${azurerm_managed_disk.db-crm2.*.name[5]}"
        managed_disk_id               = "${azurerm_managed_disk.db-crm2.*.id[5]}"
        create_option                 = "Attach"
        lun                           = 6
        disk_size_gb                  = "${var.data_disk_size_db}"
        caching                       = "ReadOnly"
    }
```
This is annoying and broken. HashiCorp is aware of this issue which is tracked [here](https://github.com/hashicorp/terraform/issues/7034).
## To do
* The file `scripts/Prepare-WS2008R2.ps1` is hosted on blob storage of the Terraform State storage account and is globally readable. It is required to be globally readable so the Azure VM extensions can access it during deployment. This should be reworked somehow, however, can be removed if the requirement for Windows Server 2008 R2 machines is descoped.
* The templates `app-crm.tf` and `app-isu.tf` are nearly identical aside from the Availability Set configuration. If the AS can be created conditionally, the templates can be merged into one generic `app` template (e.g. `server_type == "crm" ? add to AS : don't add to AS`).
* Fix adding multiple data disks when the [issue](https://github.com/hashicorp/terraform/issues/7034) described above has been resolved.
## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
## History
* v.1.0 Infrastructure build
## Authors
* **Lukas Bartsch** - *Initial work* - [GitHub](https://github.com/a142619)
## License
TODO: Write license