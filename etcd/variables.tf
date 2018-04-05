variable "etcd_count" {
  description = "number of etcd servers"
  type        = "string"
}

variable "etcd_version" {
  description = "version of etcd"
  type        = "string"
  default     = "v3.3.1"
}

variable "etcd_servers" {
  description = "List of URLs used to reach etcd servers."
  type        = "list"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "cluster_name" {
  type        = "string"
  description = "Cluster name"
}

variable "dns_zone" {
  type        = "string"
  description = "Openstack Designate DNS Zone name as given in `openstack domain list`"
}
