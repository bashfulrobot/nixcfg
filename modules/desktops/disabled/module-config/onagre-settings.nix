{
  pkgs,
  user-settings,
  ...
}:
{
  # Install onagre and dependencies
  environment.systemPackages = with pkgs; [
    # Main launcher
    onagre

    # Icon theme required by config
    papirus-icon-theme

  ];

  # User configuration
  home-manager.users."${user-settings.user.username}" = {
    home.file = {

      # Theme configuration
     ".config/onagre/theme.scss" = {
        text = ''
          .onagre {
            --exit-unfocused: true;
            height: 475px;
            width: 800px;
            --icon-theme: "Papirus";
            --icon-size: 28px;
            --font-family: "VictorMono Nerd Font Mono";
            background:  #{{base01}};
            color: #{{base05}};
            border-color: #{{base08}};
            border-radius: 10%;
            border-width: 0px;
            padding: 10px;

            .container {
              padding: 8px;
              .search {
                --spacing: 1;
                background: #{{base06}};
                border-radius: 10.0%;
                --height: fill-portion 1;
                --align-y: center;
                padding: 5px;

                .plugin-hint {
                  font-size: 18px;
                  background: #{{base08}};
                  color: #{{base05}};
                  border-radius: 10.0%;
                  border-color: #{{base08}};
                  --align-x: center;
                  --align-y: center;
                  --width: fill-portion 1;
                  --height: fill;
                }

                .input {
                    color: #{{base01}};
                    font-size: 20px;
                  --width: fill-portion 11;
                }
              }

              .rows {
                --height: fill-portion 8;

                .row-selected {
                  background: #{{base0C}};
                  color: #{{base07}};
                  border-radius: 10.0%;
                  border-color: #{{base0C}};
                  border-width: 2px;
                  --spacing: 1px;
                  --align-y: center;

                  .title {
                    font-size: 22px;
                  }

                  .description {
                    font-size: 20px;
                    color: #{{base03}};
                  }

                  .category-icon {
                    --icon-size: 15px;
                  }
                }

                .row {
                  .title {
                      font-size: 22px;
                  }

                  .description {
                      color: #{{base07}};
                      font-size: 20px;
                  }

                  .category-icon {
                    --icon-size: 15px;
                  }
                }
              }

              .scrollable {
                background: #00000000;
                .scroller {
                  color: #{{base0A}}00;
                }
              }
            }
          }
        '';
      };

      # Basic onagre configuration - you can add more settings here if needed
      ".config/onagre/onagre.yml" = {
        text = ''
          # Onagre Configuration
          plugins:
            # Applications
            - name: apps
              command: onagre-dm-apps
              prefix: ""

            # Search DuckDuckGo
            - name: search
              prefix: "?"
              command: onagre-dm-websearch
              args: ["https://duckduckgo.com/?q={}"]

            # Run commands
            - name: run
              prefix: "!"
              command: onagre-dm-run

          # Theme settings
          theme:
            style_path: '~/.config/onagre/theme.scss'
        '';
      };
    };
  };
}