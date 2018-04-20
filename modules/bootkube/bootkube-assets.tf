data "template_file" "cloud_config_opts" {
  template = "${format("\n        - --cloud-config=%s",var.cloud_config)}"
}

data "template_file" "cloud_config_volume_mount" {
  template = "${format("\n        - name: cloud-config\n          mountPath: %s\n          readOnly: true",var.cloud_config)}"
}

data "template_file" "cloud_config_volume" {
  template = "${format("\n      - name: cloud-config\n        hostPath:\n          path: %s",var.cloud_config)}"
}

# Self-hosted Kubernetes bootstrap-manifests
resource "template_dir" "bootstrap-manifests" {
  source_dir      = "${path.module}/resources/bootstrap-manifests"
  destination_dir = "${var.asset_dir}/bootkube/assets/bootstrap-manifests"

  vars {
    hyperkube_image   = "${var.container_images["hyperkube"]}"
    hyperkube_version = "${var.versions["hyperkube"]}"
    etcd_servers      = "${join(",", formatlist("https://%s:2379", var.etcd_servers))}"

    pod_cidr                  = "${var.pod_cidr}"
    service_cidr              = "${var.service_cidr}"
  }
}

# Self-hosted Kubernetes manifests
resource "template_dir" "manifests" {
  source_dir      = "${path.module}/resources/manifests"
  destination_dir = "${var.asset_dir}/bootkube/assets/manifests"

  vars {
    hyperkube_image          = "${var.container_images["hyperkube"]}"
    hyperkube_version        = "${var.versions["hyperkube"]}"
    pod_checkpointer_image   = "${var.container_images["pod_checkpointer"]}"
    pod_checkpointer_version = "${var.versions["pod_checkpointer"]}"
    kubedns_image            = "${var.container_images["kubedns"]}"
    kubedns_version          = "${var.versions["kubedns"]}"
    kubedns_dnsmasq_image    = "${var.container_images["kubedns_dnsmasq"]}"
    kubedns_dnsmasq_version  = "${var.versions["kubedns_dnsmasq"]}"
    kubedns_sidecar_image    = "${var.container_images["kubedns_sidecar"]}"
    kubedns_sidecar_version  = "${var.versions["kubedns_sidecar"]}"

    etcd_servers = "${join(",", formatlist("https://%s:2379", var.etcd_servers))}"

    cloud_provider      = "${var.cloud_provider}"
    cloud_config_opts   = "${var.cloud_provider == "openstack" ? data.template_file.cloud_config_opts.rendered : "" }"
    cloud_config_mount  = "${var.cloud_provider == "openstack" ? data.template_file.cloud_config_volume_mount.rendered : "" }"
    cloud_config_volume = "${var.cloud_provider == "openstack" ? data.template_file.cloud_config_volume.rendered : "" }"

    pod_cidr              = "${var.pod_cidr}"
    service_cidr          = "${var.service_cidr}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
    kube_dns_service_ip   = "${cidrhost(var.service_cidr, 10)}"

    ca_cert            = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
    server             = "${format("https://%s:443", element(var.api_servers, 0))}"
    apiserver_key      = "${base64encode(tls_private_key.apiserver.private_key_pem)}"
    apiserver_cert     = "${base64encode(tls_locally_signed_cert.apiserver.cert_pem)}"
    serviceaccount_pub = "${base64encode(tls_private_key.service-account.public_key_pem)}"
    serviceaccount_key = "${base64encode(tls_private_key.service-account.private_key_pem)}"

    etcd_ca_cert     = "${base64encode(var.etcd_ca)}"
    etcd_client_cert = "${base64encode(var.etcd_client_cert)}"
    etcd_client_key  = "${base64encode(var.etcd_client_key)}"
  }
}

# Generated kubeconfig
resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.asset_dir}/bootkube/assets/auth/kubeconfig"
}

# Generated kubeconfig with user-context
resource "local_file" "user-kubeconfig" {
  content  = "${data.template_file.user-kubeconfig.rendered}"
  filename = "${var.asset_dir}/bootkube/assets/auth/${var.cluster_name}-config"
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig")}"

  vars {
    ca_cert      = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
    kubelet_cert = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}"
    kubelet_key  = "${base64encode(tls_private_key.kubelet.private_key_pem)}"
    server       = "${format("https://%s:443", element(var.api_servers, 0))}"
  }
}

data "template_file" "user-kubeconfig" {
  template = "${file("${path.module}/resources/user-kubeconfig")}"

  vars {
    name         = "${var.cluster_name}"
    ca_cert      = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
    kubelet_cert = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}"
    kubelet_key  = "${base64encode(tls_private_key.kubelet.private_key_pem)}"
    server       = "${format("https://%s:443", element(var.api_servers, 0))}"
  }
}


resource "template_dir" "flannel-manifests" {
  count           = "${var.networking == "flannel" ? 1 : 0}"
  source_dir      = "${path.module}/resources/flannel"
  destination_dir = "${var.asset_dir}/bootkube/assets/manifests-networking"

  vars {
    flannel_image       = "${var.container_images["flannel"]}"
    flannel_version     = "${var.versions["flannel"]}"
    flannel_cni_image   = "${var.container_images["flannel_cni"]}"
    flannel_cni_version = "${var.versions["flannel_cni"]}"

    pod_cidr = "${var.pod_cidr}"
  }
}

resource "template_dir" "calico-manifests" {
  count           = "${var.networking == "calico" ? 1 : 0}"
  source_dir      = "${path.module}/resources/calico"
  destination_dir = "${var.asset_dir}/bootkube/assets/manifests-networking"

  vars {
    calico_image       = "${var.container_images["calico"]}"
    calico_version     = "${var.versions["calico"]}"
    calico_cni_image   = "${var.container_images["calico_cni"]}"
    calico_cni_version = "${var.versions["calico_cni"]}"

    network_mtu = "${var.network_mtu}"
    pod_cidr    = "${var.pod_cidr}"
  }
}

data "template_file" "bootkube_service" {
  template = "${file("${path.module}/resources/bootkube.service")}"
}

data "template_file" "bootkube_start" {
  template = "${file("${path.module}/resources/bootkube-start")}"
}

resource "local_file" "bootkube_start" {
  content  = "${data.template_file.bootkube_start.rendered}"
  filename = "${var.asset_dir}/bootkube/bootkube-start"
}