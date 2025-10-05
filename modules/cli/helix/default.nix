# Add this - https://medium.com/@CaffeineForCode/helix-setup-for-markdown-b29d9891a812
{ user-settings, pkgs, config, lib, ... }:
let cfg = config.cli.helix;
in {
  options = {
    cli.helix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable helix editor.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ unstable.helix ];

    # Set editor globally
    environment.variables = { EDITOR = "hx"; };

    home-manager.users."${user-settings.user.username}" = {

      programs.helix = {

        enable = true;
        defaultEditor = true;
        package = pkgs.unstable.helix;

        extraPackages = with pkgs; [
          # copilot
          unstable.helix-gpt
          # nix
          unstable.nixfmt-rfc-style
          unstable.nixd
          unstable.statix
          # markdown
          unstable.marksman
          # Go
          unstable.gopls
          unstable.golangci-lint-langserver
          unstable.delve
          #yaml
          unstable.yaml-language-server

        ];

        settings = lib.mkMerge [
          {
            editor = {
              line-number = "relative";
              lsp.display-messages = true;

              cursor-shape = {
                normal = "block";
                insert = "bar";
                select = "underline";
              };
            };
          }
        ];

        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command =
                "${pkgs.unstable.nixfmt-rfc-style}/bin/nixfmt";
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

      home = {
        # Editor is now set globally
        sessionVariables = { EDITOR = "hx"; };

        # file.".config/helix/helix.toml".text = ''
        # '';

      };
    };

  };
}
