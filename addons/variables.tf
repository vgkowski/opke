variable "kube_version" {
  type    = "string"
  default = "v1.9.6"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"

  default = {
    hyperkube        = "gcr.io/google_containers/hyperkube:v1.9.6"
  }
}


