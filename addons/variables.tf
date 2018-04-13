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
    hyperkube                = "gcr.io/google_containers/hyperkube:v1.9.6"
    cluo                     = "quay.io/coreos/container-linux-update-operator:v0.6.0"
    ingress-default          = "gcr.io/google_containers/defaultbackend:1.0"
    ingress                  = "gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.11"
    dashboard                = "gcr.io/google_containers/kubernetes-dashboard-amd64:v1.8.1"
    grafana                  = "quay.io/coreos/monitoring-grafana:5.0.3"
    alertmanager             = "v0.14.0"
    rbac-proxy               = "quay.io/brancz/kube-rbac-proxy:v0.2.0"
    kube-stat-metrics        = "quay.io/coreos/kube-state-metrics:v1.2.0"
    addon-resizer            = "gcr.io/google_containers/addon-resizer:1.0"
    node-exporter            = "quay.io/prometheus/node-exporter:v0.15.2"
    prometheus               = "v2.2.1"
    prometheus-operator      = "quay.io/coreos/prometheus-operator:v0.18.0"
    prometheus-config-reload = "quay.io/coreos/configmap-reload:v0.0.1"
  }
}


