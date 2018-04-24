#!/bin/bash

set -x
set -e

source ${DIR}/utils.sh

source ${DIR}/check.sh

[ ! -e "${DIR}/flavors/${FLAVOR}.tfvars" ] && error "$DIR/flavors/$FLAVOR.tfvars must exist"
mkdir -p ${ROOT_DIR}

pushd ${ROOT_DIR}

# set the backend to "local" for bootstrapping OPKE
sed -i '/backend "etcdv3" {}/c\  #backend "etcdv3" {}' ${DIR}/../modules/openstack/require.tf

terraform init $ROOT_DIR/../../modules/openstack

terraform apply -auto-approve -var-file=${DIR}/flavors/${FLAVOR}.tfvars $ROOT_DIR/../../modules/openstack

# get the ETCD addon cluster external IP
ETCD_IP=$(kubectl --kubeconfig tmp/vg/assets/bootkube/assets/auth/kubeconfig -n=opke get svc opke-etcd-cluster-client-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# set the backend to "etcdv3" to migrate the state into the newly created ETCD cluster
sed -i '/#backend "etcdv3" {}/c\  backend "etcdv3" {}' ${DIR}/../modules/openstack/require.tf

# save the tfstate in the ETCD
terraform init -auto-approve -backend="true" -backend-config="lock=true" -backend-config="prefix=${TFSTATE_KEY}" -backend-config="endpoints=[\"${ETCD_IP}:2379\"]"

# save the kubeconfig in the ETCD
ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/kubeconfig $(cat ${ROOT_DIR}/assets/bootkube/assets/auth/kubeconfig)

# save the tfvars in ETCD
ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/tfvars $(cat ${DIR}/flavors/${FLAVOR}.tfvars)

# save the ssh key in ETCD
ETCDCTL_API=3 etcdctl --endpoints=http://$ETCD_IP:2379 put opke/${ENV}/ssh $(cat ${ROOT_DIR}/id_core_rsa)

# delete all local files
#rm -Rf $ROOT_DIR
