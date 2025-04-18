{ lib, pkgs, ... }:
# TODO: UPDATE ME
let rev = "8bfea09aa6f1139479f80358b2e1e5c6dc991a58";
in pkgs.stdenvNoCC.mkDerivation {
  name = "sfpro-font";
  dontConfigure = true;

  src = pkgs.fetchzip {
    url =
      "https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts/archive/${rev}.zip";
    sha256 = "sha256-YrAmsiC4/Ik1zIcY3F1yYTydspLli+Tms3I4IQhFLuM=";
    stripRoot = false; # pass false to fetchzip to assume flat list of files
  };

  installPhase = ''
    mkdir -p $out/share/fonts
    cp -R $src $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "A San Franciso Pro font derivation.";
    maintainers = [ bashfulrobot ];
  };
}
