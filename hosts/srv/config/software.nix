{ config, pkgs, ... }: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # keep-sorted start case=no numeric=yes
    bat
    bottom
    cloud-utils
    curl
    du-dust
    eza
    fd
    gdu
    git
    git-crypt
    gnumake
    gnupg
    just
    nixfmt-rfc-style
    pass
    pinentry-tty
    ripgrep
    shadowenv
    tmux
    tree
    wakeonlan
    wget
    # keep-sorted end
  ];

  apps = { kvm.enable = true; };

  cli = {
    tailscale.enable = true;
    docker.enable = true;
    starship.enable = true;
    fish.enable = true;
    yazi.enable = false;
    helix.enable = true;
  };

}
