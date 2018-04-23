data "template_file" "kube_upgrade_service" {
  template = "${file("${path.module}/resources/kube-upgrade.service")}"
}

data "template_file" "kube_upgrade_wrapper" {
  template = "${file("${path.module}/resources/kube-upgrade-wrapper")}"

  vars {
    hyperkube_image   = "${var.container_images["hyperkube"]}"
    hyperkube_version = "${var.versions["hyperkube"]}"
  }
}

resource "local_file" "kube_upgrade_wrapper" {
  content  = "${data.template_file.kube_upgrade_wrapper.rendered}"
  filename = "${var.asset_dir}/bootkube/kube-upgrade-wrapper"
}

data "template_file" "kube_upgrade" {
  template = "${file("${path.module}/resources/kube-upgrade")}"
}