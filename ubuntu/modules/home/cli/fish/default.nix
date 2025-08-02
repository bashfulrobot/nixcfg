{ config, pkgs, lib, ... }:

let
  cfg = config.cli.fish;
  fd-flags = lib.concatStringsSep " " [
    "--hidden"
    "--exclude '.git'"
  ];

  # All functions from the NixOS config
  allFunctions = {
    envsource = ''

      for line in (cat $argv | grep -v '^#')
          set item (string split -m 1 '=' $line)
          set -gx $item[1] $item[2]
          echo "Exported key $item[1]"
        end
    '';
    onepass = ''
      # that's 1password cli tool used with fzf
      # it's the best to have it in a tmux session because if not it will require
      # you to reauthenticate for each new terminal that you open
      op item list | fzf --bind "enter:become( op item get {1} )"
    '';
    search_nixpkgs = ''
      nix-env -qaP | rg -Hi $argv[1]
    '';
    run_nix_package = ''
      set -x NIXPKGS_ALLOW_UNFREE 1
      nix run nixpkgs#$argv[1] --impure
    '';
    download_kubeconfig = ''
      if test (count $argv) -ne 2
          echo "Error: This function requires two arguments: the remote server IP and the Kubernetes cluster name."
          return 1
      end

      set ip $argv[1]
      set kubeconfig_name $argv[2]
      set url http://$ip:8080/kubeconfig

      while not curl --output /dev/null --silent --head --fail $url
        echo "Waiting for kubeconfig file to exist..."
        sleep 5
      end

      cd ~/.kube/clusters/
      wget $url
      mv $kubeconfig_name-kubeconfig $kubeconfig_name-kubeconfig-old
      mv kubeconfig $kubeconfig_name-kubeconfig
      code $kubeconfig_name-kubeconfig
    '';
    ek = ''
      set -l kubeconfig_dir ~/.kube/configs
      set -l selected_config (fd --type f . $kubeconfig_dir | xargs -n 1 basename | fzf --prompt="Select kubeconfig: ")
      if test -n "$selected_config"
        set -gx KUBECONFIG $kubeconfig_dir/$selected_config
        echo "KUBECONFIG set to $kubeconfig_dir/$selected_config"
      else
        echo "No kubeconfig selected."
      end
    '';
    ns = ''
      set -l namespaces (kubectl get namespaces -o jsonpath="{.items[*].metadata.name}")
      set -l selected_namespace (echo $namespaces | tr ' ' '\n' | fzf --prompt="Select namespace: ")
      if test -n "$selected_namespace"
        kubectl config set-context --current --namespace=$selected_namespace
        echo "Namespace set to $selected_namespace"
      else
        echo "No namespace selected."
      end
    '';
    et = ''
      set -l talosconfig_dir ~/.talos/configs
      set -l selected_config (fd --type f . $talosconfig_dir | xargs -n 1 basename | fzf --prompt="Select talosconfig: ")
      if test -n "$selected_config"
        set -gx TALOSCONFIG $talosconfig_dir/$selected_config
        echo "TALOSCONFIG set to $talosconfig_dir/$selected_config"
      else
        echo "No talosconfig selected."
      end
    '';
    delete_all_in_namespace = ''
      if test (count $argv) -ne 1
          echo "Error: This function requires a namespace as an argument."
          return 1
      end

      set namespace $argv[1]
      kubectl --namespace $namespace delete (kubectl api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//') --all
    '';
    k_stuck_terminating = ''
          if test -z $argv[1]
              echo "Please provide a namespace."
              return 1
          end

          kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $argv[1]
    '';
    k_force_terminating_ns = ''
      set NS (kubectl get ns | grep Terminating | awk 'NR==1 {print $1}')
      kubectl get namespace $NS -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
    '';
    get_containers_in_pods = ''
      if test -z $argv[1]
          echo "Please provide a namespace."
          return 1
      end

      set namespace $argv[1]

      kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' && echo
    '';
  };

  # Shell abbreviations
  allShellAbbrs = {
    k = "kubectl";
    t = "talosctl";
    tf = "terraform";
    tfa = "terraform apply";
    tfd = "terraform destroy";
    tfi = "terraform init -upgrade";
    tfp = "terraform plan";
    tfs = "terraform state list";
    dc = "docker compose";
    gc = "git pull && git add . && git commit -S && git push";
    nix-info = "nix-shell -p nix-info --run 'nix-info -m'";
    youtube = "mpv";
    pq = "pueue";
  };

  # Shell aliases
  allShellAliases = {
    bless = "sudo xattr -r -d com.apple.quarantine";
    ncdu = "${pkgs.gdu}/bin/gdu";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    kubectl = "${pkgs.kubecolor}/bin/kubecolor";
    ips = "ip -o -4 addr list | awk '{print $2, $4}'";
    ipull = "instruqt track pull";
    ipush = "instruqt track push";
    ilog = "instruqt track logs";
    e = "hx";
    vi = "hx";
    vim = "hx";
    nps = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
    ls = "${pkgs.eza}/bin/eza -al --octal-permissions --icons";
    du = "${pkgs.du-dust}/bin/dust";
    ps = "${pkgs.procs}/bin/procs";
    man = "${pkgs.tealdeer}/bin/tldr";
    top = "${pkgs.btop}/bin/btop";
    htop = "${pkgs.btop}/bin/btop";
    ping = "${pkgs.gping}/bin/gping";
    nixcfg = "${pkgs.man}/bin/man configuration.nix";
    hmcfg = "${pkgs.man}/bin/man home-configuration.nix";
    rustscan = "${pkgs.docker}/bin/docker run -it --rm --name rustscan rustscan/rustscan:latest";
    yless = "${pkgs.jless}/bin/jless --yaml";
    comma-db = "nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'";
  };

in {
  options.cli.fish = {
    enable = lib.mkEnableOption "Enable fish shell configuration with custom functions, aliases, and integrations";
  };

  config = lib.mkIf cfg.enable {
    # Automatically enable system-wide fish installation
    cli.fish.system = true;

    programs.fish = {
      enable = true;
      shellInit = ''
        # Shell Init
        direnv hook fish | source
        source ~/.config/op/plugins.sh
      '';
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        source ~/.config/op/plugins.sh

        # Auto-load SSH keys if this is an SSH session
        if set -q SSH_CONNECTION
          # Check if ssh-agent is actually working, not just running
          if not ssh-add -l >/dev/null 2>&1
            echo "🔑 Starting SSH agent..."
            eval (ssh-agent -c)
            echo "🔑 Loading SSH keys for remote session..."
            # Load primary keys
            ssh-add ~/.ssh/id_ed25519
            ssh-add ~/.ssh/id_rsa
          else
            echo "🔑 SSH agent already running with keys loaded"
          end
        end
      '';

      functions = allFunctions;
      shellAbbrs = allShellAbbrs;
      shellAliases = allShellAliases;
    };

    programs = {
      fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultCommand = "fd --type f ${fd-flags}";
        fileWidgetCommand = "fd --type f ${fd-flags}";
        changeDirWidgetCommand = "fd --type d ${fd-flags}";
      };
      atuin = {
        enable = true;
        enableFishIntegration = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          sync_address = "https://api.atuin.sh";
          search_mode = "fuzzy";
          filter_mode_shell_up_key_binding = "directory";
          style = "compact";
        };
      };
      yazi.enableFishIntegration = true;
      nix-index.enableFishIntegration = true;
      eza.enableFishIntegration = true;
      autojump.enableFishIntegration = false;
    };

    home.packages = with pkgs; [
      fishPlugins.tide
      fishPlugins.grc
      grc
      fishPlugins.github-copilot-cli-fish
      fishPlugins.colored-man-pages
      fishPlugins.bass
      fishPlugins.autopair
      fishPlugins.done
      fishPlugins.forgit
      fishPlugins.sponge
      gum
    ];
  };
}