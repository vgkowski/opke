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


## Creation

1. Ensure you have installed the required tools on the management environment
1. Source your Openstack rc file downloaded from Horizon webUI
2. Customize the flavors files in `scripts/flavors` to match your openstack context
3. Create a bootstrap cluster named `admin` that will be used to manage all the other clusters

`>ENV=admin ./scripts/run bootstrap <flavor>`

5. Wait for the script to terminate
6. You can now provision as many clusters as you want
`>ENV=<cluster_name> ./scripts/run create <flavor>`


## Scale in/out

1. Change the `worker_count` parameter in your configuration file
2. Reapply the Terraform

## K8S version update

This version has only been tested with K8S v1.9.x

It's only safe to automatically upgrade Kubernetes within minor versions.

1. Change the `kubernetes_version` parameter in your configuration file
2. Reapply the Terraform

# TODO

* Migrate to Kubernetes 1.10
* Use Secret for storing cloud provider config file (including Openstack password)
* Switch Kubelet to dynamic config to avoid any adherence with OS configuration and files

# Documentation

[Design](./docs/Design.md)