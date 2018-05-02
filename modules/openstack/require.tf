# Terraform version and plugin versions
terraform {
  backend "etcdv3" {}
  required_version = ">= 0.10.4"
}

provider "openstack" {
  version  = "~> 1.1.0"
}

provider "local" {
  version = "~> 1.0"
}

provider "null" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.0"
}
