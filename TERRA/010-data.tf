#### GLOBAL CONFIG

# Define datacenter
data "vsphere_datacenter" "dc" {
  name = var.dc
}

# Exctrat data port vlan creation
data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "${var.cluster}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = var.server_vm_params["disk_datastore"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = var.server_net_params["label"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "winserver_template" {
  name          = var.winserver_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "win10_template" {
  name          = var.win10_template
  datacenter_id = data.vsphere_datacenter.dc.id
}
