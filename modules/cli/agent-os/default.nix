{ user-settings, lib, pkgs, config, ... }:
let
  cfg = config.cli.agent-os;

  # Version pinning for reproducibility
  agentOsVersion = "1.4.1";
  agentOsCommit = "main"; # Use main for now, will pin to specific commit later

  # Helper function to fetch Agent-OS files
  fetchAgentOsFile = path: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/buildermethods/agent-os/${agentOsCommit}/${path}";
    sha256 =
      if path == "setup/functions.sh" then "sha256-o+XJw0pyf8Bnv0oNSvZZKpFPs8lxPWHjRGuWltdfVaM="
      else if path == "setup/project.sh" then "sha256-utgqyhpJgcGkhtelcHGYz2AxK3iPptEE9+zucjV+W3k="
      else lib.fakeSha256;
  };

  # Fetch the entire Agent-OS repository once
  agentOsRepo = pkgs.fetchFromGitHub {
    owner = "buildermethods";
    repo = "agent-os";
    rev = agentOsCommit;
    sha256 = "sha256-RtD3F2i7TeJ1P4YBKt4e4dxSWYDVj28Aspz83P2abdA=";
  };

in {
  options = {
    cli.agent-os = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Agent-OS with NixOS-managed installation and custom project type";
      };

      enableClaudeCode = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Claude Code agent configurations";
      };

      version = lib.mkOption {
        type = lib.types.str;
        default = agentOsVersion;
        description = "Agent-OS version to install";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {

      # Core Agent-OS configuration with custom project types
      home.file.".agent-os/config.yml".text = ''
        # Agent OS Configuration
        # Managed by NixOS - Do not edit manually

        agent_os_version: ${cfg.version}

        agents:
          claude_code:
            enabled: ${if cfg.enableClaudeCode then "true" else "false"}
          cursor:
            enabled: false

        project_types:
          default:
            instructions: ~/.agent-os/instructions
            standards: ~/.agent-os/standards

          nix:
            instructions: ~/.agent-os/instructions
            standards: ~/.agent-os/project_types/nix/standards

          go:
            instructions: ~/.agent-os/instructions
            standards: ~/.agent-os/project_types/go/standards

          bash:
            instructions: ~/.agent-os/instructions
            standards: ~/.agent-os/project_types/bash/standards

        default_project_type: nix
      '';

      # Core Agent-OS setup scripts (make executable)
      home.file.".agent-os/setup/functions.sh".source = fetchAgentOsFile "setup/functions.sh";
      home.file.".agent-os/setup/project.sh" = {
        source = fetchAgentOsFile "setup/project.sh";
        executable = true;
      };

      # Upstream directories from Agent-OS repo
      home.file.".agent-os/instructions".source = agentOsRepo + "/instructions";
      home.file.".agent-os/standards".source = agentOsRepo + "/standards";
      home.file.".agent-os/commands".source = agentOsRepo + "/commands";

      # Claude Code agents (conditional)
      home.file.".agent-os/claude-code".source = lib.mkIf cfg.enableClaudeCode (
        agentOsRepo + "/claude-code"
      );

      # Nix project type (NixOS projects, may include bash scripts)
      home.file.".agent-os/project_types/nix/standards/tech-stack.md".source =
        ./module-config/tech-stack.md;
      home.file.".agent-os/project_types/nix/standards/code-style/nix-style.md".source =
        ./module-config/nix-style.md;
      home.file.".agent-os/project_types/nix/standards/code-style/bash-style.md".source =
        ./module-config/bash-style.md;
      home.file.".agent-os/project_types/nix/standards/code-style/justfile-style.md".source =
        ./module-config/justfile-style.md;

      # Go project type (uses justfiles)
      home.file.".agent-os/project_types/go/standards/tech-stack.md".text = ''
        # Go Project Tech Stack

        ## Core Technologies
        - Language: Go 1.21+
        - Build Tool: Go modules
        - Package Manager: go mod
        - Task Runner: Justfile
        - Testing: Go built-in testing
        - Linting: golangci-lint
        - Formatting: gofmt, goimports

        ## Infrastructure (from base tech-stack)
        ${builtins.readFile ./module-config/tech-stack.md}
      '';
      home.file.".agent-os/project_types/go/standards/code-style/go-style.md".source =
        ./module-config/go-style.md;
      home.file.".agent-os/project_types/go/standards/code-style/justfile-style.md".source =
        ./module-config/justfile-style.md;

      # Bash project type (uses justfiles)
      home.file.".agent-os/project_types/bash/standards/tech-stack.md".text = ''
        # Bash Project Tech Stack

        ## Core Technologies
        - Language: Bash 5.0+
        - Task Runner: Justfile
        - Testing: bats-core
        - Linting: shellcheck
        - Formatting: shfmt
        - UI Framework: gum (for interactive scripts)

        ## Infrastructure (from base tech-stack)
        ${builtins.readFile ./module-config/tech-stack.md}
      '';
      home.file.".agent-os/project_types/bash/standards/code-style/bash-style.md".source =
        ./module-config/bash-style.md;
      home.file.".agent-os/project_types/bash/standards/code-style/justfile-style.md".source =
        ./module-config/justfile-style.md;

      # Shell alias to navigate to Agent-OS directory
      programs.fish.shellAliases = {
        aos = "cd ${user-settings.user.home}/.agent-os";
      };

      # Agent-OS management justfile
      home.file.".agent-os/justfile".text = ''
        # Agent-OS Management Commands
        # https://github.com/casey/just

        # === Settings ===
        set dotenv-load := true
        set ignore-comments := true
        set shell := ["bash", "-euo", "pipefail", "-c"]

        # === Variables ===
        config_file := justfile_directory() + "/config.yml"
        nixos_module := env_var_or_default("HOME", "") + "/dev/nix/nixcfg/modules/cli/agent-os/default.nix"

        # === Help ===
        # Show available Agent-OS commands
        default:
            @echo "🤖 Agent-OS Management Commands"
            @echo "==============================="
            @just --list --unsorted
            @echo ""
            @echo "🔧 Commands with Parameters:"
            @echo "  init-project [type=nix]     - Initialize project (nix, go, bash)"
            @echo ""
            @echo "💡 Usage:"
            @echo "  cd ~/.agent-os && just <command>"
            @echo "  Or use fish alias: aos && just <command>"

        # === Project Management ===
        # Initialize new project with Agent-OS
        [group('project')]
        init-project type="nix":
            #!/usr/bin/env bash
            set -euo pipefail
            echo "🚀 Initializing {{type}} project with Agent-OS..."
            if [[ ! -f ./setup/project.sh ]]; then
                echo "❌ Agent-OS project.sh not found. Check installation."
                exit 1
            fi
            ./setup/project.sh --project-type={{type}}
            echo "✅ Project initialized with {{type}} standards"

        # === Information Commands ===
        # Display Agent-OS configuration and status
        [group('info')]
        status:
            @echo "📋 Agent-OS Status"
            @echo "=================="
            @echo "📍 Installation: $(pwd)"
            @echo "🔧 Config file: $(pwd)/config.yml"
            @echo ""
            @echo "📦 Available project types:"
            @ls -1 ./project_types/ 2>/dev/null | sed 's/^/  - /' || echo "  No custom project types"
            @echo ""
            @echo "🎯 Default project type:"
            @grep "default_project_type:" ./config.yml | sed 's/.*: /  /' || echo "  Not configured"
            @echo ""
            @echo "📁 Custom standards:"
            @find ./project_types/ -name "*.md" 2>/dev/null | head -5 | sed 's|^\./|  |' || echo "  No custom standards found"

        # Show Agent-OS configuration file
        [group('info')]
        config:
            @echo "📄 Agent-OS Configuration:"
            @echo "=========================="
            @cat ./config.yml

        # List all available standards files
        [group('info')]
        standards:
            @echo "📚 Available Standards:"
            @echo "======================"
            @echo ""
            @echo "🔹 Upstream (default):"
            @find ./standards/ -name "*.md" 2>/dev/null | sed 's|^\./|  |' || echo "  No upstream standards"
            @echo ""
            @echo "🔸 Custom project types:"
            @find ./project_types/ -name "*.md" 2>/dev/null | sed 's|^\./|  |' || echo "  No custom standards"

        # === Update Management ===
        # Check for Agent-OS upstream updates
        [group('update')]
        check-upstream:
            #!/usr/bin/env bash
            set -euo pipefail
            echo "🔍 Checking Agent-OS upstream for updates..."

            if [[ -f "{{nixos_module}}" ]]; then
                CURRENT_COMMIT=$(grep "agentOsCommit" "{{nixos_module}}" | cut -d'"' -f2)
                echo "Current: $CURRENT_COMMIT"
            else
                echo "⚠️  NixOS module not found at {{nixos_module}}"
                echo "Current: Unknown"
            fi

            LATEST_COMMIT=$(curl -s https://api.github.com/repos/buildermethods/agent-os/commits/main | jq -r .sha | cut -c1-7)
            echo "Latest:  $LATEST_COMMIT"

            if [[ "$CURRENT_COMMIT" != "$LATEST_COMMIT" ]] && [[ "$CURRENT_COMMIT" != "main" ]]; then
                echo "⚠️  Updates available!"
                echo "Update via NixOS rebuild after updating agentOsCommit in module"
            else
                echo "✅ Up to date (or using 'main' branch)"
            fi

        # === Development ===
        # Test project initialization in temporary directory
        [group('dev')]
        test-init type="nix":
            #!/usr/bin/env bash
            set -euo pipefail
            TEST_DIR="/tmp/agent-os-test-$(date +%s)"
            echo "🧪 Testing {{type}} project initialization in $TEST_DIR"
            mkdir -p "$TEST_DIR"
            cd "$TEST_DIR"
            ~/.agent-os/setup/project.sh --project-type={{type}}
            echo "✅ Test completed in $TEST_DIR"
            echo "🗑️  Clean up with: rm -rf $TEST_DIR"
      '';
    };
  };
}