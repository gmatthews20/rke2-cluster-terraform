# output "ip_addr" {
#   value = openstack_networking_port_v2.ports
# }

output "control-plane-secgroup" {
  value = openstack_networking_secgroup_v2.secgroup_1.name
}

output "cluster-network" {
  value = openstack_networking_network_v2.network_1.id
}
output "kubeapi_pool" {
  value = openstack_lb_pool_v2.pool_1.id
}
