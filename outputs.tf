#output "app_external_ip" {
#  value = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}"
#  value = "${google_compute_address.app_ip.address}"
#  value = "${ruby-app-ip}"
#}
