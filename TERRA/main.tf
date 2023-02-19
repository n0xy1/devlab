provider "vsphere" {
  user           = var.vcenter.user
  password       = var.vcenter.password
  vsphere_server = var.vcenter.server
  allow_unverified_ssl = true
}
# Define datacenter
data "vsphere_datacenter" "dc" {
  name = var.dc
}
# Extract host
data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Resource Pool
data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "${var.cluster}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "winserver_template" {
  name          = var.winserver_template
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = var.global_vm_params["disk_datastore"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = var.global_vm_params["portgroup_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}


module "ctelab-directory-server" {
    source = "./modules/ctelab-directory-server"
    dc = var.dc
    cluster = var.cluster
    host = var.host
    vswitch = var.vswitch
    winserver_template = var.winserver_template
    server_vm_params = var.server_vm_params
    server_net_params = var.server_net_params
    global_vm_params = var.global_vm_params
}

module "ctelab-directory-client"{
    source = "./modules/ctelab-directory-client"
    dc = var.dc
    cluster = var.cluster
    host = var.host
    vswitch = var.vswitch
    win10_template = var.win10_template
    vm_datastore = var.global_vm_params.disk_datastore
    client_net_params = var.client_net_params
    client_vm_params = var.client_vm_params
    global_vm_params = var.global_vm_params
}





# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_file_new" {
  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform configuration.
    vsphere_user: "${var.vcenter.user}"
    vsphere_server: "${var.vcenter.server}"
    vsphere_password: "${var.vcenter.password}"
    dc_address: ${module.ctelab-directory-server.server_ip_address}
    dc_netmask_cidr: ${var.server_net_params.prefix_length}
    dc_gateway: ${var.server_net_params.gateway}
    dc_hostname: ${module.ctelab-directory-server.server_hostname}
    domain_name: ${var.global_vm_params["domain_suffix"]}
    local_admin:  ${var.global_vm_params["admin_password"]}
    temp_password: ${var.global_vm_params["admin_password"]}
    dc_password: ${var.global_vm_params["domain_password"]}
    recovery_password: ${var.global_vm_params["domain_password"]}
    upstream_dns_1: ${var.global_vm_params.dns_servers[0]}
    upstream_dns_2: ${var.global_vm_params.dns_servers[1]}
    # Need to get the .0 address from the ipv4 here \/
    reverse_dns_zone: "${replace(module.ctelab-directory-server.server_ip_address,"\\.\\d+$","0")}/${var.server_net_params.prefix_length}"
    ntp_servers: "${var.global_vm_params.ntp_servers[0]},${var.global_vm_params.ntp_servers[1]}"
    DOC
  filename = "../tf_ansible_vars_file.yml"
}

# save the inventory for ansible:
resource "local_file" "tf_client_inventory"{
  content = <<-DOC
# Ansible vars_file containing variable values from Terraform.
# Generated by Terraform configuration.
all:
  children:
    winserver:
      hosts:
        ${module.ctelab-directory-server.server_ip_address}:
          ansible_user: 'packer'
          ansible_password: '${var.global_vm_params["admin_password"]}'
          ansible_connection: winrm
          ansible_winrm_transport: ntlm
          ansible_winrm_server_cert_validation: ignore
          ansible_winrm_port: 5986 
    winclient:
      hosts:
%{ for i, name in module.ctelab-directory-client.client_ip_addresses ~}
        ${name}:
          ansible_user: 'packer'
          ansible_password: '${var.global_vm_params["admin_password"]}'
          ansible_connection: winrm
          ansible_winrm_transport: ntlm
          ansible_winrm_server_cert_validation: ignore
          ansible_winrm_port: 5986
%{ endfor ~}
          
    DOC
  filename = "../tf_ansible_inventory.yml"
}

resource "local_file" "enable_winrm_script"{
  content = <<-DOC
$creds = Get-Credential packer
$hosts_to_enable = @(
%{ for i,name in module.ctelab-directory-client.client_ip_addresses ~}
  "${name}",
%{ endfor ~}
  "${module.ctelab-directory-server.server_ip_address}"
)
Write-Output "Enabling WinRM... If this fails (usually on the clients) you gotta manually go in and enable winrm."
invoke-command -computername $hosts_to_enable  -FilePath .\ANSI\ConfigureRemotingForAnsible.ps1 -Credential $creds

  DOC
  filename = "../tf_enable_remoting.ps1"
}

resource "local_file" "final_script"{
  content = <<-DOC
You made it this far, the struggle continues.

Now run in powershell: " .\tf_enable_remoting.ps1"
(you probably need to manually enable winrm service on the clients)

and finally (in WSL) run:
ansible-playbook -i .\tf_ansible_inventory.yml ./ANSI/main.yml
ansible-playbook -i .\tf_ansible_inventory.yml ./ANSI/client-join.yml

  DOC
  filename = "../READ_ME_FOR_NEXT_STEPS.txt"
}