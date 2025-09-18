resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

data "openstack_networking_network_v2" "external_network" {
  name = "External"
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "my_router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "My neutron security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9345
  port_range_max    = 9345
  remote_group_id   = openstack_networking_secgroup_v2.secgroup_1.id
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2379
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2380
  port_range_max    = 2380
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2381
  port_range_max    = 2381
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_7" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_networking_port_v2" "lb_vip_port" {
  name = "lb_vip_port"
  network_id     = openstack_networking_network_v2.network_1.id
  admin_state_up = "true"

  tags = ["loadbalancer"]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

resource "openstack_lb_loadbalancer_v2" "lb_1" {
  name = "rke2-cluster-lb"
  vip_port_id = openstack_networking_port_v2.lb_vip_port.id
}

resource "openstack_lb_listener_v2" "listener_1" {
  protocol        = "TCP"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb_1.id
  name = "kubeapi"
}

resource "openstack_lb_pool_v2" "pool_1" {
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_1.id
  name = "kubeapi"
}

# resource "openstack_lb_member_v2" "members_1" {
#   for_each = toset([for port in openstack_networking_port_v2.ports : port.dns_assignment[0].ip_address])
#   pool_id = openstack_lb_pool_v2.pool_1.id
#   address = each.value
#   protocol_port = 6443
# }

#resource "openstack_networking_floatingip_v2" "floatingip_1" {
#  pool = data.openstack_networking_network_v2.external_network.name
#}
#
#resource "openstack_networking_floatingip_associate_v2" "fip_1" {
#  floating_ip = openstack_networking_floatingip_v2.floatingip_1.address
#  port_id     = openstack_networking_port_v2.lb_vip_port.id
#}

