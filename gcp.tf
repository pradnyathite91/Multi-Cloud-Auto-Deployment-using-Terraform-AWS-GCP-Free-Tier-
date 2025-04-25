provider "google" {
  credentials = file("reliable-stage-457909-n6-48273c0a709c.json")
  project = "reliable-stage-457909-n6"
  region  = "asia-south1"
  zone    = "asia-south1-a"
}

# VPC Network
resource "google_compute_network" "custom_vpc" {
  name                    = "my-vpc-1"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  ip_cidr_range = "10.10.1.0/24"
  region        = "asia-south1"
  network       = google_compute_network.custom_vpc.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Startup Script to Install NGINX
data "template_file" "startup_script" {
  template = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install nginx -y
    systemctl enable nginx
    systemctl start nginx
  EOT
}

# Function to Create Instances
resource "google_compute_instance" "instances" {
  count        = 3
  name         = ["dev-instance", "qa-instance", "xy-instance"][count.index]
  machine_type = "e2-micro"
  zone         = "asia-south1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.subnet_1.id

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = data.template_file.startup_script.rendered

  tags = ["nginx-server"]
}

# Outputs
output "instance_ips" {
  value = {
    for i in google_compute_instance.instances :
    i.name => i.network_interface[0].access_config[0].nat_ip
   }
}
