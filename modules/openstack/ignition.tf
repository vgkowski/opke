module "ignition-controller" {
  source = "../ignition"

  count                 = "${var.controller_count}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  node_type             = "controller"
  bootkube_service      = "${module.bootkube.bootkube_service}"
  etcd_dropin           = "${module.etcd.dropin}"
  kubeconfig            = "${module.bootkube.kubeconfig}"
  cloud_config          = "${data.template_file.cloud-config.rendered}"
  cloud_ca              = "${var.openstack_ca}"
  ssh_authorized_key    = "${tls_private_key.core.public_key_openssh}"
  addons_service        = "${module.addons.addons_service}"
  addons_start          = "${module.addons.addons_start}"
  kube_upgrade          = "${module.bootkube.kube_upgrade}"
  kube_upgrade_service  = "${module.bootkube.kube_upgrade_service}"
  kubelet_service       = "${module.bootkube.kubelet-controller-service}"
}

module "ignition-worker" {
  source = "../ignition"

  count                 = "${var.worker_count}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  node_type             = "worker"
  bootkube_service      = ""
  etcd_dropin           = [""]
  kubeconfig            = "${module.bootkube.kubeconfig}"
  cloud_config          = "${data.template_file.cloud-config.rendered}"
  cloud_ca              = "${var.openstack_ca}"
  ssh_authorized_key    = "${tls_private_key.core.public_key_openssh}"
  addons_service        = ""
  addons_start          = ""
  kube_upgrade          = ""
  kube_upgrade_service  = ""
  kubelet_service       = "${module.bootkube.kubelet-worker-service}"
}