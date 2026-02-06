#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo " Lightspeed OS build starting "
echo "=============================="

# --------------------------------
# Network-safe DNF configuration
# --------------------------------
echo "Configuring DNF for reliable builds"

# Disable slow / flaky third-party repos
dnf5 config-manager --set-disabled negativo17* || true

# Ensure core Fedora repos are enabled
dnf5 config-manager --set-enabled fedora updates updates-archive || true

# Clean metadata
dnf5 clean all

# --------------------------------
# Base packages
# --------------------------------
echo "Installing base packages"

dnf5 install -y \
  --setopt=timeout=60 \
  --setopt=retries=5 \
  tmux \
  curl \
  wget \
  vim

# --------------------------------
# Plymouth boot video (Lightspeed)
# --------------------------------
echo "Installing Lightspeed boot animation"

mkdir -p /usr/share/plymouth/themes/lightspeed

# Expecting your repo layout:
# plymouth/
# └── lightspeed/
#     ├── lightspeed.plymouth
#     ├── lightspeed.script
#     └── boot.mp4

cp -r /ctx/plymouth/lightspeed/* /usr/share/plymouth/themes/lightspeed/

plymouth-set-default-theme -R lightspeed

# --------------------------------
# System identity
# --------------------------------
echo "Setting Lightspeed OS identity"

cat <<EOF > /etc/os-release
NAME="Lightspeed OS"
ID=lightspeed
PRETTY_NAME="Lightspeed OS"
VERSION="0.1"
EOF

echo "=============================="
echo " Lightspeed OS build complete "
echo "=============================="
