{ pkgs, lib, ... }:
{

  nix = {
    # Determinate uses its own daemon to manage the Nix installation that conflicts with nix-darwin’s native Nix management.
    # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-nix.enable
    enable = false;
  };

  # TODO: find alternative after 25.05 update
  system.userActivationScripts.text = ''
    Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system = {
    stateVersion = 5;
  };
}
