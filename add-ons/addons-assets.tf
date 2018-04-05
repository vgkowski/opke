resource "template_dir" "ingress" {
  source_dir      = "${path.module}/resources/ingress"
  destination_dir = "${var.asset_dir}/addons/ingress"
}

resource "template_dir" "kube-dashboard" {
  source_dir      = "${path.module}/resources/kube-dashboard"
  destination_dir = "${var.asset_dir}/addons/kube-dashboard"
}

resource "template_dir" "kube-prometheus" {
  source_dir      = "${path.module}/resources/kube-prometheus"
  destination_dir = "${var.asset_dir}/addons/kube-prometheus"
}

resource "template_dir" "storage-class" {
  source_dir      = "${path.module}/resources/storage-class"
  destination_dir = "${var.asset_dir}/addons/storage-class"
}

data "template_file" "addons_path" {
  template = "${file("${path.module}/resources/addons.path")}"
}

data "template_file" "addons_service" {
  template = "${file("${path.module}/resources/addons.service")}"
}

data "template_file" "addons_start" {
  template = "${file("${path.module}/resources/addons-start")}"
}

resource "local_file" "addons_start" {
  content  = "${data.template_file.addons_start.rendered}"
  filename = "${var.asset_dir}/addons/addons-start"
}