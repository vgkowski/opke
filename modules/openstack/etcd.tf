data "template_file" "etcd_hostname" {
  count    = "${var.controller_count}"
  template = "${format("%s-etcd%d.%s", var.cluster_name, count.index,  var.openstack_dns_zone)}"
}

module "etcd" {
  source = "../etcd"

  etcd_count   = "${var.controller_count}"
  cluster_name = "${var.cluster_name}"
  etcd_servers = ["${data.template_file.etcd_hostname.*.rendered}"]
  dns_zone     = "${var.openstack_dns_zone}"
  asset_dir    = "${var.asset_dir}"
}