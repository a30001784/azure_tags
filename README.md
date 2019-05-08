# AGL.AAA.SAP.Infra
This project contains the code used to deploy the infrastructure for the AGL SAP Performance Testing environment, and potentially others, in future.
## Usage
There is a deployment pipeline in VSTS with the same name as this repository.
* [Build](https://aglenergydev.visualstudio.com/AAA/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=71)
* [Release](https://aglenergydev.visualstudio.com/AAA/_releaseDefinition?definitionId=1&_a=environments-editor-preview)
## To do
* The file `scripts/Prepare-WS2008R2.ps1` is hosted on blob storage of the Terraform State storage account and is globally readable. It is required to be globally readable so the Azure VM extensions can access it during deployment. This should be reworked somehow, however, can be removed if the requirement for Windows Server 2008 R2 machines is descoped.
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