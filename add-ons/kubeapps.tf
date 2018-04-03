resource "template_dir" "kube_apps" {
  source_dir      = "${path.module}/resources"
  destination_dir = "${var.asset_dir}/addons"
}