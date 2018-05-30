# Preparing virtual machines to get them ready for deploying OpenStack services in

## What to run
- run **bootstrap_management.yml** to bootstrap your management host which will run ansible playbooks
- run **bootstrap_controllers.yml** to bootstrap controllers
- run **network_cfg.yml** to configure network interfaces on compute nodes and controllers (may change in the future)
