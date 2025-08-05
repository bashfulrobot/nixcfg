{
  config,
  pkgs,
  lib,
  ...
}:
# General CLI packages for home-manager installation

{
  home.packages = with pkgs; [
    # Note: atuin handled by programs.atuin.enable in fish.nix
    # Note: fzf handled by programs.fzf.enable in fish.nix  
    # Note: starship handled by programs.starship.enable in starship.nix
    # Add explicit packages to ensure they're in PATH
    fd
    fzf
    atuin
    starship
    gemini-cli
    eza
    yazi
    nix-index
    mpv
    kubectl
    terraform
    gdu
    kubecolor
    du-dust
    procs
    gping
    jless
  ];

  programs = {
    autojump = {
      enable = false;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    # nix-search-tv = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableFishIntegration = true;
    #   enableZshIntegration = true;
    # };
    ripgrep.enable = true;
    btop.enable = true;
    tealdeer.enable = true;
  };
}
