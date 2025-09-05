{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.ghostty;
  ghostty-tip = pkgs.callPackage ./build { };
in
{
  options = {
    cli.ghostty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ghostty terminal.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ ghostty-tip ];

    # Configure nautilus to use ghostty when enabled
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };

    home-manager.users."${user-settings.user.username}" = {
      # https://ghostty.org/docs/config
      home.file.".config/ghostty/config".text = ''
        font-size = 16
        cursor-style = block
        cursor-opacity = 0.7
        cursor-style-blink = true
        link-url = true
        title = " "
        window-theme = system
        working-directory = ~/dev
        custom-shader-animation = true
        clipboard-read = allow
        clipboard-write = allow
        clipboard-trim-trailing-spaces = true
        copy-on-select = true
        window-padding-x = 10
        window-padding-y = 10
        window-padding-balance = true
        window-padding-color = extend-always
        window-decoration = auto
        mouse-hide-while-typing = true
        window-save-state = never
        shell-integration = fish
        shell-integration-features = true
        confirm-close-surface = false
        gtk-titlebar-hide-when-maximized = true
        # Theme handled by stylix
      '';
    };
  };
}
