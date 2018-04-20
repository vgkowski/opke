output "addons_service" {
  value = "${data.template_file.addons_service.rendered}"
}

output "addons_start" {
  value = "${data.template_file.addons_start.rendered}"
}