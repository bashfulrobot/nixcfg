# oco set hook
{ user-settings, pkgs, secrets, config, lib, ... }:
let cfg = config.cli.opencommit;
in {
  options = {
    cli.opencommit.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable opencommit tool.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ unstable.opencommit ];

    home-manager.users."${user-settings.user.username}" = {
      home.file.".opencommit".text = ''
        OCO_API_KEY=${secrets.anthropic.api_key}
        OCO_MODEL=claude-3-5-sonnet-20241022
        OCO_API_URL=undefined
        OCO_AI_PROVIDER=anthropic
        OCO_TOKENS_MAX_INPUT=40960
        OCO_TOKENS_MAX_OUTPUT=4096
        OCO_DESCRIPTION=false
        OCO_EMOJI=true
        OCO_LANGUAGE=en
        OCO_MESSAGE_TEMPLATE_PLACEHOLDER=$msg
        OCO_PROMPT_MODULE=conventional-commit
        OCO_ONE_LINE_COMMIT=false
        OCO_TEST_MOCK_TYPE=commit-message
        OCO_GITPUSH=true
        OCO_WHY=false

      '';

    };
  };
}
