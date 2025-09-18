resource "openstack_compute_servergroup_v2" "node-servergroup" {
  name     = format("%s%s", "my-sg", "-node")
  policies = ["soft-anti-affinity"]
}
