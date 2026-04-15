resource "random_pet" "server_name" {
  length = 4
  count  = 3
}

resource "openstack_compute_instance_v2" "basic" {
  name            = format("%s-%s", "basic", random_pet.server_name[count.index].id)
  count           = 3
  image_name      = "ubuntu-noble-24.04-nogui"
  flavor_name     = "l3.nano"
  security_groups = ["default", var.secgroup]

  user_data = templatefile("${path.module}/rke2-init.tftpl", { rke2_config = base64encode(yamlencode({
    "server" : format("https://%s:9345", var.master_server),
    "token" : var.token,
    })), server_ca_cert = base64encode(format("%s%s%s", var.leaf_ca_cert["server"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), server_ca_key = base64encode(var.leaf_ca_key["server"].private_key_pem),
    client_ca_cert      = base64encode(format("%s%s%s", var.leaf_ca_cert["client"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), client_ca_key = base64encode(var.leaf_ca_key["client"].private_key_pem),
    request_ca_cert     = base64encode(format("%s%s%s", var.leaf_ca_cert["request-header"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), request_ca_key = base64encode(var.leaf_ca_key["request-header"].private_key_pem),
    etcd_peer_ca_cert   = base64encode(format("%s%s%s", var.leaf_ca_cert["etcd/peer"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), etcd_peer_ca_key = base64encode(var.leaf_ca_key["etcd/peer"].private_key_pem),
    etcd_server_ca_cert = base64encode(format("%s%s%s", var.leaf_ca_cert["etcd/server"].cert_pem, var.intermediate_ca_cert.cert_pem, var.root_ca_cert.cert_pem)), etcd_server_ca_key = base64encode(var.leaf_ca_key["etcd/server"].private_key_pem),
  service_key = base64encode(var.service_key.private_key_pem) })

  scheduler_hints {
    group = openstack_compute_servergroup_v2.node-servergroup.id
  }

  network {
    uuid = var.cluster_network
  }
}

