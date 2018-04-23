output "max-user-watches" {
  value = "${data.ignition_file.max-user-watches.id}"
}

output "kubeconfig" {
  value = "${data.ignition_file.kubeconfig.id}"
}

output "kube-upgrade-file" {
  value = "${data.ignition_file.kube_upgrade.id}"
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

output "update-engine" {
  value = "${data.ignition_systemd_unit.update-engine.id}"
}

output "bootkube" {
  value = "${data.ignition_systemd_unit.bootkube.id}"
}

output "addons" {
  value = "${data.ignition_systemd_unit.addons.id}"
}

output "addons-start" {
  value = "${data.ignition_file.addons-start.id}"
}

output "kube-upgrade" {
  value = "${data.ignition_systemd_unit.kube_upgrade.id}"
}

output "etcd-member" {
  value = "${data.ignition_systemd_unit.etcd-member.*.id}"
}

output "core-user" {
  value = "${data.ignition_user.core.id}"
}