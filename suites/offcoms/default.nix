{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.suites.offcoms;
in
{

  options = {
    suites.offcoms.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable office and communication tools .";
    };
  };

  config = lib.mkIf cfg.enable {

    programs = {
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # mtr.enable = true;
      # gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

    };

    apps = {
      browsers.firefox.enable = false;
      browsers.chrome-based-browser.enable = false;
      browsers.google-chrome.enable = false;
      browsers.brave.enable = false;
      browsers.vivaldi.enable = false;
      browsers.zen-browser.enable = true;
      browsers.zen-browser.setAsDefault = true;
      
      one-password.enable = true;
      obsidian.enable = true;
      gcal-br.enable = false;
      gmail-br.enable = false;
      br-drive.enable = false;
    };

    cli = {
      note.enable = true;
      espanso.enable = true;
      claude-code.enable = true;
      flameshot.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # projecteur # virtual laser pointer

      # PDF

      # evince # pdf viewer
      # texliveSmall # get pdflatex
      # pdf-sign # pdf signing utility
      kdePackages.okular # pdf viewer - can add sig stamps

      # Office
      # libreoffice # office suite

      # Organize
      unstable.morgen # AI calendar - testing
      unstable.todoist-electron # task manager
      # planify

      # Communications & AI
      # inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs # AI assistant with MCP support - temporarily disabled due to hash mismatch

      unstable.zoom-us

      # # IM
      # fractal # Matrix Client
      unstable.slack # instant messaging
      whatsapp-for-linux # instant messaging
      unstable.signal-desktop # instant messaging
      unstable.zulip
      # element-desktop # Matrix Client

      # Email
      unstable.meli # terminal email client
      gmailctl # cli to write gmail filters as code
      # thunderbird # email client
      # unstable.evolutionWithPlugins
      # mailspring # email client
      #geary # email reader

      # pandoc # document converter
      # lan-mouse # software kvm

      # Static Site Generation
      hugo # static site generator

      # Networking
      unstable.wgnord
    ];

    services.flatpak.packages = [
      "net.xmind.XMind" # Mindmapping
    ];
  };
}
