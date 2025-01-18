{ user-settings, pkgs, secrets, config, lib, ... }:
let cfg = config.cli.yazi;
in {
  options = {
    cli.yazi.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable yazi file browser.";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [  ];

    home-manager.users."${user-settings.user.username}" = {

      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };

      programs.fish = {
        functions = {

          y = ''
              set tmp (mktemp -t "yazi-cwd.XXXXXX")
            	yazi $argv --cwd-file="$tmp"
            	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            		builtin cd -- "$cwd"
            	end
            	rm -f -- "$tmp"
          '';
        };
      };

    };
  };
}
