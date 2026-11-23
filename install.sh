#!/usr/bin/env bash
# Install the WirePlumber override for the current user and restart audio.
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)/51-bluetooth-output-only.conf"
dest_dir="${XDG_CONFIG_HOME:-$HOME/.config}/wireplumber/wireplumber.conf.d"

mkdir -p "$dest_dir"
cp "$src" "$dest_dir/"
systemctl --user restart wireplumber pipewire pipewire-pulse

echo "Installed to $dest_dir/51-bluetooth-output-only.conf"
echo "Reconnect your Echo Dot (bluetoothctl connect <MAC>) if it was already connected."
