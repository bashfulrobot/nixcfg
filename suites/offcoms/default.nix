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
      # Install firefox.
      firefox.enable = false;
      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # mtr.enable = true;
      # gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

    };

    apps = {
      one-password.enable = true;
      obsidian.enable = true;
      chrome-based-browser.enable = false;
      google-chrome.enable = false;
      brave.enable = true;
    };

    cli = {
      espanso.enable = true;
      claude-code.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # projecteur # virtual laser pointer
      # Browsers
      #inputs.zen-browser.packages.x86_64-linux.zen-browser
      #(opera.override { proprietaryCodecs = true; })
      # brave
      # google-chrome
      # tangram

      # PDF
      xournalpp # note taking/pdf annotator
      # evince # pdf viewer
      # texliveSmall # get pdflatex
      # pdf-sign # pdf signing utility

      # Office
      # libreoffice # office suite

      # Organize
      # morgen # AI calendar - testing
      todoist-electron # task manager
      # planify

      # Communications & AI
      # inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs # AI assistant with MCP support - temporarily disabled due to hash mismatch

      zoom-us

      # # IM
      # fractal # Matrix Client
      slack # instant messaging
      whatsapp-for-linux # instant messaging
      signal-desktop # instant messaging
      zulip
      # element-desktop # Matrix Client

      # Email
      meli # terminal email client
      gmailctl # cli to write gmail filters as code
      # thunderbird # email client
      # evolutionWithPlugins
      # mailspring # email client
      #geary # email reader

      # pandoc # document converter
      # lan-mouse # software kvm

      # Networking
      wgnord
    ];

    services.flatpak.packages = [
      "net.xmind.XMind" # Mindmapping
    ];
  };
}
