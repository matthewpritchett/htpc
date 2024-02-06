#!/bin/bash

curl -s https://api.github.com/repos/jellyfin/jellyfin-media-player/releases/latest | grep "browser_download_url.*bookworm.deb" | cut -d : -f 2,3 | tr -d \" | wget -q -i - -O /tmp/jellyfin-media-player.deb
DEBIAN_FRONTEND=noninteractive apt -yqq install /tmp/jellyfin-media-player.deb || true
