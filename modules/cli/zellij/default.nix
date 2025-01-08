{ user-settings, pkgs, secrets, config, lib, ... }:
let cfg = config.cli.zellij;
in {
  options = {
    cli.zellij.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable zellij.";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [  ];

    home-manager.users."${user-settings.user.username}" = {

      programs.zellij = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        settings = {
          scrollback_editor = "nvim";
          copy_command = "wl-copy";
          default_shell = lib.getExe pkgs.fish;
          scroll_buffer_size = 50000;
          default_layout = "compact";
          ui = {
            pane_frames.rounded_corners = true;
            ane_frames.hide_session_name = true;
          };
        };
      };

    };
  };
}
