# NixOS Configuration Management
# https://github.com/casey/just

# === Settings ===
set dotenv-load := true
set ignore-comments := true  
set fallback := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# === Variables ===
hostname := `hostname`
host_flake := ".#" + hostname
trace_log := justfile_directory() + "/rebuild-trace.log"
timestamp := `date +%Y-%m-%d_%H-%M-%S`

# === Help ===
# Show available recipes
default:
    @just --list --unsorted

# === Development Commands ===
# Fast syntax validation without building  
[group('dev')]
check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔍 Validating flake configuration..."
    git add -A
    nix flake check --show-trace

# Dry run build test
[group('dev')]  
test:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🧪 Testing build (dry run)..."
    git add -A
    sudo nixos-rebuild dry-build --fast --impure --flake {{host_flake}}

# Development rebuild with optional trace
[group('dev')]
build trace="false":
    #!/usr/bin/env bash
    set -euo pipefail
    git add -A
    if [[ "{{trace}}" == "true" ]]; then
        echo "🔧 Development rebuild with trace..."
        just clean-full
        sudo nixos-rebuild switch --impure --flake {{host_flake}} --show-trace 2>&1 | tee {{trace_log}}
    else
        echo "🔧 Development rebuild..."
        sudo nixos-rebuild switch --impure --flake {{host_flake}}
    fi

# === Production Commands ===
# Production rebuild with bootloader
[group('prod')]
rebuild trace="false":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{trace}}" == "true" ]]; then
        echo "🚀 Production rebuild with trace..."
        sudo nixos-rebuild switch --impure --flake {{host_flake}} --show-trace
    else
        echo "🚀 Production rebuild..."
        sudo nixos-rebuild switch --impure --flake {{host_flake}}
    fi

# Build VM for testing
[group('dev')]
vm:
    @echo "🖥️  Building VM..."
    @sudo nixos-rebuild build-vm --impure --flake {{host_flake}} --show-trace

# Full system upgrade
[group('prod')]  
upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⬆️  Upgrading system..."
    cp flake.lock flake.lock-backup-{{timestamp}}
    nix flake update
    sudo nixos-rebuild switch --impure --upgrade --flake {{host_flake}} --show-trace

# === Maintenance Commands ===
# Quick garbage collection (5 days)
[group('maintenance')]
clean:
    @echo "🧹 Cleaning packages older than 5 days..."
    @sudo nix-collect-garbage --delete-older-than 5d

# Full garbage collection
[group('maintenance')]
clean-full:
    @echo "🧹 Full garbage collection..."
    @sudo nix-collect-garbage -d

# Update nix database for comma tool
[group('maintenance')]
update-db:
    @echo "🗄️  Updating nix database..."
    @nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'

# Lint all nix files
[group('maintenance')]
lint:
    @echo "🔍 Linting nix files..."
    @fd -e nix --hidden --no-ignore --follow . -x statix check {}

# === System Info ===
# Show kernel and boot info
[group('info')]
kernel:
    @echo "🐧 Current kernel:"
    @uname -r
    @echo "📁 Boot entries:"
    @sudo ls /boot/EFI/nixos/ 2>/dev/null || echo "No EFI entries found"

# Comprehensive system information
[group('info')]
sysinfo:
    @echo "💻 System Information:"
    @nix shell github:NixOS/nixpkgs#nix-info --extra-experimental-features 'nix-command flakes' --command nix-info -m

# Update hardware firmware
[group('info')]
firmware:
    @echo "🔧 Checking firmware updates..."
    @sudo fwupdmgr get-updates || true
    @sudo fwupdmgr update || true

# === Git Commands ===
# Show recent commits (default: 7 days)
[group('git')]
log days="7":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📜 Commits from last {{days}} days:"
    echo "Total: $(git rev-list --count --since='{{days}} days ago' HEAD)"
    echo "===================="
    git log --since="{{days}} days ago" --pretty=format:"%h - %an: %s (%cr)" --graph

# Reset to remote origin
[group('git')]
reset-origin:
    @echo "🔄 Resetting to origin/main..."
    @git fetch
    @git reset --hard origin/main
    @git pull

# Hard reset with cleanup
[group('git')]
reset-hard:
    @echo "⚠️  Hard reset with file cleanup..."
    @git fetch
    @git reset --hard HEAD
    @git clean -fd
    @git pull

# === Helper Commands ===
# Full rebuild cycle with reboot
[group('helpers')]
rebuild-reboot:
    @echo "🔄 Full rebuild cycle..."
    @just clean-full
    @just rebuild
    @just clean-full
    @echo "🔌 Rebooting in 10 seconds... (Ctrl+C to cancel)"
    @sleep 10
    @sudo reboot

# Show config inspection examples
[group('helpers')]
inspect:
    @echo "🔍 Config inspection examples:"
    @echo "nix eval .#nixosConfigurations.{{hostname}}.config.users.users --json"
    @echo "nix eval .#nixosConfigurations.{{hostname}}.options.services --json"
    @echo "================================"
    @if [ -f helpers/nix-repl.sh ]; then helpers/nix-repl.sh; fi

# === Ubuntu Commands ===
# Bootstrap Ubuntu with home-manager
[group('ubuntu')]
ubuntu-init:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🐧 Bootstrapping Ubuntu system..."
    git add -A
    ubuntu/helpers/ubuntu-update-nix-conf.sh
    cd ubuntu && nix run home-manager/release-25.05 -- switch --impure --flake .#$(whoami)@{{hostname}}
    cd ubuntu && sudo nix run 'github:numtide/system-manager' -- switch --flake .#{{hostname}}
    sudo ubuntu/helpers/fix-suid-permissions.sh

# Ubuntu rebuild with optional trace
[group('ubuntu')]
ubuntu-rebuild trace="false":
    #!/usr/bin/env bash
    set -euo pipefail
    git add -A
    if [[ "{{trace}}" == "true" ]]; then
        echo "🔧 Ubuntu rebuild with trace..."
        cd ubuntu && home-manager switch --impure --flake .#$(whoami)@{{hostname}} --show-trace
        cd ubuntu && sudo nix run 'github:numtide/system-manager' -- switch --flake .#{{hostname}} --show-trace
    else
        echo "🔧 Ubuntu rebuild..."
        cd ubuntu && home-manager switch --impure --flake .#$(whoami)@{{hostname}}
        cd ubuntu && sudo nix run 'github:numtide/system-manager' -- switch --flake .#{{hostname}}
    fi
    sudo ubuntu/helpers/fix-suid-permissions.sh

# Ubuntu cleanup with options
[group('ubuntu')]
ubuntu-clean full="false":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{full}}" == "true" ]]; then
        echo "🧹 Ubuntu full cleanup..."
        home-manager expire-generations "-0 days"
        nix-collect-garbage -d
    else
        echo "🧹 Ubuntu cleanup (5 days)..."
        home-manager expire-generations "-5 days"
        nix-collect-garbage --delete-older-than 5d
    fi
    nix-store --optimise

# Emergency Ubuntu reset
[group('ubuntu')]
ubuntu-reset:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⚠️  WARNING: This removes ALL home-manager configurations!"
    echo "Press Enter to continue or Ctrl+C to cancel..."
    read -r
    rm -rf ~/.local/state/home-manager || true
    nix run home-manager/release-25.05 -- expire-generations "-0 days" || true
    nix-collect-garbage -d
    nix-store --optimise
    find ~ -type l -name ".*" -exec sh -c 'readlink "$1" | grep -q "/nix/store" && rm -f "$1"' _ {} \; 2>/dev/null || true
    echo "✅ Reset complete! Run 'just ubuntu-init' to start fresh."

# === Workflow Aliases ===
alias c := check
alias t := test  
alias b := build
alias r := rebuild
alias up := upgrade
alias gc := clean
alias l := log