{ lib, isDarwin, pkgs, user-settings }:

{
  # System aliases
  cat = "${pkgs.bat}/bin/bat";
  ls = "${pkgs.eza}/bin/eza";
  ll = "${pkgs.eza}/bin/eza -l";
  la = "${pkgs.eza}/bin/eza -la";
  tree = "${pkgs.eza}/bin/eza --tree";

  # Git aliases
  g = "git";
  gs = "git status";
  gc = "git commit";
  gp = "git pull";

  # Navigation aliases
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";

  # Directory listing aliases
  rm = "rm -i";
  cp = "cp -i";
  mv = "mv -i";

  # Add more aliases as needed
}