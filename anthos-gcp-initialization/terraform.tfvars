credentials_file    = "../../Certs/SA_Anthos.json"

# CLUSTER & PROJECT
project_id          = "anthos-lab-310709"
region              = "europe-west3"
zones               = ["europe-west3-c"]
vpc                 = "default"
subnet              = "default"
clusters_info       = {
                        "1" = {
			  region = "europe-west3"
			  zones = ["europe-west3-c"]
                          name = "gke-anthos-west",
                          master_ip_range = "172.16.0.0/28"
			  	
                        },
                        "2" = {
			  region = "europe-north1"
			  zones = ["europe-north1-a"]
                          name = "gke-anthos-north",
                          master_ip_range = "172.16.1.0/28"
                        }
			"3" = {
			  region = "europe-west1"
			  zones = ["europe-west1-b"]
			  name = "gke-ingress"
			  master_ip_range = "172.16.2.0/28"
			}
                      }

# CONFIG SYNC
acm_repo_location   = "git@github.com:Francesco-cloud24/anthos-lab.git"
acm_branch          = "master"
acm_dir             = "/anthos-hrp"
acm_secret_type     = "ssh"
secret_path         = "../../Certs/gitlab_anthos.key"



