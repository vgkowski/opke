#!/bin/bash

set -e

function error() {
	echo "error: $1"
	exit 1
}


function with_backoff {
  local max_attempts=${ATTEMPTS-5}
  local timeout=${TIMEOUT-1}
  local attempt=1
  local exitCode=0

  while (( $attempt < $max_attempts ))
  do
    if "$@"
    then
      return 0
    else
      exitCode=$?
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "Exponential backoff failed! ($@)" 1>&2
  fi

  return $exitCode
}


function get_flavor() {
    printf "checking the FLAVOR..."
    [ -z ${FLAVOR} ] && error "missing FLAVOR environment variable"
    [ -f ${DIR}/flavors/${FLAVOR}.tfvars ] || error "${DIR}/flavors/${FLAVOR}.tfvars does not exist"
    cp ${DIR}/flavors/${FLAVOR}.tfvars ${ROOT_DIR}/${ENV}.tfvars
    export TFVARS="${ROOT_DIR}/${ENV}.tfvars"
    printf "    OK\n"
}

function get_kube_version() {
    printf "checking the KUBE_VERSION..."
    [ -z ${KUBE_VERSION} ] && error "missing KUBE_VERSION environment variable"
    sed -i '/kubernetes_version = /c\kubernetes_version = "'$KUBE_VERSION'"' ${TFVARS}
    printf "    OK\n"
}

function get_etcd() {
    printf "checking backend ETCD..."
    [ -z ${ETCD_IP} ] && error "missing ETCD_IP environment variable"
    with_backoff $(ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 member list >/dev/null 2>&1 || error "etcd server must be available")
    printf "    OK\n"
}

function get_workercount() {
    printf "checking WORKER_COUNT..."
    [ -z ${WORKER_COUNT} ] && error "missing WORKER_COUNT environment variable"
    sed -i '/worker_count = /c\worker_count = "'$WORKER_COUNT'"' ${TFVARS}
    printf "    OK\n"
}

function get_host_cidr() {
    printf "checking HOST_CIDR..."
    [ -z ${HOST_CIDR} ] && error "missing HOST_CIDR environment variable (ex: 10.1.0.0/16)"
    sed -i '/host_cidr = /c\host_cidr = "'$HOST_CIDR'"' ${TFVARS}
    printf "    OK\n"
}

function preflight_check() {
    printf "Preflights checks..."
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
    printf "    OK\n"
}

function prepare_workdir() {
    printf "Preparing workdir..."
    rm -Rf ${ROOT_DIR}
    mkdir -p ${ROOT_DIR}
    pushd ${ROOT_DIR} >/dev/null
    printf "    OK\n"
}

function clean_workdir() {
    printf "Cleaning workdir"
    rm -Rf ${ROOT_DIR}
    printf "    OK\n"
}

function set_local_backend() {
    printf "Setting local backend..."
    sed -i '/backend "etcdv3" {}/c\  #backend "etcdv3" {}' ${DIR}/../modules/openstack/require.tf
    printf "    OK\n"
}

function set_etcd_backend() {
    printf "Setting remote backend..."
    sed -i '/#backend "etcdv3" {}/c\  backend "etcdv3" {}' ${DIR}/../modules/openstack/require.tf
    printf "    OK\n"
}

function export_kubeconfig() {
    printf "exporting KUBECONFIG in ETCD backend...    "
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/kubeconfig "$(cat ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig | base64)"
}

function import_kubeconfig() {
    printf "importing KUBECONFIG from ETCD backend...    "
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 get opke/${ENV}/kubeconfig --print-value-only=true | base64 --decode >> kubeconfig
}

function export_tfvars() {
    printf "exporting TFVARS in ETCD backend...    "
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/tfvars "$(cat ${TFVARS} | base64)"
}

function import_tfvars() {
    printf "importing TFVARS from ETCD backend...    "
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 get opke/${ENV}/tfvars --print-value-only=true | base64 --decode >> ${ROOT_DIR}/${ENV}.tfvars
    export TFVARS=${ROOT_DIR}/${ENV}.tfvars
}

function export_ssh() {
    printf "exporting SSH keys in ETCD backend...    "
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/ssh "$(cat ${ROOT_DIR}/id_rsa_core | base64)"
}

function import_ssh() {
    printf "importing SSH keys from ETCD backend...    "
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 get opke/${ENV}/ssh --print-value-only=true | base64 --decode >> id_rsa_core
}

function init_local_terraform() {
    terraform init -var-file=${TFVARS} $ROOT_DIR/../../modules/openstack
}

function init_remote_terraform() {
    terraform init -var-file=${TFVARS} -force-copy -backend="true" -backend-config="lock=true" -backend-config="prefix=${TFSTATE_KEY}" -backend-config="endpoints=[\"${ETCD_IP}:2379\"]" ${ROOT_DIR}/../../modules/openstack
}

function apply_terraform() {
    terraform apply -auto-approve -var-file=${TFVARS} ${ROOT_DIR}/../../modules/openstack
}

function destroy_terraform() {
    terraform destroy -force -var-file=${TFVARS} ${ROOT_DIR}/../../modules/openstack
}

function pull_tfstate() {
    terraform state pull >> ${ROOT_DIR}/terraform.tfstate
}

function get_etcd_service() {
    printf "waiting for opke etcd service to be ready..."
    with_backoff $([ ! -z $(kubectl --kubeconfig ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig -n=opke get svc opke-etcd-client-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2> /dev/null) ] || exit 1)
    export ETCD_IP=$(kubectl --kubeconfig ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig -n=opke get svc opke-etcd-client-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    printf "    OK\n"
}

function clean_K8S_services() {
    printf "Cleaning K8S external services"
    NAMESPACES=$(kubectl --kubeconfig ${ROOT_DIR}/kubeconfig get namespaces | grep -v 'kube-system\|kube-public\|default\|NAME' | awk '{print $1}' | xargs)
    [ -z "$NAMESPACES" ] || kubectl --kubeconfig ${ROOT_DIR}/kubeconfig delete namespaces $NAMESPACES
    ATTEMPTS=6 with_backoff $([ -z $(kubectl --kubeconfig ${ROOT_DIR}/kubeconfig get namespaces | grep -v 'kube-system\|kube-public\|default\|NAME' | awk '{print $1}' | xargs) ] || exit 1)
    printf "    OK\n"
}








function tf_get_instance_id() {
	local tfstatefile=${1}
	local instance=${2}
	local id
	id=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".primary.id')
	if [ $? -ne 0 ]; then
		# if someone has tainted the resource try with tainted instead of primary
		id=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".tainted[0].id')
		if [ $? -ne 0 ]; then
			echo ""
			return
		fi
	fi
	echo $id
}

function tf_get_instance_public_ip() {
	local tfstatefile=${1}
	local instance=${2}
	local ip
	ip=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".primary.attributes.public_ip')
	if [ $? -ne 0 ]; then
		# if someone has tainted the resource try with tainted instead of primary
		ip=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".tainted[0].attributes.public_ip')
		if [ $? -ne 0 ]; then
			echo ""
			return
		fi
	fi
	echo $ip
}

function tf_get_all_instance_ids() {
	local tfstatefile=${1}
	local ids
	ids=$(cat ${tfstatefile} | jq -c -e -r -M '.modules[0].resources | to_entries | map(select(.key | test("aws_instance\\..*"))) | map(.value.primary.id)')
	if [ $? -ne 0 ]; then
		echo ""
		return
	fi
	echo $ids
}

function tf_get_all_instance_public_ips() {
	local tfstatefile=${1}
	local ids
	ids=$(cat ${tfstatefile} | jq -c -e -r -M '.modules[0].resources | to_entries | map(select(.key | test("aws_instance\\..*"))) | map(.value.primary.attributes.public_ip)')
	if [ $? -ne 0 ]; then
		echo ""
		return
	fi
	echo $ids
}
