{ lib, isDarwin }:

{
  # Nix abbreviations
  nd = "nix develop";
  ns = "nix shell";
  nr = "nix run";
  nfu = "nix flake update";
  nfui = "nix flake update --inputs";

  # Git abbreviations
  ga = "git add";
  gcm = "git commit -m";
  gco = "git checkout";
  gcob = "git checkout -b";
  gpl = "git pull";
  gps = "git push";

  # System abbreviations
  sc = "systemctl";
  jc = "journalctl";

  # Platform specific abbreviations
  ${lib.optionalString isDarwin ''
    brew = "arch -arm64 brew";
  ''}

  # Add more abbreviations as needed
}