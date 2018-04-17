# Secure copy etcd TLS assets and kubeconfig to controllers. Activates kubelet-controller.service
resource "null_resource" "copy-secrets" {
  depends_on = ["module.etcd","openstack_compute_instance_v2.controller_node"]
  count      = "${var.controller_count}"

  connection {
    type        = "ssh"
    host        = "${element(openstack_networking_floatingip_v2.controller.*.address, count.index)}"
    user        = "core"
    timeout     = "15m"
    private_key = "${tls_private_key.core.private_key_pem}"
  }

  provisioner "file" {
    content     = "${module.bootkube.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "file" {
    content     = "${module.etcd.ca_cert}"
    destination = "$HOME/etcd-client-ca.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.client_cert}"
    destination = "$HOME/etcd-client.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.client_key}"
    destination = "$HOME/etcd-client.key"
  }

  provisioner "file" {
    content     = "${module.etcd.server_cert}"
    destination = "$HOME/etcd-server.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.server_key}"
    destination = "$HOME/etcd-server.key"
  }

  provisioner "file" {
    content     = "${module.etcd.peer_cert}"
    destination = "$HOME/etcd-peer.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.peer_key}"
    destination = "$HOME/etcd-peer.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ssl/etcd/etcd",
      "sudo mv etcd-client* /etc/ssl/etcd/",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/server-ca.crt",
      "sudo mv etcd-server.crt /etc/ssl/etcd/etcd/server.crt",
      "sudo mv etcd-server.key /etc/ssl/etcd/etcd/server.key",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/peer-ca.crt",
      "sudo mv etcd-peer.crt /etc/ssl/etcd/etcd/peer.crt",
      "sudo mv etcd-peer.key /etc/ssl/etcd/etcd/peer.key",
      "sudo chown -R etcd:etcd /etc/ssl/etcd",
      "sudo chmod -R 500 /etc/ssl/etcd",
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}

# Copy kubelet configuration and start the service on controller
# This is required to manage updates (idempotent action)
resource "null_resource" "kubelet_controller" {
  depends_on = ["module.bootkube", "null_resource.copy-secrets"]
  count = "${var.controller_count}"

  triggers {
    kubelet_env = "${module.bootkube.kubelet-env}"
  }

  connection {
    type    = "ssh"
    host    = "${element(openstack_networking_floatingip_v2.controller.*.address, count.index)}"
    user    = "core"
    timeout = "15m"
    private_key = "${tls_private_key.core.private_key_pem}"
  }

  provisioner "file" {
    source      = "${var.asset_dir}/kubelet"
    destination = "$HOME"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubelet/kubelet.env /etc/kubernetes/kubelet.env",
      "sudo systemctl restart kubelet",
      "rm -Rf /home/core/kubelet",
    ]
  }
}

# Copy kubelet configuration and start the service on worker
# This is required to manage updates (idempotent action)
resource "null_resource" "kubelet_worker" {
  depends_on = ["module.bootkube", "null_resource.copy-secrets"]
  count = "${var.worker_count}"

  triggers {
    kubelet_env = "${module.bootkube.kubelet-env}"
  }

  connection {
    type    = "ssh"
    host    = "${element(openstack_networking_floatingip_v2.worker.*.address, count.index)}"
    user    = "core"
    timeout = "15m"
    private_key = "${tls_private_key.core.private_key_pem}"
  }

  provisioner "file" {
    source      = "${var.asset_dir}/kubelet"
    destination = "$HOME"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubelet/kubelet.env /etc/kubernetes/kubelet.env",
      "sudo systemctl restart kubelet",
      "rm -Rf /home/core/kubelet",
    ]
  }
}

# Secure copy bootkube assets to ONE controller and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube-start" {
  depends_on = ["null_resource.kubelet_controller"]

  triggers {
    kubelet_env = "${module.bootkube.kubelet-env}"
  }

  connection {
    type    = "ssh"
    host    = "${element(openstack_networking_floatingip_v2.controller.*.address, 0)}"
    user    = "core"
    timeout = "15m"
    private_key = "${tls_private_key.core.private_key_pem}"
  }

  provisioner "file" {
    source      = "${var.asset_dir}/bootkube"
    destination = "$HOME"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/core/bootkube/bootkube-start",
      "chmod +x /home/core/bootkube/kube-upgrade-wrapper",
      "sudo mkdir -p /opt/bootkube",
      "sudo mv /home/core/bootkube/* /opt/bootkube/",
      "sudo systemctl start bootkube",
    ]
  }
}

# Secure copy addons assets to ONE controller and start addons to install them.
resource "null_resource" "addons-start" {
  depends_on = ["null_resource.bootkube-start","module.addons"]

  connection {
    type    = "ssh"
    host    = "${element(openstack_networking_floatingip_v2.controller.*.address, 0)}"
    user    = "core"
    timeout = "15m"
    private_key = "${tls_private_key.core.private_key_pem}"
  }

  provisioner "file" {
    source      = "${var.asset_dir}/addons"
    destination = "$HOME"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/core/addons/addons-wrapper",
      "sudo mkdir -p /opt/addons",
      "sudo mv /home/core/addons/* /opt/addons/",
      "sudo systemctl start addons",
    ]
  }
}

# Update Kubernetes control plane with bootkube manifests to manage cluster upgrade (idempotent)
resource "null_resource" "k8s-upgrade" {
  depends_on = ["null_resource.bootkube-start","null_resource.addons-start","null_resource.kubelet_worker"]

  triggers {
    kubelet_env = "${module.bootkube.kubelet-env}"
  }

  connection {
    type    = "ssh"
    host    = "${element(openstack_networking_floatingip_v2.controller.*.address, 0)}"
    user    = "core"
    timeout = "15m"
    private_key = "${tls_private_key.core.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start kube-upgrade",
    ]
  }
}