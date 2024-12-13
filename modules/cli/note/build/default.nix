{ lib, pkgs, ... }:
# TODO: UPDATE ME
let version = "0.1.3";
in pkgs.stdenv.mkDerivation {
  name = "note";
  dontConfigure = true;

  src = pkgs.fetchzip {
    #
    url =
      "https://github.com/armand-sauzay/note/releases/download/v${version}/note_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-Tnz+kuexjb9QiQhADS6ak4mP4SwNnJPi9F8PcHwIDls=";
    stripRoot=false; # pass false to fetchzip to assume flat list of files
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    # ls $src > $out/bin/ls.txt
    cp $src/note $out/bin/note
    # chmod +x $out/bin/note
  '';

  meta = with lib; {
    description =
      "note - https://github.com/armand-sauzay/note";
    maintainers = [ bashfulrobot ];
  };
}
