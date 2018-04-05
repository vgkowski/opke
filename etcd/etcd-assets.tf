data "template_file" "etcd-dropin" {
  count    = "${var.etcd_count}"
  template = "${file("${path.module}/resources/dropins/etcd-member.service")}"

  vars {
    etcd_version = "${var.etcd_version}"
    etcd_name    = "etcd${count.index}"
    etcd_domain  = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", formatlist("%s=https://%s:2380", null_resource.repeat.*.triggers.name, null_resource.repeat.*.triggers.domain))}"

  }
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "repeat" {
  count = "${var.etcd_count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}