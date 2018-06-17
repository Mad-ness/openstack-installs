#!/bin/bash

conf_file="${0}.conf"

if [[ -f ${conf_file} ]]; then
    source ${conf_file}
else
    touch ${conf_file}
fi

os="openstack"

INTNET_1_ID=${INTNET_1_ID:-}
INTNET_1_NAME=${INETNET_1_NAME:=InternalNetwork-1}

EXTNET_1_ID=${EXTNET_1_ID:-}

IMAGE_ID=${IMAGE_ID:=1}

INTNET_1_SUBNET_1=${INTNET_1_SUBNET_1:-}
EXTNET_1_SUBNET_1=${EXTNET_1_SUBNET_1:-}

TMPBUF=""

update_conf() {
    key="$1"
    value="$2"
    grep -q ^$key ${conf_file} && sed -i -e 's/^'$key'=.*$/'$key'='$value'/' $conf_file || echo "$key=$value" >> ${conf_file} && echo "Config updated: $key = $value"
    return $?
}

get_value() {
    os_output="$1"
    attr="$2"
    result=$($os_output | awk -F'|' '/ '$attr'\s+/{gsub(/ /, "", $3); print $3}');
    TMPBUF="${result}"
}

create_ext_network() {
    name="$1"
    $os network create \
    --internal \
    --provider-network vlan \
    --provider-segment 51 \
    --provider-physical-network tenants \
    "${name}" || { echo "Failed to create network $name"; exit 1; }

   get_value "$os network show ${INTNET_1_NAME}" "id"
   net_id=${TMPBUF}
   update_conf NETWORK_ID $net_id
   $os subnet create \
           --dhcp \
    --network ${net_id} \
    --subnet-range 10.0.0.0/24 \
    --gateway 10.0.0.1 \
    SubNet-1
    get_value "$os subnet show SubNet-1" "id"
    update_conf SUBNET_ID $TMPBUF
}

network_delete() {
    name="$1"
    $os network delete "$name" || echo "Failed to delete network $name"
}

create_image() {
    get_value "$os image show cirros-0.4.0" id
    if [[ -z ${id} ]]; then
        echo "Downloading cirros image ..."
        wget -q -c http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img -O /tmp/cirros-0.4.0-x86_64-disk.img && \
        $os image create --container-format bare --disk-format qcow2 --public --file /tmp/cirros-0.4.0-x86_64-disk.img cirros-0.4.0
        get_value "$os image show cirros-0.4.0" id
    update_conf IMAGE_ID $id
    fi
}

create_ext_network "${INTNET_1_NAME}"
network_delete "${INTNET_1_NAME}"
create_image

