# Justfile for NixOS Configuration Management
# Documentation: https://github.com/casey/just

# === Settings ===
set dotenv-load
set ignore-comments
set fallback
set shell := ["bash", "-cu"]

# === Variables ===
hostname := `hostname`
host_flake := ".#" + hostname
trace_log := "~/dev/nix/nixcfg/rebuild-trace.log"

# === Help ===
_default:
    @just --list --unsorted --list-prefix ····

# === Development Commands ===
# Fast validation - syntax and options only (no building)
dev-check:
    @git add -A
    @nix flake check --show-trace

# Dry run build without bootloader changes
dev-test:
    @git add -A
    @sudo nixos-rebuild dry-build --fast --impure --flake {{host_flake}}

# Development rebuild (no bootloader)
dev-rebuild trace="":
    @git add -A
    #!/usr/bin/env bash
    if [[ "{{trace}}" == "trace" ]]; then
        just garbage-full
        sudo nixos-rebuild switch --impure --flake {{host_flake}} --show-trace > {{trace_log}} 2>&1
    else
        sudo nixos-rebuild switch --impure --flake {{host_flake}}
    fi

# === Production Commands ===
# Production rebuild with bootloader
rebuild trace="":
    #!/usr/bin/env bash
    if [[ "{{trace}}" == "trace" ]]; then
        sudo nixos-rebuild switch --impure --flake {{host_flake}} --show-trace
    else
        sudo nixos-rebuild switch --impure --flake {{host_flake}}
    fi

# Build VM for testing
rebuild-vm:
    @sudo nixos-rebuild build-vm --impure --flake {{host_flake}} --show-trace

# Full system upgrade with flake update
upgrade-system:
    @cp flake.lock flake.lock-pre-upg-{{hostname}}-$(date +%Y-%m-%d_%H-%M-%S)
    @nix flake update
    @sudo nixos-rebuild switch --impure --upgrade --flake {{host_flake}} --show-trace

# === Maintenance Commands ===
# Garbage collection (5 days)
garbage:
    @sudo nix-collect-garbage --delete-older-than 5d

# Full garbage collection
garbage-full:
    @sudo nix-collect-garbage -d

# Update nix database for comma
nixdb:
    @nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'

# Lint nix files
nix-lint:
    @fd -e nix --hidden --no-ignore --follow . -x statix check {}

# === System Info ===
# Show active kernel
kernel:
    @uname -r
    @sudo ls /boot/EFI/nixos/

# System information for debugging
system-info:
    @nix shell github:NixOS/nixpkgs#nix-info --extra-experimental-features nix-command --extra-experimental-features flakes --command nix-info -m

# Update hardware firmware
firmware-update:
    @sudo fwupdmgr get-updates || true
    @sudo fwupdmgr update || true

# === Git Commands ===
# View changelog with different time periods
changelog days="7" format="summary":
    #!/usr/bin/env bash
    case "{{format}}" in
        "full")
            echo "=== Commits from last {{days}} days ==="
            git rev-list --count --since="{{days}} days ago" HEAD
            echo "==="
            git log --since="{{days}} days ago" --pretty=full
            ;;
        "summary")
            echo "=== Commits from last {{days}} days ==="
            git rev-list --count --since="{{days}} days ago" HEAD
            echo "==="
            git log --since="{{days}} days ago" --pretty=format:"%h - %s"
            ;;
        "count")
            echo "=== Total commits from last {{days}} days ==="
            git rev-list --count --since="{{days}} days ago" HEAD
            ;;
    esac

# Reset to remote (resolve syncthing conflicts)
repo-reset hard="":
    @git fetch
    #!/usr/bin/env bash
    if [[ "{{hard}}" == "hard" ]]; then
        git reset --hard HEAD
        git clean -fd
    else
        git reset --hard origin/main
    fi
    @git pull

# === Helper Commands ===
# Quick reboot after full rebuild
final-rebuild-reboot:
    @just garbage-full
    @just rebuild
    @just garbage-full
    @sudo reboot

# Show config inspection commands
inspect:
    @echo "To find values for config:"
    @echo 'Example: ${config.users.users.arthur.home}'
    @echo "==="
    @helpers/nix-repl.sh

# === Ubuntu Commands (simplified) ===
# Bootstrap Ubuntu system
ubuntu-bootstrap:
    @git add -A
    @ubuntu/helpers/ubuntu-update-nix-conf.sh
    @cd ubuntu && nix run home-manager/release-25.05 -- switch --impure --flake .#{{`whoami`}}@{{hostname}}
    @cd ubuntu && sudo nix run 'github:numtide/system-manager' -- switch --flake .#{{hostname}}
    @sudo ubuntu/helpers/fix-suid-permissions.sh

# Ubuntu rebuild
ubuntu-rebuild trace="":
    @git add -A
    #!/usr/bin/env bash
    if [[ "{{trace}}" == "trace" ]]; then
        cd ubuntu && home-manager switch --impure --flake .#{{`whoami`}}@{{hostname}} --show-trace
        cd ubuntu && sudo nix run 'github:numtide/system-manager' -- switch --flake .#{{hostname}} --show-trace
    else
        cd ubuntu && home-manager switch --impure --flake .#{{`whoami`}}@{{hostname}}
        cd ubuntu && sudo nix run 'github:numtide/system-manager' -- switch --flake .#{{hostname}}
    fi
    @sudo ubuntu/helpers/fix-suid-permissions.sh

# Ubuntu garbage collection
ubuntu-garbage full="":
    #!/usr/bin/env bash
    if [[ "{{full}}" == "full" ]]; then
        home-manager expire-generations "-0 days"
        nix-collect-garbage -d
    else
        home-manager expire-generations "-5 days"
        nix-collect-garbage --delete-older-than 5d
    fi
    @nix-store --optimise

# Clean slate Ubuntu (emergency reset)
ubuntu-clean-slate:
    @echo "WARNING: This will remove ALL home-manager configurations!"
    @echo "Press Ctrl+C within 10 seconds to cancel..."
    @sleep 10
    @rm -rf ~/.local/state/home-manager || true
    @nix run home-manager/release-25.05 -- expire-generations "-0 days" || true
    @nix-collect-garbage -d
    @nix-store --optimise
    @find ~ -type l -name ".*" -exec sh -c 'readlink "$1" | grep -q "/nix/store" && rm -f "$1"' _ {} \; 2>/dev/null || true
    @echo "Clean slate complete! Run 'just ubuntu-bootstrap' to start fresh."

# === Aliases for common workflows ===
alias check := dev-check
alias test := dev-test
alias build := dev-rebuild
alias up := upgrade-system
alias clean := garbage
alias log := changelog