{ user-settings, pkgs, config, lib, inputs, ... }:
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
    environment.systemPackages = [ inputs.ghostty.packages.${pkgs.system}.default ];

    home-manager.users."${user-settings.user.username}" = {

      programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };

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
        window-save-state = never
        shell-integration = fish
        # Theme handled by stylix
      '';
    };
  };
}
