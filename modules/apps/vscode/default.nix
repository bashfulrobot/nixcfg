{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.apps.vscode;
  inherit (config.lib.stylix) colors;
in {
  options = {
    apps.vscode.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the vscode editor.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.vscode
    ];
    home-manager.users."${user-settings.user.username}" = {
      # VSCode with Stylix theme integration - relies on settings sync for user configuration
      programs.vscode = {
        enable = true;
      };
      
      # Enable Stylix theming for VS Code
      stylix.targets.vscode = lib.mkIf (config.stylix.enable or false) {
        enable = true;
        profileNames = [ "default" ];
      };

      # force vscode to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
      home.file.".config/code-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
        --enable-features=WaylandWindowDecorations
      '';
    };
  };
}
