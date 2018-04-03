# worker

resource "openstack_compute_servergroup_v2" "worker_group" {
  name     = "${var.cluster_name}-worker"
  policies = ["anti-affinity"]
}


# Worker Container Linux Config
data "template_file" "worker_config" {
  template = "${file("${path.module}/resources/worker.yaml.tmpl")}"

  vars = {
    kubeconfig            = "${indent(10, module.bootkube.kubeconfig)}"
    ssh_authorized_key    = "${tls_private_key.core.public_key_openssh}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"

    user        = "${var.username}"
    password    = "${var.password}"
    auth_url    = "${var.auth_url}"
    tenant_id   = "${var.tenant_id}"
    domain_name = "${var.domain_name}"
    subnet_id   = "${openstack_networking_subnet_v2.subnet.id}"
    floating_id = "${var.floating_id}"
    ca_pem      = "${var.ca}"
  }
}

data "ct_config" "worker_ign" {
  content      = "${data.template_file.worker_config.rendered}"
  platform     = "openstack-metadata"
  pretty_print = true
}

resource "openstack_compute_instance_v2" "worker_node" {
  count = "${var.worker_count}"
  name  = "${var.cluster_name}-worker${count.index}"

  image_name = "${var.os_image_name}"
  image_id   = "${var.os_image_id}"

  flavor_name = "${var.worker_flavor_name}"
  flavor_id   = "${var.worker_flavor_id}"

  key_pair = "${var.cluster_name}_keypair"

  metadata {
    role = "worker"
  }

  network {
    port = "${openstack_networking_port_v2.worker.*.id[count.index]}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.worker_group.id}"
  }

  user_data    = "${data.ct_config.worker_ign.rendered}"
  config_drive = true
}

resource "openstack_compute_floatingip_associate_v2" "worker" {
  count = "${var.worker_count}"

  floating_ip = "${openstack_networking_floatingip_v2.worker.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.worker_node.*.id[count.index]}"
}
