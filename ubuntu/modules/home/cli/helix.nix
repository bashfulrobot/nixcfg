{ config, pkgs, lib, ... }:
# Helix editor configuration for Ubuntu home-manager

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    
    extraPackages = with pkgs; [
      # copilot
      helix-gpt
      # nix
      nixfmt-rfc-style
      nixd
      statix
      # markdown
      marksman
      # Go
      gopls
      golangci-lint-langserver
      delve
      # yaml
      yaml-language-server
    ];

    settings = {
      editor = {
        line-number = "relative";
        lsp.display-messages = true;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      theme = "onedark";
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          language-servers = [ "nixd" "statix" ];
        }
        {
          name = "toml";
          auto-format = true;
        }
        {
          name = "yaml";
          language-servers = [ "yaml" "scls" ];
        }
      ];

      language-server = {
        yaml = {
          command = "yaml-language-server";
          args = [ "--stdio" ];
          scope = "source.yaml";
        };
      };
    };
  };

  # Set editor environment variable
  home.sessionVariables = { 
    EDITOR = "hx";
  };
}