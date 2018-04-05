output "max-user-watches" {
  value = "${data.ignition_file.max-user-watches.id}"
}

output "kubeconfig" {
  value = "${data.ignition_file.kubeconfig.id}"
}

output "kubelet-env" {
  value = "${data.ignition_file.kubelet-env.id}"
}

output "delete-node-file" {
  value = "${data.ignition_file.delete-node.id}"
}

output "cloud-config" {
  value = "${data.ignition_file.cloud-config.id}"
}

output "cloud-ca" {
  value = "${data.ignition_file.cloud-ca.id}"
}

output "kubelet" {
  value = "${data.ignition_systemd_unit.kubelet.id}"
}

output "update-ca-certs" {
  value = "${data.ignition_systemd_unit.update-ca-certs.id}"
}

output "wait-for-dns" {
  value = "${data.ignition_systemd_unit.wait-for-dns.id}"
}

output "docker" {
  value = "${data.ignition_systemd_unit.docker.id}"
}

output "locksmithd" {
  value = "${data.ignition_systemd_unit.locksmithd.id}"
}

output "addons" {
  value = "${data.ignition_systemd_unit.addons.id}"
}

output "addons-path" {
  value = "${data.ignition_systemd_unit.addons-path.id}"
}

output "bootkube" {
  value = "${data.ignition_systemd_unit.bootkube.id}"
}

output "bootkube-path" {
  value = "${data.ignition_systemd_unit.bootkube-path.id}"
}

output "delete-node-service" {
  value = "${data.ignition_systemd_unit.delete-node.id}"
}

output "etcd-member" {
  value = "${data.ignition_systemd_unit.etcd-member.*.id}"
}

output "core-user" {
  value = "${data.ignition_user.core.id}"
}