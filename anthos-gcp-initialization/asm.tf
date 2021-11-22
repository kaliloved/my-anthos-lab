#LINK: https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/asm

module "asm" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version             = "17.0.0"
  project_id          = var.project_id
  for_each            = module.cluster
  cluster_name        = each.value.name #module.cluster.name
  location            = each.value.location #module.cluster.location
  cluster_endpoint    = each.value.endpoint #module.cluster.endpoint
  enable_registration = true
  enable_all          = true
  asm_version      = "1.10"
}
