# High-level overview

The SAP automation release pipeline consists of a number of distinct components, which are represented by Agent Phases in Azure Devops.

The most recent and up-to-date environment, is named `Refactor`. This is the configuration that any future environments should be cloned from.

The components are as follows:
### Infrastructure prep (Azure PowerShell)
    1. Create RG
    2. Create TF state storage account
    3. Create TF state storage account container
### Infrastructure deployment (Terraform, bash, python)
    1. Terraform plan
    2. Manual intervention step (approve/reject Terraform Plan)
    3. Terraform apply
    4. Generate Ansible Inventory file
    5. Print Ansible inventory file
### Operating System and Application configuration (Ansible, PowerShell)
    1. Run playbook - Common
    2. Run playbook - ASCS
    3. Run playbook - Data
    4. Run playbook - Application install
    5. Run playbook - BDLS
    6. Output Logical System Names - CRM
    7. Output Logical System Names - ISU
    8. Run playbook - CRM Java**
### Post-Configuration (Docker, python)**
There shoud be a number of tasks here which map to the post-configuration steps as defined in the Confluence document. 

** Not yet orechestrated in the release pipeline

# Detailed description of tasks

## Infrastructure prep

### Create RG
Creates the resource group in which the resources will be created.
### Create TF state storage account
Creates the storage account that is used to store the Terraform state file.
### Create TF state storage account container
Creats the storage account container that is used to store the Terraform state file.

## Infrastructure deployment

### Terraform plan
Invokes the bash script `scripts/tf_deploy.sh` with the following arguments: 
    `plan`

This script performs the following actions:
1. Login to AzureRM with specified service principal.
2. Retrieve the Terraform state storage account key.
3. Export a number of required environment variables so they are available for use in Terraform.
4. Initialise Terraform and the backend.
5. Run Terraform plan.
6. Exit with the error code result of the TF plan.

Whenever the Terraform code is updated, this file must be updated with any new variables.

### Manual intervention
Allows a DevOps Engineer to review the output of the Terraform plan before committing the changes. Useful if you don't want to blow up the world.

### Terraform apply
Invokes the bash script `scripts/tf_deploy.sh` with the following arguments: 
    `apply`

This script performs the following actions:
1. Login to AzureRM with specified service principal.
2. Retrieve the Terraform state storage account key.
3. Export a number of required environment variables so they are available for use in Terraform.
4. Initialise Terraform and the backend.
5. Run Terraform apply.
6. Provision the required resources in Azure.
7. Exit with the error code result of the TF apply.

### Generate Ansible inventory file
Runs a Python script `scripts/generate_ansible_inventory.py` to generate an inventory file which is passed to the Ansible playbooks.

The script organises the hosts into roles (crm, isu, etc.) and sub-roles (app, ascs, data), so that Ansible can filter against certain hosts. 
It also specifies a number of group and host specific variables, so that Ansible playbooks can be written in a modular fashion, removing the need for writing
boilerplate code. 

To get the required hostnames, IPs and variables, it calls `terraform output` against a number of the TF resources to determine what to put where. There are also 
some environment variables it depends on:

| Variable | Description |
| ------------- | ------------- |
| `NUM_POOLED_DISKS_DATA_CRM` | Number of data disks that will be used to create a storage pool on the CRM DB server |
| `NUM_POOLED_DISKS_DATA_ISU` | Number of data disks that will be used to create a storage pool on the ISU DB server |
| `HAS_BACKUP_DISK_CRM` | True/false whether the CRM DB server has a disk dedicated to backups |
| `HAS_BACKUP_DISK_ISU` | True/false whether the ISU DB server has a disk dedicated to backups |

The script also has a number of arguments that can be passed in, such as:

| Variable | Description |
| ------------- | ------------- |
| `--roles` | Modules that are being built as part of this deployment (crm isu) |
| `--sub-roles` | Server classes (app ascs data) |
| `--inv-dir` | Directory to save the outputted Ansible inventory file (ansible) |
| `--tf-path` | Relative path to the Terraform folder from which to runn `terraform output` (terraform) |

### Print inventory file
Runs a bash script to output the result of the Ansible inventory file so it can be viewed from the Azure Devops logs. 

## Operating System and Application configuration

### Run playbook - Common
This playbook targets all the hosts in the deployment, and performs operating system configuration tasks required by the SAP installer, such as, but not limited to:

* Set timezone
* Disable firewall
* Create working directories
* Disable IE Security Enhanced Condfiguration
* Download and install preqrequisite software
* Install roles and features
* Join to the Active Direvtory domain
* Add groups to local admin
* Grants privileges to install user

This is all documented and commented in the Ansible code. 

#### Required variables
| Argument  | Description |
| ------------- | ------------- |
| `ansible_user` | Username of user running Ansible playbook |
| `ansible_password` | Password of user running Ansible playbook |
| `storage_account_name` | Storage account name for where the SAP software files are stored | 
| `storage_account_key` | Storage account key for the storage account where the SAP software files are stored |
| `file_share_uri` | File share location for SAP software files |
| `dns_domain_name` | FQDN of AGL internal domain e.g. `agl.int` |
| `domain_join_username` | Username of user to join domain with |
| `domain_join_password` | Password of user to join domain with |
| `domain_ou_path` | Full DN to Active Directory OU where computer objects will be created |
| `domain_admin_group` | Group which is added to local admin on every server e.g. `Func-DG-SAPInstallers` |

Example of how to run this playbook, taken from the task in Azure Devops.

```bash
ansible-playbook ansible/common.yaml -i ansible/inventory.txt \
    -e  'ansible_user="$(host_username)"' \
    -e  'ansible_password="$(hostPassword)"' \
    -e  'storage_account_name="$(install_files_storage_account_name)"' \
    -e  'storage_account_key="$(installFilesStorageAccountKey)"' \
    -e  'file_share_uri="$(install_files_file_share_uri)"' \
    -e  'dns_domain_name="$(dns_domain_name)"' \
    -e  'domain_join_username="$(domain_join_username)"' \
    -e  'domain_join_password="$(domainJoinPassword)"' \
    -e  'domain_ou_path="$(domain_ou_path)"' \
    -e  'domain_admin_group="$(domain_admin_group)"' -vvv
```

### Run playbook - ASCS
This playbook targets only the ASCS servers in the deployment, and formats the disks on these server.s This task should probably be refactored into the common role, 
with a filter on the ASCS servers.

#### Required variables
| Argument  | Description |
| ------------- | ------------- |
| `ansible_user` | Username of user running Ansible playbook |
| `ansible_password` | Password of user running Ansible playbook |

Example of how to run this playbook, taken from the task in Azure Devops.

```bash
ansible-playbook ansible/ascs.yaml -i ansible/inventory.txt \
    -e  'ansible_user="$(host_username)"' \
    -e  'ansible_password="$(hostPassword)"' -vvv
```

### Run playbook - Data
This playbook targets the database servers. This is where things get interesting/complex.

Because the database restore process is manual, this role is split into two sections:
* `restore-pre`
* `restore-post`

It should be self-explanatory why these tasks are named as they are.

In `restore-pre.yaml`, the following actions are performed:
* Create Storage Pools for the main data and backup disks
* Download SAP software files
* Install SQL server
* Configure directories for database `.mdf` and `.ldf` files
* Configure SQL server services (users, schedules)
* Grant privileges to SQL server service account

After the `restore-pre` task completed, the SQL server should be successfully installed. 

Now an engineer must restore the database from a production copy, manually, or create a process which does this automatically. 

Ruschal can provide the details and scripts to complete this. 

After the database has been successfully installed on all the database servers in the deployment, it is time for the SQL server post configuration to be run. 

There are Azure Devops variables which must be updated now:
* `db_restored_crm` false -> true
* `db_restored_isu` false -> true

This provides a way for the pipeline to be re-run, without invoking the SQL server *pre* installation steps again.

In `restore-post.yaml`, the following actions are performed:
* Transfer SQL script files to the DB servers
* Change logical file names in SQL server to represent new SID
* Change OS file names
* Move and create additional files for TempDB
* Set recovery model and other SQL server configuration settings
* Update SQL server memory utilisation settings

#### Required variables
| Argument  | Description |
| ------------- | ------------- |
| `ansible_user` | Username of user running Ansible playbook |
| `ansible_password` | Password of user running Ansible playbook |
| `storage_account_name` | Storage account name for where the SAP software files are stored | 
| `storage_account_key` | Storage account key for the storage account where the SAP software files are stored |
| `file_share_uri` | File share location for SAP software files |
| `dns_domain_name` | FQDN of AGL internal domain e.g. `agl.int` |
| `domain_join_username` | Username of user to join domain with |
| `domain_join_password` | Password of user to join domain with |
| `domain_ou_path` | Full DN to Active Directory OU where computer objects will be created |
| `domain_admin_group` | Group which is added to local admin on every server e.g. `Func-DG-SAPInstallers` |
| `datacentre` | Datacentre ID used to construct SID e.g. A = Azure |
| `environment_instance_count` | Number used to construct SID. Should be incremented every time a new environment is created |
| `sap_install_username` | Username of user to run SQL server installer. Must be a domain user and be a part of the `domain_admin_group` |
| `sap_install_password` | Password of user to run SQL server installer |
| `db_restored_crm` | True/false whether CRM database has been restored |
| `db_restored_isu` | True/false whether ISU database has been restored |

Example of how to run this playbook, taken from the task in Azure Devops.

```bash
ansible-playbook ansible/data.yaml -i ansible/inventory.txt \
    -e  'ansible_user="$(host_username)"' \
    -e  'ansible_password="$(hostPassword)"' \
    -e  'storage_account_name="$(install_files_storage_account_name)"' \
    -e  'storage_account_key="$(installFilesStorageAccountKey)"' \
    -e  'file_share_uri="$(install_files_file_share_uri)"' \
    -e  'dns_domain_name="$(dns_domain_name)"' \`
    -e  'domain_name="$(domain_name)"' \
    -e  'domain_join_username="$(domain_join_username)"' \
    -e  'domain_join_password="$(domainJoinPassword)"' \
    -e  'domain_ou_path="$(domain_ou_path)"' \
    -e  'domain_admin_group="$(domain_admin_group)"' \
    -e  'datacentre="$(datacentre_id)"' \
    -e  'environment_instance_count="$(environment_instance_count)"' \
    -e  'sap_install_username="$(sapInstallUsername)"' \
    -e  'sap_install_password="$(sap_install_password)"'  \
    -e  'db_restored_crm="$(db_restored_crm)"' \
    -e  'db_restored_isu="$(db_restored_isu)"' -vvv
```

### Run playbook - Application install
This playbooks targets all the servers in the deployment, and installs the SAP installation on each. 

The order in which it completes this is as follows:
1. ASCS server
2. DB server
3. Primary app server (Instance 10)
4. Additional app servers (Instance 10)
5. All app servers (Instance 20)
6. All app servers (Instance 30)

This playbook can be run multiple times with no effect on existing instances, it will always just ensure the right number of installs and instances exist.

The installer binaries exist on the storage account specified in the playbook extra variables, and are downloaded prior to installation. 

#### Required variables
| Argument  | Description |
| ------------- | ------------- |
| `ansible_user` | Username of user running Ansible playbook |
| `ansible_password` | Password of user running Ansible playbook |
| `storage_account_name` | Storage account name for where the SAP software files are stored | 
| `storage_account_key` | Storage account key for the storage account where the SAP software files are stored |
| `file_share_uri` | File share location for SAP software files |
| `dns_domain_name` | FQDN of AGL internal domain e.g. `agl.int` |
| `domain_join_username` | Username of user to join domain with |
| `domain_join_password` | Password of user to join domain with |
| `domain_ou_path` | Full DN to Active Directory OU where computer objects will be created |
| `domain_admin_group` | Group which is added to local admin on every server e.g. `Func-DG-SAPInstallers` |
| `datacentre` | Datacentre ID used to construct SID e.g. A = Azure |
| `environment_instance_count` | Number used to construct SID. Should be incremented every time a new environment is created |
| `sap_install_username` | Username of user to run SQL server installer. Must be a domain user and be a part of the `domain_admin_group` |
| `sap_install_password` | Password of user to run SQL server installer |
| `sap_master_password_base` | Base of SAP master password (the part that doesn't change) |

Example of how to run this playbook, taken from the task in Azure Devops.

```bash
ansible-playbook ansible/app.yaml -i ansible/inventory.txt \
    -e  'ansible_user="$(host_username)"' \
    -e  'ansible_password="$(hostPassword)"' \
    -e  'storage_account_name="$(install_files_storage_account_name)"' \
    -e  'storage_account_key="$(installFilesStorageAccountKey)"' \
    -e  'file_share_uri="$(install_files_file_share_uri)"' \
    -e  'dns_domain_name="$(dns_domain_name)"' \`
    -e  'domain_name="$(domain_name)"' \
    -e  'domain_join_username="$(domain_join_username)"' \
    -e  'domain_join_password="$(domainJoinPassword)"' \
    -e  'domain_ou_path="$(domain_ou_path)"' \
    -e  'domain_admin_group="$(domain_admin_group)"' \
    -e  'datacentre="$(datacentre_id)"' \
    -e  'environment_instance_count="$(environment_instance_count)"' \
    -e  'sap_install_username="$(sapInstallUsername)"' \
    -e  'sap_install_password="$(sap_install_password)"'  \
    -e  'sap_master_password_base="$(sapMasterPasswordBase)"' -vvv
```

### Run playbook - BDLS
This playbook targets the database servers and runs the BDLS offline steps. 

BDLS offline is effectively a bunch of SQL scripts which take a long time to run (~14 hours).

Before it begins, it runs the PowerShell script `Get-LogicalSystemNames.ps1` which retrieves some IDs from the database which are required for later use in the pipeline. It saves this Logical System Names to a file which is read by a task in a later step.

It also does some pre-configuration of SQL server to increase the speed of the BDLS scripts e.g. updating indexes, setting MaxDOP etc. 

The BDLS SQL scripts are organised into sets for each environment (CRM and ISU), and each set runs in parellel to optimise the speed as much as possible. 

For example, Set 1 runs on both CRM/ISU at the same time, waits for completion, then runs Set 2, Set 3 and so on.

If it was up to me, the role would not be structured like this. But I ran out of time before leaving and it was too much effort to compeletely understand and refactor another engineer's code. So I apologise that you need to deal with this.

#### Required variables
| Argument  | Description |
| ------------- | ------------- |
| `ansible_user` | Username of user running Ansible playbook |
| `ansible_password` | Password of user running Ansible playbook |
| `storage_account_name` | Storage account name for where the SAP software files are stored | 
| `storage_account_key` | Storage account key for the storage account where the SAP software files are stored |
| `file_share_uri` | File share location for SAP software files |
| `dns_domain_name` | FQDN of AGL internal domain e.g. `agl.int` |
| `domain_join_username` | Username of user to join domain with |
| `domain_join_password` | Password of user to join domain with |
| `domain_ou_path` | Full DN to Active Directory OU where computer objects will be created |
| `domain_admin_group` | Group which is added to local admin on every server e.g. `Func-DG-SAPInstallers` |
| `datacentre` | Datacentre ID used to construct SID e.g. A = Azure |
| `environment_instance_count` | Number used to construct SID. Should be incremented every time a new environment is created |
| `sap_install_username` | Username of user to run SQL server installer. Must be a domain user and be a part of the `domain_admin_group` |
| `sap_install_password` | Password of user to run SQL server installer |
| `sap_master_password_base` | Base of SAP master password (the part that doesn't change) |

Example of how to run this playbook, taken from the task in Azure Devops.

```bash
ansible-playbook ansible/bdls.yaml -i ansible/inventory.txt \
    -e  'ansible_user="$(host_username)"' \
    -e  'ansible_password="$(hostPassword)"' \
    -e  'storage_account_name="$(install_files_storage_account_name)"' \
    -e  'storage_account_key="$(installFilesStorageAccountKey)"' \
    -e  'file_share_uri="$(install_files_file_share_uri)"' \
    -e  'dns_domain_name="$(dns_domain_name)"' \`
    -e  'domain_name="$(domain_name)"' \
    -e  'domain_join_username="$(domain_join_username)"' \
    -e  'domain_join_password="$(domainJoinPassword)"' \
    -e  'domain_ou_path="$(domain_ou_path)"' \
    -e  'domain_admin_group="$(domain_admin_group)"' \
    -e  'datacentre="$(datacentre_id)"' \
    -e  'environment_instance_count="$(environment_instance_count)"' \
    -e  'sap_install_username="$(sapInstallUsername)"' \
    -e  'sap_install_password="$(sap_install_password)"'  \
    -e  'sap_master_password_base="$(sapMasterPasswordBase)"' -vvv
```

### Output Logical System Name variables - CRM
Task runs a script `Output-LogicalSystemNameVariables.ps1` which reads a file of Logical System Names and outputs them as Azure Devops variables, so they can be used by the post-configuration steps. This file was generated by `Get-LogicalSystemNames.ps1` in the previous task: `BDLS`

### Output Logical System Name variables - ISU
Same as above, but for ISU. 

### Run Playbook - CRM Java
This task targets the Primary App Server and the first Additional App Server in the CRM environment, and performs a Java installation on each.

All the code is there, but I'm not certain that the orchestration part will work. I guess you'll find out.

After the app has been installed successfully, a licence must be generated from the SAP ONE Support Portal. The script that does this is `generator.js` and should be run from within a Docker container that can be built with the file at `scripts/Dockerfile`. You need to provide the script with the hardware key of the target system, and a few other parameters.

An example of how to run this `Dockerfile`, for Java in AJ3, is as follows:

```bash
cd scripts/Dockerfile
docker build -t sap-licence-generator . && \
    docker run --rm -it \
        -e SAP_USER=S0019332459 \
        -e SAP_PASS=<redacted> \
        -e HARDWARE_KEY="I1758814741" \
        -e SYSTEM_TYPE="JAVA" \
        -e SYSTEM_ID="AJ3" \
        -e SYSTEM_NAME="PTIA#3" \
        -v $(pwd):/app \
        sap-licence-generator
```

To input the licence file, it needs to be sent over Telnet to the target system. The script that can do this is `scripts/Install-SAPLicence.ps1`. 

## TODO

* Insert SAP instance STOP/START tasks before and after BDLS run. Must be run on the ASCS server, and shutdown all instances
* Complete CRM Java installation orchestration. All the parts are there just not orchestrated. 
* Complete post-configuration orchestration tasks. Calling the Python modules from with the PyRFC SAP SDK Docker container, passing the arguments outputted 
from the steps `Output Logical System Name variables - ISU` and `Output Logical System Name variables - CRM`