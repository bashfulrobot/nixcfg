{ user-settings, lib, pkgs, config, ... }:
let 
  cfg = config.cli.claude-code;
  
  commit-script = pkgs.writeShellApplication {
    name = "commit";
    runtimeInputs = with pkgs; [ git ];
    text = builtins.readFile ./commit;
  };
in {
  options = {
    cli.claude-code.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable claude-code CLI tool with commit helper.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.claude-code
      commit-script
    ];

    home-manager.users."${user-settings.user.username}" = {
      xdg.configFile."claude/CLAUDE.md".source = ./CLAUDE.md;

      programs.fish.shellAbbrs = {
        cc = {
          position = "command";
          setCursor = true;
          expansion = "claude -p \"%\"";
        };
        # Common commit shortcuts
        cf = "commit feat";
        cfx = "commit fix";
        cdocs = "commit docs";
        cchore = "commit chore";
        cref = "commit refactor";
        cstyle = "commit style";
        ctest = "commit test";
        cbuild = "commit build";
        cci = "commit ci";
        csec = "commit security";
        cdeps = "commit deps";
      };
    };
  };
}