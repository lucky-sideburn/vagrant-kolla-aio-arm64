Vagrant.configure("2") do |config|
	# Custom Kolla-Ansible AIO ARM64 box (Ubuntu Noble, provisioned).
	config.vm.box = "lucky-sideburn/kolla-aio-arm64"
	# Use a local box file for development, e.g.:
	#BOX_URL=file:///Users/eugenio/WORK/vagrant-kolla-aio-vmware-fusion-arm64/kolla-aio-arm64-provisioned.box vagrant up
	config.vm.box_url = ENV.fetch("BOX_URL", "https://devopstribe.it/wp-content/uploads/2026/08/kolla-aio-arm64.box")
	config.vm.box_check_update = false

	# VM identity.
	config.vm.hostname = "kolla-aio-arm64"

	# Private network (host-only) - Kolla management/API interface.
	config.vm.network "private_network", ip: "192.168.50.2"

	# Second private network (host-only), left without an IP so Neutron/OVS
	# can take ownership of it as the neutron_external_interface (br-ex).
	config.vm.network "private_network", ip: "192.168.50.3"

	# Optional synced folder from host to guest.
	# Set SYNC_DIR to a host path if needed, e.g.:
	# SYNC_DIR=$PWD vagrant up --provider=vmware_desktop
	if ENV["SYNC_DIR"] && !ENV["SYNC_DIR"].empty?
		config.vm.synced_folder ENV["SYNC_DIR"], "/vagrant_data", create: true
	end

	# SSH defaults.
	config.ssh.insert_key = false
	config.ssh.keep_alive = true

	# VMware Fusion / Vagrant VMware Desktop plugin settings.
	config.vm.provider "vmware_desktop" do |v|
  	v.gui = true
		v.vmx["displayName"] = ENV.fetch("VM_NAME", "ubuntu-arm64-vm")
  	v.vmx["numvcpus"] = ENV.fetch("VM_CPUS", "4")
		v.vmx["memsize"] = ENV.fetch("VM_MEMORY_MB", "12288") # 12 GiB
	end

	# List of services that must be enabled and running (see kolla-services.conf).
	config.vm.provision "file", source: "kolla-services.conf", destination: "/tmp/kolla-services.conf"

	# List of Kolla container images to pre-pull (see kolla-images.conf).
	config.vm.provision "file", source: "kolla-images.conf", destination: "/tmp/kolla-images.conf"

	# SSH login banner (see motd-banner.sh).
	config.vm.provision "file", source: "motd-banner.sh", destination: "/tmp/00-kolla-banner"

	# Heads-up message shown as soon as provisioning starts, since pulling
	# ~30 Kolla images can take a while depending on your connection.
	config.vm.provision "shell", inline: <<-SHELL
		echo "==> Provisioning started: this will pull ~30 Kolla container images"
		echo "==> (tens of GB in total). This can take a while depending on your"
		echo "==> network connection - please be patient and let it finish."
	SHELL

	# Basic provisioning convenience.
	config.vm.provision "shell", inline: <<-SHELL
		set -eux
		sudo apt-get update
		sudo apt-get install -y curl git vim

		# Install the dynamic MOTD banner shown on every SSH login.
		sudo install -o root -g root -m 0755 /tmp/00-kolla-banner /etc/update-motd.d/00-kolla-banner

		# Pre-pull all Kolla container images listed in kolla-images.conf
		# before enabling/starting the kolla-*-container services below, so
		# systemd doesn't race Docker for the same images on first boot.
		while IFS= read -r image; do
			image="${image%%#*}"
			image="$(echo "$image" | xargs)"
			[ -z "$image" ] && continue

			sudo docker pull "$image"
		done < /tmp/kolla-images.conf

		# Ensure Docker and all Kolla-Ansible container services listed in
		# kolla-services.conf are both enabled (start on boot) and started
		# (running now). Idempotent: `enable`/`start` are no-ops if a service
		# is already enabled/active. Unknown units are skipped so this stays
		# safe to run on a box where Kolla hasn't been deployed yet.
		while IFS= read -r svc; do
			svc="${svc%%#*}"
			svc="$(echo "$svc" | xargs)"
			[ -z "$svc" ] && continue

			if systemctl list-unit-files "$svc" --no-legend 2>/dev/null | grep -q "^$svc"; then
				sudo systemctl enable "$svc"
				cat <<-'BANNER'
				+--------------------------------------------------------------------+
				|  REBOOTING THE VM                                                  |
				|  This lets all OpenStack (Kolla) services start cleanly.           |
				|                                                                    |
				|    1) Wait a few minutes, then run: vagrant ssh                    |
				|    2) Check the VM status in your provider (VMware Fusion)         |
				+--------------------------------------------------------------------+
				BANNER
				reboot
				#sudo systemctl start "$svc"

			else
				echo "Skipping $svc: unit not found"
			fi
		done < /tmp/kolla-services.conf
	SHELL
end
