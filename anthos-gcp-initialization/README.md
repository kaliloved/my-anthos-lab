# Anthos LAB Terraform

This module is responsible for creating an entire environment for anthos, with a configured cluster, a membership and a config sync

### Modules used:
- GKE
- ACM
- HUB
- ASM
- ...

## Example
```hcl
module "" {
## General Variables

}
```

## Compatibility

This module is meant for use with Terraform 0.15. If you haven't [upgraded](https://www.terraform.io/upgrade-guides/0-15.html) 
and need a Terraform 0.11.x-compatible version of this module, the last released version intended for Terraform 0.11.x
is [0.1.0](https://registry.terraform.io/modules/terraform-google-modules/event-function/google/0.1.0).


## Usage

Before the terraform apply we have gcloud commands to execute:
- Run terminal as Administrator
- gcloud components update
- gcloud components install kubectl
- gcloud components install alpha
- install kpt (https://cloud.google.com/service-mesh/docs/environment-setup#use-linux & https://cloud.google.com/architecture/managing-cloud-infrastructure-using-kpt#applying_a_kpt_package)
- sudo apt-get install jq
- gcloud auth activate-service-account terrafom-connector@anthos-lab-310709.iam.gserviceaccount.com --key-file=../creds/anthos_sa_key.json --project=anthos-lab-310709

Then is possible to do:
- terraform init
- terraform plan
- terraform apply

Or:
- terraform init && terraform apply --auto-approve

And at the end
- terraform destroy --auto-approve

__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__NO__

## Terraform Created Source Files

If you have `local_file` Terraform resources that need to be included in the function's archive include them in the optional `source_dependent_files`.

This will tell the module to wait until those files exist before creating the archive.

Example can also be seen in `examples/dynamic-files`

```hcl
resource "local_file" "file" {
  content  = "some content"
  filename = "${path.module}/function_source/terraform_created_file.txt"
}

module "localhost_function" {
  ...

  source_dependent_files = [local_file.file]
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| zone | The zone in which resources will be applied. | string | `"europe-west3"` | yes |
| func\_bucket\_name | The name to apply to the bucket. Will default to a string of the function name. | string | `"atlas-mongodb-log-cloud-function"` | no |
| func\_entry\_point | The name of a method in the function source which will be invoked when the function is executed. | string | n/a | yes |
| func\_name | The name to apply to any nameable resources. | string | n/a | yes |
| project\_id | The ID of the project to which resources will be applied. | string | `""` | yes |
| region | The region in which resources will be applied. | string | `"europe-west3"` | yes |
| func\_runtime | The runtime in which the function will be executed. | string | n/a | yes |
| func\_timeout\_s | The amount of time in seconds allotted for the execution of the function. | number | `"60"` | no |
| gcs\_prefix | Prefix used to generate the bucket name. | string | `""` | no |
| gsj\_job\_name | The name of the scheduled job to run | string | `"http-scheduler"` | no |
| gsj\_job\_schedule | The job frequency, in cron syntax | string | `"*/2 * * * *"` | no |
| gsj\_region | The region in which resources will be applied. | string | `"europe-west3"` | yes |
| gsj\_time\_zone | The timezone to use in scheduler | string | `"Etc/UTC"` | no |
| sm\_secrets | List of secrets to manage, their locations, enable and data. | list(object({secret_name = string location = list(string) secret_enable = bool secret_data = string})) | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| service-account | The email of the Service Account created. |
| secret-manager | Secret resources. |
| scheduler | List with the name of the job created and the Cloud Scheduler job instance |
| cloud-function | List with URL which triggers function execution. Returned only if trigger_http is used. and the name of the function. |
| bucket | List of bucket resource and Bucket name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

The following sections describe the requirements which must be met in
order to invoke this module.

### Software Dependencies

The following software dependencies must be installed on the system
from which this module will be invoked:

- [Terraform][terraform-site] v0.15
- [Terraform Provider for Archive][terraform-provider-archive-site]
  v1.2
- [Terraform Provider for Google Cloud Platform][terraform-provider-gcp-site] v2.5

### IAM Roles

The Service Account which will be used to invoke this module is automatically created with
the following IAM roles:

- roles/cloudfunctions.invoker
- roles/secretmanager.secretAccessor 
- roles/storage.objectCreator
- roles/storage.objectViewer

### APIs

The project against which this module will be invoked must have the
following APIs enabled:

- Cloud Functions API: `cloudfunctions.googleapis.com`
- Cloud Storage API: `storage-component.googleapis.com`
- Cloud Secret Manager API: `secretmanager.googleapis.com`

The [Project Factory module][project-factory-module-site] can be used to
provision projects with specific APIs activated.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[automatic-labelling-from-localhost-example]: examples/automatic-labelling-from-localhost
[event-project-log-entry-submodule]: modules/event-project-log-entry
[repository-function-submodule]: modules/repository-function
[project-factory-module-site]: https://github.com/terraform-google-modules/terraform-google-project-factory/
[terraform-provider-gcp-site]: https://github.com/terraform-providers/terraform-provider-google/
[terraform-site]: https://www.terraform.io/
