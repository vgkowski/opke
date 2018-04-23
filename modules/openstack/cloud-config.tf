data "template_file" "cloud-config" {
  template = "${file("${path.module}/resources/files/cloud-config")}"

  vars {
    user        = "${var.openstack_username}"
    password    = "${var.openstack_password}"
    auth_url    = "${var.openstack_auth_url}"
    tenant_id   = "${var.openstack_tenant_id}"
    domain_name = "${var.openstack_domain_name}"
    subnet_id   = "${openstack_networking_subnet_v2.subnet.id}"
    floating_id = "${var.openstack_external_gateway}"
  }
}