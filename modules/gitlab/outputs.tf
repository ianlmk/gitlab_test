output "load_balancer_ip" {
  value = google_compute_forwarding_rule.gitlab_forwarding_rule.IP_address
}

