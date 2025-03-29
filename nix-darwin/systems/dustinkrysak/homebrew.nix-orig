{ config, pkgs, ... }:

{
  homebrew = {
    enable = true;
    onActivation.upgrade = true;
    onActivation.autoUpdate = true;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    taps = [
      # "deskflow/homebrew-tap"
    ];
    brews = [
      "neovim"
      "just"
      "gh"
      ];
    casks = [
      # "hammerspoon"
      "1password-cli"
    ];
  };
}
