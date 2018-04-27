#!/bin/bash

set -e
set -x

function error() {
	echo "error: $1"
	exit 1
}

function get_flavor() {
    [ -z ${FLAVOR} ] && error "missing FLAVOR environment variable"
    export TFVARS="${DIR}/flavors/${FLAVOR}.tfvars"
    [ -f ${TFVARS} ] || error "${TFVARS} does not exist"
}

function get_etcd() {
    [ -z ${ETCD_IP} ] && error "missing ETCD_IP environment variable"
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 member list >/dev/null 2>&1 || error "etcd server must be available"
}

function get_workercount() {
    [ -z ${WORKER_COUNT} ] && error "missing WORKER_COUNT environment variable"
    sed -i '/worker_count = /c\worker_count = "'$WORKER_COUNT'"' ${TFVARS}
}

function prefligth_check() {
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
}

function prepare_workdir() {
    rm -Rf ${ROOT_DIR}
    mkdir -p ${ROOT_DIR}
    pushd ${ROOT_DIR}
}

function clean_workdir() {
    #rm -Rf ${ROOT_DIR}
    sleep 1
}

function set_local_backend() {
    sed -i '/backend "etcdv3" {}/c\  #backend "etcdv3" {}' ${DIR}/../modules/openstack/require.tf
}

function set_etcd_backend() {
    sed -i '/#backend "etcdv3" {}/c\  backend "etcdv3" {}' ${DIR}/../modules/openstack/require.tf
    cp ${ROOT_DIR}/terraform.tfstate ${ROOT_DIR}/../
    cp ${ROOT_DIR}/id_rsa_core ${ROOT_DIR}/../
    cp ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig ${ROOT_DIR}/../
}

function export_kubeconfig() {
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/kubeconfig "$(cat ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig | base64)"
}

function import_kubeconfig() {
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 get opke/${ENV}/kubeconfig --print-value-only=true | base64 --decode >> kubeconfig
}

function export_tfvars() {
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/tfvars "$(cat ${TFVARS} | base64)"
}

function import_tfvars() {
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 get opke/${ENV}/tfvars --print-value-only=true | base64 --decode >> ${ROOT_DIR}/${ENV}.tfvars
    export TFVARS=${ROOT_DIR}/${ENV}.tfvars
}

function export_ssh() {
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/ssh "$(cat ${ROOT_DIR}/id_rsa_core | base64)"
}

function import_ssh() {
    ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 get opke/${ENV}/ssh --print-value-only=true | base64 --decode >> id_rsa_core
}

function init_local_terraform() {
    terraform init -var-file=${TFVARS} $ROOT_DIR/../../modules/openstack
}

function init_remote_terraform() {
    terraform init -var-file=${TFVARS} -force-copy -backend="true" -backend-config="lock=true" -backend-config="prefix=${TFSTATE_KEY}" -backend-config="endpoints=[\"${ETCD_IP}:2379\"]" ${ROOT_DIR}/../../modules/openstack
}

function apply_terraform() {
    terraform apply -auto-approve -var-file=${TFVARS} $ROOT_DIR/../../modules/openstack
}

function destroy_terraform() {
    terraform destroy -force
}

function pull_tfstate() {
    terraform state pull >> ${ROOT_DIR}/terraform.tfstate
}

function get_etcd_service() {
    until [ ! -z $(kubectl --kubeconfig ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig -n=opke get svc opke-etcd-client-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2> /dev/null) ]; do sleep 1; printf "."; done
    export ETCD_IP=$(kubectl --kubeconfig ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig -n=opke get svc opke-etcd-client-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
}

function clean_K8S_services() {
    kubectl --kubeconfig ${ROOT_DIR}/kubeconfig delete --all namespaces
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
