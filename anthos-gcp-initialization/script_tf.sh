#!/bin/bash

## COSTANTS

# START COMMANDS
INIT=0                                              # if 0 do init else if 1 skip
DESTROY=0                                           # if 0 don't destroy else if 1 do terraform destroy
APPLY=0                                             # if 0 apply with separate modules else if 1 terraform apply command

# CONFIG FILE
CONFIG_FILE="../script.conf"

## KEYS
#KEY_PATH="../../creds/anthos_sa_key.json"           # Path of the Service Account for Terraform credentials
#GIT_KEY_PATH="../../creds/ssh-git/key_git"          # Path of the git credentials

## PROJECT INFORMATIONS
#PROJECT="anthos-lab-310709"                         # Project ID
#REGION="europe-west3"                               # Project Region
#SA="anthos-lab-310709.iam.gserviceaccount.com"      # Service account for terraform

## SCRIPT INITIALIZATION
function base_function ()
{
    while [ $# -gt 0 ]; # if params are passed
    do
      key=$1

      case $key in
        --skip-init|-s) # skip terraform init command
            INIT=1
            shift # past argument
            shift # past value
            ;;
        --destroy|-d) # terraform destroy
            DESTROY=1
            shift
            shift
            ;;
        --apply|-a) # terraform apply
            APPLY=1
            shift
            shift
            ;;
        --apply-skip|-as) # terraform apply and terraform init skip
            APPLY=1
            INIT=1
            shift
            shift
            ;;
      esac
      shift
    done
}


## FUNCTIONS

# If the config file not exist print a ERROR and exit
function check_config ()
{
    if ! test -r "$CONFIG_FILE"
    then
        echo "ERROR: File not readable '$CONFIG_FILE'"
        exit 1;
    fi
}

function print_help ()
{
    echo 'This script rcreate clusters on gke, install service mash, create membership and secret for config management'
}

# CHECK TERRAFORM INSTALLATION
function terraform_check ()
{
  echo "Check Terraform version"
  T_VER=$(eval "terraform --version")
  if [[ $T_VER == *"Terraform v"* ]]; then
    echo "$T_VER"
  else
    echo "Terraform not Installed, install it before start script";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi

  if [ "$?" -ne 0 ]; then
    echo "ERROR: Terraform Check FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# GCLOUD LOGIN
function gcloud_login ()
{
  echo "gcloud login with terraform service account"
  eval "gcloud auth activate-service-account terrafom-connector@$SA --key-file=$KEY_PATH --project=$PROJECT 2> error.txt"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: gcloud login FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# TERRAFORM INITIALIZATION
function terraform_init ()
{
  if [ $INIT -eq 0 ]; then
    echo "Terraform initialization"
    eval "terraform init 2> error.txt"
    if [ "$?" -ne 0 ]; then
      echo "ERROR: init command FAILED!";
      cat error.txt;
      # your termination logic here
      exit 1;
    fi
  else
    echo "Terraform init skipped..."
  fi
}

# TERRAFORM APPLY ALL
function terraform_apply ()
{
  echo "Terraform initialization"
  eval "terraform apply --auto-approve 2> error.txt"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: apply command FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# TERRAFORM DESTROY ALL
function terraform_destroy ()
{
  echo "Terraform Destroy started"
  eval "terraform destroy --auto-approve 2> error.txt"

  CLUSTERS_NAME=$(eval "terraform output cluster-name")
  CLUSTERS_NAME=${CLUSTERS_NAME//[/(}
  CLUSTERS_NAME=${CLUSTERS_NAME//]/)}
  CLUSTERS_NAME=${CLUSTERS_NAME//,/}
  declare -a CLUSTERS_NAME=${CLUSTERS_NAME}
  echo ${CLUSTERS_NAME}

  echo "Remove all clusters memberships:"
  for t in "${CLUSTERS_NAME[@]}"
  do
    echo "Remove cluster $t-$PROJECT-$REGION membership"
    eval "gcloud container hub memberships delete $t-$PROJECT-$REGION --quiet 2>> error.txt"
  done

  if [ "$?" -ne 0 ]; then
        echo "ERROR: destroy command FAILED!";
        cat error.txt;
        exit 1;
  fi
}

# CLUSTER CREATION
function cluster_creation ()
{
  echo "Cluster creation"
  eval "terraform apply -target=module.cluster --auto-approve 2> error.txt"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Cluster creation command FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# CLUSTER REGISTRATION
function cluster_registration ()
{
  echo "Starting Cluster membership registration"
  eval "terraform apply -target=module.hub --auto-approve 2> error.txt"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Anthos Cluster membership registration FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# ASM CONFIGURATION
function asm_configuration ()
{
  echo "Anthos Service Mesh configuration"
  eval "terraform apply -target=module.asm -parallelism=1 --auto-approve 2> error.txt"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Anthos Service Mesh configuration FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# GIT CREDENTIAL CREATION
function git_secret_creation ()
{
  echo "Secret creation for git repository synchronization"
  CLUSTERS_NAME=$(eval "terraform output cluster-name")
  CLUSTERS_NAME=${CLUSTERS_NAME//[/(}
  CLUSTERS_NAME=${CLUSTERS_NAME//]/)}
  CLUSTERS_NAME=${CLUSTERS_NAME//,/}
  declare -a CLUSTERS_NAME=${CLUSTERS_NAME}
  echo ${CLUSTERS_NAME}

  for t in "${CLUSTERS_NAME[@]}"
  do
    echo "Create secret for cluster $t"
    eval "gcloud container clusters get-credentials $t --region $REGION --project $PROJECT 2>> error.txt"
    # Check if exist the namespace before run the next command!!!
    eval "kubectl create ns config-management-system 2>> error.txt"
    eval "kubectl create secret generic git-creds --namespace=config-management-system --from-file=ssh=$GIT_KEY_PATH 2>> error.txt"
  done
  if [ "$?" -ne 0 ]; then
    echo "ERROR: secret creation FAILED!";
    cat error.txt;
    # your termination logic here
#    exit 1;
  fi
}

# ACM CONFIGURATION
function acm_configuration ()
{
  echo "Anthos Config Management configuration"
  eval "terraform apply -target=module.acm --auto-approve 2> error.txt"
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Anthos Config Management configuration FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

# WORKLOAD_IDENTITY
function wl_configuration ()
{
  echo "Make a workload_identity"
#  eval "terraform apply -target=module.workload_identity --auto-approve 2> error.txt"
  eval "gcloud iam service-accounts add-iam-policy-binding --role roles/iam.workloadIdentityUser --member \"serviceAccount:$PROJECT.svc.id.goog[config-management-system/root-reconciler]\" $WL_SA@$PROJECT.iam.gserviceaccount.com 2> error.txt"

  if [ "$?" -ne 0 ]; then
    echo "ERROR: workload_identity configuration FAILED!";
    cat error.txt;
    # your termination logic here
    exit 1;
  fi
}

## START ALL FUNCTIONS
# Check all inputs and sets constants
base_function $*
source "$CONFIG_FILE"

# Initial Checks
terraform_check

# Check if you are destroying or creating services
if [ $DESTROY -eq 0 ]; then
  # Do gcloud auth for terraform SA
  gcloud_login
  # Do terraform init
  terraform_init
  if [ $APPLY -eq 0 ]; then
    # Do clusters creation
    cluster_creation
    # Install asm on clusters
    asm_configuration
    # Cluster registration (actually integrated in asm)
    # cluster_registration
    # Install acm on clusters
    acm_configuration
    # Set workload identity after acm
    #wl_configuration
  else
    # If -a apply normally
    terraform_apply
    # Set workload identity after config management
    #wl_configuration
  fi
  # Secret creation (git key)
  git_secret_creation
else
  # If necessary destroy all
  terraform_destroy
fi
