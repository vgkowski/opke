# controller

resource "openstack_compute_servergroup_v2" "controller_group" {
  name     = "${var.cluster_name}-controller"
  policies = ["anti-affinity"]
}


# Controller Container Linux Ignition
data "ignition_config" "controller-ignition" {
  count = "${var.controller_count}"
  files = [
    "${module.ignition-controller.kubelet-env}",
    "${module.ignition-controller.max-user-watches}",
    "${module.ignition-controller.kubeconfig}",
    "${module.ignition-controller.cloud-ca}",
    "${module.ignition-controller.cloud-config}"
  ]
  systemd = [
    "${module.ignition-controller.wait-for-dns}",
    "${module.ignition-controller.kubelet}",
    "${module.ignition-controller.update-ca-certs}",
    "${module.ignition-controller.bootkube}",
    "${module.ignition-controller.docker}",
    "${module.ignition-controller.locksmithd}",
    "${module.addons.addons_service}",
    "${element(module.ignition-controller.etcd-member,count.index)}"
  ]
  users = [
    "${module.ignition-controller.core-user}",
  ]
}

resource "openstack_compute_instance_v2" "controller_node" {
  count = "${var.controller_count}"
  name  = "${var.cluster_name}-controller${count.index}"

  image_name = "${var.openstack_os_image_name}"
  image_id   = "${var.openstack_os_image_id}"

  flavor_name = "${var.openstack_controller_flavor_name}"
  flavor_id   = "${var.openstack_controller_flavor_id}"

  key_pair = "${var.cluster_name}_keypair"

  metadata {
    role = "controller"
  }

  network {
    port = "${openstack_networking_port_v2.controller.*.id[count.index]}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.controller_group.id}"
  }

  user_data    = "${element(data.ignition_config.controller-ignition.*.rendered, count.index)}"
  config_drive = true
}

resource "openstack_compute_floatingip_associate_v2" "controller" {
  count = "${var.controller_count}"

  floating_ip = "${openstack_networking_floatingip_v2.controller.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.controller_node.*.id[count.index]}"
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "repeat" {
  count = "${var.controller_count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.openstack_dns_zone}"
  }
}
