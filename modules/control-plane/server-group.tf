resource "openstack_compute_servergroup_v2" "control-plane-servergroup" {
  name     = format("%s%s", "my-sg", "-control-plane")
  policies = ["anti-affinity"]
}
