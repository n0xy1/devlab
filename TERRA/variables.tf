# Configure the VMware vSphere Provider
variable "vcenter"{
  default = {
    user = "administrator@vsphere.local"
    password = "SANITISED"
    server = "vcenter.secn3t.lan"
  }
  # sensitive = true
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
# what swtich should they connect to?
variable "vswitch" {
  default = "NSX-DSWITCH"
}

variable "win10_template" {
  default = "tpl-windows-10-eval"
}

variable "winserver_template" {
  default = "tpl-windows-2022-eval"
}

# -----------------------
# VM Parameters
# -----------------------

# shared variables for all vms
variable "global_vm_params"{
    default = {
        client_count = 5
        ntp_servers = ["0.au.pool.ntp.org","1.au.pool.ntp.org"]
        dns_servers = ["172.16.254.253","8.8.8.8"]
        domain_suffix = "dev.local"
        disk_datastore = "ISCSI-One"
        portgroup_name = "SN-SEG-TESTDEV"
        admin_password = "packer"
        domain_password = "P@ssw0rd"
    }
}


variable "server_vm_params" {
  default = {
    hostname = "DEVAD01"
    vcpu     = "2"
    ram      = "4096"
    disk_datastore = "ISCSI-One"
    disk_size      = "100"
    admin_password = "packer"
    domain_password = "P@ssw0rd"
  }
}

variable "server_net_params" {
    default = {
        # use ansible to build the domain controller in next stage.  DOMAIN_CONTROLLER_IP..
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
        ram = "6144"
        disk_datastore = "ISCSI-One"
        disk_size = "100"
        admin_password = "packer"
    }
}

variable "client_net_params" {
    default = {
        # use ansible to build the domain controller? not sure how to progress here..
       label = "SN-SEG-TESTDEV"
       #DHCP
    }
}