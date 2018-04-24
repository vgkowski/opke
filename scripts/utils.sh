#!/bin/bash

set -x
set -e

function error() {
	echo $1
	exit 1
}

function tf_get_instance_id() {
	local tfstatefile=${1}
	local instance=${2}
	local id
	id=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".primary.id')
	if [ $? -ne 0 ]; then
		# if someone has tainted the resource try with tainted instead of primary
		id=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".tainted[0].id')
		if [ $? -ne 0 ]; then
			echo ""
			return
		fi
	fi
	echo $id
}

function tf_get_instance_public_ip() {
	local tfstatefile=${1}
	local instance=${2}
	local ip
	ip=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".primary.attributes.public_ip')
	if [ $? -ne 0 ]; then
		# if someone has tainted the resource try with tainted instead of primary
		ip=$(cat ${tfstatefile} | jq -e -r -M '.modules[0].resources."aws_instance.'"${instance}"'".tainted[0].attributes.public_ip')
		if [ $? -ne 0 ]; then
			echo ""
			return
		fi
	fi
	echo $ip
}

function tf_get_all_instance_ids() {
	local tfstatefile=${1}
	local ids
	ids=$(cat ${tfstatefile} | jq -c -e -r -M '.modules[0].resources | to_entries | map(select(.key | test("aws_instance\\..*"))) | map(.value.primary.id)')
	if [ $? -ne 0 ]; then
		echo ""
		return
	fi
	echo $ids
}

function tf_get_all_instance_public_ips() {
	local tfstatefile=${1}
	local ids
	ids=$(cat ${tfstatefile} | jq -c -e -r -M '.modules[0].resources | to_entries | map(select(.key | test("aws_instance\\..*"))) | map(.value.primary.attributes.public_ip)')
	if [ $? -ne 0 ]; then
		echo ""
		return
	fi
	echo $ids
}

# Get the latest (by creation date) ami id with specified version tag value
function get_ami_id_by_version() {
	local ami_id=$(aws ec2 describe-images --filters "Name=tag:version,Values=${1}" --query 'Images[].[ImageId,CreationDate]' --output text | sort -n -k2 | head -1 | awk '{ print $1 }')
	echo $ami_id
}

function delete_s3_object() {
	# Ignore errors if file doesn't exists
	set +e
	aws s3 rm "s3://${1}/${2}"
	set -e
}