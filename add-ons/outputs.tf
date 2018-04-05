
output "addons_path" {
  value = "${data.template_file.addons_path.rendered}"
}

output "addons_service" {
  value = "${data.template_file.addons_service.rendered}"
}