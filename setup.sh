#!/bin/bash

function replace_text() {
  local filename=$1
  local old=$2
  local new=$3

  sed --in-place "s|$old|$new|g" "$filename"
}

echo "HTPC Setup Script"
echo "=================="
echo ""
echo ""

echo "Setting up automatic security updates"
echo "=================="
echo ""
echo ""
DEBIAN_FRONTEND=noninteractive apt -yqq install unattended-upgrades
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades
echo ""
echo ""

echo "Setting up mDNS"
echo "=================="
echo ""
echo ""
DEBIAN_FRONTEND=noninteractive apt -yqq install avahi-daemon
systemctl enable --now avahi-daemon.service
echo ""
echo ""

echo "Setting up cockpit"
echo "=================="
echo ""
echo ""
DEBIAN_FRONTEND=noninteractive apt -yqq install cockpit tuned
systemctl unmask cockpit
systemctl enable cockpit
systemctl start cockpit
echo ""
echo ""

echo "Setting up jellyfin media player"
echo "=================="
echo ""
echo ""
DEBIAN_FRONTEND=noninteractive apt -yqq install cifs-utils wget
install -m 600 -o root -g root ./root/.smbcredentials_vault_containers /root
read -r -p "Enter the password for mediaserver network share: " -s mediaPassword
replace_text "/root/.smbcredentials_vault_containers" "MEDIAPASSWORD" "$mediaPassword"
mkdir -p /vault/containers
install -m 644 -o root -g root ./etc/systemd/system/vault-containers.mount /etc/systemd/system
systemctl daemon-reload
systemctl enable --now vault-containers.mount

install -m 644 -o root -g root ./etc/systemd/system/vault-containers.automount /etc/systemd/system
systemctl daemon-reload
systemctl enable vault-containers.automount

DEBIAN_FRONTEND=noninteractive apt -yqq install wget curl
install -m 755 -o root -g root ./usr/local/bin/update-jellyfinmediaplayer.sh /usr/local/bin
install -m 644 -o root -g root ./etc/systemd/system/jellyfinmediaplayer-updater.service /etc/systemd/system
install -m 644 -o root -g root ./etc/systemd/system/jellyfinmediaplayer-updater.timer /etc/systemd/system
systemctl daemon-reload
systemctl enable --now jellyfinmediaplayer-updater.service

DEBIAN_FRONTEND=noninteractive apt -yqq install cage xwayland pulseaudio
install -m 644 -o root -g root ./etc/pam.d/jellyfinmediaplayer /etc/pam.d
install -m 644 -o root -g root ./etc/systemd/system/jellyfinmediaplayer.service /etc/systemd/system
systemctl enable jellyfinmediaplayer.service
systemctl set-default graphical.target
echo ""
echo ""

echo "Setting up automatic mouse hiding"
echo "=================="
echo ""
echo ""
DEBIAN_FRONTEND=noninteractive apt -yqq install interception-tools interception-tools-compat
install -m 755 -o root -g root ./usr/bin/hideaway /usr/bin
install -m 644 -o root -g root ./etc/interception/udevmon.d/config.yaml /etc/interception/udevmon.d
systemctl restart udevmon
install -m 644 -o root -g root ./usr/share/icons/transparent/cursors/left_ptr /usr/share/icons/Adwaita/cursors
echo ""
echo ""

echo "Setting up root certificate"
echo "=================="
echo ""
echo ""
DEBIAN_FRONTEND=noninteractive apt -yqq install wget libnss3-tools
wget -q -i https://github.com/matthewpritchett/mediaserver/releases/download/1.0.0/root.crt -O /usr/local/share/ca-certificates/mediaserver.crt
update-ca-certificates
certutil -d sql:$HOME/.pki/nssdb -A -t "CP,CP," -n mediaserver -i /usr/local/share/ca-certificates/mediaserver.crt
echo ""
echo ""

read -n 1 -s -r -p "Press any key to reboot"
echo "=================="
echo "Rebooting"
echo "=================="
systemctl reboot
