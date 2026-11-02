#!/bin/bash
# Switching kernel in Secureblue.

set -ex -o pipefail

# restore deleted files
rsync -a /usr/etc/containers/policy.json /etc/containers/policy.json
rsync -a /usr/etc/containers/registries.d/secureblue.yaml /etc/containers/registries.d/secureblue.yaml

systemctl stop rpm-ostreed-automatic.timer
systemctl stop flatpak-system-update.timer
systemctl stop brew-update.timer
systemctl stop podman-auto-update.timer
rpm-ostree cancel

# Fixes for latest kernel not booting: provide option to boot into an older kernel

# Prepare for grub usage
echo "timeout=3" >> /boot/grub2/user.cfg

# Deploy LTS kernel
# dnf copr enable kwizart/kernel-longterm-6.18 fedora-44-aarch64 # this does not work yet as of 2026 Oct.
while ! dnf copr enable kwizart/kernel-longterm-6.12 fedora-43-aarch64 -y; do sleep 5; done
while ! rpm-ostree override remove kernel{,-core,-modules,-modules-extra} $(echo "--install kernel-longterm"{,-core,-modules,-modules-extra}) --install gnome-remote-desktop; do sleep 5; done
ostree admin status
rpm-ostree status
