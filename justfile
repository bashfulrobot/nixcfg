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
    @echo "📋 NixOS Configuration Management Commands"
    @echo "=========================================="
    @just --list --unsorted
    @echo ""
    @echo "🔧 Commands with Parameters:"
    @echo "  build [trace=true]         - Add trace=true for detailed debugging"
    @echo "  rebuild [trace=true]       - Add trace=true for detailed debugging"
    @echo "  log [days=7]               - Show commits from last N days"
    @echo "  lint [target=.]            - Lint specific file/directory (use jlint for tab completion)"
    @echo "  pkg-search <query>         - Search for packages"
    @echo "  aos-init-project [type=nix] - Initialize project with Agent-OS (nix, go, bash)"
    @echo "  brand-icons <source> <target> - Create branded icons (e.g. gmail-br kong-email)"
    @echo "  backup-icons <app>         - Backup app icons before branding"
    @echo "  restore-icons <app>        - Restore original icons from backup"
    @echo ""
    @echo "💡 Pro Tips:"
    @echo "  • Use 'jlint <tab>' and 'jcheck <tab>' for file completion"
    @echo "  • Run 'just <command>' to see what each command does"
    @echo "  • Common workflow: just check → just build → just rebuild"

# === Development Commands ===
# Fast syntax validation without building
[group('dev')]
check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔍 Validating flake configuration..."
    git add -A
    nix flake check --show-trace

# Fast check of changed nix files only
[group('dev')]
check-diff:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⚡ Checking changed nix files..."

    # Get changed .nix files (working tree + staged)
    changed_files=$(git diff --name-only HEAD 2>/dev/null | grep '\.nix$' || true)
    staged_files=$(git diff --cached --name-only 2>/dev/null | grep '\.nix$' || true)
    all_changed=$(echo -e "$changed_files\n$staged_files" | sort | uniq | grep -v '^$' || true)

    if [[ -z "$all_changed" ]]; then
    echo "✅ No changed .nix files"
        exit 0
    fi

    echo "📁 Changed files:"
    echo "$all_changed" | sed 's/^/  /'

    # Quick syntax check on each file
    echo "🔍 Syntax check..."
    failed_files=""
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            if ! nix-instantiate --parse "$file" >/dev/null 2>&1; then
                failed_files="$failed_files$file\n"
            fi
        fi
    done <<< "$all_changed"

    if [[ -n "$failed_files" ]]; then
        echo "❌ Syntax errors in:"
        echo -e "$failed_files" | sed 's/^/  /'
        exit 1
    fi

    # Quick eval test - only if files are in critical paths
    critical_paths="flake.nix modules/ suites/ hosts/"
    needs_eval=false
    while IFS= read -r file; do
        for path in $critical_paths; do
            if [[ "$file" == $path* ]]; then
                needs_eval=true
                break 2
            fi
        done
    done <<< "$all_changed"

    if [[ "$needs_eval" == "true" ]]; then
        echo "🔍 Checking options and missing imports..."
        # Try targeted evals to catch missing options quickly
        if timeout 8 nix eval .#nixosConfigurations.{{hostname}}.options --quiet >/dev/null 2>&1; then
            echo "✅ All options available"
        else
            echo "❌ Options evaluation failed - likely missing option or import issue"
            echo "💡 Run 'just e' for detailed error"
            exit 1
        fi
    else
        echo "✅ No critical files changed, skipping option check"
    fi

    echo "✅ All checks passed"

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
    if [[ -f "$HOME/.config/nix-flags/gnome-enabled" ]]; then
        {{justfile_directory()}}/extras/helpers/fix-gtk-css.sh
    fi
    git add -A
    if [[ "{{trace}}" == "true" ]]; then
        echo "🔧 Development rebuild with trace..."
        just clean-full
        sudo nixos-rebuild switch --fast --impure --flake {{host_flake}} --show-trace 2>&1 | tee {{trace_log}}
    else
        echo "🔧 Development rebuild..."
        sudo nixos-rebuild switch --fast --impure --flake {{host_flake}}
    fi

# === Production Commands ===
# Production rebuild with bootloader
[group('prod')]
rebuild trace="false":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -f "$HOME/.config/nix-flags/gnome-enabled" ]]; then
        {{justfile_directory()}}/extras/helpers/fix-gtk-css.sh
    fi
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
    @sudo nixos-rebuild build-vm --fast --impure --flake {{host_flake}} --show-trace

# Full system upgrade
[group('prod')]
upgrade trace="false":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -f "$HOME/.config/nix-flags/gnome-enabled" ]]; then
        {{justfile_directory()}}/extras/helpers/fix-gtk-css.sh
    fi
    echo "⬆️  Upgrading system..."
    cp flake.lock flake.lock-backup-{{timestamp}}
    nix flake update
    if [[ "{{trace}}" == "true" ]]; then
        sudo nixos-rebuild switch --impure --upgrade --flake {{host_flake}} --show-trace
    else
        sudo nixos-rebuild switch --impure --upgrade --flake {{host_flake}}
    fi

# === Maintenance Commands ===
# Fix GTK CSS file conflicts with home-manager
[group('maintenance')]
fix-gtk:
    @{{justfile_directory()}}/extras/helpers/fix-gtk-css.sh

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

# Lint nix files (all by default, or specify a file/directory)
# Note: Use `jlint` function in fish for tab completion of file paths
[group('maintenance')]
lint target=".":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{target}}" == "." ]]; then
        echo "🔍 Linting all nix files..."
        fd -e nix --hidden --no-ignore --follow . -x statix check {}
    else
        echo "🔍 Linting {{target}}..."
        if [[ -f "{{target}}" ]]; then
            # Single file
            statix check "{{target}}"
        elif [[ -d "{{target}}" ]]; then
            # Directory
            fd -e nix --hidden --no-ignore --follow . "{{target}}" -x statix check {}
        else
            echo "❌ Target not found: {{target}}"
            exit 1
        fi
    fi

# Monitor COSMIC settings changes in real-time
[group('dev')]
cosmic-monitor:
    @echo "👁️  Monitoring COSMIC settings changes..."
    @echo "Press Ctrl+C to stop"
    @inotifywait -m -r -e create,modify,moved_to ~/.config/cosmic


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

# List available base16 color schemes for stylix
[group('info')]
themes:
    @echo "🎨 Available base16 themes ($(nix-shell -p base16-schemes --run 'ls /nix/store/*base16-schemes*/share/themes/ | wc -l') total):"
    @nix-shell -p base16-schemes --run 'ls /nix/store/*base16-schemes*/share/themes/ | sed "s/.yaml$//" | sort'

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

# Hard reset with cleanup
[group('git')]
reset-hard:
    @echo "⚠️  Hard reset with file cleanup..."
    @git fetch
    @git reset --hard HEAD
    @git clean -fd
    @git pull

# === Helper Commands ===
# Enhanced package search functionality
[group('helpers')]
pkg-search query:
    @echo "🔍 Searching for packages: {{query}}"
    @nix search nixpkgs {{query}}

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
    @if [ -f extras/helpers/nix-repl.sh ]; then extras/helpers/nix-repl.sh; fi

# Check for Agent-OS upstream updates
[group('helpers')]
aos-check-upstream:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔍 Checking Agent-OS upstream for updates..."
    CURRENT_COMMIT=$(grep "agentOsCommit" modules/cli/agent-os/default.nix | cut -d'"' -f2)
    LATEST_COMMIT=$(curl -s https://api.github.com/repos/buildermethods/agent-os/commits/main | jq -r .sha | cut -c1-7)
    echo "Current: $CURRENT_COMMIT"
    echo "Latest:  $LATEST_COMMIT"
    if [[ "$CURRENT_COMMIT" != "$LATEST_COMMIT" ]]; then
        echo "⚠️  Updates available!"
        echo "Run 'just aos-update' to update (manual review required)"
    else
        echo "✅ Up to date"
    fi

# Display Agent-OS configuration and project types
[group('helpers')]
aos-status:
    @echo "📋 Agent-OS Status"
    @echo "=================="
    @echo "📍 Installation: ~/.agent-os/"
    @echo "🔧 Config file: ~/.agent-os/config.yml"
    @echo ""
    @echo "📦 Available project types:"
    @ls -1 ~/.agent-os/project_types/ 2>/dev/null | sed 's/^/  - /' || echo "  No custom project types"
    @echo ""
    @echo "🎯 Default project type:"
    @grep "default_project_type:" ~/.agent-os/config.yml | sed 's/.*: /  /'
    @echo ""
    @echo "📁 Custom standards:"
    @find ~/.agent-os/project_types/ -name "*.md" 2>/dev/null | head -5 | sed 's/^/  /'

# Create new project with Agent-OS
[group('helpers')]
aos-init-project type="nix":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚀 Initializing {{type}} project with Agent-OS..."
    if [[ ! -f ~/.agent-os/setup/project.sh ]]; then
        echo "❌ Agent-OS not installed. Enable cli.agent-os in your NixOS config."
        exit 1
    fi
    ~/.agent-os/setup/project.sh --project-type={{type}}
    echo "✅ Project initialized with {{type}} standards"

# === Branded Icons ===
# Create branded work icons with Kong overlay (1/4 corner, pristine sources)
[group('branding')]
brand-icons source_app target_app:
    @echo "🎨 Creating branded {{target_app}} from {{source_app}}..."
    @./extras/helpers/create-branded-icons.sh extras/helpers/pristine-icons/work-overlay-logo.png {{source_app}} {{target_app}} 0.5 --pristine

# Backup app icons to pristine folder before branding
[group('branding')]
backup-icons app_name:
    @echo "💾 Backing up {{app_name}} icons..."
    @./extras/helpers/backup-icons.sh {{app_name}}

# List all apps and their backup status
[group('branding')]
list-icons:
    @./extras/helpers/backup-icons.sh --list

# Restore original icons from backup
[group('branding')]
restore-icons app_name:
    @echo "🔄 Restoring {{app_name}} from backup..."
    @./extras/helpers/backup-icons.sh --restore {{app_name}}

# === Workflow Aliases ===
alias c := check
alias d := check-diff
alias t := test
alias b := build
alias r := rebuild
alias up := upgrade
alias gc := clean
alias l := log