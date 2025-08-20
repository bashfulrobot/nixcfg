{ user-settings, pkgs, config, lib, inputs, ... }:
let 
  cfg = config.apps.claude-desktop;
  system = pkgs.system;
  
in {
  options = {
    apps.claude-desktop.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Claude Desktop with full MCP server support.";
    };
    
    apps.claude-desktop.withMcp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable MCP server support with FHS environment for npx, uvx, docker.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Claude Desktop with FHS environment for MCP server compatibility
    environment.systemPackages = with pkgs; [
      # Use FHS version when MCP enabled for npx/uvx/docker support
      (if cfg.withMcp 
       then inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
       else inputs.claude-desktop.packages.${system}.claude-desktop)
    ] ++ lib.optionals cfg.withMcp [
      # Core MCP server runtimes (as mentioned in upstream flake)
      nodejs_22                # For npx-based MCP servers
      python3                  # For uvx/uv-based MCP servers
      python3Packages.uv       # Modern Python package manager (uvx)
      docker                   # For docker-based MCP servers
    ];

    # Enable Docker for container-based MCP servers
    virtualisation.docker.enable = lib.mkIf cfg.withMcp true;
    
    # Add user to docker group for MCP server access
    users.users."${user-settings.user.username}".extraGroups = lib.optionals cfg.withMcp [ "docker" ];
  };
}