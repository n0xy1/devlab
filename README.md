# DEV LAB Deployment

Packer used to generate the templates

Terraform used to deploy vms from the templates

Ansible used to configure the vms.

## Packer

update `PACK\variables.auto.pkrvars.hcl` with passwords etc.

Build the templates:

        .\packer\build-10.ps1
        .\packer\build-2022.ps1

## Terraform

update `TERRA\variables.tf`

deploy the vms from the templates:

        cd TERRA
        terraform plan
        terraform apply

## Domain Controller Prep

do some setup:
- run `invoke-command -computername (dc-ip) -filepath .\ANSI\ConfigureRemotingForAnsible.ps1 -Credential (get-credential packer)`

## Ansible

I use a WSL2 Ubuntu box for this.

        ansible-playbook .\ANSI\main.yml 

## Inevitably troubleshoot

Its probably gonna break at some point

>  Problems are inevitable, but they're a learning opportunity.
> 
> -Some dude on the internet

