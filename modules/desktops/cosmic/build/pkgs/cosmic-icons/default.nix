{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  just,
  pop-icon-theme,
  hicolor-icon-theme,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cosmic-icons";
  version = "epoch-1.0.0-alpha.7-unstable-2025-03-21";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-icons";
    rev = "70b07582e24ec2114672256b9657ca80670bca8a";
    hash = "sha256-KDmEYeuiDTYvqg2XJK8pMDfsmROKtN+if5Qxz57H5xs=";
  };

  nativeBuildInputs = [ just ];

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
  ];

  propagatedBuildInputs = [
    pop-icon-theme
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  meta = {
    description = "System76 Cosmic icon theme for Linux";
    homepage = "https://github.com/pop-os/cosmic-icons";
    license = with lib.licenses; [
      cc-by-sa-40
    ];
  };
})
