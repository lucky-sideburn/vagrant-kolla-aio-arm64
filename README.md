
## Description
A Vagrant box for trying Kolla OpenStack all-in-one through Vagrant on Ubuntu 24 ARM with the VMware Fusion provider (for now...).

This box is a pre-provisioned Kolla OpenStack.

### Usage

```bash
vagrant plugin install vagrant-vmware-desktop
vagrant up
```

To tear the VM down:

```bash
vagrant destroy
```

### Supported OpenStack version

This project supports OpenStack **2026.1**.

### Skyline Console

- URL: http://192.168.50.10:9999/
- Credentials: /etc/kolla/admin-openrc.sh

### Why VMware Fusion specifically, in this case

On Apple Silicon, the choice is more practical than ideological:

- **VirtualBox**: ARM64/Apple Silicon support is still immature.
- **UTM/QEMU** (this one *is* open source): works, but with a different virtualization overhead, less mature for "heavy" workloads like an OpenStack AIO with nested networking.
- **VMware Fusion**: native hardware virtualization on Apple Silicon is very mature, with better performance for a workload like Kolla-Ansible with all the OpenStack containers.

So the choice is pragmatic: the part that matters (OpenStack) stays open source and reproducible, while the hypervisor is chosen for stability/performance on this specific hardware, not for its license.
