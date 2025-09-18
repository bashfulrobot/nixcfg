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
    home-manager.users."${user-settings.user.username}" = {
      home.packages = with pkgs; [ claude-code-router ];
      
      xdg.configFile."../claude-code-router/config.json".text = builtins.toJSON {
        LOG = false;
        Providers = [
          {
            name = "ollama";
            api_base_url = "http://localhost:11434/v1/chat/completions";
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
    };
  };
}