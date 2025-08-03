#!/bin/bash
# Ubuntu Nix Configuration Helper
# Updates /etc/nix/nix.conf with standard settings for this Ubuntu system

set -e

# Default nix.conf content for Ubuntu systems
NIX_CONF_CONTENT='# Nix configuration for Ubuntu system
# Managed by ubuntu-update-nix-conf.sh

# Enable experimental features
experimental-features = nix-command flakes

# Allow unfree packages (handled by nixpkgs.config.allowUnfree in configuration)

# Sandbox configuration for Chromium/1Password compatibility
sandbox = relaxed
extra-sandbox-paths = /usr/bin/env

# Performance settings
max-jobs = auto
cores = 0

# Substituter settings
substituters = https://cache.nixos.org/ https://nix-community.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=

# Build settings
keep-outputs = false
keep-derivations = false
'

echo "Updating /etc/nix/nix.conf for Ubuntu system..."

# Create the directory if it doesn't exist
sudo mkdir -p /etc/nix

# Write the configuration
echo "$NIX_CONF_CONTENT" | sudo tee /etc/nix/nix.conf > /dev/null

echo "✓ /etc/nix/nix.conf has been updated successfully"
echo ""
echo "Current configuration:"
echo "====================="
sudo cat /etc/nix/nix.conf
echo ""
echo "Restarting nix-daemon to apply changes..."
sudo systemctl restart nix-daemon.service
echo "Checking nix-daemon status..."
sudo systemctl status nix-daemon.service
echo "✓ Configuration applied successfully"