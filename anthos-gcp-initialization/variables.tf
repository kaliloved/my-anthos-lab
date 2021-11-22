variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "region" {
  description = "The primary region to be used"
}
variable "zones" {
  description = "The primary zones to be used"
}

variable "vpc" {
  description = "Name of used VPC"
}

variable "subnet" {
  description = "Name of used subnet"
}

# CONFIG SYNC
variable "acm_repo_location" {
  description = "The location of the git repo ACM will sync to"
  default = ""
}
variable "acm_branch" {
  description = "The git branch ACM will sync to"
  default = ""
}
variable "acm_dir" {
  description = "The directory in git ACM will sync to"
  default = ""
}

variable "acm_secret_type" {
  description = "git authentication secret type"
  default = ""
}

variable "secret_path" {
  description = "path for git secret key file"
  default = ""
}

variable "credentials_file" {
  default = ""
  description = "file with json key for auth"
}

variable "clusters_info" {
  type = map(object({
    region = string
    zones = list(string)
    name = string
    master_ip_range = string
  }))
  description = "list of names and master ip ranges for clusters"
}

