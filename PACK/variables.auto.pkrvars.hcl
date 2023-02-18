# Name or IP of you vCenter Server
vsphere_server          = "vcenter.secn3t.lan"

# vsphere username
vsphere_username        = "administrator@vsphere.local"

# vsphere password
vsphere_password        = "SANITISED"

# vsphere datacenter name
vsphere_datacenter      = "Datacenter"

# name or IP of the ESXi host
vsphere_host            = "snhv000.secn3t.lan"

# vsphere network
vsphere_network         = "SN-SEG-TESTDEV"

# vsphere datastore
vsphere_datastore       = "ISCSI-One"

# datastore path to the vmtools iso file (You can download VMware Tools packages for Windows here (.zip file): https://customerconnect.vmware.com/en/downloads/details?downloadGroup=VMTOOLS1135&productId=1073&rPId=74478)
vmtools_iso_path        = "[R730-NVMe-Large-1] packer/vmtools/windows.iso"

# datastore path to the floppy image for virtual iSCSI drivers (part of VM Tools, see above) 
floppy_pvscsi           = "[R730-NVMe-Large-1] packer/floppies/pvscsi-Windows8.flp"


# Windows username (created in autounattend.xml. If you change it here the please also adjust in all autounattend.xml)
winrm_password          = "packer"

# Windows password (created in autounattend.xml. If you change it here the please also adjust in all autounattend.xml)
winrm_username          = "packer"