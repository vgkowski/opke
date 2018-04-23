data "template_file" "kubelet_env" {
  template = "${file("${path.module}/resources/kubelet.env")}"

  vars {
    kubelet_image   = "${var.container_images["hyperkube"]}"
    kubelet_version = "${var.versions["hyperkube"]}"
  }
}

resource "local_file" "kubelet_env" {
  content  = "${data.template_file.kubelet_env.rendered}"
  filename = "${var.asset_dir}/kubelet/kubelet.env"
}

data "template_file" "kubelet_controller_service" {
  template = "${file("${path.module}/resources/kubelet-controller.service")}"

  vars {
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}


data "template_file" "kubelet_worker_service" {
  template = "${file("${path.module}/resources/kubelet-worker.service")}"

  vars {
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}