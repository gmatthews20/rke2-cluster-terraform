output "token" {
  value = random_password.password.result
}

output "master_server" {
  value = openstack_networking_port_v2.master-port.dns_assignment[0].fqdn
}