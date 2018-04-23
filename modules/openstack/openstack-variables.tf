# openstack variables
variable "openstack_username" {
  type    = "string"
}

variable "openstack_password" {
  type    = "string"
}

variable "openstack_auth_url" {
  type    = "string"
}

variable "openstack_tenant_id" {
  type    = "string"
}

variable "openstack_domain_name" {
  type    = "string"
}

variable "openstack_ca" {
  type    = "string"
}

variable "openstack_dns_zone" {
  type        = "string"
  description = "Openstack Designate DNS Zone name as given in `openstack domain list`"
}

variable "openstack_controller_flavor_id" {
  type        = "string"
  default = ""
  description = "Flavor ID for master compute instances (see `openstack flavor list`)"
}

variable "openstack_controller_flavor_name" {
  type        = "string"
  default = ""
  description = "Flavor name for master compute instances (see `openstack flavor list`)"
}

variable "openstack_worker_flavor_id" {
  type        = "string"
  default = ""
  description = "Flavor ID for worker compute instances (see `openstack flavor list`)"
}

variable "openstack_worker_flavor_name" {
  type        = "string"
  default = ""
  description = "Flavor name for worker compute instances (see `openstack flavor list`)"
}

variable "openstack_os_image_name" {
  type        = "string"
  default = ""
  description = "OS image name from which to initialize the disk (see `openstack image list`)"
}

variable "openstack_os_image_id" {
  type        = "string"
  default = ""
  description = "OS image ID from which to initialize the disk (see `openstack image list`)"
}

variable "openstack_external_gateway" {
  description = "The ID of the network to be used as the external internet gateway as given in `openstack network list`"
  type        = "string"
}

variable "openstack_floating_pool" {
  description = "The pool name to pick up floating ips"
  type        = "string"
}

variable "openstack_lb_provider" {
  description = "The type of load balancer used"
  type        = "string"
  default     = "haproxy"
}