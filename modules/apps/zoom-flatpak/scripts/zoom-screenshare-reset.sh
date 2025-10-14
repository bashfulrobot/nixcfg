#!/usr/bin/env bash

echo "🔄 Resetting Zoom screen sharing..."

# Kill any existing Zoom processes
pkill -f "us.zoom.Zoom" || true

# Reset xdg-desktop-portal-hyprland screencopy sessions
systemctl --user restart xdg-desktop-portal-hyprland

# Wait a moment for services to restart
sleep 2

# Restart Zoom
echo "✅ Restarting Zoom..."
flatpak run us.zoom.Zoom &

echo "🎥 Try screen sharing again. If issues persist, check Zoom settings:"
echo "   Settings > Screen Share > Advanced > Screen Capture Mode: PipeWire Mode"