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

      # Shell aliases for convenience
      programs.fish.shellAliases = {
        aos-project-init = "${user-settings.user.home}/.agent-os/setup/project.sh";
        aos-config = "cat ${user-settings.user.home}/.agent-os/config.yml";
        aos-standards-nix = "ls -la ${user-settings.user.home}/.agent-os/project_types/nix/standards/";
        aos-standards-go = "ls -la ${user-settings.user.home}/.agent-os/project_types/go/standards/";
        aos-standards-bash = "ls -la ${user-settings.user.home}/.agent-os/project_types/bash/standards/";
        aos-project-init-nix = "${user-settings.user.home}/.agent-os/setup/project.sh nix";
        aos-project-init-go = "${user-settings.user.home}/.agent-os/setup/project.sh go";
        aos-project-init-bash = "${user-settings.user.home}/.agent-os/setup/project.sh bash";
      };
    };
  };
}