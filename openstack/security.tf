# common rules

resource "openstack_networking_secgroup_v2" "k8s" {
  name                 = "${var.cluster_name}_k8s"
  description          = "Ports needed by all cluster nodes"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.k8s.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.k8s.id}"
}

resource "openstack_networking_secgroup_rule_v2" "flannel" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8472
  port_range_max    = 8472
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.k8s.id}"
  security_group_id = "${openstack_networking_secgroup_v2.k8s.id}"
}

resource "openstack_networking_secgroup_rule_v2" "kubelet-read" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10255
  port_range_max    = 10255
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.k8s.id}"
  security_group_id = "${openstack_networking_secgroup_v2.k8s.id}"
}

resource "openstack_networking_secgroup_rule_v2" "bgp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 179
  port_range_max    = 179
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.k8s.id}"
  security_group_id = "${openstack_networking_secgroup_v2.k8s.id}"
}

# controller specific rules

resource "openstack_networking_secgroup_v2" "controller" {
  name                 = "${var.cluster_name}_controller"
  description          = "Ports needed by controller nodes"
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.controller.id}"
}

resource "openstack_networking_secgroup_rule_v2" "etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 2379
  port_range_max    = 2380
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller.id}"
  security_group_id = "${openstack_networking_secgroup_v2.controller.id}"
}

resource "openstack_networking_secgroup_rule_v2" "node-exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 9100
  port_range_max    = 9100
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.controller.id}"
}

resource "openstack_networking_secgroup_rule_v2" "kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10250
  port_range_max    = 10250
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.controller.id}"
  security_group_id = "${openstack_networking_secgroup_v2.controller.id}"
}


# worker specific rules

resource "openstack_networking_secgroup_v2" "worker" {
  name                 = "${var.cluster_name}_worker"
  description          = "Ports needed by worker nodes"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ingress-http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-health" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10254
  port_range_max    = 10254
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "kubelet-worker" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10250
  port_range_max    = 10250
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.k8s.id}"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "worker-node-exporter" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 9100
  port_range_max    = 9100
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.worker.id}"
}

