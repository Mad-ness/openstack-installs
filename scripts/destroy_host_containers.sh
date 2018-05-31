#!/bin/bash


for cnt in `lxc-ls`; do 
    lxc-stop -n "$cnt"
	lxc-destroy -n "$cnt"
done

