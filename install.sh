#!/bin/bash

# OpenRazer Linux Mint 21.3 Setup Script
# Automatic installer for OpenRazer v3.12.3 with proper permissions
# Supports Razer Huntsman Tournament Edition and other Razer devices

set -e

echo "================================================"
echo "OpenRazer Linux Mint 21.3 Setup"
echo "================================================"
echo ""

# Check if running on Linux Mint
if ! grep -q "DISTRIB_ID=Linuxmint" /etc/lsb-release 2>/dev/null; then
    echo "⚠️  Warning: This script is optimized for Linux Mint 21.3"
    echo "Your system: $(cat /etc/lsb-release | grep DISTRIB_DESCRIPTION)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if user is in plugdev group
if ! groups $USER | grep -q plugdev; then
    echo "⚠️  Adding $USER to plugdev group..."
    sudo usermod -aG plugdev $USER
    echo "✅ Added to plugdev group (log out and back in for changes to take effect)"
fi

echo "Step 1: Removing old OpenRazer packages..."
sudo apt remove -y openrazer-daemon openrazer-driver-dkms python3-openrazer 2>/dev/null || true
echo "✅ Old packages removed"

echo ""
echo "Step 2: Adding OpenRazer PPA..."
sudo add-apt-repository -y ppa:openrazer/stable
echo "✅ PPA added"

echo ""
echo "Step 3: Updating package list and installing OpenRazer..."
sudo apt update
sudo apt install -y openrazer-meta
echo "✅ OpenRazer v3.12.3 installed"

echo ""
echo "Step 4: Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb --subsystem-match=hid
echo "✅ udev rules reloaded"

echo ""
echo "Step 5: Restarting OpenRazer daemon..."
sudo systemctl stop openrazer-daemon 2>/dev/null || pkill -9 openrazer-daemon || true
sleep 1
rm -f ~/.cache/openrazer/openrazer-daemon.pid 2>/dev/null || true
openrazer-daemon &
sleep 3
echo "✅ Daemon started"

echo ""
echo "Step 6: Fixing driver permissions..."
sudo chmod g+w /sys/bus/hid/drivers/razerkbd/bind /sys/bus/hid/drivers/razerkbd/unbind /sys/bus/hid/drivers/razerkbd/new_id 2>/dev/null || true
sudo chmod g+w /sys/bus/hid/drivers/razermouse/bind /sys/bus/hid/drivers/razermouse/unbind /sys/bus/hid/drivers/razermouse/new_id 2>/dev/null || true
sudo chown :plugdev /sys/bus/hid/drivers/razerkbd/* 2>/dev/null || true
sudo chown :plugdev /sys/bus/hid/drivers/razermouse/* 2>/dev/null || true
echo "✅ Permissions fixed"

echo ""
echo "Step 7: Creating systemd service for persistent permissions..."
sudo tee /etc/systemd/system/openrazer-permissions.service > /dev/null << 'EOF'
[Unit]
Description=Set OpenRazer driver permissions
After=openrazer-daemon.service

[Service]
Type=oneshot
ExecStart=/usr/bin/chmod g+w /sys/bus/hid/drivers/razerkbd/bind /sys/bus/hid/drivers/razerkbd/unbind /sys/bus/hid/drivers/razerkbd/new_id
ExecStart=/usr/bin/chmod g+w /sys/bus/hid/drivers/razermouse/bind /sys/bus/hid/drivers/razermouse/unbind /sys/bus/hid/drivers/razermouse/new_id
ExecStart=/usr/bin/chown :plugdev /sys/bus/hid/drivers/razerkbd/bind /sys/bus/hid/drivers/razerkbd/unbind /sys/bus/hid/drivers/razerkbd/new_id
ExecStart=/usr/bin/chown :plugdev /sys/bus/hid/drivers/razermouse/bind /sys/bus/hid/drivers/razermouse/unbind /sys/bus/hid/drivers/razermouse/new_id
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openrazer-permissions.service
echo "✅ Systemd service created"

echo ""
echo "Step 8: Installing Polychromatic GUI..."
sudo apt install -y libxcb-cursor0 polychromatic 2>/dev/null || true
echo "✅ Polychromatic installed"

echo ""
echo "================================================"
echo "✅ Setup complete!"
echo "================================================"
echo ""
echo "Detected Razer devices:"
lsusb | grep -i razer || echo "No Razer devices detected"
echo ""
echo "Next steps:"
echo "1. Launch Polychromatic: polychromatic-controller"
echo "2. Or use CLI: openrazer-daemon, razer-cli"
echo ""
echo "If you don't see your devices:"
echo "  - Replug the device"
echo "  - Restart the daemon: sudo systemctl restart openrazer-daemon"
echo "  - Check permissions: ls -la /sys/bus/hid/drivers/razor*/"
echo ""
