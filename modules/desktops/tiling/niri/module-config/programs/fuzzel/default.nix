{ user-settings, lib, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = lib.mkForce "JetBrainsMonoNL Nerd Font Mono";
          width = 64;
          tabs = 4;
        };
        # Add other sections like colors, etc.
      };
    };
  };
}