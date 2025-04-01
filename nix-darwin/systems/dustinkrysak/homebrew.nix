{ user-settings, config, lib, ... }:

{
  environment.shellInit = ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';
  programs.zsh.shellInit = ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
  programs.fish.interactiveShellInit = ''
    if test -d (brew --prefix)"/share/fish/completions"
      set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
      set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  '';

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    "nrlquaker/createzap"
  ];

  # Prefer installing application from the Mac App Store
  homebrew.masApps = {
    "Todoist" = 585829637;
    "Iscreen Shoter" = 1596559494;
    "Hidden Bar" = 1452453066;
    "Save to Raindrop" = 1549370672;
    "1password for Safari" = 1569813296;
    "Wipr 2" = 1662217862;
    "Adblock Pro" = 1018301773;
    "Kagi for Safari" = 1622835804;
    "Rocketchat" = 1086818840;
    "Tailscale" = 1475387142;
    "Darkreader for Safari" = 1438243180;
    "Unread" = 1363637349;
    "Fantastical" = 975937182;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    "1password"
    "1password-cli"
    "visual-studio-code"
    # "raycast"
    # "anki"
    # "arq"
    # "autodesk-fusion"
    # "balenaetcher"
    # "bambu-studio"
    # "betterdisplay"
    # "chatgpt"
    # "claude"
    # "clay"
    # "cleanmymac"
    # "cursor"
    # "discord"
    # "docker"
    # "element"
    # "etrecheckpro"
    # "firefox"
    # "github-copilot-for-xcode"
    # "google-chrome"
    # "google-drive"
    # "gpg-suite"
    # # "keybase"
    # "ledger-live"
    # "loopback"
    # "multiviewer-for-f1"
    # "notion"
    # "obsbot-center"
    # "parallels"
    # "pdf-expert"
    # "postman"
    # "protonvpn"
    "signal"
    # "sloth"
    # "steam"
    # "superhuman"
    # "superlist"
    # "tor-browser"
    # "transmission"
    # "transmit"

    # "vlc"
    # "yubico-yubikey-manager"
    # "zed"
  ];

  # Configuration related to casks
  home-manager.users."${user-settings.user.username}" = {
    programs.ssh.enable = true;
    programs.ssh.extraConfig = ''
      # Only set `IdentityAgent` not connected remotely via SSH.
      # This allows using agent forwarding when connecting remotely.
      Match host * exec "test -z $SSH_TTY"
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };

  # For cli packages that aren't currently available for macOS in `nixpkgs`. Packages should be
  # installed in `../home/packages.nix` whenever possible.
  homebrew.brews = [
    "just"
    "gh"
    "yazi"
    "direnv"
    "ncspot"
    "shadowenv"
    "npm"
  ];
}
