#!/bin/bash

echo "===================================="
echo "HTPC Setup Script"
echo "===================================="
echo ""
echo ""

echo "===================================="
echo "Setting up root certificate sync"
echo "===================================="
echo ""
echo ""
wget --directory-prefix=/storage/.config/ https://github.com/matthewpritchett/mediaserver/releases/download/1.0.0/root.crt
openssl x509 -in /storage/.config/root.crt -out /storage/.config/cacert.pem -outform PEM
echo '* * * * * [ "$(< /run/libreelec/cacert.pem)" = "$(< /storage/.kodi/addons/script.module.certifi/lib/certifi/cacert.pem)" ] || cp /run/libreelec/cacert.pem /storage/.kodi/addons/script.module.certifi/lib/certifi/cacert.pem' | crontab -
echo ""
echo ""

echo "===================================="
echo "Setting up custom keymaps"
echo "===================================="
echo ""
echo ""
install -m 755 -o root -g root ./storage/.kodi/userdata/keymaps/custom.xml /storage/.kodi/userdata/keymaps
echo ""
echo ""

read -n 1 -s -r -p "Press any key to reboot"
echo "===================================="
echo "Rebooting"
echo "===================================="
systemctl reboot
