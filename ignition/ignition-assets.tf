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

data "ignition_file" "kube_upgrade" {
  filesystem = "root"
  path = "/etc/kubernetes/kube-upgrade"
  mode = 0744
  content {
    content = "${var.kube_upgrade}"
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

data "ignition_file" "addons-start" {
  filesystem = "root"
  path = "/etc/kubernetes/addons-start"
  mode = 0644
  content {
    content = "${var.addons_start}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name    = "kubelet.service"
  enabled = true
  content = "${var.kubelet_service}"
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
  name    = "locksmithd.service"
  mask    = true
  enabled = false
}

data "ignition_systemd_unit" "update-engine" {
  name    = "update-engine.service"
  mask    = false
  enabled = true
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

data "ignition_systemd_unit" "kube_upgrade" {
  name    = "kube-upgrade.service"
  enabled = false
  content = "${var.kube_upgrade_service}"
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