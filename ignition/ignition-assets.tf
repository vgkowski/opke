data "template_file" "max-user-watches" {
  template = "${file("${path.module}/resources/files/max-user-watches.conf")}"
}

data "ignition_file" "max-user-watches" {
  filesystem = "root"
  path = "/etc/sysctl.d/max-user-watches.conf"
  content {
    content = "${data.template_file.max-user-watches.rendered}"
  }
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path = "/etc/kubernetes/kubeconfig"
  mode = 0644
  content {
    content = "${var.kubeconfig}"
  }
}

data "template_file" "kubelet-env" {
  template = "${file("${path.module}/resources/files/kubelet.env")}"
}

data "ignition_file" "kubelet-env" {
  filesystem = "root"
  path = "/etc/kubernetes/kubelet.env"
  mode = 0644
  content {
    content = "${data.template_file.kubelet-env.rendered}"
  }
}

data "template_file" "delete-node-file" {
  template = "${file("${path.module}/resources/files/delete-node")}"
}

data "ignition_file" "delete-node" {
  filesystem = "root"
  path = "/etc/kubernetes/delete-node"
  mode = 0744
  content {
    content = "${data.template_file.delete-node-file.rendered}"
  }
}

data "ignition_file" "cloud-config" {
  filesystem = "root"
  path = "/etc/kubernetes/cloud-config"
  mode = 0600
  uid = 0
  content {
    content = "${var.cloud_config}"
  }
}

data "ignition_file" "cloud-ca" {
  filesystem = "root"
  path = "/etc/ssl/certs/openstack-ca.pem"
  mode = 0644
  uid = 0
  content {
    content = "${var.cloud_ca}"
  }
}

data "template_file" "kubelet-controller-service" {
  template = "${file("${path.module}/resources/service/kubelet-controller.service")}"

  vars {
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "template_file" "kubelet-worker-service" {
  template = "${file("${path.module}/resources/service/kubelet-worker.service")}"

  vars {
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = "${var.node_type == "controller" ? data.template_file.kubelet-controller-service.rendered : data.template_file.kubelet-worker-service.rendered}"
}

data "template_file" "update-ca-certs" {
  template = "${file("${path.module}/resources/service/update-ca-certs.service")}"
}

data "ignition_systemd_unit" "update-ca-certs" {
  name    = "update-ca-certs.service"
  enabled = true
  content = "${data.template_file.update-ca-certs.rendered}"
}

data "template_file" "wait-for-dns" {
  template = "${file("${path.module}/resources/service/wait-for-dns.service")}"
}

data "ignition_systemd_unit" "wait-for-dns" {
  name    = "wait-for-dns.service"
  enabled = true
  content = "${data.template_file.wait-for-dns.rendered}"
}

data "ignition_systemd_unit" "docker" {
  name    = "docker.service"
  enabled = true
}

data "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data "ignition_systemd_unit" "bootkube" {
  name    = "bootkube.service"
  enabled = false
  content = "${var.bootkube_service}"
}

data "ignition_systemd_unit" "addons" {
  name    = "addons.service"
  enabled = false
  content = "${var.addons_service}"
}

data "template_file" "delete-node-service" {
  template = "${file("${path.module}/resources/service/delete-node.service")}"
}

data "ignition_systemd_unit" "delete-node" {
  name    = "delete-node.service"
  content = "${data.template_file.delete-node-service.rendered}"
}

data "ignition_systemd_unit" "etcd-member" {
  count   = "${var.count}"
  name    = "etcd-member.service"
  enabled = true
  dropin {
    name    = "40-etcd-cluster.conf"
    content = "${element(var.etcd_dropin,count.index)}"
  }
}

data "ignition_user" "core" {
  name = "core"
  ssh_authorized_keys = ["${var.ssh_authorized_key}"]
}