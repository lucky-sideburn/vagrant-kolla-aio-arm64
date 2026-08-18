
## Description
A Vagrant box for trying Kolla OpenStack all-in-one through Vagrant on Ubuntu 24 ARM with the VMware Fusion provider (for now...).

<p align="center"><img src="architecture.svg" width="100%" alt="kolla-aio-arm64 is a VM with OpenStack Kolla-Ansible pre-installed, boxed with Vagrant without container images; images are pulled from quay.io during first-boot provisioning"></p>

For installing OpenStack, I followed the Kolla Ansible quickstart at https://docs.openstack.org/kolla-ansible/2026.1/user/quickstart.html#install-kolla-ansible. The base box I used was https://portal.cloud.hashicorp.com/vagrant/discover/gyptazy/ubuntu24.04-server-arm64 (thank you, gyptazy!).

I built the images directly into the box using the following command. Change the regex to specify which component you want to build:

```bash
kolla-build -b ubuntu --openstack-release 2026.1 --tag 2026.1-ubuntu-noble-aarch64 '^(nova).*'
```

### Docker images not included in the box, pulled on first boot

To keep the box size down, this Vagrant box is distributed **without** the Kolla Docker images pre-pulled. On first boot, Docker will pull all the Kolla container images from the registry, so the `kolla-*-container` services may take a few minutes to become healthy the first time. A banner reminding you of this is shown on every SSH login.

### Supported OpenStack version

This project supports OpenStack **2026.1**.

### Skyline Console

- URL: http://192.168.50.10:9999/
- Credentials: /etc/kolla/admin-openrc.sh

### Instance creation example

Once you're SSH'd into the VM, source the admin credentials, grab a test image, and create some flavors before booting your first instance:

```bash
root@kolla-aio-arm64:~# . /etc/kolla/admin-openrc.sh

root@kolla-aio-arm64:~# curl -LO https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-aarch64-disk.img
root@kolla-aio-arm64:~# openstack image create "cirros" \
  --file cirros-0.6.3-aarch64-disk.img \
  --disk-format qcow2 \
  --container-format bare \
  --public

root@kolla-aio-arm64:~# openstack flavor list --all

root@kolla-aio-arm64:~# openstack flavor create --id 1 --ram 512  --disk 1  --vcpus 1 m1.tiny
root@kolla-aio-arm64:~# openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
root@kolla-aio-arm64:~# openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
```

Then create a network and subnet for your instances to attach to:

```bash
root@kolla-aio-arm64:~# openstack network create test
root@kolla-aio-arm64:~# openstack network create test --provider-network-type vxlan --internal --enable
root@kolla-aio-arm64:~# openstack subnet create test-subnet --network test --subnet-range 10.0.0.0/24 --gateway 10.0.0.1 --dns-nameserver 8.8.8.8
```

### Why VMware Fusion specifically, in this case

On Apple Silicon, the choice is more practical than ideological:

- **VirtualBox**: ARM64/Apple Silicon support is still immature.
- **UTM/QEMU** (this one *is* open source): works, but with a different virtualization overhead, less mature for "heavy" workloads like an OpenStack AIO with nested networking.
- **VMware Fusion**: native hardware virtualization on Apple Silicon is very mature, with better performance for a workload like Kolla-Ansible with all the OpenStack containers.

So the choice is pragmatic: the part that matters (OpenStack) stays open source and reproducible, while the hypervisor is chosen for stability/performance on this specific hardware, not for its license.