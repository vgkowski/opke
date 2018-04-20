output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}

output "ip" {
  value = "${concat(openstack_networking_floatingip_v2.controller.*.address,openstack_networking_floatingip_v2.worker.*.address)}"
}