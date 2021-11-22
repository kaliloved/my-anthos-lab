variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "region" {
  description = "The primary region to be used"
  type = string
  default = "europe-west3"
}

variable "zones" {
  description = "The primary zones to be used"
  type = list(string)
  default = ["europe-west3-c"]
}

variable "credentials_file" {
  type = string
  default = "../../creds/anthos_sa_key.json"
  description = "file with json key for auth"
}

variable "kube_config" {
  description = "path of the kube config file"
  type = string
  default  = "~/.kube/config"
}

# variable "context" {
#   description = "cluster context"
# }

variable "roles" {
  description = "List of roles for workload identity"
  type = list(string)
  default = []
}

variable "namespace" {
  description = "name of the new namespace to create"
  type = string
  default  = "config-management-system"
}

variable "k8s_svc_name" {
  description = "name of the service account in k8s"
  type = string
  default  = "root-reconciler"
}

