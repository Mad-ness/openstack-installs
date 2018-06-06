#!/bin/bash

VMS="1-controller-1 1-controller-2 1-controller-3 1-compute-1 1-compute-2 1-compute-3"
A_VMS="`echo $VMS | tr ' ' ','`"
scripts_root=/infrastructure/openstack-installs

destroy_vms() {
    for h in $VMS; do
		virsh destroy $h
		virsh undefine $h
	done
}

deploy_vms() {
	for h in $VMS; do
		python infra_getcmds.py $h | sh
	done
}


start_vms() {
	for h in $VMS; do
		virsh start $h
	done

	ansible -m ping $A_VMS
	while [ $? -ne 0 ]; do
		sleep 15
		ansible -m ping $A_VMS
	done
}

bootstrap_vms() {
	ansible-playbooks playbooks/{bootstrap_controllers.yml,network_cfg.yml} -e hosts=$A_VMS
	ansible -b -m command -a 'reboot' $A_VMS
	ansible -m ping $A_VMS
	while [ $? -ne 0 ]; do
		sleep 15
		ansible -m ping $A_VMS
	done
	echo "----------------------------------------------------"
	echo "############ THE VMs have been prepared ############"
	echo "===================================================="
}

pushd $scripts_root
destroy_vms
deploy_vms
start_vms
bootstrap_vms
popd

