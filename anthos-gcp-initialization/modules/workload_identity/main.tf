# provider "google-beta" {
#   credentials = file(var.credentials_file)
#   project = var.project_id
#   region  = var.region
#   zone    = var.zones[0]
# }

# provider "google" {
#   credentials = file(var.credentials_file)
#   project = var.project_id
#   region  = var.region
#   zone    = var.zones[0]
# }

provider "kubernetes" {
  config_path    = var.kube_config
  # config_context = var.context
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = var.namespace
  }
}

module "my-app-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_k8s_sa = true
  name       = var.k8s_svc_name
  namespace  = kubernetes_namespace.example.metadata[0].name
  project_id = var.project_id
  roles      = var.roles
}