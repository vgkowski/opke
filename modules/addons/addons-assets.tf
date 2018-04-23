resource "template_dir" "cluo" {
  source_dir      = "${path.module}/resources/cluo"
  destination_dir = "${var.asset_dir}/addons/cluo"

  vars {
    cluo_image   = "${var.container_images["cluo"]}"
    cluo_version = "${var.versions["cluo"]}"
  }
}

resource "template_dir" "ingress" {
  source_dir      = "${path.module}/resources/ingress"
  destination_dir = "${var.asset_dir}/addons/ingress"

  vars {
    ingress_default_image   = "${var.container_images["ingress-default"]}"
    ingress_default_version = "${var.versions["ingress-default"]}"
    ingress_image           = "${var.container_images["ingress"]}"
    ingress_version         = "${var.versions["ingress"]}"
  }
}

resource "template_dir" "kube-dashboard" {
  source_dir      = "${path.module}/resources/kube-dashboard"
  destination_dir = "${var.asset_dir}/addons/kube-dashboard"

  vars {
    dashboard_image   = "${var.container_images["dashboard"]}"
    dashboard_version = "${var.versions["dashboard"]}"
  }
}

resource "template_dir" "kube-prometheus" {
  source_dir      = "${path.module}/resources/kube-prometheus"
  destination_dir = "${var.asset_dir}/addons/kube-prometheus"

  vars {
    grafana_image                    = "${var.container_images["grafana"]}"
    grafana_version                  = "${var.versions["grafana"]}"
    alertmanager_version             = "${var.versions["alertmanager"]}"
    rbac_proxy_image                 = "${var.container_images["rbac-proxy"]}"
    rbac_proxy_version               = "${var.versions["rbac-proxy"]}"
    kube_stat_metrics_image          = "${var.container_images["kube-stat-metrics"]}"
    kube_stat_metrics_version        = "${var.versions["kube-stat-metrics"]}"
    addon_resizer_image              = "${var.container_images["addon-resizer"]}"
    addon_resizer_version            = "${var.versions["addon-resizer"]}"
    node_exporter_image              = "${var.container_images["node-exporter"]}"
    node_exporter_version            = "${var.versions["node-exporter"]}"
    prometheus_version               = "${var.versions["prometheus"]}"
    prometheus_operator_image        = "${var.container_images["prometheus-operator"]}"
    prometheus_operator_version      = "${var.versions["prometheus-operator"]}"
    prometheus_config_reload_image   = "${var.container_images["prometheus-config-reload"]}"
    prometheus_config_reload_version = "${var.versions["prometheus-config-reload"]}"
  }
}

resource "template_dir" "opke" {
  source_dir      = "${path.module}/resources/opke"
  destination_dir = "${var.asset_dir}/addons/opke"

  vars {
    etcd_operator_image   = "${var.container_images["etcd_operator"]}"
    etcd_operator_version = "${var.versions["etcd_operator"]}"
    etcd_version          = "${var.versions["etcd"]}"
  }
}


resource "template_dir" "storage-class" {
  source_dir      = "${path.module}/resources/storage-class"
  destination_dir = "${var.asset_dir}/addons/storage-class"
}

data "template_file" "addons_service" {
  template = "${file("${path.module}/resources/addons.service")}"
}

data "template_file" "addons_start" {
  template = "${file("${path.module}/resources/addons-start")}"
}

data "template_file" "addons_wrapper" {
  template = "${file("${path.module}/resources/addons-wrapper")}"

  vars {
    hyperkube_image   = "${var.container_images["hyperkube"]}"
    hyperkube_version = "${var.versions["hyperkube"]}"
  }
}

resource "local_file" "addons_wrapper" {
  content  = "${data.template_file.addons_wrapper.rendered}"
  filename = "${var.asset_dir}/addons/addons-wrapper"
}