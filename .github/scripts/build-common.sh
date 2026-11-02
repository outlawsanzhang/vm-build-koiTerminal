#!/bin/bash
set -uexo pipefail

pwd
id
lsblk
df -h .

echo -n $GITHUB_ACTION | tee ~/GITHUB_ACTION
sudo bash -c "echo -n $GITHUB_ACTION | tee ~/GITHUB_ACTION"
echo
sudo apt install -y zip rsync tmux apt-utils binfmt-support qemu-system-arm qemu-user-static qemu-utils genisoimage isomd5sum libguestfs-tools podman wget

