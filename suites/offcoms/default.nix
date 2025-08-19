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
      chrome-based-browser.enable = true;
      vivaldi.enable = false;
      zen-browser.enable = false;
      gcal-br.enable = true;
      gmail-br.enable = true;
      br-drive.enable = true;
    };

    cli = {
      note.enable = true;
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
      unstable.todoist-electron # task manager
      # planify

      # Communications & AI
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs # AI assistant with MCP support

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

      # Networking
      unstable.wgnord
    ];

    services.flatpak.packages = [
      "net.xmind.XMind" # Mindmapping
    ];
  };
}
