output "controllers_fip" {
  value = "${join(", ", openstack_networking_floatingip_v2.controller.*.address)}"
}

output "workers_fip" {
  value = "${join(", ", openstack_networking_floatingip_v2.worker.*.address)}"
}

output "kubeconfig" {
  value = "\n${module.bootkube.kubeconfig}"
}
