#!/bin/bash
trap 'popd' 2
#
# Specify the version. it can be v1, v2, etc.
#
ver="$1"
if [[ -z $ver ]]; then
	echo "Need to specify a version."; exit 1
fi
dest_host=1-openstack-ansible
dest_dir="/etc/openstack_deploy"
mandatory_files="openstack_user_config.yml user_variables.yml"
# optional_files="ceph.conf ceph.client.cinder.keyring ceph.client.glance.keyring"
optional_files="ceph.keyring"

pushd ../configs

ok=0
for h in $mandatory_files; do 
    if [[ ! -f ${h}.${ver} ]]; then
        echo " -- [fail] Missing a mandatory file: "${h}"."${ver}  
		ok=1
    fi
done

if [[ $ok -eq 1 ]]; then
    echo "Cannot continue."; exit 1
fi


for h in $mandatory_files; do 
	scp ${h}.${ver} ${dest_host}:/etc/openstack_deploy/${h}
done

for h in $optional_files; do
	if [[ ! -f ${h}.${ver} ]]; then
    	echo "  --- [warn] Skipping an optional file: ${h}.${ver}" 
	else
		scp ${h}.${ver} ${dest_host}:/etc/openstack_deploy/${h}
	fi
done


popd

echo "=== [ configs files copied ] ==="


