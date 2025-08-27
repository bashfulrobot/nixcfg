{ user-settings, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMonoNL Nerd Font Mono";
          show-actions = "yes";
          width = 64;
          tabs = 4;
          exit-on-keyboard-focus-loss = "yes";
        };
      };
    };
  };
}