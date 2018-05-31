# Deploying the OpenStack cloud using the openstack-ansible playbooks on KVM virtual machines

This guide describes how to deploy the OpenStack cloud on KVM virtual machines.


## Architecture in a few words

The cloud will have three controller nodes and three compute nodes (actually it doesn't matter how many), and a NFS server as a storage. All OpenStack services will run behind HAProxy. The cloud is going to be deployed on KVM virtual machines. This is suitable for PoCs (Proof Of Concepts).


## Requirements

### Ansible host

This host runs the OpenStack-Ansible playbooks. It should have at least:
- 1vCPU            # recommended to give it as much as possible resources
- 6GB RAM
- 20GB HDD


### Controller nodes requirements

Each of the controller nodes should have at least the following characteristics:
- 1 vCPU           # two or more is better
- 6GB RAM
- 30G HDD


### Compute nodes requirements

Each of the compute nodes should have at least the following characteristics:
- 1 vCPU        
- 3GB RAM
- 10G HDD

Actual characteristics of a compute node depends on how much instances are going to be
run on it.


### NFS server

Give to it the resources as much as needed, at least following are enough:
- 1 vCPU
- 1GB RAM
- 10G HDD


## Preparing a host

Host is a physical server that plays a role of a virtual datacenter. All KVM machines will run on it. This is why we need to make sure that the network is configured properly before moving on.


### Network configuration

Network diagram may look as following:

```
              physical host
              +---------------------------------------------------------
 real world <=|=[ eth0    ]<----->[ br-mgmt       ] -->
              | [ eth0.10 ]<----->[ br-containers ] --> to
              | [ eth0.20 ]<----->[ br-tenants    ] --> virtual machines
              | [ eth0.30 ]<----->[ br-storage    ] -->
              |

eth0.20 and eth.30 are optional.
```


In our case we'll need to have following networks as described in the chart:

| Name           | Network            | Bridge Name  |
|----------------|:------------------:|--------------|
| Management     | 192.168.0.0/24     | br-mgmt      |
| Container      | 10.0.0.0/24        | br-container |
| Tenants        | 10.1.0.0/24        | br-tenants   |
| Storage        | 10.2.0.0/24        | br-storage   |

**Management Network** is used for accessing to virtual machines - controller and compute nodes. This is the only network that should be routable outside the physical host. Floating IP addresses are also allocated from this subnet, if the flat type is configured or vlan with some additions.


**Container Network**. Almost all OpenStack services, if not change default settings, run
in LXC containers. And this  network is used as an internal network for communications services
each to other. The network is also utilized by the openstack-ansible playbooks for accessing the services.


**Tenants Network** is for virtual machines in the OpenStack cloud.


**Storage Network**. Designed to access to storage from compute nodes.


Create the required bridges on the host and assign IP addresses on them.
- br-mgmt - 192.168.0.10
- br-container - 10.0.0.1
- br-tenantns - 10.1.0.1
- br-storage - 10.2.0.1

Virtual machines should have following IP addresses:

| Virtual Node | Management   | Container | Tenants   | Storage   |
|--------------|:------------:|:---------:|:---------:|:---------:|
| ansible-host | 192.168.0.11 | 10.0.0.11 | 10.1.0.11 | x         |
| controller-1 | 192.168.0.12 | 10.0.0.12 | 10.1.0.12 | x         |
| controller-2 | 192.168.0.13 | 10.0.0.13 | 10.1.0.13 | x         |
| controller-3 | 192.168.0.14 | 10.0.0.14 | 10.1.0.14 | x         |
| compute-1    | 192.168.0.15 | 10.0.0.15 | 10.1.0.15 | 10.2.0.15 |
| compute-2    | 192.168.0.16 | 10.0.0.16 | 10.1.0.16 | 10.2.0.16 |
| compute-3    | 192.168.0.17 | 10.0.0.17 | 10.1.0.17 | 10.2.0.17 |
| nfs-storage  | 192.168.0.18 | 10.0.0.18 | x         | 10.2.0.18 |
