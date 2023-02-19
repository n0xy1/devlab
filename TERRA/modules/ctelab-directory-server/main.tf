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
  name          = var.server_net_params["label"]
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_virtual_machine" "server1" {
  name             = var.server_vm_params["hostname"]
  num_cpus         = var.server_vm_params["vcpu"]
  memory           = var.server_vm_params["ram"]
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.winserver_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.winserver_template.scsi_type

  # Configure network interface
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Configure Disk
  disk {
    label = "${var.server_vm_params["hostname"]}.vmdk"
    size = "${var.server_vm_params["disk_size"]}"
  }

  # Define template and customisation params
  clone {
    template_uuid = data.vsphere_virtual_machine.winserver_template.id

    customize {
      windows_options {
        computer_name = var.server_vm_params["hostname"]
        workgroup = "PROVISION"
        admin_password = var.server_vm_params["admin_password"]
      }

      network_interface {
        ipv4_address    = var.server_net_params["ipv4_address"]
        ipv4_netmask    = var.server_net_params["prefix_length"]
        dns_server_list = var.global_vm_params.dns_servers
      }
      ipv4_gateway = var.server_net_params["gateway"]
    }
  }
}
