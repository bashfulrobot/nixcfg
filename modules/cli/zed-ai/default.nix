{ user-settings, lib, pkgs, config, secrets, ... }:
let
  cfg = config.cli.zed-ai;
  zedaiSecrets = secrets.zedai or {};
in {
  options = {
    cli.zed-ai.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GLM-4.6 integration with claude-code via Z.AI API.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create feature flag to indicate zed-ai is enabled
    home-manager.users."${user-settings.user.username}" = {
      home.file.".config/nix-flags/zed-ai-enabled".text = "";

      programs.fish.shellInit = lib.mkAfter ''
        # GLM-4.6 integration via Z.AI API
        set -gx ANTHROPIC_BASE_URL "${zedaiSecrets.base_url or "https://api.z.ai/api/anthropic"}"
        set -gx ANTHROPIC_AUTH_TOKEN "${zedaiSecrets.auth_token or ""}"
      '';

      programs.fish.functions = {
        zed-ai-status = {
          description = "Show current ZED-AI configuration status";
          body = ''
            echo "ZED-AI GLM-4.6 Integration Status:"
            echo "=================================="
            if test -n "$ANTHROPIC_BASE_URL"
              echo "✓ ANTHROPIC_BASE_URL: $ANTHROPIC_BASE_URL"
            else
              echo "✗ ANTHROPIC_BASE_URL: Not set"
            end

            if test -n "$ANTHROPIC_AUTH_TOKEN"
              echo "✓ ANTHROPIC_AUTH_TOKEN: Set ($(string length "$ANTHROPIC_AUTH_TOKEN") characters)"
            else
              echo "✗ ANTHROPIC_AUTH_TOKEN: Not set"
            end

            if test -f ~/.config/nix-flags/zed-ai-enabled
              echo "✓ Module Status: Enabled"
            else
              echo "✗ Module Status: Disabled"
            end
          '';
        };

        zed-ai-unset = {
          description = "Unset ZED-AI environment variables in current session";
          body = ''
            set -e ANTHROPIC_BASE_URL
            set -e ANTHROPIC_AUTH_TOKEN
            echo "ZED-AI environment variables unset for current session"
            echo "Note: Variables will be restored on next shell reload"
          '';
        };

        zed-ai-set = {
          description = "Manually set ZED-AI environment variables in current session";
          body = ''
            set -gx ANTHROPIC_BASE_URL "${zedaiSecrets.base_url or "https://api.z.ai/api/anthropic"}"
            set -gx ANTHROPIC_AUTH_TOKEN "${zedaiSecrets.auth_token or ""}"
            echo "ZED-AI environment variables set for current session"
          '';
        };
      };

      programs.fish.shellAbbrs = {
        zed-status = {
          position = "command";
          setCursor = false;
          expansion = "zed-ai-status";
        };
      };
    };

    # Ensure claude-code is available for GLM-4.6 integration
    assertions = [
      {
        assertion = config.cli.claude-code.enable;
        message = "cli.zed-ai requires cli.claude-code to be enabled";
      }
      {
        assertion = zedaiSecrets ? auth_token && zedaiSecrets.auth_token != "";
        message = "cli.zed-ai requires zedai.auth_token to be set in secrets.json";
      }
    ];
  };
}