{ lib, pkgs, ... }:
# TODO: UPDATE ME
let version = "0.1.1";
in pkgs.stdenv.mkDerivation {
  name = "meetsum";
  src = pkgs.fetchurl {
    url =
      "https://github.com/bashfulrobot/meetsum/releases/download/v${version}/meetsum-linux-amd64";
    sha256 = "sha256-NHxdaG6OE6YiK/m9OXukqJ0aISyYmmk4ez/UM6cUKR4=";
  };
  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/meetsum
    chmod +x $out/bin/meetsum
  '';

  meta = with lib; {
    description =
      "AI-powered meeting summarizer - https://github.com/bashfulrobot/meetsum.";
    maintainers = [ bashfulrobot ];
  };
}