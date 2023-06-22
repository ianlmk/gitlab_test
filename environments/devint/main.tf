module "gitlab" {
  source                = "../../modules/gitlab"
  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  credentials           = var.credentials
  subnetwork_cidr       = var.subnetwork_cidr
  machine_type          = var.machine_type
  source_image_family   = var.source_image_family
  service_account_email = var.service_account_email
  instance_count        = var.instance_count
}
