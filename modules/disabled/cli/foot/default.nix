{ user-settings, pkgs, secrets, config, lib, ... }:
let cfg = config.cli.foot;
in {
  options = {
    cli.foot.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Foot Terminal.";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [  ];

    home-manager.users."${user-settings.user.username}" = {

      programs.foot = {
        enable = true;
        server.enable = true;
        # enableBashIntegration = true;
        # enableFishIntegration = true;
        settings = {
          main = {
            shell = "${pkgs.fish}/bin/fish";
            font = "JetBrainsMono Nerdfont:size=18";
            pad = "12x12";
            dpi-aware = "yes";
            line-height = 20;
            selection-target = "both";
          };
          colors = { alpha = 0.8; };
          mouse = { hide-when-typing = "yes"; };
          scrollback = { lines = 50000; };
          csd = { size = 0; };
        };
      };

    };
  };
}
