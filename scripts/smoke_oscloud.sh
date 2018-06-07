#!/bin/bash

#
# Run the script on any of the utility containers doing the source /root/openrc before.
#

function runcmd() {
    cmd="$1"
    msg="$2"
    echo -n "${msg} (${cmd}) ... "
    $cmd 2>&1 >/dev/null
    retcode=$?
    if [[ $retcode -ne 0 ]]; then
        echo "FAILED"
    else
        echo "PASSED"
    fi
    return $retcode
}


runcmd "openstack user list" 				"Getting a list of users"
runcmd "openstack user list --os-cloud=default" 	"Getting a list of users in the default cloud"
runcmd "openstack endpoint list"			"Listing endpoints"
runcmd "openstack compute service list"			"Listing compute services"
runcmd "openstack network agent list"			"Listing neutron agents"
runcmd "openstack volume service list"			"Listing volume services"
runcmd "openstack image list"				"Listing images"
runcmd "openstack flavor list"				"Listing flavors"
runcmd "openstack floating ip list"			"Listing floating ips"
runcmd "openstack catalog list"				"Listing catalog"


