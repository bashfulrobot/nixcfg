{ user-settings, config, lib, pkgs, ... }:
let cfg = config.cli.hammerspoon;
in {
  options = {
    cli.hammerspoon.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable hammerspoon.";
    };
  };

  config = lib.mkIf cfg.enable {

    homebrew = {
      # taps = [ "sylvanfranklin/srhd" ];
      # brews = [ "sylvanfranklin/srhd/srhd" ];
      casks = [ "hammerspoon" ];
    };

    system.defaults.CustomUserPreferences."org.hammerspoon.Hammerspoon" = {
      MJShowMenuIconKey = false; # hide menu bar icon
      MJKeepConsoleOnTopKey = true; # console always on top
    };

    # Add srhd to launch at login
    # launchd.user.agents.srhd = {
    #   path = [ cfg.package ];
    #   command = "${cfg.package}/bin/ollama serve";
    #   environment = { OLLAMA_HOST = "${cfg.hostname}:${toString cfg.port}"; };
    #   serviceConfig = {
    #     KeepAlive = true;
    #     RunAtLoad = true;
    #     ProcessType = "Background";
    #   };
    # };

    home-manager.users."${user-settings.user.username}" = {

      home.file.".hammerspoon/init.lua" = {
        text = ''
                   
          for num = 1, 9 do
            local name = tostring(num)
            hs.hotkey.bind("cmd", name, function()
              local command = "${pkgs.yabai}/bin/yabai -m space --focus " .. name
              hs.execute(command)
            end)
            hs.hotkey.bind({"cmd", "shift"}, name, function()
              local win = hs.window.focusedWindow()
              if win then
                local screen = win:screen()
                local spaces = hs.spaces.spacesForScreen(screen)
                if spaces and spaces[num] then
                  hs.spaces.moveWindowToSpace(win, spaces[num], true)
                end
              end
            end)
          end        '';
      };

    };

  };

}
