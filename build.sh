#!/usr/bin/env bash
set -e

echo "=============================="
echo " Building Lightspeed OS"
echo " Debloat + Performance + Boot"
echo "=============================="

# --------------------------------
# OS Identity
# --------------------------------
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

hostnamectl set-hostname lightspeed

# --------------------------------
# Boot optimizations
# --------------------------------
systemctl disable NetworkManager-wait-online.service || true

# --------------------------------
# GNOME Debloat (SAFE)
# --------------------------------
rpm-ostree override remove \
  gnome-tour \
  gnome-contacts \
  gnome-weather \
  gnome-maps \
  gnome-characters \
  gnome-clocks \
  gnome-connections \
  yelp \
  cheese \
  simple-scan || true

# --------------------------------
# ZRAM (RAM compression)
# --------------------------------
cat <<EOF >/etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF

# --------------------------------
# VM & Memory tuning
# --------------------------------
mkdir -p /etc/sysctl.d
cat <<EOF >/etc/sysctl.d/99-lightspeed.conf
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF

# --------------------------------
# IO scheduler (SSD friendly)
# --------------------------------
mkdir -p /etc/udev/rules.d
cat <<EOF >/etc/udev/rules.d/60-ioschedulers.rules
ACTION=="add|change", KERNEL=="nvme*n*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
EOF

# --------------------------------
# Journal size limit
# --------------------------------
mkdir -p /etc/systemd/journald.conf.d
cat <<EOF >/etc/systemd/journald.conf.d/size.conf
[Journal]
SystemMaxUse=200M
EOF

# --------------------------------
# Plymouth boot video (Lightspeed)
# --------------------------------
echo "Installing Lightspeed boot animation"

mkdir -p /usr/share/plymouth/themes/lightspeed
cp -r /ctx/plymouth/lightspeed/* /usr/share/plymouth/themes/lightspeed/

mkdir -p /etc/plymouth
cat <<EOF >/etc/plymouth/plymouthd.conf
[Daemon]
DeviceTimeout=8
EOF

plymouth-set-default-theme -R lightspeed

# --------------------------------
# Finish
# --------------------------------
echo "Lightspeed OS build complete"
