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
      # Some programs need SUID wrapper, can be configured further or are
      # started in user sessions.
      # mtr.enable = true;
      # gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

    };

    apps = {
      browsers = {
        firefox = {
          enable = false;
          setAsDefault = false;
        };
        chrome-based-browser.enable = false;
        google-chrome = {
          enable = false;
          setAsDefault = false;
        };
        brave.enable = false;
        vivaldi = {
          enable = true;
          setAsDefault = true;
        };
        zen-browser = {
          enable = false;
          setAsDefault = false;
        };
      };

      one-password.enable = true;
      obsidian.enable = true;
      br-gcal.enable = true;
      br-gmail.enable = true;
      br-drive.enable = true;
      zoom-us = {
        enable = true;
        downgrade = false;
      };
      zoom-flatpak.enable = false;
      slack.enable = true;
    };

    cli = {
      note.enable = true;
      espanso.enable = false;
      claude-code.enable = true;
      flameshot.enable = false;
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

      #unstable.zoom-us

      # # IM
      # fractal # Matrix Client
      whatsapp-for-linux # instant messaging
      unstable.signal-desktop # instant messaging
      unstable.zulip
      # element-desktop # Matrix Client

      # Email
      meli # terminal email client
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
