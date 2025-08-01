#!/bin/bash
# Script to install CrowdStrike Falcon

# Update package repository
sudo apt update

# Install the Falcon sensor from the deb file in the same directory as this script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
sudo dpkg -i "$SCRIPT_DIR"/falcon-sensor*.deb

# Configure CrowdStrike with the specific CID
sudo /opt/CrowdStrike/falconctl -s -f --cid=0C5DDB6CF50842F28AA5FE966B9851B6-52

# Start the Falcon sensor service
sudo systemctl start falcon-sensor

# Verify installation status
sudo systemctl status falcon-sensor

# Check if process is running
echo "Checking if Falcon sensor processes are running:"
sudo ps -e | grep falcon-sensor

# Optional check of logs
echo "Latest logs from Falcon sensor (press Ctrl+C to exit):"
sudo journalctl -u falcon-sensor --no-pager -n 20

echo "CrowdStrike Falcon installation completed"
echo "Current directory: $(pwd)"