{ lib, pkgs, ... }:
# https://mimestream.com
# TODO: UPDATE ME
let version = "1.6.1";
in pkgs.stdenv.mkDerivation {
  # pname = "Mimestream";
  name = "Mimestream";
  src = pkgs.fetchurl {
    name = "Mimestream-${version}.dmg";
    url =
      "https://download.mimestream.com/Mimestream_${version}.dmg";

    sha256 = "sha256-g4Tx4a8HkYDMz26XL+rz2a/+4rinLjNXAHKocdEdMlo=";
  };

  nativeBuildInputs = [ pkgs.undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R Mimestream.app $out/Applications
    runHook postInstall
  '';

  meta = with lib; {
    description =
      "Mimestream - https://mimestream.com.";
    homepage = "https://mimestream.com";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "Mimestream.app";
    maintainers = [ bashfulrobot ];
    platforms = platforms.darwin;
  };
}
