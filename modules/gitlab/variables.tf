variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "credentials" {
  type = string
}

variable "subnetwork_cidr" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "source_image_family" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "instance_count" {
  type = number
}
