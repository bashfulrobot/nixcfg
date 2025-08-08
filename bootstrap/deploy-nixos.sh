#!/usr/bin/env bash

# NixOS System Deployment Script
# Usage: curl -L https://raw.githubusercontent.com/bashfulrobot/nixcfg/main/bootstrap/deploy-nixos.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   log_info "Please run: sudo $0"
   exit 1
fi

# Check if we're in a NixOS live environment
if ! command -v nix &> /dev/null; then
    log_error "Nix command not found. Are you running this from a NixOS live ISO?"
    exit 1
fi

WORKING_DIR="/tmp/nixos-deploy"
REPO_URL="https://github.com/bashfulrobot/nixcfg"

log_info "Starting NixOS deployment process..."

# Clean up any previous runs
rm -rf "$WORKING_DIR"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

# List available systems
log_info "Setting up environment..."
nix-shell -p git git-crypt wget curl --run "
    git clone $REPO_URL
    cd nixcfg
    
    echo
    echo -e '${BLUE}Available systems:${NC}'
    echo '1) qbert (workstation)'
    echo '2) donkeykong (workstation)' 
    echo '3) srv (server)'
    echo '4) Exit'
    echo
    
    # Loop until valid selection is made
    while true; do
        read -p 'Select system number (1-4): ' system_choice
        
        case \$system_choice in
            1)
                SYSTEM_NAME='qbert'
                break
                ;;
            2)
                SYSTEM_NAME='donkeykong'
                break
                ;;
            3)
                SYSTEM_NAME='srv'
                break
                ;;
            4)
                echo -e '${YELLOW}Exiting deployment script${NC}'
                exit 0
                ;;
            *)
                echo -e '${RED}Invalid selection. Please enter 1, 2, 3, or 4.${NC}'
                ;;
        esac
    done
    
    echo
    echo -e '${BLUE}Selected system:${NC} '\$SYSTEM_NAME
    echo
    
    # Check if system has disko config
    DISKO_CONFIG=\"hosts/\$SYSTEM_NAME/config/disko.nix\"
    if [[ -f \"\$DISKO_CONFIG\" ]]; then
        echo -e '${YELLOW}DISKO PARTITIONING WILL ERASE ALL DATA ON THE TARGET DISK${NC}'
        echo
        read -p 'Do you want to partition with disko? (y/N): ' use_disko
        
        if [[ \"\$use_disko\" =~ ^[Yy]$ ]]; then
            echo
            echo -e '${BLUE}Available disks:${NC}'
            lsblk -d -o NAME,SIZE,MODEL | grep -E '^(sd|nvme|vd)'
            echo
            read -p 'Enter disk device (e.g., /dev/nvme0n1, /dev/sda): ' disk_device
            
            if [[ ! -b \"\$disk_device\" ]]; then
                echo -e '${RED}Invalid disk device: \$disk_device${NC}'
                exit 1
            fi
            
            echo
            echo -e '${RED}WARNING: This will DESTROY ALL DATA on \$disk_device${NC}'
            read -p 'Type \"YES\" to continue: ' confirm
            
            if [[ \"\$confirm\" != \"YES\" ]]; then
                echo -e '${YELLOW}Aborted by user${NC}'
                exit 1
            fi
            
            echo -e '${BLUE}Running disko partitioning...${NC}'
            nix --experimental-features \"nix-command flakes\" run github:nix-community/disko -- --mode disko \"\$DISKO_CONFIG\" --arg device '\"\$disk_device\"' || {
                # If device arg doesn't work, try updating the disko config directly
                sed -i \"s|device = \\\"/dev/[^\\\"]*\\\"|device = \\\"\$disk_device\\\"|g\" \"\$DISKO_CONFIG\"
                nix --experimental-features \"nix-command flakes\" run github:nix-community/disko -- --mode disko \"\$DISKO_CONFIG\"
            }
            
            echo -e '${GREEN}Disko partitioning complete${NC}'
            mount | grep /mnt
        else
            echo -e '${YELLOW}Skipping disko partitioning - please ensure /mnt is properly mounted${NC}'
            if ! mountpoint -q /mnt; then
                echo -e '${RED}/mnt is not mounted. Please mount your target filesystem first.${NC}'
                exit 1
            fi
        fi
    else
        echo -e '${YELLOW}No disko config found for \$SYSTEM_NAME - please ensure /mnt is properly mounted${NC}'
        if ! mountpoint -q /mnt; then
            echo -e '${RED}/mnt is not mounted. Please mount your target filesystem first.${NC}'
            exit 1
        fi
    fi
    
    # Handle secrets (git-crypt) and SSH keys FIRST
    GIT_CRYPT_KEY_PATH=\"\"
    echo
    echo -e '${BLUE}Secrets (git-crypt) & SSH Key Options${NC}'
    echo -e '${YELLOW}This repository uses git-crypt to manage secrets. To unlock them, you need a symmetric key file.${NC}'
    echo
    echo '1) Fetch from 192.168.169.2 (git-crypt key + SSH keys)'
    echo '2) Fetch from 192.168.168.1 (git-crypt key + SSH keys)'
    echo '3) Provide custom SSH location for key'
    echo '4) Provide local path to key file'
    echo '5) Exit'
    echo
    
    while true; do
        read -p 'Select an option (1-5): ' secrets_choice
        
        case \"\$secrets_choice\" in
            1|2)
                local_ip=\"192.168.169.2\"
                if [[ \"\$secrets_choice\" == \"2\" ]]; then
                    local_ip=\"192.168.168.1\"
                fi
                
                echo -e \"${BLUE}Fetching git-crypt key and SSH keys from \$local_ip...${NC}\"
                
                if scp \"dustin@\$local_ip:~/.ssh/git-crypt\" ./git-crypt-key; then
                    GIT_CRYPT_KEY_PATH=\"\$PWD/git-crypt-key\"
                    if git-crypt unlock \"\$GIT_CRYPT_KEY_PATH\"; then
                        echo -e '${GREEN}Git-crypt unlocked successfully.${NC}'
                        git checkout .
                        git-crypt status
                        
                        # Fetch SSH keys (optional)
                        echo -e \"${BLUE}Attempting to fetch SSH keys from \$local_ip (optional)...${NC}\"
                        mkdir -p ./ssh-keys
                        if scp \"dustin@\$local_ip:~/.ssh/id*\" ./ssh-keys/ 2>/dev/null; then
                            mkdir -p /mnt/home/dustin/.ssh
                            cp ./ssh-keys/* /mnt/home/dustin/.ssh/ 2>/dev/null || true
                            chmod 700 /mnt/home/dustin/.ssh 2>/dev/null || true
                            chmod 600 /mnt/home/dustin/.ssh/id_* 2>/dev/null || true
                            chmod 644 /mnt/home/dustin/.ssh/id_*.pub 2>/dev/null || true
                            echo -e '${GREEN}SSH keys copied successfully.${NC}'
                        else
                            echo -e '${YELLOW}SSH keys not found or failed to copy (this is not critical).${NC}'
                        fi
                        break
                    else
                        echo -e '${RED}Failed to unlock git-crypt with the fetched key.${NC}'
                    fi
                else
                    echo -e \"${RED}Failed to fetch git-crypt key from \$local_ip.${NC}\"
                fi
                ;;
            3)
                echo -e '${BLUE}Enter SSH location to fetch the symmetric git-crypt key:${NC}'
                read -p 'SSH location (user@host:path): ' ssh_location
                
                if [[ -n \"\$ssh_location\" ]]; then
                    if scp \"\$ssh_location\" ./git-crypt-key; then
                        GIT_CRYPT_KEY_PATH=\"\$PWD/git-crypt-key\"
                        if git-crypt unlock \"\$GIT_CRYPT_KEY_PATH\"; then
                            echo -e '${GREEN}Git-crypt unlocked successfully.${NC}'
                            git checkout .
                            git-crypt status
                            break
                        else
                            echo -e '${RED}Failed to unlock git-crypt with the provided key.${NC}'
                        fi
                    else
                        echo -e \"${RED}Failed to fetch git-crypt key from \$ssh_location.${NC}\"
                    fi
                fi
                ;;
            4)
                echo -e '${BLUE}Please provide the local file path for the symmetric git-crypt key:${NC}'
                read -p 'Key file path: ' key_path
                
                if [[ -f \"\$key_path\" ]]; then
                    GIT_CRYPT_KEY_PATH=\$(readlink -f \"\$key_path\")
                    if git-crypt unlock \"\$GIT_CRYPT_KEY_PATH\"; then
                        echo -e '${GREEN}Git-crypt unlocked successfully.${NC}'
                        git checkout .
                        git-crypt status
                        break
                    else
                        echo -e \"${RED}Failed to unlock git-crypt with key: \$key_path${NC}\"
                    fi
                else
                    echo -e \"${RED}Key file not found: \$key_path${NC}\"
                fi
                ;;
            5)
                echo -e '${YELLOW}Exiting deployment script.${NC}'
                exit 0
                ;;
            *)
                echo -e '${RED}Invalid selection. Please enter 1, 2, 3, 4, or 5.${NC}'
                ;;
        esac
        echo
    done
    
    # Generate hardware configuration
    echo -e '${BLUE}Generating hardware configuration...${NC}'
    nixos-generate-config --no-filesystems --root /mnt
    
    # Copy hardware config to repo
    cp /mnt/etc/nixos/hardware-configuration.nix \"hosts/\$SYSTEM_NAME/config/hardware-configuration.nix\"
    
    echo -e '${BLUE}Hardware configuration saved to hosts/\$SYSTEM_NAME/config/hardware-configuration.nix${NC}'
    
    # Handle wallpapers (OPTIONAL for theme support)
    echo
    echo -e '${BLUE}Wallpaper fetching (for theme support):${NC}'
    echo '1) Fetch from 192.168.169.2 (dustin@192.168.169.2:Pictures/Wallpapers/)'
    echo '2) Fetch from 192.168.168.1 (dustin@192.168.168.1:Pictures/Wallpapers/)'
    echo '3) Provide custom SSH location'
    echo '4) Skip wallpapers (will cause theme build errors)'
    echo
    
    while true; do
        read -p 'Select wallpaper option (1-4): ' wallpaper_choice
        
        case \"\$wallpaper_choice\" in
            1)
                echo -e '${BLUE}Fetching wallpapers from 192.168.169.2...${NC}'
                if scp -r dustin@192.168.169.2:Pictures/Wallpapers ./wallpapers 2>/dev/null; then
                    mkdir -p /mnt/home/dustin/Pictures
                    cp -r ./wallpapers /mnt/home/dustin/Pictures/
                    echo -e '${GREEN}Wallpapers copied successfully${NC}'
                    break
                else
                    echo -e '${RED}Failed to fetch wallpapers from 192.168.169.2${NC}'
                fi
                ;;
            2)
                echo -e '${BLUE}Fetching wallpapers from 192.168.168.1...${NC}'
                if scp -r dustin@192.168.168.1:Pictures/Wallpapers ./wallpapers 2>/dev/null; then
                    mkdir -p /mnt/home/dustin/Pictures
                    cp -r ./wallpapers /mnt/home/dustin/Pictures/
                    echo -e '${GREEN}Wallpapers copied successfully${NC}'
                    break
                else
                    echo -e '${RED}Failed to fetch wallpapers from 192.168.168.1${NC}'
                fi
                ;;
            3)
                echo -e '${BLUE}Enter SSH location for wallpapers:${NC}'
                echo '(Format: user@host:path/to/Pictures/Wallpapers/)'
                read -p 'SSH location: ' ssh_location
                
                if [[ -n \"\$ssh_location\" ]]; then
                    echo -e \"${BLUE}Fetching wallpapers from \$ssh_location...${NC}\"
                    if scp -r \"\$ssh_location\" ./wallpapers 2>/dev/null; then
                        mkdir -p /mnt/home/dustin/Pictures
                        cp -r ./wallpapers /mnt/home/dustin/Pictures/
                        echo -e '${GREEN}Wallpapers copied successfully${NC}'
                        break
                    else
                        echo -e \"${RED}Failed to fetch wallpapers from \$ssh_location${NC}\"
                    fi
                else
                    echo -e '${RED}No SSH location provided${NC}'
                fi
                ;;
            4)
                echo -e '${YELLOW}Skipping wallpapers - theme may fail to build${NC}'
                break
                ;;
            *)
                echo -e '${RED}Invalid selection. Please enter 1, 2, 3, or 4.${NC}'
                ;;
        esac
        echo
    done
    
    # Temporarily fix wallpaper setting for stylix theme generation
    echo -e '${BLUE}Temporarily fixing wallpaper setting for initial build...${NC}'
    if [[ -f settings/settings.json ]]; then
        # Backup original settings
        cp settings/settings.json settings/settings.json.backup
        
        # Replace urban.jpg with available adwaita-l.jpg temporarily
        sed -i 's/\\\"urban.jpg\\\"/\\\"adwaita-l.jpg\\\"/' settings/settings.json
        echo -e '${GREEN}Wallpaper setting temporarily updated for build${NC}'
    else
        echo -e '${YELLOW}Settings file not found - skipping wallpaper fix${NC}'
    fi
    
    # CRITICAL: Copy the unlocked repository to the target system before installation
    echo -e '${BLUE}Copying unlocked repository to /mnt/tmp/nixcfg-source for the installation...${NC}'
    mkdir -p /mnt/tmp
    cp -r . /mnt/tmp/nixcfg-source
    
    # Copy the pristine (still locked) repo to the final user destination
    mkdir -p /mnt/home
    cp -r . /mnt/home/nixcfg
    
    # Unlock the final user repo if a key was provided
    if [[ -n \"\$GIT_CRYPT_KEY_PATH\" ]]; then
        echo -e '${BLUE}Unlocking git-crypt in final user repository at /mnt/home/nixcfg...${NC}'
        (cd /mnt/home/nixcfg && git-crypt unlock \"\$GIT_CRYPT_KEY_PATH\")
        echo -e '${GREEN}Git-crypt unlocked in /mnt/home/nixcfg${NC}'
    fi

    # Define the flake path for installation
    INSTALL_FLAKE_PATH=\"/mnt/tmp/nixcfg-source#\$SYSTEM_NAME\"
    echo -e \"${BLUE}Installation will proceed using the flake at: \${INSTALL_FLAKE_PATH}${NC}\"
    
    # Deployment options
    echo
    echo -e '${BLUE}Deployment options:${NC}'
    echo '1) Auto-install (run nixos-install automatically)'
    echo '2) Manual install (show command to run manually)'
    echo '3) Skip installation (configuration only)'
    echo
    
    while true; do
        read -p 'Select deployment option (1-3): ' deploy_choice
        
        case \$deploy_choice in
            1)
                echo -e '${BLUE}Running automatic installation...${NC}'
                echo -e \"${YELLOW}Command:${NC} ulimit -n 4096 && nixos-install --flake \$INSTALL_FLAKE_PATH --impure --no-root-passwd\"
                echo
                ulimit -n 4096
                if nixos-install --flake \"\$INSTALL_FLAKE_PATH\" --impure --no-root-passwd; then
                    echo -e '${GREEN}Installation completed successfully!${NC}'
                else
                    echo -e '${RED}Installation failed. Check the error messages above.${NC}'
                fi
                break
                ;;
            2)
                echo
                echo -e '${YELLOW}Run the following command to install:${NC}'
                echo \"ulimit -n 4096 && nixos-install --flake \$INSTALL_FLAKE_PATH --impure --no-root-passwd\"
                echo
                echo -e '${BLUE}Press Enter when installation is complete...${NC}'
                read -p '' install_done
                break
                ;;
            3)
                echo -e '${YELLOW}Skipping installation - configuration prepared only${NC}'
                break
                ;;
            *)
                echo -e '${RED}Invalid selection. Please enter 1, 2, or 3.${NC}'
                ;;
        esac
    done
    
    # Restore original wallpaper setting
    if [[ -f /mnt/tmp/nixcfg-source/settings/settings.json.backup ]]; then
        echo -e '${BLUE}Restoring original wallpaper setting...${NC}'
        mv /mnt/tmp/nixcfg-source/settings/settings.json.backup /mnt/tmp/nixcfg-source/settings/settings.json
        echo -e '${GREEN}Original settings restored${NC}'
    fi
    
    echo
    echo -e '${GREEN}Installation complete!${NC}'
    echo
    echo -e '${BLUE}Post-installation steps:${NC}'
    echo '1. Reboot into the new system'
    echo '2. Set up user password: sudo passwd \$(whoami)'
    echo '3. Move repo: mv /home/nixcfg ~/dev/nix/nixcfg && mkdir -p ~/dev/nix'
    echo '4. Update remote: cd ~/dev/nix/nixcfg && git remote set-url origin git@github.com:bashfulrobot/nixcfg.git'
    echo '5. Commit hardware config: git add . && git commit && git push'
    echo '6. Run: just rebuild (to apply any updates)'
    echo
    echo -e '${YELLOW}The nixcfg repository (with updated hardware config) is available at /home/nixcfg${NC}'
    echo
    read -p 'Reboot now? (y/N): ' reboot_now
    
    if [[ \"\$reboot_now\" =~ ^[Yy]$ ]]; then
        echo -e '${BLUE}Rebooting...${NC}'
        reboot
    fi
"

log_success "Deployment script completed!"