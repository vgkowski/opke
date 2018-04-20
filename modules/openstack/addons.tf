module "addons" {
  source = "../addons"

  asset_dir    = "${var.asset_dir}"
  kube_version = "${var.kubernetes_version}"
}