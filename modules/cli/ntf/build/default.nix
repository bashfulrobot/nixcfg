{ lib, pkgs, ... }:
# https://github.com/hrntknr/ntf
# TODO: UPDATE ME
let version = "1.0.1";
in pkgs.stdenv.mkDerivation {
  name = "ntf";
  src = pkgs.fetchurl {
    url =
      "https://github.com/hrntknr/ntf/releases/download/v${version}/ntf-x86_64-unknown-linux-gnu";

    sha256 = "sha256-0rjWOOzs1RafCruTGM2wFVjo7vkOEqZuPeryqScy0OI=";
  };
  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ntf
    chmod +x $out/bin/ntf
  '';

  meta = with lib; {
    description =
      "NTF - https://github.com/hrntknr/ntf.";
    maintainers = [ bashfulrobot ];
  };
}
