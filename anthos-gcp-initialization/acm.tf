//# LINK: https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/acm

# Actually it don't work, maybe caused by new google's updates

module "acm" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm"
  for_each         = module.cluster
  project_id       = var.project_id
  cluster_name     = each.value.name
  location         = each.value.location
  cluster_endpoint = each.value.endpoint
  sync_repo        = var.acm_repo_location
  sync_branch      = var.acm_branch
  secret_type      = var.acm_secret_type
#  ssh_auth_key     = file(var.secret_path)
#  policy_dir       = var.acm_dir
#  create_ssh_key   = false
  enable_policy_controller = true
}
