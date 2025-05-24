{ user-settings, config, ... }:

{
  # environment.systemPackages = with pkgs; [
  #   unstable.mas
  # ];
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

  homebrew.taps = [ "nrlquaker/createzap" "siderolabs/tap" ];

  # Prefer installing application from the Mac App Store
  homebrew.masApps = {
    "Todoist" = 585829637;
    "Iscreen Shoter" = 1596559494;
    "Hidden Bar" = 1452453066;
    "Save to Raindrop" = 1549370672;
    "1password for Safari" = 1569813296;
    "Wipr 2" = 1662217862;
    "Adblock Pro" = 1018301773;
    "Tailscale" = 1475387142;
    "Darkreader for Safari" = 1438243180;
    "Unread" = 1363637349;
    "Grammarly - Safari Writing Support" = 1462114288;
    "PDF Gear - Editor, Reader" = 6469021132;
    "Overlap: World Clock" = 1516950324;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    "1password"
    "1password-cli"
    "visual-studio-code"
    #"alacritty"
    #"font-victor-mono"
    # "raycast"
    # "todoist"
    # "tailscale"
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
    # "firefox"
    # "github-copilot-for-xcode"
    # "gpg-suite"

    # "multiviewer-for-f1"
    # "postman"
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
    "shellcheck"
    "just"
    "gh"
    "yazi"
    "direnv"
    "ncspot"
    "shadowenv"
    "npm"
    "sequoia-chameleon-gnupg"
    "sequoia-sq"
    "siderolabs/tap/talosctl"
    "kubectl"
    fontconfig
  ];
}
