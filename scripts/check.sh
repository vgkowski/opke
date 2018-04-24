#!/bin/bash

set -x
set -e

[ -z ${ENV} ] && error "missing ENV environment variable"
[ -z ${OS_USERNAME} ] && error "missing OS_USERNAME environment variable"
[ -z ${OS_PASSWORD} ] && error "missing OS_PASSWORD environment variable"
[ -z ${OS_AUTH_URL} ] && error "missing OS_AUTH_URL environment variable"
[ -z ${OS_PROJECT_ID} ] && error "missing OS_PROJECT_ID environment variable"
[ -z ${OS_USER_DOMAIN_NAME} ] && error "missing OS_USER_DOMAIN_NAME environment variable"

export TF_VAR_openstack_username=${OS_USERNAME}
export TF_VAR_openstack_password=${OS_PASSWORD}
export TF_VAR_openstack_auth_url=${OS_AUTH_URL}
export TF_VAR_openstack_tenant_id=${OS_PROJECT_ID}
export TF_VAR_openstack_domain_name=${OS_USER_DOMAIN_NAME}
export TF_VAR_cluster_name=${ENV}
export TFSTATE_KEY="opke/${ENV}/terraform"
export TFSTATE_FILE="${ROOT_DIR}/.terraform/terraform.tfstate"

command -v terraform >/dev/null 2>&1 || { echo >&2 "terraform is required but not installed.  Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo >&2 "kubectl is required but not installed.  Aborting."; exit 1; }
command -v etcdctl >/dev/null 2>&1 || { echo >&2 "etcdctl is required but not installed.  Aborting."; exit 1; }
