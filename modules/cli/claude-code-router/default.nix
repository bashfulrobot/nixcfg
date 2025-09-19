{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.cli.claude-code-router;
  claude-code-router = pkgs.callPackage ./build { };

in {
  options = {
    cli.claude-code-router.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable claude-code-router - Route Claude Code requests to different models.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Docker as a dependency
    cli.docker.enable = true;

    home-manager.users."${user-settings.user.username}" = {
      
      home.file = {
        "docker/claude-code-router-config/config.json".text = builtins.toJSON {
          LOG = false;
          Providers = [
            {
              name = "ollama";
              api_base_url = "http://host.docker.internal:11434/v1/chat/completions";
              api_key = "ollama";
              models = [
                "qwen3:latest"
                "llama3.2:3b"
                "deepseek-r1:1.5b"
              ];
            }
          ];
          Router = {
            default = "ollama,qwen3:latest";
            "/model ollama" = "ollama,qwen3:latest";
            "/model qwen" = "ollama,qwen3:latest";
            "/model llama" = "ollama,llama3.2:3b";
            "/model deepseek" = "ollama,deepseek-r1:1.5b";
          };
        };

        "docker/claude-code-router-config/docker-compose.yml".text = ''
          services:
            claude-code-router:
              build: ./claude-code-router
              ports:
                - "3456:3456"
              volumes:
                - ./config.json:/root/.claude-code-router/config.json
              restart: unless-stopped
        '';
      };

      programs.fish.functions = {
        ccr-init = ''
          echo "🚀 Setting up claude-code-router..."
          
          # Create docker directory and navigate to config folder
          mkdir -p ~/docker
          cd ~/docker/claude-code-router-config
          
          # Clone the repository if it doesn't exist
          if test -d claude-code-router
            echo "📁 claude-code-router directory already exists"
            cd claude-code-router
            echo "🔄 Pulling latest changes..."
            git pull
            cd ..
          else
            echo "📦 Cloning claude-code-router repository..."
            git clone https://github.com/musistudio/claude-code-router.git
          end
          
          # Start the service using our custom docker compose
          echo "🔨 Building and starting claude-code-router service..."
          docker compose up -d
          
          echo "✅ claude-code-router is now running!"
          echo "💡 Use 'ccr <command>' to interact with it"
          echo "💡 Use 'ccr-stop' to stop the service"
        '';

        ccr-stop = ''
          if test -d ~/docker/claude-code-router-config
            cd ~/docker/claude-code-router-config
            echo "🛑 Stopping claude-code-router service..."
            docker compose down
            echo "✅ Service stopped"
          else
            echo "❌ claude-code-router-config not found. Run 'ccr-init' first."
          end
        '';

        ccr = ''
          # Check if service is running
          if not docker ps | grep -q claude-code-router-config
            echo "❌ claude-code-router service is not running"
            echo "💡 Run 'ccr-init' to set up and start the service"
            return 1
          end
          
          # Execute command in the running container
          docker exec -it (docker ps -q -f name=claude-code-router-config) ccr $argv
        '';
      };
    };
  };
}