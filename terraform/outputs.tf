output "gateway_public_ip" {
  value       = google_compute_instance.gateway.network_interface[0].access_config[0].nat_ip
  description = "Public IP of the gateway VM"
}

output "inference_private_ip" {
  value       = google_compute_instance.inference.network_interface[0].network_ip
  description = "Private IP of the inference VM"
}
