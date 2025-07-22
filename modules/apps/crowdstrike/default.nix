{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.crowdstrike;

  version = "6.57.0";
  build = "15402";
  arch = "amd64";

  falcon-sensor = pkgs.stdenv.mkDerivation rec {
    name = "falcon-sensor";

    buildInputs = [
      pkgs.dpkg
      pkgs.zlib
    ];

    sourceRoot = ".";

    src = ./${name}_${version}-${build}_${arch}.deb;

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      mkdir $out
      cp -r . $out
    '';

    meta = with lib; {
      description = "Crowdstrike Falcon Sensor";
      homepage = "https://www.crowdstrike.com/";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [ ];
    };
  };

in
{
  options = {
    apps.crowdstrike.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Crowdstrike sensor.";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-wide packages
    environment.systemPackages = with pkgs; [
      falcon-sensor
    ];

    # Home-manager user configuration (optional)
    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
