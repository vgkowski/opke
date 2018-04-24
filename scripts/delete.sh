#!/bin/bash

set -x
set -e

source ${DIR}/utils.sh

source ${DIR}/check.sh

kubectl --kubeconfig assets/bootkube/assets/auth/kubeconfig get svc --all-namespaces -o json | jq ".items[] | select(.status.loadBalancer.ingress[0].ip != null) | .metadata.name"
