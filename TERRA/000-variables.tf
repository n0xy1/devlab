# Configure the VMware vSphere Provider
# You can use vcenter login params or simply host esxi login params
provider "vsphere" {
  # If you use a domain set your login like this "MyDomain\\MyUser"
  user           = "administrator@vsphere.local"
  password       = "SANITISED"
  vsphere_server = "vcenter.secn3t.lan"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#### TEMPLATE VARS

# You must add the templates in vsphere before using them
variable "win10_template" {
  default = "tpl-windows-10-eval"
}
variable "winserver_template" {
  default = "tpl-windows-2022-eval"
}


#### DC AND CLUSTER
# Set vpshere datacenter (default usually is Datacenter)
variable "dc" {
  default = "Datacenter"
}

# Set cluster where you want your vms deployed
variable "cluster" {
  default = "Cluster"
}

# Set host  where you want your vms deployed
variable "host" {
  default = "snhv000.secn3t.lan"
}

#### GLOBAL NETWORK PARAMS
# Virtual switch used
variable "vswitch" {
  default = "NSX-DSWITCH"
}

variable "dns_servers" {
  default = ["172.16.254.253"]
}


# Set the number of client vms you want to create
variable "global_vm_params"{
    default = {
        client_count = 5
    }
}

# Variables for the VMs themselves, split in to vm_params and net_params.
# the admin_password is the local admin creds (These templates were created with packer, so packer:packer is the default.)
#
variable "server_vm_params" {
  default = {
    hostname = "DEVAD01"
    vcpu     = "2"
    ram      = "4096"
    disk_datastore = "ISCSI-One"
    disk_size      = "100"
    admin_password = "packer"
  }
}

variable "server_net_params" {
    default = {
        # use ansible to build the domain controller in next stage.  DOMAIN_CONTROLLER_IP..
       workgroup = "dev.local"
       label = "SN-SEG-TESTDEV"
       ipv4_address = "172.16.6.10"
       prefix_length = "24"
       gateway = "172.16.6.1"
    }
}

variable "client_vm_params"{
    default = {
        # when global.client_count > 0 it will look like hostname-x where is the index. e.g. "DEVCLIENT-0", "DEVCLIENT-1" etc..
        hostname = "DEVCLIENT"
        vcpu = "2"
        ram = "4096"
        disk_datastore = "ISCSI-One"
        disk_size = "100"
        admin_password = "packer"
    }
}

variable "client_net_params" {
    default = {
        # use ansible to build the domain controller? not sure how to progress here..
       workgroup = "dev.local"
       label = "SN-SEG-TESTDEV"
       #DHCP
    #    ipv4_address = "172.16.6.10"
    #    prefix_length = "24"
    #    gateway = "172.16.6.1"
    }
}