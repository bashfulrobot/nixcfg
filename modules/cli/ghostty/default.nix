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
    environment.systemPackages = with pkgs; [
      inputs.ghostty.packages.x86_64-linux.default
     ];

    home-manager.users."${user-settings.user.username}" = {
    # https://ghostty.org/docs/config
        home.file.".config/ghostty/config".text = ''
          font-size = 16
          cursor-style = block
          mouse-hide-while-typing = true
          window-padding-x = 10
          window-padding-balance = true
          window-theme = system
        '';
    };
  };
}
