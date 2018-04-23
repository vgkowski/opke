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
    hyperkube                = "gcr.io/google_containers/hyperkube"
    cluo                     = "quay.io/coreos/container-linux-update-operator"
    ingress-default          = "gcr.io/google_containers/defaultbackend"
    ingress                  = "gcr.io/google_containers/nginx-ingress-controller"
    dashboard                = "gcr.io/google_containers/kubernetes-dashboard-amd64"
    grafana                  = "quay.io/coreos/monitoring-grafana"
    rbac-proxy               = "quay.io/brancz/kube-rbac-proxy"
    kube-stat-metrics        = "quay.io/coreos/kube-state-metrics"
    addon-resizer            = "gcr.io/google_containers/addon-resizer"
    node-exporter            = "quay.io/prometheus/node-exporter"
    prometheus-operator      = "quay.io/coreos/prometheus-operator"
    prometheus-config-reload = "quay.io/coreos/configmap-reload"
    etcd_operator            = "quay.io/coreos/etcd-operator"
  }
}

variable "versions" {
  description = "Versions to use"
  type        = "map"

  default = {
    hyperkube                = "v1.9.6"
    cluo                     = "v0.6.0"
    ingress-default          = "1.0"
    ingress                  = "0.9.0-beta.11"
    dashboard                = "v1.8.1"
    grafana                  = "5.0.3"
    alertmanager             = "v0.14.0"
    rbac-proxy               = "v0.2.0"
    kube-stat-metrics        = "v1.2.0"
    addon-resizer            = "1.0"
    node-exporter            = "v0.15.2"
    prometheus               = "v2.2.1"
    prometheus-operator      = "v0.18.0"
    prometheus-config-reload = "v0.0.1"
    etcd_operator            = "v0.9.2"
    etcd                     = "3.2.13"
  }
}


