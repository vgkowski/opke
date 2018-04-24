#!/bin/bash

set -x
set -e

source ${DIR}/utils.sh

source ${DIR}/check.sh

[ ! -e "${DIR}/flavors/${FLAVOR}.tfvars" ] && error "$DIR/flavors/$FLAVOR.tfvars must exist"
mkdir -p ${ROOT_DIR}
echo "test $ROOT_DIR"

pushd ${ROOT_DIR}

# Remove local cached terraform.tfstate file. This is to avoid having a cached state file referencing another environment due to manual tests or wrong operations.
rm -f ${TFSTATE_FILE}
terraform remote config -backend=etcd --backend-config="key=$TFSTATE_KEY"

#terraform plan -input=false -var "env=$ENV" || error "terraform plan failed"

#terraform apply -input=false -var "env=$ENV" || error "terraform apply failed"

#ALL_INSTANCE_IDS=$(tf_get_all_instance_ids ${TFSTATE_FILE})
#aws ec2 wait instance-running --instance-ids ${ALL_INSTANCE_IDS} || error "some instances not active"

# Wait all instances are reachable via ssh
#ansible-playbook -i ${__root}/scripts/terraform_to_ansible_inventory.sh ${__ansible}/wait_instance_up.yml

# Wait for all the consul server being active. Check this using the first consul server.
#consul01ip=$(tf_get_instance_public_ip ${TFSTATE_FILE} "consul_server01")
#ansible-playbook -i ${consul01ip}, ${__ansible}/test_consul_servers_active.yml