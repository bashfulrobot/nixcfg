{ lib, pkgs, ... }:
# TODO: UPDATE ME
let version = "0.0.1";
in pkgs.stdenv.mkDerivation {
  name = "aharoni-font";
  src = ./src/aharoni;
  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p $out/share/fonts
    cp -R $src $out/share/fonts/
  '';

  meta = with lib; {
    description = "aharoni font";
    maintainers = [ bashfulrobot ];
  };
}
