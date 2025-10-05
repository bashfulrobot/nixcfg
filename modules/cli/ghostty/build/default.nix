{ lib
, callPackage
, fetchFromGitHub
, ...
}:

let
  # Latest commit hash from main branch for true tip build  
  latestCommit = "7622d2662d81a3af9e7a85b5f4e649cba0932618";
  shortCommit = builtins.substring 0 7 latestCommit;

  # Get the latest source
  latestSrc = fetchFromGitHub {
    owner = "ghostty-org";
    repo = "ghostty";
    rev = latestCommit;
    hash = "sha256-OJ63LuQnD2ax4VtSGimLRJWZAr/ZgNQXrzZRG39qtUQ=";
  };

in (callPackage ./package.nix {
  # Override with latest source and optimized build
  revision = shortCommit;
  optimize = "ReleaseFast";
}).overrideAttrs (oldAttrs: {
  # Override the source to use latest commit - provide the whole source
  src = latestSrc;
  
  # Override version to indicate this is tip
  version = "1.2.0-tip-${shortCommit}";
  
  meta = with lib; {
    description = "Fast, feature-rich, and cross-platform terminal emulator (tip version with latest GTK improvements)";
    homepage = "https://ghostty.org";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "ghostty";
  };
})