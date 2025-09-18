{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.apps.ollama;
in {
  options = {
    apps.ollama = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Ollama local LLM service with AMD GPU support.";
      };

      acceleration = lib.mkOption {
        type = lib.types.enum [ "cpu" "rocm" ];
        default = "rocm";
        description = "GPU acceleration type. Use 'rocm' for AMD GPUs or 'cpu' for CPU-only.";
      };

      rocmOverrideGfx = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "10.3.0";  # RX 6800/6800 XT / 6900 XT (Navi 21)
        description = "Override ROCm GFX version for AMD GPU compatibility.";
      };

      loadModels = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "llama3.2:3b" "deepseek-r1:1.5b" ];
        description = "List of models to automatically load on service start.";
      };

      openWebUI = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Open WebUI for browser-based LLM interaction.";
      };

      host = {
        qbert = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable on qbert host only.";
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.host.qbert) {
    # Ollama service configuration
    services.ollama = {
      enable = true;
      acceleration = if cfg.acceleration == "cpu" then false else cfg.acceleration;
      inherit (cfg) loadModels;
    } // lib.optionalAttrs (cfg.acceleration == "rocm" && cfg.rocmOverrideGfx != null) {
      inherit (cfg) rocmOverrideGfx;
    };

    # Open WebUI for browser-based interaction
    services.open-webui = lib.mkIf cfg.openWebUI {
      enable = true;
      port = 3000;  # Use port 3000 to avoid conflicts with Docker containers
    };

    # System packages for LLM development and interaction
    environment.systemPackages = with pkgs; [
      # CLI tools for model management
      curl
      wget
      
      # Optional: GPU monitoring tools for AMD
      radeontop
      
      # Optional: System monitoring
      htop
      nvtopPackages.amd  # GPU monitoring for AMD GPUs
    ];

    # Enable ROCm for AMD GPU acceleration
    systemd.services.ollama = lib.mkIf (cfg.acceleration == "rocm") {
      environment = {
        # Ensure ROCm can find the GPU
        HSA_OVERRIDE_GFX_VERSION = lib.mkIf (cfg.rocmOverrideGfx != null) cfg.rocmOverrideGfx;
      };
    };

    # Create flag file for feature detection in build scripts
    home-manager.users."${user-settings.user.username}" = {
      home.file.".config/nix-flags/ollama-enabled".text = "";
    };

    # Open firewall ports for web access (optional)
    networking.firewall = {
      allowedTCPPorts = [ 
        11434  # Ollama API
      ] ++ lib.optionals cfg.openWebUI [ 
        3000   # Open WebUI default port
      ];
    };
  };
}