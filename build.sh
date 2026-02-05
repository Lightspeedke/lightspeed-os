#!/usr/bin/env bash
set -e

echo "=============================="
echo " Building Lightspeed OS"
echo "=============================="

# --------------------------------
# OS Identity
# --------------------------------
echo "Setting OS release information"

cat <<EOF >/usr/lib/os-release
NAME="Lightspeed OS"
PRETTY_NAME="Lightspeed OS (GNOME)"
ID=lightspeed
ID_LIKE=fedora
VERSION_ID=0.1
VERSION="0.1 (Lightspeed)"
PLATFORM_ID="platform:f41"
ANSI_COLOR="0;36"
LOGO=fedora-logo-icon
HOME_URL="https://github.com/Lightspeedke/lightspeed-os"
SUPPORT_URL="https://github.com/Lightspeedke/lightspeed-os/issues"
BUG_REPORT_URL="https://github.com/Lightspeedke/lightspeed-os/issues"
EOF

# --------------------------------
# Hostname
# --------------------------------
echo "Setting hostname"
hostnamectl set-hostname lightspeed

# --------------------------------
# System defaults (safe)
# --------------------------------
echo "Applying system defaults"

# Faster boot (safe)
systemctl disable NetworkManager-wait-online.service || true

# Reduce journal size
mkdir -p /etc/systemd/journald.conf.d
cat <<EOF >/etc/systemd/journald.conf.d/size.conf
[Journal]
SystemMaxUse=200M
EOF

# --------------------------------
# Finish
# --------------------------------
echo "Lightspeed OS base configuration complete"
