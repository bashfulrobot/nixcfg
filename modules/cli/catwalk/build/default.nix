{ lib, pkgs, ... }:
# TODO: Periodically version bump
let version = "0.5.8";
in pkgs.stdenv.mkDerivation {
  name = "catwalk";
  dontConfigure = true;

  src = pkgs.fetchzip {
    url =
      "https://github.com/charmbracelet/catwalk/releases/download/v${version}/catwalk_${version}_linux_amd64.tar.gz";
    sha256 = "0r10bphnsgynilascnvqidgxfxvqnh8fpvnflzmnfvl4jzrpgdz0";
    stripRoot = false; # pass false to fetchzip to assume flat list of files
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/catwalk $out/bin/catwalk
    chmod +x $out/bin/catwalk
  '';

  meta = with lib; {
    description =
      "catwalk - A database for Crush-compatible models - https://github.com/charmbracelet/catwalk";
    maintainers = [ bashfulrobot ];
  };
}