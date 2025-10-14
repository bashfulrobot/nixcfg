#!/usr/bin/env bash

echo "🔧 Fixing Zoom screen sharing (keeping meeting active)..."

# Only restart the portal service, don't kill Zoom
echo "Restarting xdg-desktop-portal-hyprland..."
systemctl --user restart xdg-desktop-portal-hyprland

# Brief pause for service restart
sleep 3

echo "✅ Portal service restarted!"
echo "🎥 Now try screen sharing again in Zoom."
echo ""
echo "💡 If still not working:"
echo "   1. In Zoom: Stop any current screen share attempt"
echo "   2. Wait 5 seconds"
echo "   3. Try sharing again"
echo "   4. If persistent issues, check Zoom settings:"
echo "      Settings > Screen Share > Advanced > Screen Capture Mode: PipeWire Mode"