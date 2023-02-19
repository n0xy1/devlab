output "server_ip_address" {
  value = vsphere_virtual_machine.server1.default_ip_address
}
output "server_hostname"{
  value = vsphere_virtual_machine.server1.name
}
