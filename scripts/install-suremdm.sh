#!/bin/bash
# Script to install sureMDM

# Update package repository
sudo apt update

# Install Java Runtime Environment
sudo apt install default-jre -y

# Change to temporary directory
cd /tmp

# Download and install sureMDM nix agent
rm -rf nix.tar.gz; rm -rf nix
wget https://suremdm.42gears.com/nix/nix.tar.gz
tar -xvzf nix.tar.gz
sudo nix/installnix.sh eyJhY2NvdW50X2lkIjoiMDcyMzAwNDc1Iiwic2VydmVyX3VybCI6Imtvbmcuc3VyZW1kbS5pbyIsImdyb3VwX3BhdGgiOiJIb21lIiwicGFzc3dvcmQiOiIiLCJkZXZpY2VfbmFtZV90eXBlIjo0LCJpc19wcm94eV9yZXF1aXJlZCI6ZmFsc2UsImlzX3V1aWQiOmZhbHNlLCJwcm94eV91cmwiOiIiLCJwcm94eV9wb3J0IjozMTI4fQ==

echo "SureMDM installation completed"
echo "Current directory: $(pwd)"