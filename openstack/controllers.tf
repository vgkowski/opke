# controller

resource "openstack_compute_servergroup_v2" "controller_group" {
  name     = "${var.cluster_name}-controller"
  policies = ["anti-affinity"]
}


# Controller Container Linux Config
data "template_file" "controller_config" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/resources/controller.yaml.tmpl")}"

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", formatlist("%s=https://%s:2380", null_resource.repeat.*.triggers.name, null_resource.repeat.*.triggers.domain))}"

    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    ssh_authorized_key    = "${tls_private_key.core.public_key_openssh}"
    kubeconfig            = "${indent(10, module.bootkube.kubeconfig)}"

    user        = "${var.username}"
    password    = "${var.password}"
    auth_url    = "${var.auth_url}"
    tenant_id   = "${var.tenant_id}"
    domain_name = "${var.domain_name}"
    subnet_id   = "${openstack_networking_subnet_v2.subnet.id}"
    floating_id = "${var.external_gateway_id}"
    ca_pem      = "${var.ca}"
  }
}

data "ct_config" "controller_ign" {
  count        = "${var.controller_count}"
  content      = "${element(data.template_file.controller_config.*.rendered, count.index)}"
  platform     = "openstack-metadata"
  pretty_print = true
}

resource "openstack_compute_instance_v2" "controller_node" {
  count = "${var.controller_count}"
  name  = "${var.cluster_name}-controller${count.index}"

  image_name = "${var.os_image_name}"
  image_id   = "${var.os_image_id}"

  flavor_name = "${var.controller_flavor_name}"
  flavor_id   = "${var.controller_flavor_id}"

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

  user_data    = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"
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
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}
