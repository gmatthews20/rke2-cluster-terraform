provider "openstack" {
  auth_url = var.os_auth_url
  cloud    = var.os_cloud
}


module "cluster-network" {
  source = "./modules/network"

  os_auth_url = var.os_auth_url
  os_cloud    = var.os_cloud
}

module "control-plane" {
  source = "./modules/control-plane"

  os_auth_url = var.os_auth_url
  os_cloud    = var.os_cloud
  # port = module.cluster-network.ip_addr
  cluster_network = module.cluster-network.cluster-network
  secgroup        = module.cluster-network.control-plane-secgroup
}

module "workers" {
  source = "./modules/nodes"

  os_auth_url     = var.os_auth_url
  os_cloud        = var.os_cloud
  master_server   = module.control-plane.master_server
  token           = module.control-plane.token
  cluster_network = module.cluster-network.cluster-network
  secgroup        = module.cluster-network.control-plane-secgroup
}
