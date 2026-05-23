provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "alchemyst-vpc"
  auto_create_subnetworks = false
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name          = "alchemyst-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Firewall: allow HTTP on gateway from internet
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-gateway"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["3111", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gateway"]
}

# Firewall: allow internal traffic between VMs
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.1.0/24"]
}

# Gateway VM (public IP)
resource "google_compute_instance" "gateway" {
  name         = "gateway-vm"
  machine_type = "n2-standard-2"
  zone         = var.zone
  tags         = ["gateway"]

  advanced_machine_features {
    enable_nested_virtualization = true
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
    access_config {}
  }

  metadata_startup_script = file("${path.module}/../scripts/setup-gateway.sh")
}

# Inference VM (no public IP)
resource "google_compute_instance" "inference" {
  name         = "inference-vm"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["inference"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
  }

  metadata_startup_script = templatefile("${path.module}/../scripts/setup-inference.sh", {
    gateway_ip = google_compute_instance.gateway.network_interface[0].network_ip
  })
}
