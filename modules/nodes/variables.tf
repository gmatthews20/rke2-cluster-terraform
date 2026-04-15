variable "os_auth_url" {
  type        = string
  description = "Openstack auth url"
  default     = null
}

variable "os_cloud" {
  type        = string
  description = "Entry in clouds.yaml"
  default     = "openstack"
}

variable "master_server" {
}

variable "secgroup" {
}

variable "cluster_network" {
}

variable "token" {
}

variable "leaf_ca_key" {
}
variable "leaf_ca_cert" {
}
variable "service_key" {
}
variable "root_ca_cert" {
}
variable "intermediate_ca_cert" {
}

variable "os_application_credential_id" {
  type        = string
  description = "Openstack applicaion credential id"
  default     = null
  sensitive   = true
}

variable "os_application_credential_secret" {
  type        = string
  description = "Openstack applicaion credential secret"
  default     = null
  sensitive   = true
}

variable "os_flavor_name" {
  type        = string
  description = "Openstack VM flavor name"
  default     = "l3.nano"
}

variable "os_image_name" {
  type        = string
  description = "Openstack VM image name"
  default     = "ubuntu-noble-24.04-nogui"
}

variable "os_control_count" {
  type        = number
  description = "Number of openstack control plane nodes"
  default     = 3
}
