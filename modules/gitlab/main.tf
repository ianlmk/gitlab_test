provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials)
}

resource "google_compute_network" "gitlab_network" {
  name                    = "gitlab-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gitlab_subnetwork" {
  name          = "gitlab-subnetwork"
  ip_cidr_range = var.subnetwork_cidr
  region        = var.region
  network       = google_compute_network.gitlab_network.self_link
}

resource "google_compute_instance_template" "gitlab" {
  name_prefix  = "gitlab-template-"
  machine_type = var.machine_type

  disk {
    boot = true
    source_image_family = var.source_image_family
  }

  network_interface {
    subnetwork = google_compute_subnetwork.gitlab_subnetwork.self_link
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "gitlab" {
  name               = "gitlab-instance-group"
  base_instance_name = "gitlab-instance"
  instance_template  = google_compute_instance_template.gitlab.self_link
  zone               = var.zone
  target_size        = var.instance_count
}

resource "google_compute_firewall" "gitlab_allow_ssh_http_https" {
  name    = "gitlab-allow-ssh-http-https"
  network = google_compute_network.gitlab_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_target_pool" "gitlab_target_pool" {
  name = "gitlab-target-pool"

  instances = [
    google_compute_instance_group_manager.gitlab.instance_group
  ]

  health_checks = [
    google_compute_http_health_check.gitlab_health_check.name
  ]
}

resource "google_compute_http_health_check" "gitlab_health_check" {
  name                = "gitlab-health-check"
  request_path        = "/-/readiness"
  check_interval_sec  = 5
  timeout_sec         = 5
  unhealthy_threshold = 2
  healthy_threshold   = 2
}

resource "google_compute_forwarding_rule" "gitlab_forwarding_rule" {
  name       = "gitlab-forwarding-rule"
  target     = google_compute_target_pool.gitlab_target_pool.self_link
  port_range = "80"
}

