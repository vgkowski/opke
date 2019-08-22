Kubernetes as a Service for Openstack

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


# TODO

* Secure the ETCD on bootstrap server
* Migrate to Kubernetes 1.10
* Use Secret for storing cloud provider config file (including Openstack password)
* Switch Kubelet to dynamic config to avoid any adherence with OS configuration and files

# Documentation

[Design](./docs/Design.md)

[Openstack usage](./docs/openstack.md)
