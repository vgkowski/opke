#!/bin/bash

set -e

export DIR="$(readlink -f $(dirname ${0}))"
export ROOT_DIR="${DIR}/../tmp/${ENV}"

source ${DIR}/utils.sh

preflight_check

case ${1} in
	"bootstrap")
        prepare_workdir
        get_flavor
        get_workercount
        get_host_cidr
        get_kube_version
        set_local_backend
        init_local_terraform
        apply_terraform
        get_etcd_service
        get_etcd
        set_etcd_backend
        init_remote_terraform
        export_kubeconfig
        export_tfvars
        export_ssh
        clean_workdir
		;;
	"create")
        get_etcd
        prepare_workdir
        get_flavor
        get_workercount
        get_host_cidr
        get_kube_version
        set_etcd_backend
        init_remote_terraform
        apply_terraform
        export_kubeconfig
        export_tfvars
        export_ssh
        clean_workdir
		;;
    "scale")
        get_etcd
        prepare_workdir
        import_tfvars
        set_etcd_backend
        get_workercount
        init_remote_terraform
        apply_terraform
        export_tfvars
        clean_workdir
        ;;
	"upgrade")
        get_etcd
        prepare_workdir
        set_etcd_backend
        import_tfvars
        get_kube_version
        init_remote_terraform
        apply_terraform
        export_tfvars
        clean_workdir
        ;;
	"delete")
        get_etcd
        prepare_workdir
		import_kubeconfig
		import_tfvars
        init_remote_terraform
        clean_K8S_services
        destroy_terraform
        clean_workdir
		;;
	"bootstrap_delete")
        get_etcd
        prepare_workdir
		import_kubeconfig
		import_tfvars
		pull_tfstate
		set_local_backend
        init_local_terraform
        clean_K8S_services
        destroy_terraform
        clean_workdir
		;;	*)
		error "Usage: ${0} {bootstrap|bootstrap_delete|create|upgrade|delete}"
esac