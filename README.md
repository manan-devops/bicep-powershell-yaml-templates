# bicep-powershell-yaml-templates

This project contains:

1) **api.bicep** - A bicep template that deploys app plans, app service with configuration to DEV, QA & Prod stage
2) **ConfigureDomainController.ps1** - Powershell DSC script that configures a blank VM into a Domain Controller
3) **azure-pipeline.yml** - A YAML pipeline workflow to deploy infrastructure to Dev, QA & Prod stage
4) **linux-vm.bicep** - A Bicep template that creates a VM and all the related components

