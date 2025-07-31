# Docs
# ---- https://github.com/casey/just
# ---- https://stackabuse.com/how-to-change-the-output-color-of-echo-in-linux/
# ---- https://cheatography.com/linux-china/cheat-sheets/justfile/
# load a .env file if in the directory
set dotenv-load
# Ignore recipe lines beginning with #.
set ignore-comments
# Search justfile in parent directory if the first recipe on the command line is not found.
set fallback
# Set the shell to bash
#set shell := ["bash", "-cu"]
# Set the shell to fish
set shell := ["fish", "-c"]

# "_" hides the recipie from listings
_default:
    @just --list --unsorted --list-prefix ····
# Test nixos cfg on your current host without git commit. Switches, but does not create a bootloader entry
dev-test:
    @git add -A
    # @just garbage-build-cache
    # @sudo nixos-rebuild test --fast--impure --flake .#\{{`hostname`}}
    @sudo nixos-rebuild dry-build --fast --impure --flake .#\{{`hostname`}}
# Rebuild nixos cfg on your current host without git commit.
dev-rebuild:
    @git add -A
    @sudo nixos-rebuild switch --impure --flake .#\{{`hostname`}}
    # @just _sway-reload
# Rebuild nixos cfg without the cache.
dev-rebuild-no-cache:
    @git add -A
    @sudo nixos-rebuild switch --impure --flake .#\{{`hostname`}}  --option binary-caches ''
    # @just _sway-reload
# Rebuild and trace nixos cfg on your current host without git commit.
dev-rebuild-trace:
    @git add -A
    @just garbage-build-cache
    @sudo nixos-rebuild switch --impure --flake .#\{{`hostname`}} --show-trace > ~/dev/nix/nixcfg/rebuild-trace.log 2>&1
    # @just _sway-reload
# Test (with Trace) nixos cfg on your current host without git commit. Switches, but does not create a bootloader entry
dev-test-trace:
    @git add -A
    @just garbage-build-cache
    @sudo nixos-rebuild test --impure --flake .#\{{`hostname`}} --show-trace
# Final build and garbage collect, will reboot
final-build-reboot:
    @just garbage-build-cache
    @just rebuild
    @just garbage-build-cache
    @sudo reboot
# Garbage Collect items older than 5 days on the current host
garbage:
    @sudo nix-collect-garbage --delete-older-than 5d
### The below will delete from the Nix store everything that is not used by the current generations of each  profile
# Garbage collect all, clear build cache
garbage-build-cache:
    @sudo nix-collect-garbage -d
# Version Updates (flake update) - IE sysdig-cli-scanner
version-update:
    @sudo nix-collect-garbage -d
    @sudo nix flake update
# check active kernel
kernel:
    @uname -r
    @sudo ls /boot/EFI/nixos/
# lint nix files
nix-lint:
    fd -e nix --hidden --no-ignore --follow . -x statix check {}
# update nix database for use with comma
nixdb:
    nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'
# Rebuild nixos cfg on your current host.
rebuild:
    @sudo nixos-rebuild switch --impure --flake .#\{{`hostname`}}
    # @just _sway-reload
# Rebuild nixos cfg on your current host with show-trace.
rebuild-trace:
    @sudo nixos-rebuild switch --impure --flake .#\{{`hostname`}} --show-trace
    @just _sway-reload
# Rebuild nixos cfg in a vm host with show-trace.
rebuild-vm:
    @sudo nixos-rebuild build-vm --impure --flake .#\{{`hostname`}} --show-trace
# git fetch and reseset to remote repo git - leaving any untracked files and directories. Used to resolve conflicts due to syncthing
repo-conflict:
    @git fetch
    @git reset --hard origin/main
    @git pull
# git reset and clean - unstage any changes and revert your working directory to the last commit,remove any untracked files and directories. Used to resolve conflicts due to syncthing
repo-conflict-nuke:
    @git reset --hard HEAD
    @git clean -fd
    @git pull
# Show commands to inspect config
inspect:
    @echo "to find values to use in config:"
    @echo 'IE - ${config.users.users.arthur.home}'
    @echo "==================================="
    @helpers/nix-repl.sh

# Update Hardware Firmware
run-fwup:
    # @sudo fwupdmgr refresh --force?
    @sudo fwupdmgr get-updates || true
    @sudo fwupdmgr update || true
# Update Flake
upgrade-system:
    #ulimit -n 4096
    @cp flake.lock flake.lock-pre-upg-$(hostname)-$(date +%Y-%m-%d_%H-%M-%S)
    @nix flake update
    @sudo nixos-rebuild switch --impure --upgrade --flake .#\{{`hostname`}} --show-trace
# Change Log - 7 Days
changelog-7d:
    @echo "==================================="
    @echo "Total commits in the last 7 days:"
    @git rev-list --count --since="7 days ago" HEAD
    @echo "==================================="
    @git log --since="7 days ago" --pretty=full
# Change Log - 2 Days
changelog-2d:
    @echo "==================================="
    @echo "Total commits in the last 2 days:"
    @git rev-list --count --since="2 days ago" HEAD
    @echo "==================================="
    @git log --since="2 days ago" --pretty=full
# Change Log - 10 Commits
changelog-10:
    @git log -n 10 --pretty=full
# Change Log - 7 Day Summary
changelog-7d-summary:
    @echo "==================================="
    @echo "Total commits in the last 7 days:"
    @git rev-list --count --since="7 days ago" HEAD
    @echo "==================================="
    @git log --since="7 days ago" --pretty=format:"%h - %s"
# Change Log - 2 Day Summary
changelog-2d-summary:
    @echo "==================================="
    @echo "Total commits in the last 2 days:"
    @git rev-list --count --since="2 days ago" HEAD
    @echo "==================================="
    @git log --since="2 days ago" --pretty=format:"%h - %s"
# Change Log - 10 Commit Summary
changelog-10-summary:
    @git log -n 10 --pretty=format:"%h - %s"
# Change Log - 7 Day Summary
changelog-7d-count:
    @echo "==================================="
    @echo "Total commits in the last 7 days:"
    @git rev-list --count --since="7 days ago" HEAD
    @echo "==================================="
# Change Log - 2 Day Summary
changelog-2d-count:
    @echo "==================================="
    @echo "Total commits in the last 2 days:"
    @git rev-list --count --since="2 days ago" HEAD
    @echo "==================================="
# Get system Info for Nix related Issues
nix-system-info:
    @nix shell github:NixOS/nixpkgs#nix-info --extra-experimental-features nix-command --extra-experimental-features flakes --command nix-info -m

# === Ubuntu/Home Manager Commands ===
# Bootstrap home-manager on Ubuntu - run this first on a new Ubuntu system
ubuntu-bootstrap:
    @git add -A
    @nix --extra-experimental-features 'nix-command flakes' run home-manager/release-25.05 -- switch --impure --flake .#\{{`whoami`}}@\{{`hostname`}}
# Test home-manager config without switching
ubuntu-test:
    @git add -A
    @home-manager build --impure --flake .#\{{`whoami`}}@\{{`hostname`}}
# Switch to new home-manager configuration
ubuntu-rebuild:
    @git add -A
    @home-manager switch --impure --flake .#\{{`whoami`}}@\{{`hostname`}}
# Switch to new home-manager configuration with trace
ubuntu-rebuild-trace:
    @git add -A
    @home-manager switch --impure --flake .#\{{`whoami`}}@\{{`hostname`}} --show-trace
# Update flake and switch home-manager
ubuntu-upgrade-system:
    @cp flake.lock flake.lock-pre-upg-$(hostname)-$(date +%Y-%m-%d_%H-%M-%S)
    @nix flake update
    @home-manager switch --impure --upgrade --flake .#\{{`whoami`}}@\{{`hostname`}} --show-trace
