# If you start experiencing lag and FPS drops in games or programs like Blender on stable NixOS when using the Hyprland flake, it is most likely a mesa version mismatch between your system and Hyprland.
# - https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/
# You can fix this issue by using mesa from Hyprland’s nixpkgs input

{ user-settings, pkgs, inputs, config, lib, ... }:
let cfg = config.desktops.hyprland;
in {
  options = {
    desktops.hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hypland.";
    };
  };

  config = lib.mkIf cfg.enable {

    programs = {
      hyprland = {
        enable = true;

        # set the flake package
        package =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };

    environment.systemPackages = with pkgs; [ wl-clipboard ];
    # TODO: Update version periodically

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
