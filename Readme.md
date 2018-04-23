Terraform automation to manage Kubernetes clusters on premise (currently Openstack only tested)

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

# Openstack requirements

* Openstack components:
  * Nova for compute nodes
  * Neutron network with LBaaS
  * Designate: can be replaced by static IPs
  * Cinder for K8S storage class integration
* Internet access from your Openstack to download Kubernetes Hyperkube docker images

# Usage on Openstack

## Creation

1. Ensure you meet all the requirements
1. Source your Openstack rc file downloaded from Horizon webUI
2. Copy the `env/example` directory to `env/<YOUR_ENV_NAME>`
3. Go in `env/<YOUR_ENV_NAME>` and change variables according to your openstack context and disared options
4. Initialize Terraform with `terraform init ../../openstack`
5. Run the terraform with

`TF_VAR_openstack_username=$OS_USERNAME \`

`TF_VAR_openstack_password=$OS_PASSWORD \`

`TF_VAR_openstack_auth_url=$OS_AUTH_URL \`

`TF_VAR_openstack_tenant_id=$OS_PROJECT_ID \`

`TF_VAR_openstack_domain_name=$OS_USER_DOMAIN_NAME \`

`terraform apply ../../openstack/`

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