variable "insecure_openstack_api" {
  description = "true if Openstack API certificate is self signed"
}

variable "cluster_name" {
  type        = "string"
  description = "Cluster name"
}

variable "dns_zone" {
  type        = "string"
  description = "Openstack Designate DNS Zone name as given in `openstack domain list`"
}

variable "controller_flavor_id" {
  type        = "string"
  default = ""
  description = "Flavor ID for master compute instances (see `openstack flavor list`)"
}

variable "controller_flavor_name" {
  type        = "string"
  default = ""
  description = "Flavor name for master compute instances (see `openstack flavor list`)"
}

variable "worker_flavor_id" {
  type        = "string"
  default = ""
  description = "Flavor ID for worker compute instances (see `openstack flavor list`)"
}

variable "worker_flavor_name" {
  type        = "string"
  default = ""
  description = "Flavor name for worker compute instances (see `openstack flavor list`)"
}

variable "os_image_name" {
  type        = "string"
  default = ""
  description = "OS image name from which to initialize the disk (see `openstack image list`)"
}

variable "os_image_id" {
  type        = "string"
  default = ""
  description = "OS image ID from which to initialize the disk (see `openstack image list`)"
}

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

# bootkube assets

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "flannel"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only). Use 8981 if using instances types with Jumbo frames."
  type        = "string"
  default     = "1480"
}

variable "host_cidr" {
  description = "CIDR IP range to assign compute nodes"
  type        = "string"
  default     = "10.1.0.0/16"
}


variable "pod_cidr" {
  description = "CIDR IP range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IP range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}

variable "external_gateway_id" {
  description = "The ID of the network to be used as the external internet gateway as given in `openstack network list`"
  type        = "string"
}

variable "floating_ip_pool" {
  description = "The pool name to pick up floating ips"
  type        = "string"
}

variable "floating_id" {
  description = "The pool ID to pick up floating ips"
  type    = "string"
}

variable "lb_provider" {
  description = "The type of load balancer used"
  type        = "string"
  default     = "haproxy"
}

variable "username" {
  type    = "string"
}

variable "password" {
  type    = "string"
}

variable "auth_url" {
  type    = "string"
}

variable "tenant_id" {
  type    = "string"
}

variable "domain_name" {
  type    = "string"
}

variable "ca" {
  type    = "string"
}

