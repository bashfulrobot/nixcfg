{
  config,
  lib,
  pkgs,
  ...
}:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall formulae not in spec
    };
    
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/core"
      "homebrew/services"
      "nikitabobko/tap" # Added for aerospace
    ];

    # Homebrew packages (formulae)
    brews = [
      "nikitabobko/tap/aerospace" # Specify the full formula name
      # Add your other brew formulae here
    ];

    # Homebrew casks
    casks = [
      # Add your casks here
    ];
  };
}