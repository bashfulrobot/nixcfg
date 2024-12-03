{ lib, pkgs, ... }:
let version = "2208-3ea4fac";
in pkgs.stdenv.mkDerivation {
  name = "instruqt";
  src = pkgs.fetchzip {
    url =
      "https://github.com/instruqt/cli/releases/download/${version}/instruqt-linux.zip";
    sha256 = "sha256-qgED6Y3pkX0zmb0Wz8ICaJB0tavUvg5pAVxbuY67lBk=";
    # stripRoot = false;
  };
  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/instruqt $out/bin/instruqt
    chmod +x $out/bin/instruqt
  '';

  meta = with lib; {
    description =
      "Instruqt CLI - https://github.com/instruqt/cli/.";
    maintainers = [ bashfulrobot ];
  };
}
