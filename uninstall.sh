#!/bin/bash

# OpenRazer Uninstall Script

echo "================================================"
echo "OpenRazer Linux Mint Uninstall"
echo "================================================"
echo ""

read -p "Are you sure you want to remove OpenRazer? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo "Stopping OpenRazer daemon..."
sudo systemctl stop openrazer-daemon 2>/dev/null || pkill -9 openrazer-daemon || true
echo "✅ Daemon stopped"

echo ""
echo "Removing OpenRazer packages..."
sudo apt remove -y openrazer-daemon openrazer-driver-dkms openrazer-meta python3-openrazer 2>/dev/null || true
echo "✅ Packages removed"

echo ""
echo "Removing Polychromatic..."
sudo apt remove -y polychromatic 2>/dev/null || true
echo "✅ Polychromatic removed"

echo ""
echo "Removing systemd service..."
sudo systemctl disable openrazer-permissions.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/openrazer-permissions.service
sudo rm -f /etc/udev/rules.d/99-razer*.rules
sudo systemctl daemon-reload
echo "✅ Systemd service removed"

echo ""
echo "Removing PPA..."
sudo add-apt-repository -r ppa:openrazer/stable -y 2>/dev/null || true
echo "✅ PPA removed"

echo ""
echo "Auto-removing unused dependencies..."
sudo apt autoremove -y
echo "✅ Cleanup complete"

echo ""
echo "================================================"
echo "✅ OpenRazer uninstalled successfully"
echo "================================================"
