Terraform automation to install Kubernetes  on premise (currently Openstack only tested)

# Functionalities

* Self hosted multi master Kubernetes clusters deployed with Bootkube
* Terraform apply Worker scale in/out
* CoreOS Container Linux hosts with automatic and synchronized OS updates through the Container Linux Update Operator (CLUO)
* Addons with
  * Prometheus Operator
  * Kubernetes cluster monitoring
  * Kubernetes dashboard
  * NGINX ingress controller
  * Cinder storage class (for Openstack deployment)

# Openstack requirements

* Openstack components:
  * Nova for compute nodes
  * Neutron network with LBaaS
  * Designate: can be replaced by static IPs
  * Cinder for K8S storage class integration
  * Swift
* Internet access from your Openstack to download Kubernetes Hyperkube docker images

# Creating K8S clusters on Openstack

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

# TODO

* Migrate to Kubernetes 1.10
* Use Secret for storing cloud provider config file (including Openstack password)
* Switch Kubelet to dynamic config to avoid any adherence with OS configuration and files