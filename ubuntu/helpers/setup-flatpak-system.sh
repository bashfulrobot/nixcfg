#!/bin/bash

# Complete Flatpak Setup for Ubuntu
# This script sets up both system-level and user-level Flatpak integration
# Replaces the need for a separate home-manager flatpak module

set -e

echo "=========================================="
echo "COMPLETE FLATPAK SETUP FOR UBUNTU"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "${BLUE}[SECTION]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Run with sudo when prompted."
   exit 1
fi

# === SYSTEM SETUP ===
print_section "Setting up system-level components..."

# Update package list
print_status "Updating package list..."
sudo apt update

# Install flatpak system package
print_status "Installing flatpak system package..."
if dpkg -l | grep -q "^ii  flatpak "; then
    print_warning "flatpak is already installed system-wide"
else
    sudo apt install -y flatpak
    print_status "flatpak installed successfully"
fi

# Install GNOME Software Flatpak plugin (optional)
print_status "Installing GNOME Software Flatpak plugin..."
if dpkg -l | grep -q "^ii  gnome-software-plugin-flatpak "; then
    print_warning "gnome-software-plugin-flatpak is already installed"
else
    sudo apt install -y gnome-software-plugin-flatpak
    print_status "GNOME Software Flatpak plugin installed successfully"
fi

# Check if polkit is enabled (should be by default on Ubuntu)
print_status "Checking polkit service..."
if systemctl is-enabled polkit > /dev/null 2>&1; then
    print_status "polkit service is already enabled"
else
    print_warning "Enabling polkit service..."
    sudo systemctl enable --now polkit
fi

# === USER SETUP ===
print_section "Setting up user-level components..."

# Add Flathub repository for user
print_status "Adding Flathub repository..."
if flatpak remote-list --user | grep -q flathub; then
    print_warning "Flathub repository already exists for user"
else
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    print_status "Flathub repository added successfully"
fi

# Setup environment variables
print_status "Setting up environment variables..."
BASHRC="$HOME/.bashrc"
PROFILE="$HOME/.profile"

# XDG_DATA_DIRS environment variable
ENV_LINE='export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share"'

# Add to .profile if not already present
if ! grep -q "flatpak/exports/share" "$PROFILE" 2>/dev/null; then
    echo "" >> "$PROFILE"
    echo "# Flatpak integration" >> "$PROFILE"
    echo "$ENV_LINE" >> "$PROFILE"
    print_status "Added Flatpak environment variables to ~/.profile"
else
    print_warning "Flatpak environment variables already in ~/.profile"
fi

# Add to .bashrc if not already present (for interactive shells)
if ! grep -q "flatpak/exports/share" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# Flatpak integration" >> "$BASHRC"
    echo "$ENV_LINE" >> "$BASHRC"
    print_status "Added Flatpak environment variables to ~/.bashrc"
else
    print_warning "Flatpak environment variables already in ~/.bashrc"
fi

# Check if user is in any relevant groups
print_status "Checking user permissions..."
if groups | grep -q "sudo\|admin"; then
    print_status "User has administrative privileges"
else
    print_warning "User may need to be added to sudo group for some flatpak operations"
fi

# === COMPLETION ===
echo ""
echo "=========================================="
print_status "Complete Flatpak setup finished!"
echo "=========================================="
echo ""
print_warning "NEXT STEPS:"
echo "1. Log out and log back in (or reboot) to load environment variables"
echo "2. Test with: flatpak --version"
echo "3. Browse available apps: flatpak search [app-name]"
echo "4. Install apps: flatpak install flathub [app-id]"
echo ""
print_status "Flathub repository is now available for installing applications!"
echo "Example: flatpak install flathub org.mozilla.firefox"
echo "=========================================="