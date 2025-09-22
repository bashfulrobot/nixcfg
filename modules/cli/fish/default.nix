{
  user-settings,
  lib,
  pkgs,
  secrets,
  config,
  isWorkstation,
  ...
}:
let
  cfg = config.cli.fish;
  fd-flags = lib.concatStringsSep " " [
    "--hidden"
    "--exclude '.git'"
  ];
  inherit (pkgs.stdenv) isDarwin;

  # Define which functions should be excluded on Darwin
  darwinExcludedFunctions = lib.unique [
    "shutdown_all_local_vms"
    "libvirt_list_all_networks"
    "libvirt_list_all_pools"
    "libvirt_list_all_images"
    "libvirt_list_all_vms"
    "get_libvirt_networks"
    "get_wm_class"
    "active_nixstore_file"
    "scratch-new"
    "scratch"
    "run_nix_package"
    "send_to_phone"
  ];

  # All functions defined
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
    # active_nixstore_pkg = ''
    #   set -l query $argv
    #   if test -z "$query"
    #       echo "Usage: nix-find <search-term>"
    #       return 1
    #   end

    #   nix-store --query --requisites /run/current-system | grep --ignore-case $query
    #   #exa -R (nix-store --query --requisites /run/current-system | grep --ignore-case $query)
    # '';

    active_nixstore_file = ''
      set search_term $argv[1]
      sudo fd -Hi $search_term (readlink -f /run/current-system/sw)
    '';
    # Not working for OP yet.
    # op_signin = ''
    #   op list templates >> /dev/null 2>&1
    #   	if test $status -ne 0
    #   		eval (op signin)
    #   	end
    # '';

    # op_get_names = ''
    #   op item list | jq -r '.[].overview.title'
    # '';

    # op_get_entry = ''
    #     set json (op item get "$argv[1]")
    #   	set username (echo $json | jq -r '.details.fields[]|select(.designation=="username")|.value')
    #   	set password (echo $json | jq -r '.details.fields[]|select(.designation=="password")|.value')
    #   	echo "item: $argv[1] | user: $username | pass: $password"
    # '';

    # oppw = ''
    #   op_signin
    #   	set opname (op_get_names | fzf)
    #   	op_get_entry $opname
    # '';

    # GNOME Shell Version
    get_wm_class = ''
      gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.List | grep -Po '"wm_class_instance":"\K[^"]*'
      gtk-update-icon-cache
    '';

    # Hyprland Version
    get_hypr_class = ''
      hyprctl clients | grep -A1 class | grep -v "class:" | sed 's/^[[:space:]]*//'
    '';

    scratch-new = ''
      set date (date "+%Y-%m-%d")
      set note_type (echo -e "External Meeting\nReminder\nInternal Meeting\nProduct Note" | fzf --prompt="Select note type: ")
      cd ~/Documents/Scratch/
      switch $note_type
          case "External Meeting"
              set folder ExternalMeeting
          case Reminder
              set folder Reminder
          case "Internal Meeting"
              set folder InternalMeeting
          case "Product Note"
              set folder ProductNote
      end

      read -P "Enter file name: " filename_suffix
      set filename "$folder/$date-$filename_suffix.md"

      # Create the folder if it doesn't exist
      mkdir -p $folder

      touch $filename
      echo "# "$date" "$filename_suffix | tr - ' ' >$filename

      switch $note_type
          case "External Meeting"
              echo "# "$date" "$filename_suffix | tr '-' ' ' > $filename
              echo >>$filename
              echo "## Meeting Type" >>$filename
              echo >>$filename
              echo "- External Meeting" >>$filename
              echo >>$filename
              echo "## Attendees" >>$filename
              echo >>$filename
              echo "## Summary" >>$filename
              echo >>$filename
              echo "## Action Items" >>$filename
              echo >>$filename
          case "Internal Meeting"
              echo "# "$date" "$filename_suffix | tr '-' ' ' > $filename
              echo >>$filename
              echo "## Meeting Type" >>$filename
              echo >>$filename
              echo "- Internal Meeting" >>$filename
              echo >>$filename
              echo "## Attendees" >>$filename
              echo >>$filename
              echo "## Summary" >>$filename
              echo >>$filename
              echo "## Action Items" >>$filename
              echo >>$filename
          case "Product Note"
              set product_name (echo -e "Secure\nMonitor\nPlatform" | fzf --prompt="Select product name: ")
              set use_cases (echo -e "CDR\nTD\nVM\nCSPM\nCIEM" | fzf --prompt="Select use cases: " --multi --delimiter="\n")
              echo "# "$date" "$filename_suffix | tr '-' ' ' > $filename
              echo >>$filename
              echo "## $product_name" >>$filename
              echo >>$filename
              for use_case in $use_cases
                  echo "## $use_case" >>$filename
                  echo >>$filename
              end
              echo "## Notes" >>$filename
              echo >>$filename
              echo "## Action Items" >>$filename
              echo >>$filename
      end

      hx $filename

    '';

    scratch = ''
      cd ~/Documents/Scratch/
      glow
    '';

    run_nix_package = ''
      set -x NIXPKGS_ALLOW_UNFREE 1
      nix run nixpkgs#$argv[1] --impure
    '';
    search_nixpkgs = ''
      nix-env -qaP | rg -Hi $argv[1]
    '';
    shutdown_all_local_vms = ''
      set -l domains (sudo virsh list --name --state-running)
      if test -z "$domains"
        echo "No running VMs detected." | gum format -t template | gum format -t emoji
      else
        echo "Shutting down the following VMs:" | gum format -t template | gum format -t emoji
        for domain in $domains
          echo "Shutting down $domain..." | gum format -t template | gum format -t emoji
          sudo virsh shutdown $domain
          if test $status -eq 0
            echo "$domain has been shut down successfully." | gum format -t template | gum format -t emoji
          else
            echo "Failed to shut down $domain." | gum format -t template | gum format -t emoji
          end
        end
      end
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
    libvirt_list_all_networks = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh net-list --all | grep $filter
      else if test (count $argv) -eq 0
        sudo virsh net-list --all
      else
        echo "Error: This function requires zero or one argument: an optional filter."
        return 1
      end
    '';

    libvirt_list_all_pools = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh pool-list --all | grep $filter
      else if test (count $argv) -eq 0
        sudo virsh pool-list --all
      else
        echo "Error: This function requires zero or one argument: an optional filter."
        return 1
      end
    '';

    libvirt_list_all_images = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh vol-list --pool $filter
      else if test (count $argv) -eq 0
        sudo virsh vol-list --pool default
      else
        echo "Error: This function requires zero or one argument: an optional volume name filter."
        return 1
      end
    '';

    libvirt_list_all_vms = ''
      if test (count $argv) -eq 1
        set filter $argv[1]
        sudo virsh list --all | grep $filter
      else if test (count $argv) -eq 0
        sudo virsh list --all
      else
        echo "Error: This function requires zero or one argument: an optional filter."
        return 1
      end
    '';
    send_to_phone = ''
      if test (count $argv) -ne 1
          echo "Error: This function requires a file path as an argument."
          return 1
      end

      set file_path $argv[1]
      tailscale file cp $file_path maximus:
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

    get_libvirt_networks = ''
          for net in (sudo virsh net-list --all | awk 'NR>2 {print $1}')
          if test -n "$net"
              echo "Network: $net"
              sudo virsh net-info $net | grep 'Bridge:'
          end
      end
    '';
    frm = ''
      set matches (fd -Hi $argv --max-depth 1 .)
      if test (count $matches) -eq 0
        echo "No matches found for pattern: $argv"
        return 1
      end

      echo "Found matches:"
      for match in $matches
        if test -d $match
          set contents (eza -la $match 2>/dev/null | wc -l)
          if test $contents -gt 3  # More than just . and .. entries
            echo "📁 $match (non-empty directory)"
          else
            echo "📁 $match (empty directory)"
          end
        else
          echo "📄 $match"
        end
      end

      echo
      read -P "Remove all these items? [y/N]: " -n 1 confirm
      echo

      if test "$confirm" = "y" -o "$confirm" = "Y"
        for match in $matches
          if test -d $match
            rm -rf $match
            echo "Removed directory: $match"
          else
            rm $match
            echo "Removed file: $match"
          end
        end
        echo "✅ Removal complete"
      else
        echo "❌ Operation cancelled"
      end
    '';

    jlint = ''
      if test (count $argv) -eq 0
        ${pkgs.just}/bin/just lint
      else
        ${pkgs.just}/bin/just lint $argv[1]
      end
    '';

    jcheck = ''
      if test (count $argv) -eq 0
        echo "Usage: jcheck <file.nix> [file2.nix ...]"
        echo "Example: jcheck modules/apps/firefox/default.nix"
        return 1
      end

      echo "⚡ Syntax checking specified files..."

      set failed_files
      set checked_count 0

      for file in $argv
        if not test -f "$file"
          echo "❌ File not found: $file"
          set failed_files $failed_files $file
          continue
        end

        if not string match -q "*.nix" $file
          echo "⚠️  Skipping non-nix file: $file"
          continue
        end

        echo "  📄 $file"
        if not nix-instantiate --parse "$file" >/dev/null 2>&1
          echo "    ❌ Syntax error"
          set failed_files $failed_files $file
        else
          echo "    ✅ Valid syntax"
        end
        set checked_count (math $checked_count + 1)
      end

      if test (count $failed_files) -gt 0
        echo "❌ Found syntax errors in "(count $failed_files)" file(s)"
        return 1
      end

      echo "✅ All $checked_count files have valid syntax"
    '';
  };

  # Create a version of functions with Darwin exclusions
  filteredFunctions = lib.filterAttrs (
    name: _: !(isDarwin && builtins.elem name darwinExcludedFunctions)
  ) allFunctions;

  darwinExcludedShellAbbrs = lib.unique [
    "nix-lint"
    "dc"
    "gc"
    "pq"
    "cam-devs"
    "cam-features"
    "cam-sat"
  ];

  allShellAbbrs = {
    nix-lint = "fd -e nix --hidden --no-ignore --follow . -x statix check {}";
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
    cam-devs = "v4l2-ctl --list-devices";
    cam-features = "v4l2-ctl --list-ctrls -d /dev/video0";
    cam-sat = "v4l2-ctl --set-ctrl=saturation=50 -d /dev/video0";
  };

  filteredShellAbbrs = lib.filterAttrs (
    name: _: !(isDarwin && builtins.elem name darwinExcludedShellAbbrs)
  ) allShellAbbrs;

  darwinExcludedShellAliases = lib.unique [
    "support-info"
    "support-info-extended"
    "tshoot-last-boot"
    "copy-icons"
    "echo-home"
    "hm-logs"
    "tailscale-up-lt"
    "tailscale-up-dt"
    "oc"
    "ncdu"
    "nix-get-video-id"
    "ips"
    "ipull"
    "ipush"
    "ilog"
    "gotf"
    "gotfc"
    "gotfm"
    "gotf-e"
    "gos"
    "gon"
    "gon-e"
    "do-update"
    "goagent"
    "goscreen"
    "y"
    "e"
    "ny"
    "n"
    "ncommit"
    "ls"
    "font-cache-refresh"
    "font-list"
    "du"
    "ps"
    "man"
    "top"
    "htop"
    "ping"
    "nixcfg"
    "hmcfg"
    "rustscan"
    "kcfg"
    "vms"
    "yless"
    "nxb"
    "nxr"
    "nxu"
    "nxt"
    "kubitect"
    "comma-db"
  ];

  allShellAliases = {
    support-info = ", fastfetch --logo none -c ${user-settings.user.home}/dev/nix/nixcfg/modules/cli/fastfetch/support.jsonc | xclip -selection clipboard";
    support-info-extended = ", fastfetch --logo none -c ${user-settings.user.home}/dev/nix/nixcfg/modules/cli/fastfetch/support-extended.jsonc | xclip -selection clipboard";
    tshoot-last-boot = "sudo journalctl -b -1 | curl -F 'file=@-' 0x0.st";
    copy-icons = "copy_icons";
    echo-home = "echo ${user-settings.user.home}";
    hm-logs = "sudo systemctl restart home-manager-dustin.service; journalctl -xeu home-manager-dustin.service";
    tailscale-up-lt = "sudo tailscale up --ssh --accept-dns --accept-routes --operator=$USER";
    tailscale-up-dt = "sudo tailscale up --operator=$USER --ssh --accept-dns";
    bless = "sudo xattr -r -d com.apple.quarantine";
    ncdu = "${pkgs.gdu}/bin/gdu";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    nix-get-video-id = "nix --experimental-features 'flakes nix-command' run github:eclairevoyant/pcids";
    kubectl = "${pkgs.kubecolor}/bin/kubecolor";
    ips = "ip -o -4 addr list | awk '{print $2, $4}'";
    ipull = "instruqt track pull";
    ipush = "instruqt track push";
    ilog = "instruqt track logs";
    gotf = "cd ~/dev/terraform";
    gotfc = "cd ~/dev/terraform/clusters/";
    gotfm = "cd ~/dev/terraform/modules/";
    gotf-e = "cd ~/dev/terraform && code -r .";
    gos = "cd ~/Documents/Scratch/";
    gon = "cd ~/dev/nix/nixcfg";
    gon-e = "cd ~/dev/nix/nixcfg && code -r .";
    do-update = "gon && git pull && nxu && git add -A && git commit -S && git push";
    goscreen = "cd ~/Pictures/Screenshots/";
    # y = "cd ~/; yazi";
    e = "hx";
    vi = "hx";
    vim = "hx";
    ny = "cd ~/dev/nix/nixcfg/; yazi";
    n = "cd ~/dev/nix/nixcfg/; hx";
    ncommit = "clear && cd ~/dev/nix/nixcfg && git add . && git commit -S && rm -f ${user-settings.user.home}/.config/mimeapps.list && rebuild && cd ~/dev/nix/nixcfg && git push";
    nps = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
    font-cache-refresh = "sudo fc-cache -f -v";
    font-list = "fc-list";
    du = "${pkgs.du-dust}/bin/dust";
    ps = "${pkgs.procs}/bin/procs";
    man = "${pkgs.tealdeer}/bin/tldr";
    top = "${pkgs.btop}/bin/btop";
    htop = "${pkgs.btop}/bin/btop";
    ping = "${pkgs.gping}/bin/gping";
    nixcfg = "${pkgs.man}/bin/man configuration.nix";
    hmcfg = "${pkgs.man}/bin/man home-configuration.nix";
    rustscan = "${pkgs.docker}/bin/docker run -it --rm --name rustscan rustscan/rustscan:latest";
    kcfg = "sudo chown -R dustin ~/.kube && sudo chmod -R 0700 ~/.kube && cd ~/.kube && ${pkgs.just}/bin/just";
    vms = "sudo ${pkgs.libvirt}/bin/virsh list --all";
    yless = "${pkgs.jless}/bin/jless --yaml";
    rebuild-mac = "clear && echo;echo '***** UPDATE VERSIONS PERIODIALLY *****'; echo;  sleep 1; cd ~/dev/nix/nixcfg/ && ${pkgs.just}/bin/just darwin-rebuild";
    # NixOS system management (nx prefix)
    nxb = "clear && cd ~/dev/nix/nixcfg/; rm -f ${user-settings.user.home}/.config/mimeapps.list && ${pkgs.just}/bin/just build";
    nxr = "clear && echo;echo '***** UPDATE APPIMAGES PERIODIALLY *****'; echo;  sleep 1; cd ~/dev/nix/nixcfg/ && ${pkgs.just}/bin/just rebuild";
    nxu = "clear && cd ~/dev/nix/nixcfg/; ${pkgs.just}/bin/just upgrade";
    nxt = "clear && cd ~/dev/nix/nixcfg/; rm -f ${user-settings.user.home}/.config/mimeapps.list && ${pkgs.just}/bin/just test";
    kubitect = "${pkgs.steam-run}/bin/steam-run /etc/profiles/per-user/dustin/bin/kubitect";
    comma-db = "nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'";
  };

  filteredShellAliases = lib.filterAttrs (
    name: _: !(isDarwin && builtins.elem name darwinExcludedShellAliases)
  ) allShellAliases;

in
{

  options = {
    cli.fish.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the fish shell.";
    };
  };

  config = lib.mkIf cfg.enable {
    # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you will also want to enable the fish shell in /etc/nixos/configuration.nix:
    programs.fish.enable = true;

    environment.shells = lib.mkIf isDarwin [ pkgs.fish ];

    home-manager.users."${user-settings.user.username}" = {
      programs.fish = {
        enable = true;
        shellInit =
          if isWorkstation then
            ''
              # Shell Init
              direnv hook fish | source
              ${lib.optionalString (!isDarwin) "source ${user-settings.user.home}/.config/op/plugins.sh"}

              # Just completions
              ${pkgs.just}/bin/just --completions fish | source

            ''
          else
            ''
              # Just completions
              ${pkgs.just}/bin/just --completions fish | source

            '';
        interactiveShellInit =
          if isWorkstation then
            ''
                  set fish_greeting # Disable greeting
                  ${lib.optionalString (!isDarwin) "source ${user-settings.user.home}/.config/op/plugins.sh"}

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


            ''
          else
            ''
                  set fish_greeting # Disable greeting

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

        # Apply the filtered functions
        functions = filteredFunctions;

        shellAbbrs = filteredShellAbbrs;

        # Apply the filtered shell aliases
        shellAliases = filteredShellAliases;
      };

      # Add custom completions for jlint and jcheck
      home = {
        file = {
          ".config/fish/completions/jlint.fish".text = ''
            # Tab completion for jlint function
            complete -c jlint -xa "(__fish_complete_directories)"
            complete -c jlint -xa "(find . -name '*.nix' -type f 2>/dev/null | string replace './' \"\")"
          '';

          ".config/fish/completions/jcheck.fish".text = ''
            # Tab completion for jcheck function - supports multiple files
            complete -c jcheck -xa "(find . -name '*.nix' -type f 2>/dev/null | string replace './' \"\")"
          '';
        };

        packages = with pkgs; [
          fishPlugins.tide
          fishPlugins.grc
          grc
          fishPlugins.github-copilot-cli-fish
          # TODO: fishPlugins.fzf-fish is broken on NixOS
          # fishPlugins.fzf-fish

          fishPlugins.colored-man-pages
          fishPlugins.bass
          fishPlugins.autopair
          # fishPlugins.async-prompt
          fishPlugins.done
          fishPlugins.forgit
          fishPlugins.sponge
          gum
        ];
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
    };
  };
}
