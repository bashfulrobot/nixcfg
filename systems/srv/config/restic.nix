{ user-settings, config, pkgs, secrets, ... }: {

  systemPackages = with pkgs; [ restic autorestic ];
  home-manager.users."${user-settings.user.username}" = {

  };
}
