{ user-settings, pkgs, config, lib, secrets, ... }:
let 
  cfg = config.dev.cachix;
in {
  options = {
    dev.cachix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable cachix binary cache management tools.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Authentication setup for cachix
    environment.variables = {
      CACHIX_AUTH_TOKEN = secrets.cachix.auth_token;
    };

    # Cachix and helper scripts
    environment.systemPackages = with pkgs; [
      cachix # Binary cache client for pushing/pulling packages
      
      (writeShellScriptBin "cachix-auth" ''
        # Authenticate with cachix using token from secrets
        echo "🔐 Authenticating with cachix..."
        echo "${secrets.cachix.auth_token}" | cachix authtoken --stdin
        echo "✅ Cachix authentication successful!"
      '')
      
      (writeShellScriptBin "push-to-bashfulrobot-cache" ''
        # Generic helper to push build results to bashfulrobot cache
        if [[ $# -eq 0 ]]; then
          echo "Usage: push-to-bashfulrobot-cache <nix-build-result-path>"
          echo "Example: push-to-bashfulrobot-cache ./result"
          exit 1
        fi
        
        BUILD_RESULT="$1"
        if [[ ! -e "$BUILD_RESULT" ]]; then
          echo "❌ Build result not found: $BUILD_RESULT"
          exit 1
        fi
        
        echo "🔐 Authenticating with cachix..."
        echo "${secrets.cachix.auth_token}" | cachix authtoken --stdin
        
        echo "📦 Pushing $BUILD_RESULT to bashfulrobot cache..."
        nix-store -qR "$BUILD_RESULT" | cachix push bashfulrobot
        
        echo "✅ Successfully pushed to bashfulrobot cache!"
        echo "🔗 Cache: https://bashfulrobot.cachix.org"
      '')
    ];

    # Configure bashfulrobot binary cache
    nix.settings = {
      substituters = [ "https://bashfulrobot.cachix.org" ];
      trusted-public-keys = [ "bashfulrobot.cachix.org-1:dV0OEgd/ccYivTMyL8nsIE4nmlSZs+X30bTrvgPL7rg=" ];
    };
  };
}