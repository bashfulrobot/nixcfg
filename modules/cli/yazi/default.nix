{ user-settings, pkgs, config, lib, ... }:
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

      imports = [ ./build/keymap.nix ./build/plugins.nix ./build/settings.nix ];
      # Shortcuts for Yazi: https://yazi-rs.github.io/docs/quick-start/
      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
        initLua = ./init.lua;
        # keymap.manager.prepend_keymap = [{
        #   on = [ "!" ];
        #   run = "shell /run/current-system/sw/bin/fish --block";
        #   desc = "yazi to shell.";
        # }];
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
