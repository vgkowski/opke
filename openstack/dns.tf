data "openstack_dns_zone_v2" "cluster" {
  name = "${var.dns_zone}."
}

resource "openstack_dns_recordset_v2" "apiserver" {
  count   = "1"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_networking_floatingip_v2.controller_loadbalancer.address}"]
}

resource "openstack_dns_recordset_v2" "etcd" {
  count   = "${var.controller_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s-etcd%d.%s.", var.cluster_name, count.index, var.dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${list(element(flatten(openstack_networking_port_v2.controller.*.all_fixed_ips), count.index))}"]
}

resource "openstack_dns_recordset_v2" "controller_host" {
  count   = "${var.controller_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s-controller%d.%s.", var.cluster_name, count.index, var.dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${list(element(flatten(openstack_networking_port_v2.controller.*.all_fixed_ips), count.index))}"]
}

resource "openstack_dns_recordset_v2" "worker_host" {
  count   = "${var.worker_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s-worker%d.%s.", var.cluster_name, count.index, var.dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${list(element(flatten(openstack_networking_port_v2.worker.*.all_fixed_ips), count.index))}"]
}