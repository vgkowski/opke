# Self-hosted Kubernetes assets (kubeconfig, manifests)

module "bootkube" {
  source = "../bootkube"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${format("%s.%s", var.cluster_name, var.openstack_dns_zone)}"]
  etcd_servers          = ["${data.template_file.etcd_hostname.*.rendered}"]
  etcd_ca               = "${module.etcd.ca_cert}"
  etcd_client_cert      = "${module.etcd.client_cert}"
  etcd_client_key       = "${module.etcd.client_key}"
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  cloud_provider        = "openstack"
  cloud_config          = "/etc/kubernetes/cloud-config"
}
