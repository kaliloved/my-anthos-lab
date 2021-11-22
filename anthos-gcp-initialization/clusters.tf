# LINK: https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/5.0.0/submodules/beta-public-cluster
# LINK: https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/5.0.0/submodules/private-cluster

locals {
  cluster_info = {
    for i in range(length(var.clusters_info)):
      tostring(i) => {
	region = values(var.clusters_info)[i].region, 
	zones = values(var.clusters_info)[i].zones,
        name = values(var.clusters_info)[i].name,
        master_ip_range = values(var.clusters_info)[i].master_ip_range
      }
    }
}

module "cluster" {
  for_each                = local.cluster_info
  name                    = each.value.name
  project_id              = module.project-services.project_id
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  //source                  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"

  version                 = "17.0.0"
  regional                = true
  region                  = each.value.region
  network                 = var.vpc
  subnetwork              = var.subnet
  ip_range_pods           = ""
  ip_range_services       = ""
  enable_private_endpoint = true
  master_authorized_networks = [{"cidr_block" = "10.0.1.0/24", "display_name" = "proxy_vm"
				},
				{"cidr_block" = "34.88.13.127/32", "display_name" = "nat_europe_north_1"
				},
				{"cidr_block" = "34.107.73.210/32", "display_name" = "nat_europe_west3"
				}]
  master_ipv4_cidr_block  = each.value.master_ip_range
  enable_private_nodes    = false
  zones                   = each.value.zones
  release_channel         = "STABLE" #"REGULAR"
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  horizontal_pod_autoscaling = true
  add_master_webhook_firewall_rules = true
  firewall_inbound_ports = ["15017"]
  node_pools = [
    {
      name         = "default-node-pool-${each.value.name}"
      autoscaling  = false
      auto_upgrade = true
      image_type   = "COS"
      node_count   = 3
      machine_type = "e2-standard-4"
      master_authorized_networks_config = "10.0.1.0/24,34.88.13.127/32,34.107.73.210/32"
    }
  ]
}


/*
resource "kubernetes_namespace" "eks-config-management" {
  metadata {
    name = "config-management-system"
  }
}


resource "kubernetes_secret" "eks-acm-secret" {
  metadata {
    name = "git-creds"
    namespace = kubernetes_namespace.eks-config-management.id
  }

  data = {
    "ssh-privatekey" = file(var.gitlab_anthos.key)
  }


}*/
