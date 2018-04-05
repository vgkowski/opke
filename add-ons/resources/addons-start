#!/bin/bash

set -e

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 kubeconfig assets_path"
    exit 1
fi

KUBECONFIG="$1"
ASSETS_PATH="$2"

# Setup API Authentication
KUBECTL="/opt/bin/kubectl --kubeconfig=$KUBECONFIG"

# Setup helper functions

kubectl() {
  i=0

  echo "Executing kubectl" "$@"
  while true; do
    i=$((i+1))
    [ $i -eq 100 ] && echo "kubectl failed, giving up" && exit 1

    set +e
    out=$($KUBECTL "$@" 2>&1)
    status=$?
    set -e

    if echo "$out" | grep -q "AlreadyExists"; then
      echo "$out, skipping"
      return
    fi

    echo "$out"
    if [ "$status" -eq 0 ]; then
      return
    fi

    echo "kubectl failed, retrying in 5 seconds"
    sleep 5
  done
}

wait_for_crd() {
  set +e
  i=0

  echo "Waiting for CRD $2"
  until $KUBECTL -n "$1" get customresourcedefinitions "$2"; do
    i=$((i+1))
    echo "CRD $2 not available yet, retrying in 5 seconds ($i)"
    sleep 5
  done
  set -e
}

wait_for_nodes() {
  set +e
  echo "Waiting for nodes $1"
  while true; do
    RUNNING=1
    for i in $1
    do
      out=$($KUBECTL get nodes $i -o custom-columns=STATUS:.status.conditions[3].status)
      stat=$(echo "$out"| grep -v '^True')
      if [ -z "$stat" ]; then
        echo "Node not available yet, waiting for 5 seconds"
        RUNNING=0
        break
      fi
    done
    if [ $RUNNING = 0 ]; then
      sleep 5
      continue
    else
      return
    fi
  done
  set -e
}

wait_for_pods() {
  set +e
  echo "Waiting for pods in namespace $1"
  while true; do

    out=$($KUBECTL -n "$1" get po -o custom-columns=STATUS:.status.phase,NAME:.metadata.name)
    status=$?
    echo "$out"

    if [ "$status" -ne "0" ]; then
      echo "kubectl command failed, retrying in 5 seconds"
      sleep 5
      continue
    fi

    # make sure kubectl does not return "no resources found"
    if [ "$(echo "$out" | tail -n +2 | grep -c '^')" -eq 0 ]; then
      echo "no resources were found, retrying in 5 seconds"
      sleep 5
      continue
    fi

    stat=$(echo "$out"| tail -n +2 | grep -v '^Running')
    if [ -z "$stat" ]; then
      return
    fi

    echo "Pods not available yet, waiting for 5 seconds"
    sleep 5
  done
  set -e
}

# chdir into the assets path directory
cd "$ASSETS_PATH"

# Wait for Kubernetes to be in a proper state
set +e
i=0
echo "Waiting for Kubernetes API..."
until $KUBECTL cluster-info; do
  i=$((i+1))
  echo "Cluster not available yet, waiting for 5 seconds ($i)"
  sleep 5
done
set -e

# wait for Kubernetes pods
wait_for_pods kube-system
echo "Creating storage class"
$KUBECTL apply -f storage-class/cinder.yaml

# Creating resources
echo "Creating ingress resources"
$KUBECTL apply -f ingress/ingress-rbac.yaml
$KUBECTL apply -f ingress/default-backend.yaml
$KUBECTL apply -f ingress/ingress-controller.yaml
echo "Creating dashboard app"
$KUBECTL apply -f kube-dashboard/kube-dashboard.yaml

echo "Kube-apps installation is done"
exit 0
