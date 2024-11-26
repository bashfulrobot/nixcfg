{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./config/autoimport.nix
    ../../modules/autoimport.nix
    ../../archetype/autoimport.nix
    # ../../suites/autoimport.nix
  ];

  programs = {
    # Install firefox.
    firefox.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ git git-crypt neovim ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
