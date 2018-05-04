Kubernetes as a Service for on premise deployments (currently Openstack only tested)

# Functionalities

* Self hosted multi master Kubernetes clusters deployed with Bootkube
* Worker scale in/out through Terraform variables
* Kubernetes version updates through Terraform variables.Currently the Kubelet restarts are not synchronized
* CoreOS Container Linux hosts with automatic OS updates without K8S service interruption through the Container Linux Update Operator (CLUO)
* Addons with
  * Prometheus Operator
  * Pre-configured Kubernetes cluster monitoring
  * Kubernetes dashboard
  * NGINX ingress controller
  * Cinder storage class (for Openstack deployment)
  * Openstack LBaaS service type (for Openstack deployment)

Only compatible with Kubernetes up to v1.9.x

# Requirements

This service requires the following tools to be installed on the management environment
* terraform
* kubectl
* etcdctl


# Usage on Openstack

## Requirements

* Openstack components:
  * Nova for compute nodes
  * Neutron network with LBaaS
  * Designate: can be replaced by static IPs
  * Cinder for K8S storage class integration
* Internet access from your Openstack to download Kubernetes Hyperkube docker images


## Bootstrap

1. Ensure you have installed the required tools on the management environment
1. Source your Openstack rc file downloaded from Horizon webUI
2. Customize the flavors files in `scripts/flavors` to match your openstack context
3. Create a bootstrap cluster named `admin` that will be used to manage all the other clusters. The following rules are expected:
    1. The flavor name must match a TFVARS file `scripts/flavors/<FLAVOR>.tfvars`
    2. The WORKER_COUNT must be 3 at minimum to match anti affinity rules for the ETCD cluster that will store all OPKE clusters data
    3. The HOST_CIDR must be unique in your Openstack tenant

`>ENV=admin FLAVOR=<flavor_name> KUBERNETES_VERSION="v1.9.6" WORKER_COUNT=3 HOST_CIDR="192.168.200.0/24" ./scripts/run bootstrap`

5. Wait for the script to terminate
6. Get the ETCD external IP of the bootstrap cluster

`> kubectl --kubeconfig $HOME/kubeconfig -n=opke get svc opke-etcd-client-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`

## Clusters creation

1. You can now provision as many clusters as you want

`>ENV=<your_env_name> FLAVOR=<flavor_name> KUBERNETES_VERSION="v1.9.6" WORKER_COUNT=3 HOST_CIDR="192.168.201.0/24" ETCD_IP=<your_etcd_ip>./scripts/run create`

2. Get your kubeconfig file from ETCD

`>ETCDCTL_API=3 etcdctl --endpoints=http://<your_etcd_ip>:2379 get opke/<your_env_name>/kubeconfig --print-value-only=true | base64 --decode > <SOME_PATH>`


## Scale in/out

1. You can scale in or out the number of worker (but not the number of controller)

`>ENV=<your_env_name> WORKER_COUNT=4 ETCD_IP=<your_etcd_ip>./scripts/run scale`


## K8S version update

This version has only been tested with K8S v1.9.x

1. It's only safe to automatically upgrade Kubernetes within minor versions.

`>ENV=<your_env_name> KUBERNETES_VERSION="v1.9.7" ETCD_IP=<your_etcd_ip>./scripts/run upgrade`

# TODO

* Migrate to Kubernetes 1.10
* Use Secret for storing cloud provider config file (including Openstack password)
* Switch Kubelet to dynamic config to avoid any adherence with OS configuration and files

# Documentation

[Design](./docs/Design.md)