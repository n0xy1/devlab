# ---------------------------------------------------------------
# One server
# 5 clients
# ---------------------------------------------------------------

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
        workgroup = var.server_net_params["workgroup"]
        admin_password = var.server_vm_params["admin_password"]
      }

      network_interface {
        ipv4_address    = var.server_net_params["ipv4_address"]
        ipv4_netmask    = var.server_net_params["prefix_length"]
        dns_server_list = var.dns_servers
      }
      ipv4_gateway = var.server_net_params["gateway"]
    }
  }
}

resource "vsphere_virtual_machine" "client" {

  # Loops!
  count = var.global_vm_params["client_count"]

  name             = "${var.client_vm_params["hostname"]}-${count.index}"
  num_cpus         = var.client_vm_params["vcpu"]
  memory           = var.client_vm_params["ram"]
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.win10_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.win10_template.scsi_type

  # Configure network interface
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Configure Disk
  disk {
    label = "${var.client_vm_params["hostname"]}.vmdk"
    size = "${var.client_vm_params["disk_size"]}"
  }

  # Define template and customisation params
  clone {
    template_uuid = data.vsphere_virtual_machine.win10_template.id

    customize {
      windows_options {
        computer_name = "${var.client_vm_params["hostname"]}-${count.index}"
        workgroup = var.client_net_params["workgroup"]
        admin_password = var.client_vm_params["admin_password"]
      }
      #needs an empty block for DHCP
      network_interface {}
    }
  }
  depends_on = [
    data.vsphere_virtual_machine.winserver_template
  ]
}