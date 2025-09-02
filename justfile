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

# Quick syntax check without building or evaluation
[group('dev')]
syntax:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "⚡ Quick syntax check..."
    nix flake check --no-build 2>/dev/null || echo "❌ Syntax issues detected"

# Fast evaluation check (validates options without building packages)
[group('dev')]
eval-check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔍 Quick evaluation check..."
    git add -A
    if nix eval .#nixosConfigurations.{{hostname}}.config --quiet >/dev/null 2>&1; then
        echo "✅ Configuration evaluates successfully"
    else
        echo "❌ Configuration evaluation failed"
        nix eval .#nixosConfigurations.{{hostname}}.config --quiet 2>&1 | head -20
    fi

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

# Interactive theme selector using fuzzel
[group('info')]
theme-select:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🎨 Select a base16 theme..."
    selected=$(nix-shell -p base16-schemes --run 'ls /nix/store/*base16-schemes*/share/themes/ | sed "s/.yaml$//" | sort' | fuzzel --dmenu --prompt "Theme: ")
    if [[ -n "$selected" ]]; then
        echo "✨ Selected theme: $selected"
        echo "📝 To use this theme, update settings/settings.json:"
        echo "   \"handmade-scheme\": \"$selected\""
        echo "💡 Or run: just set-theme $selected"
    fi

# Set theme in settings.json and optionally rebuild
[group('info')]
set-theme theme rebuild="false":
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Validate theme exists
    if ! nix-shell -p base16-schemes --run 'ls /nix/store/*base16-schemes*/share/themes/ | sed "s/.yaml$//"' | grep -q "^{{theme}}$"; then
        echo "❌ Theme '{{theme}}' not found. Run 'just themes' to see available themes."
        exit 1
    fi
    
    echo "🎨 Setting theme to: {{theme}}"
    
    # Update settings.json
    if command -v jq >/dev/null; then
        jq '.theme."handmade-scheme" = "{{theme}}"' settings/settings.json > settings/settings.json.tmp
        mv settings/settings.json.tmp settings/settings.json
        echo "✅ Updated settings/settings.json"
    else
        echo "⚠️  jq not available. Please manually update settings/settings.json:"
        echo "   \"handmade-scheme\": \"{{theme}}\""
    fi
    
    # Optionally rebuild
    if [[ "{{rebuild}}" == "true" ]]; then
        echo "🔄 Rebuilding system..."
        just build
    else
        echo "💡 Run 'just build' to apply the new theme"
    fi

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

# === Workflow Aliases ===
alias c := check
alias s := syntax
alias e := eval-check
alias d := check-diff
alias t := test
alias b := build
alias r := rebuild
alias up := upgrade
alias gc := clean
alias l := log