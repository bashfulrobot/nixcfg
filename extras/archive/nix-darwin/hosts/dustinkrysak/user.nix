{ user-settings, pkgs, ... }:

{

  system.primaryUser = "dustin.krysak";

  #  error:
  #    Failed assertions:
  #    - users.users.dustin.krysak.shell is set to fish, but
  #    programs.fish.enable is not true. This will cause the fish
  #    shell to lack the basic Nix directories in its PATH and might make
  #  logging in as that user impossible. You can fix it with:
  #  programs.fish.enable = true;
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${user-settings.user.username}" = {
    description = "${user-settings.user.full-name}";
    shell = pkgs.fish;
    home = "${user-settings.user.home}";
  };

}
