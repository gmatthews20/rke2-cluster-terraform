resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "server_name" {
  length = 4
  count  = 3
}

resource "openstack_networking_port_v2" "master-port" {
  name           = "master_port"
  network_id     = var.cluster_network
  admin_state_up = "true"

  tags = ["control-plane"]

  # fixed_ip {
  #   subnet_id = openstack_networking_subnet_v2.subnet_1.id
  # }
}

locals {
  master_server = openstack_networking_port_v2.master-port.dns_assignment[0].fqdn
}

resource "openstack_compute_instance_v2" "control-nodes" {
  name            = format("%s-%s", "basic", random_pet.server_name[count.index+1].id)
  count           = 3-1
  image_name      = "ubuntu-noble-24.04-nogui"
  flavor_name     = "l3.nano"
  security_groups = ["default", var.secgroup]

  lifecycle {
    create_before_destroy = true
  }

  user_data = templatefile("${path.module}/rke2-init.tftpl", { rke2_config = base64encode(yamlencode({
    "server" : format("https://%s:9345", local.master_server),
    # WIP Cloud provider setup
    "cloud-provider-name": "openstack",
    "cloud-provider-config": ""
    "token": random_password.password.result,
    "debug": true,
    "with-node-id": true,
    # WIP IRIS IAM integration
    # "kube-apiserver-arg": [
    #   "--oidc-issuer-url=https://iris-iam.stfc.ac.uk/",
    #   "--oidc-client-id=<client-id>",
    #   "--oidc-username-claim=preferred_username",
    #   "--oidc-groups-claim=groups",
    #   "--oidc-username-prefix=oidc:",
    #   "--oidc-groups-prefix=oidc:",
    # ]
    })), server_ca_cert = base64encode(format("%s%s%s", var.leaf_ca_cert["server"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), server_ca_key = base64encode(var.leaf_ca_key["server"].private_key_pem),
    client_ca_cert      = base64encode(format("%s%s%s", var.leaf_ca_cert["client"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), client_ca_key = base64encode(var.leaf_ca_key["client"].private_key_pem),
    request_ca_cert     = base64encode(format("%s%s%s", var.leaf_ca_cert["request-header"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), request_ca_key = base64encode(var.leaf_ca_key["request-header"].private_key_pem),
    etcd_peer_ca_cert   = base64encode(format("%s%s%s", var.leaf_ca_cert["etcd/peer"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), etcd_peer_ca_key = base64encode(var.leaf_ca_key["etcd/peer"].private_key_pem),
    etcd_server_ca_cert = base64encode(format("%s%s%s", var.leaf_ca_cert["etcd/server"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), etcd_server_ca_key = base64encode(var.leaf_ca_key["etcd/server"].private_key_pem),
  service_key = base64encode(var.service_key.private_key_pem) })

  scheduler_hints {
    group = openstack_compute_servergroup_v2.control-plane-servergroup.id
  }

  network {
    uuid = var.cluster_network
  }

  # dynamic "network" {
  #   for_each = [count.index]

  #   content {
  #     uuid = network.value == 0 ? null : var.cluster_network
  #     port = network.value == 0 ? openstack_networking_port_v2.master-port.id : null
  #   }
  # }
}

resource "time_sleep" "sync-control-plane" {
  depends_on = [openstack_compute_instance_v2.control-nodes]
  destroy_duration = "120s"
}


resource "openstack_compute_instance_v2" "master-node" {
  depends_on = [time_sleep.sync-control-plane]
  name            = format("%s-%s", "basic", random_pet.server_name[0].id)
  image_name      = "ubuntu-noble-24.04-nogui"
  flavor_name     = "l3.nano"
  security_groups = ["default", var.secgroup]

  user_data = templatefile("${path.module}/rke2-init.tftpl", { rke2_config = base64encode(yamlencode({
    "server" : "",
    "token": random_password.password.result,
    "debug": true,
    "with-node-id": true,
    # WIP IRIS IAM integration
    # "kube-apiserver-arg": [
    #   "--oidc-issuer-url=https://iris-iam.stfc.ac.uk/",
    #   "--oidc-client-id=<client-id>",
    #   "--oidc-username-claim=preferred_username",
    #   "--oidc-groups-claim=groups",
    #   "--oidc-username-prefix=oidc:",
    #   "--oidc-groups-prefix=oidc:",
    # ]
    })), server_ca_cert = base64encode(format("%s%s%s", var.leaf_ca_cert["server"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), server_ca_key = base64encode(var.leaf_ca_key["server"].private_key_pem),
    client_ca_cert      = base64encode(format("%s%s%s", var.leaf_ca_cert["client"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), client_ca_key = base64encode(var.leaf_ca_key["client"].private_key_pem),
    request_ca_cert     = base64encode(format("%s%s%s", var.leaf_ca_cert["request-header"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), request_ca_key = base64encode(var.leaf_ca_key["request-header"].private_key_pem),
    etcd_peer_ca_cert   = base64encode(format("%s%s%s", var.leaf_ca_cert["etcd/peer"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), etcd_peer_ca_key = base64encode(var.leaf_ca_key["etcd/peer"].private_key_pem),
    etcd_server_ca_cert = base64encode(format("%s%s%s", var.leaf_ca_cert["etcd/server"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), etcd_server_ca_key = base64encode(var.leaf_ca_key["etcd/server"].private_key_pem),
    service_key         = base64encode(var.service_key.private_key_pem)
  })

  scheduler_hints {
    group = openstack_compute_servergroup_v2.control-plane-servergroup.id
  }

  network {
    port = openstack_networking_port_v2.master-port.id
  }
}

resource "openstack_lb_members_v2" "members_1" {
  pool_id = var.kubeapi_pool

  dynamic "member" {
    for_each = openstack_compute_instance_v2.control-nodes

    content {
      address       = member.value.network[0].fixed_ip_v4
      protocol_port = 6443
    }
  }
}
