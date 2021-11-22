# LINK: https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/v15.0.1/modules/hub

//module "hub" {
//  source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"
//  project_id       = var.project_id
//  for_each            = module.cluster
//  cluster_name        = each.value.name #module.cluster.name
//  location            = each.value.location #module.cluster.location
//  cluster_endpoint    = each.value.endpoint #module.cluster.endpoint
//  gke_hub_membership_name = "${each.value.name}-connect"
//  // If you want to create a SA
//  gke_hub_sa_name = "${each.value.name}-connect"
//}