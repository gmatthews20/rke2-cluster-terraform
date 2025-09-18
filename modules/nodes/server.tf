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

  user_data = templatefile("${path.module}/rke2-bootstrap.tftpl", { rke2_config = base64encode(yamlencode({
    "server" : format("https://%s:9345", var.master_server),
    "token" : var.token,
  })) })

  scheduler_hints {
    group = openstack_compute_servergroup_v2.node-servergroup.id
  }

  network {
    uuid = var.cluster_network
  }
}

