variable "count" {
  type        = "string"
}

variable "service_cidr" {
  type        = "string"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}

variable "node_type" {
  description = "Controller or worker"
  type        = "string"
}

variable "bootkube_service" {
  description = "content of the bootkube systemd service"
  type        = "string"
}

variable "addons_service" {
  description = "content of the addons systemd service"
  type        = "string"
}

variable "etcd_dropin" {
  description = "content of the etcd dropin"
  type        = "list"
}

variable "kubeconfig" {
  description = "content of the kubeconfig"
  type        = "string"
}

variable "cloud_config" {
  description = "content of the configuration file for cloud provider integration"
  type        = "string"
}

variable "cloud_ca" {
  description = "content of the CA of the cloud provider API"
  type        = "string"
}

variable "ssh_authorized_key" {
  description = "the public key for SSH access"
  type        = "string"
}