#!/bin/bash

curl -s https//api.github.com/repos/jellyfin/jellyfin-media-player/release/latest | grep "browser_download_url.*bookworm.deb" | cut -  -f 2,3 | tr -d \" | wget -q -i - -O /tmp/jellyfin-mediaplayer.deb
apt install /tmp/jellyfin-mediaplayer.deb
