#!/bin/bash
# Setting up Secureblue kernel arguments.

set -ex -o pipefail

systemctl stop rpm-ostreed-automatic.timer
systemctl stop flatpak-system-update.timer
systemctl stop brew-update.timer
systemctl stop podman-auto-update.timer
rpm-ostree cancel

# Multi-tabbing essentials
# Directly invoking brew-proxy
while ! BREW_PROXY_NONINTERACTIVE=1 /usr/bin/brew-proxy install -y screen tmux; do sleep 10; done

# Using resolved for compatibility with tunneling over SOCKS5
ujust dns-selector resolver resolved

# Set up group for koiTerminal systemd services
groupadd --system koi-services
# Set up group for GUI login without passwd
groupadd --system nopasswdlogin
# Set up user for handling koi-tun2proxy
useradd --system koi-tun2proxy

# Set up permanent tunnel for koi-tun2proxy
while ! nmcli \
    connection add save yes type tun \
    ifname koi con-name koi \
    tun.mode tun tun.owner $(id -u koi-tun2proxy) tun.pi yes \
    ipv4.method manual ip4 10.0.0.33/24 ipv4.gateway 10.0.0.1 ipv4.dns 10.0.0.1 ipv4.routes "0.0.0.0/0" \
    ipv6.method manual ipv6.addr-gen-mode stable-privacy ipv6.routes "::0/0"
do
    sleep 5
done

# https://secureblue.dev/post-install
echo -e 'y\ny\nn' | ujust set-kargs-hardening
rpm-ostree kargs --append-if-missing=console=hvc0 # (see ks.cfg)
# leave out --append-if-missing=module.sig_enforce=1 # this omission was fixed upstream
# leave out --append-if-missing=ia32_emulation=0 for now

