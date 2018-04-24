#!/bin/bash

set -x
set -e

export DIR="$(readlink -f $(dirname ${0}))"
export ROOT_DIR="${DIR}/../tmp/${ENV}"
export FLAVOR="${2}"

source ${DIR}/utils.sh

case ${1} in
	"bootstrap")
		${DIR}/bootstrap.sh
		;;
	"create")
		${DIR}/create.sh
		;;
	"upgrade")
		${DIR}/upgrade.sh
		;;
	"destroy")
		${DIR}/destroy.sh
		;;
	*)
		error "Usage: ${0} {create|upgrade|destroy}"
esac