{ user-settings, pkgs, config, lib, inputs, secrets, ... }:

let
  cfg = config.cli.crush;
in {

  options = {
    cli.crush.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Crush - A CLI for AI models with Ollama integration.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ 
      inputs.nix-ai-tools.packages.${pkgs.system}.crush
      
      # Language servers for crush LSP integration (all using unstable)
      unstable.gopls                                          # Go
      unstable.nil                                            # Nix
      unstable.nodePackages.bash-language-server             # Bash
      unstable.nodePackages.typescript-language-server       # JavaScript/TypeScript
      unstable.nodePackages.yaml-language-server             # YAML/Kubernetes
      unstable.yaml-language-server                           # Alternative YAML LSP
      unstable.marksman                                       # Markdown
      unstable.python312Packages.python-lsp-server           # Python
      unstable.rust-analyzer                                  # Rust
      unstable.terraform-ls                                   # Terraform
      unstable.vscode-langservers-extracted                   # HTML/CSS/JSON/ESLint from VSCode
      unstable.docker-language-server                         # Docker
      unstable.dockerfile-language-server                     # Dockerfile
      unstable.docker-compose-language-service                # Docker Compose
      unstable.postgres-lsp                                   # PostgreSQL
      
      # MCP dependencies
      unstable.nodejs                                         # For npm-based MCP servers
    ];
    
    home-manager.users."${user-settings.user.username}" = {
      
      # Create crush configuration directory and baseline config
      home.file.".config/crush/crush.json".text = builtins.toJSON {
        "$schema" = "https://charm.land/crush.json";
        
        providers = {
          ollama = {
            base_url = "http://localhost:11434/v1/";
            type = "openai";
            models = [
              {
                name = "Qwen 3 Latest";
                id = "qwen3:latest";
                context_window = 131072;
              }
              {
                name = "Llama 3.2 3B";
                id = "llama3.2:3b";
                context_window = 131072;
              }
              {
                name = "DeepSeek R1 1.5B";
                id = "deepseek-r1:1.5b";
                context_window = 131072;
              }
            ];
          };
        };
        
        # Default provider
        default_provider = "ollama";
        # Default model within the provider (qwen3 for coding)
        default_model = "qwen3:latest";
        
        # Options
        options = {
          attribution = {
            co_authored_by = false;
            generated_with = false;
          };
        };
        
        # Permissions - pre-allow standard Linux and development tools
        permissions = {
          allowed_tools = [
            "cat"
            "bat"
            "exa"
            "eza"
            "ls"
            "grep"
            "rg"
            "find"
            "fd"
            "head"
            "tail"
            "less"
            "more"
            "view"
            "edit"
            "git"
            "docker"
            "docker-compose"
            "kubectl"
            "helm"
            "terraform"
            "nix"
            "nix-env"
            "nix-shell"
            "nix-build"
            "nixos-rebuild"
            "statix"
            "systemctl"
            "journalctl"
            "ps"
            "top"
            "htop"
            "df"
            "du"
            "free"
            "curl"
            "wget"
            "ssh"
            "rsync"
            "tar"
            "zip"
            "unzip"
          ];
        };
        
        # Language Server Protocols (LSPs)
        lsp = {
          # Core development languages
          go = {
            command = "gopls";
          };
          
          nix = {
            command = "nil";
          };
          
          bash = {
            command = "bash-language-server";
            args = ["start"];
          };
          
          javascript = {
            command = "typescript-language-server";
            args = ["--stdio"];
          };
          
          typescript = {
            command = "typescript-language-server";
            args = ["--stdio"];
          };
          
          python = {
            command = "pylsp";
          };
          
          rust = {
            command = "rust-analyzer";
          };
          
          # Web development
          html = {
            command = "vscode-html-language-server";
            args = ["--stdio"];
          };
          
          css = {
            command = "vscode-css-language-server";
            args = ["--stdio"];
          };
          
          json = {
            command = "vscode-json-language-server";
            args = ["--stdio"];
          };
          
          # Infrastructure as Code
          terraform = {
            command = "terraform-ls";
            args = ["serve"];
          };
          
          yaml = {
            command = "yaml-language-server";
            args = ["--stdio"];
          };
          
          # Container/Docker
          dockerfile = {
            command = "docker-langserver";
            args = ["--stdio"];
          };
          
          # Database
          sql = {
            command = "postgres-lsp";
          };
          
          # Documentation
          markdown = {
            command = "marksman";
          };
        };
        
        # Model Content Protocols (MCPs)
        mcp = {
          # Filesystem operations
          filesystem = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-filesystem" "/home/${user-settings.user.username}"];
          };
          
          # Git operations
          git = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-git"];
          };
          
          # SQLite database access
          sqlite = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-sqlite"];
          };
          
          # Browser automation
          puppeteer = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-puppeteer"];
          };
          
          # Memory/notes system
          memory = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-memory"];
          };
          
          # Brave browser integration
          brave = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-brave-search"];
          };
          
          # Time/date utilities
          time = {
            type = "stdio";
            command = "npx";
            args = ["@modelcontextprotocol/server-time"];
          };
          
          # GitHub integration (uses GITHUB_TOKEN from secrets)
          github = {
            type = "stdio";
            command = "npx";
            args = ["@github/github-mcp-server"];
            env = {
              GITHUB_TOKEN = "${secrets.github.token}";
            };
          };
        };
      };

      # Create a shell alias for quick access
      programs.fish.shellAbbrs = {
        cr = "crush";
      };
      
    };
  };
}