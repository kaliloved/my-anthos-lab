
//LINK: https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/v15.0.1

provider "google-beta" {
  credentials = file(var.credentials_file)
  project = var.project_id
  region  = var.region
  zone    = var.zones[0]
}

provider "google" {
  credentials = file(var.credentials_file)
  project = var.project_id
  region  = var.region
  zone    = var.zones[0]
}

# PROJECT DATA
data "google_client_config" "current" {}

data "google_project" "project" {
  project_id = var.project_id
}

output "project" {
  value = data.google_client_config.current.project
}
