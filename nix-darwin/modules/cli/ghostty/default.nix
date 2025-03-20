{ user-settings, pkgs, config, lib, ... }:
let cfg = config.cli.ghostty;
in {
  options = {
    cli.ghostty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ghostty terminal.";
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
    enable = true;
    onActivation.upgrade = true;
    onActivation.autoUpdate = true;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    taps = [];
    brews = [

      ];
    casks = [
      "ghostty"
    ];
  };

    home-manager.users."${user-settings.user.username}" = {
      # https://ghostty.org/docs/config
      home.file.".config/ghostty/config".text = ''
        font-size = 16
        cursor-style = block
        window-theme = system
        working-directory = ~/dev
        custom-shader-animation = true
        clipboard-read = allow
        clipboard-write = allow
        window-padding-x = 10
        window-padding-y = 10
        window-padding-balance = true
        window-padding-color = extend-always
        cursor-style-blink = true
        mouse-hide-while-typing = true
      '';
    };
  };
}
