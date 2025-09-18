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