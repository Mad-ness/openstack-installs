# openstack-installs
Useful things for deploying OpenStack clouds


## Utility infra_getcmds.py

It uses the files *virt_infra/infra_vars.yml* and *virt_infra/infra_templ.j2* 
to render the arguments of the **virt-install** CLI tool for deploying virtual machines.

File *virt_infra/infra_vars.yml* includes a description of VMs parameters and the file *virt_infra/infra_templ.j2* 
has a template of the command.

### Running infra_getcmds.py

Make sure you have the Yaml and Jinja2 python modules installed.
```shell
python infra_getcmds.py compute-1 | sudo sh
```
