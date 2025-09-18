{ lib, pkgs, ... }:
# TODO: UPDATE ME - Check https://github.com/musistudio/claude-code-router/commits/main for latest commit hash
pkgs.buildNpmPackage rec {
  pname = "claude-code-router";
  version = "unstable-2024-09-18";

  src = pkgs.fetchFromGitHub {
    owner = "musistudio";
    repo = "claude-code-router";
    rev = "5cd21c570fb87cc131e0c4254b40d5ffd127b176";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  # Node.js 20+ is required
  nodejs = pkgs.nodejs_20;

  meta = with lib; {
    description = "A powerful tool to route Claude Code requests to different models and customize any request";
    homepage = "https://github.com/musistudio/claude-code-router";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}