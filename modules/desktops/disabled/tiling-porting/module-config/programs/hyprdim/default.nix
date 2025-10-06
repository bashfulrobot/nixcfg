{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    hyprdim
  ];

  systemd.user.services = {
    hyprdim = {
      description = "Hyprdim - Window dimming for Hyprland";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hyprdim}/bin/hyprdim --strength 0.5 --duration 600 --fade 5 --dialog-dim 0.8";
        Restart = "on-failure";
        RestartSec = 2;
        TimeoutStopSec = 10;
      };
    };
  };
}