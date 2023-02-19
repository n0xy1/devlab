output "client_ip_addresses" {
  value = [
    for vm in vsphere_virtual_machine.client: "${vm.default_ip_address}"
  ]
}