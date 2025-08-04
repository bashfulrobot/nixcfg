{ config, pkgs, lib, user-settings, secrets, ... }:

{
  # Git configuration for home-manager in Ubuntu environment
  programs.git = {
    enable = true;
    userName = "${secrets.git.username}";
    userEmail = "${secrets.git.email}";

    extraConfig = {
      init.defaultBranch = "main";
      merge.ff = "only";
      push.default = "simple";
      pull.ff = "only";
      rebase.autoSquash = true;
      url."git@github.com:".pushInsteadOf = "https://github.com";
      credential.helper = "store";
      user = {
        signingkey = "${secrets.git.ssh-signing-key}";
      };
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      core.fsmonitor = true;
    };

    aliases = {
      a = "add";
      c = "commit";
    };

    difftastic = {
      enable = true;
      background = "dark";
      color = "always";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        parseEmoji = true;
      };
      gui.theme = {
        lightTheme = false;
        nerdFontVersion = "3";
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      editor = "hx";
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  programs.gitui = { 
    enable = true; 
  };

  home.file.".config/git/allowed_signers".text = ''
    ${secrets.git.email} ${secrets.git.ssh-signing-key-content}
  '';

  home.packages = with pkgs; [
    git-crypt
  ];
}