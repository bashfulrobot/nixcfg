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

  # Fish script packages using standard pattern
  fishScripts = with pkgs; [
    (writeShellScriptBin "rofi-fish-commands" (builtins.readFile ./scripts/rofi-fish-commands.sh))
  ];


  # Command metadata for help system
  # Format: "command" = "emoji description|type|usage";
  # Types: exec (no args), interactive (prompts for args), template (show usage)
  commandHelp = {
    # System commands
    "sys-commit-rebuild" = "🔧 Commit changes and rebuild NixOS system|exec|";
    "sys-update-push" = "⬆️  Pull, upgrade, commit and push system changes|exec|";
    "sys-support-info" = "📋 Copy system info to clipboard|exec|";
    "sys-support-info-extended" = "📋 Copy extended system info to clipboard|exec|";
    "sys-troubleshoot-last-boot" = "🔧 Upload last boot logs to pastebin|exec|";
    "sys-logs-home-manager" = "📜 Restart and show home-manager logs|exec|";
    "sys-tailscale-up-laptop" = "🔗 Start tailscale for laptop mode|exec|";
    "sys-tailscale-up-desktop" = "🔗 Start tailscale for desktop mode|exec|";
    "sys-font-cache-refresh" = "🔤 Refresh font cache|exec|";
    "sys-font-list" = "🔤 List all fonts|exec|";
    "sys-get-video-id" = "📺 Get video device IDs|exec|";
    "sys-get-ips" = "🌐 List network interfaces and IPs|exec|";
    "sys-docs-nixcfg" = "📖 Open NixOS configuration manual|exec|";
    "sys-docs-home-manager" = "📖 Open Home Manager manual|exec|";

    # Nix commands
    "nix-build" = "🏗️  Build NixOS config without switching|exec|";
    "nix-rebuild" = "🔄 Rebuild and switch to new NixOS config|exec|";
    "nix-test" = "🧪 Test NixOS config (dry run)|exec|";
    "nix-upgrade" = "⬆️  Update flake inputs and rebuild|exec|";
    "nix-store-find-file" = "🔍 Find file in active nix store|template|nix-store-find-file <search-term>";
    "nix-run-ephemeral" = "🚀 Run a nixpkgs package temporarily|template|nix-run-ephemeral <package-name>";
    "nix-pkg-search" = "🔍 Search nixpkgs for packages|template|nix-pkg-search <search-term>";
    "nix-pkg-search-cli" = "🔍 Search nixpkgs via nix search|template|nix-pkg-search-cli <search-term>";
    "nix-lint" = "🔍 Lint nix files with statix|exec|";
    "nix-info" = "ℹ️  Display nix system information|exec|";
    "nix-index-update" = "📇 Update nix-index database|exec|";

    # Kubernetes commands
    "k8s-set-config" = "⚙️  Select kubeconfig file with fzf|exec|";
    "k8s-set-namespace" = "📁 Select kubernetes namespace with fzf|exec|";
    "k8s-ns-delete-all-resources" = "💥 Delete all resources in namespace|template|k8s-ns-delete-all-resources <namespace>";
    "k8s-ns-find-stuck" = "🔍 Find stuck terminating resources|template|k8s-ns-find-stuck <namespace>";
    "k8s-ns-force-terminate" = "💀 Force terminate stuck namespace|exec|";
    "k8s-get-containers" = "📦 List containers in pods by namespace|template|k8s-get-containers <namespace>";
    "k8s-setup-config" = "⚙️  Setup kubernetes configuration";
    "k8s" = "🚢 kubectl with color support";
    "k8s-scan" = "🔍 Run rustscan in docker";

    # Talos commands
    "talos" = "🤖 talosctl command";
    "talos-set-config" = "⚙️  Select talosconfig file with fzf";

    # Terraform commands
    "tf" = "🏗️  terraform command";
    "tf-apply" = "✅ terraform apply";
    "tf-destroy" = "💥 terraform destroy";
    "tf-init" = "🚀 terraform init with upgrade";
    "tf-plan" = "📋 terraform plan";
    "tf-state" = "📊 terraform state list";

    # VM commands
    "vm-shutdown-all" = "⏹️  Shutdown all running VMs";
    "vm-list-all" = "📋 List all VMs";
    "vm-list" = "📋 List all VMs (alias)";
    "vm-net-list-all" = "🌐 List all libvirt networks";
    "vm-pool-list-all" = "💾 List all libvirt storage pools";
    "vm-img-list-all" = "💿 List all VM images in pool";
    "vm-net-get-info" = "ℹ️  Get libvirt network bridge info";

    # File system commands
    "fs-remove-interactive" = "🗑️  Find and remove files/dirs interactively";
    "fs-nav-terraform" = "📁 Navigate to terraform directory";
    "fs-nav-terraform-clusters" = "📁 Navigate to terraform clusters";
    "fs-nav-terraform-modules" = "📁 Navigate to terraform modules";
    "fs-nav-terraform-edit" = "📁 Navigate to terraform and edit";
    "fs-nav-nixcfg" = "📁 Navigate to nixcfg directory";
    "fs-nav-scratch" = "📁 Navigate to scratch directory";
    "fs-nav-screenshots" = "📁 Navigate to screenshots directory";
    "fs-find-files" = "🔍 Find files with fzf and preview";
    "fs-list" = "📋 Enhanced ls with eza";
    "fs-list-all" = "📋 Enhanced ls -a with eza";
    "fs-tree" = "🌳 Tree view with eza";
    "fs-tree-all" = "🌳 Tree view with hidden files";
    "fs-disk-usage" = "💿 Disk usage with dust";
    "fs-nav-up" = "⬆️  Go up one directory";
    "fs-nav-up-2" = "⬆️  Go up two directories";
    "fs-nav-up-3" = "⬆️  Go up three directories";
    "fs-nav-up-4" = "⬆️  Go up four directories";
    "fs-ncdu" = "📊 Interactive disk usage with gdu";

    # Development commands
    "dev-edit" = "✏️  Open editor (helix)";
    "dev-edit-nixcfg" = "⚙️  Open nixcfg in editor";
    "dev-edit-vscode-nixcfg" = "💻 Open nixcfg in VSCode";
    "dev-git" = "📱 git command";
    "dev-docker" = "🐳 docker command";
    "dev-docker-compose" = "🐳 docker compose command";
    "dev-git-commit-push" = "🚀 Pull, add, commit and push changes";
    "dev-process-list" = "📊 Enhanced process list with procs";
    "dev-help" = "📖 Get help with tldr";
    "dev-top" = "📊 System monitor with btop";
    "dev-ping" = "🏓 Enhanced ping with gping";
    "dev-yaml-viewer" = "📄 View YAML files with jless";
    "sys-get-wm-class" = "👁️  Get window manager class for GNOME|exec|";
    "sys-get-hypr-class" = "👁️  Get window class for Hyprland|exec|";
    "dev-jlint" = "🔍 Lint nix files with tab completion|interactive|dev-jlint [file.nix]";
    "dev-jcheck" = "✅ Check nix file syntax with tab completion|template|dev-jcheck <file.nix> [file2.nix ...]";
    "k8s-download-kubeconfig" = "📥 Download kubeconfig from remote server|template|k8s-download-kubeconfig <ip> <cluster-name>";

    # Instruqt commands
    "instruqt-pull" = "⬇️  Pull instruqt track";
    "instruqt-push" = "⬆️  Push instruqt track";
    "instruqt-logs" = "📜 View instruqt track logs";

    # Application commands
    "app-scratch-new" = "📝 Create new scratch note with template";
    "app-scratch-browse" = "📖 Browse scratch notes with glow";
    "app-onepass-fzf" = "🔐 Browse 1Password items with fzf";
    "app-send-to-phone" = "📱 Send file to phone via tailscale";
    "app-mpv-youtube" = "📺 Play video with mpv";
    "app-pueue" = "⏳ Task queue manager";
    "app-kubitect" = "🎯 Kubitect with steam-run";

    # Camera commands
    "cam-list-devices" = "📷 List camera devices";
    "cam-list-features" = "📷 List camera features";
    "cam-set-saturation" = "📷 Set camera saturation";

    # Media commands
    "media-video-1080p" = "🎬 Transcode video to 1080p";
    "media-video-4k" = "🎬 Transcode video to 4K";
    "media-img-to-jpg" = "🖼️  Convert image to JPG";
    "media-img-to-jpg-small" = "🖼️  Convert image to small JPG";
    "media-img-to-png" = "🖼️  Convert image to optimized PNG";
  };

  # All functions defined
  allFunctions = {
    # Interactive help system
    fish-help = ''
      set -l commands
      set -l previews
      set -l types

      # Parse commandHelp entries
      ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (name: metadata:
        let
          # Split metadata by | delimiter
          parts = lib.splitString "|" metadata;
          description = lib.head parts;
          cmdType = if lib.length parts > 1 then lib.elemAt parts 1 else "exec";
          usage = if lib.length parts > 2 then lib.elemAt parts 2 else "";
        in
        ''set commands $commands "${name}"
        set types $types "${cmdType}"
        if test "${cmdType}" = "template"
          set previews $previews "${description}\n\nUsage: ${usage}"
        else if test "${cmdType}" = "interactive"
          set previews $previews "${description}\n\nUsage: ${usage}\n\n💡 This command can prompt for missing arguments"
        else
          set previews $previews "${description}\n\n✅ Ready to execute (no arguments required)"
        end''
      ) commandHelp)}

      # Create combined list for fzf with type indicators
      set -l combined
      for i in (seq 1 (count $commands))
        set -l type_indicator
        switch $types[$i]
          case "exec"
            set type_indicator "⚡"
          case "interactive"
            set type_indicator "🔧"
          case "template"
            set type_indicator "📝"
        end
        set combined $combined "$type_indicator $commands[$i]\t$previews[$i]"
      end

      # Use fzf to select command
      set -l selected (printf "%s\n" $combined | fzf \
        --delimiter="\t" \
        --with-nth=1 \
        --preview="echo -e {2}" \
        --preview-window="down:5:wrap" \
        --header="🐠 Fish Commands | ⚡=exec 🔧=interactive 📝=needs-args | Enter=insert Ctrl-E=execute" \
        --bind="enter:accept" \
        --bind="ctrl-e:accept")

      if test -n "$selected"
        set -l cmd (echo $selected | cut -d"\t" -f1 | string replace -r "^[⚡🔧📝] " "")
        set -l key $last_key

        # Get command type
        set -l cmd_type
        for i in (seq 1 (count $commands))
          if test "$commands[$i]" = "$cmd"
            set cmd_type $types[$i]
            break
          end
        end

        # Handle based on fzf key binding used
        if test "$FZF_KEY" = "ctrl-e"
          # Ctrl-E: Execute directly (only for exec type)
          if test "$cmd_type" = "exec"
            echo "🚀 Executing: $cmd"
            eval $cmd
          else
            echo "⚠️  Command '$cmd' requires arguments. Use Enter to insert into prompt."
          end
        else
          # Enter: Insert into command line
          commandline -i "$cmd"
          commandline -f repaint
        end
      end
    '';

    fish-help-group = ''
      set -l group $argv[1]
      if test -z "$group"
        echo "Usage: fish-help-group <group>"
        echo "Available groups: sys, nix, k8s, vm, fs, dev, app, media"
        return 1
      end

      set -l commands
      set -l descriptions

      # Filter commands by group prefix
      ${lib.concatStringsSep "\n      " (lib.mapAttrsToList (name: desc:
        "if string match -q \"${name}*\" \"$group-*\"\n        set commands $commands \"${name} (alias)\"\n        set descriptions $descriptions \"${desc}\"\n      end"
      ) commandHelp)}

      # Add matching functions
      for func in (functions | grep "^$group-")
        set commands $commands "$func (function)"
        if set -q commandHelp[$func]
          set descriptions $descriptions $commandHelp[$func]
        else
          set descriptions $descriptions "📋 Custom function"
        end
      end

      if test (count $commands) -eq 0
        echo "No commands found for group: $group"
        return 1
      end

      # Create combined list for fzf
      set -l combined
      for i in (seq 1 (count $commands))
        set combined $combined "$commands[$i]\t$descriptions[$i]"
      end

      # Use fzf to select and execute
      set -l selected (printf "%s\n" $combined | fzf \
        --delimiter="\t" \
        --with-nth=1 \
        --preview="echo {2}" \
        --preview-window="down:3:wrap" \
        --header="🐠 $group Commands - Press Enter to execute" \
        --bind="enter:accept")

      if test -n "$selected"
        set -l cmd (echo $selected | cut -d"\t" -f1 | string replace " (alias)" "" | string replace " (function)" "")
        echo "🚀 Executing: $cmd"
        eval $cmd
      end
    '';
    envsource = ''

      for line in (cat $argv | grep -v '^#')
          set item (string split -m 1 '=' $line)
          set -gx $item[1] $item[2]
          echo "Exported key $item[1]"
        end
    '';
    app-onepass-fzf = ''
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

    nix-store-find-file = ''
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

    # System window manager functions
    sys-get-wm-class = ''
      gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.List | grep -Po '"wm_class_instance":"\K[^"]*'
      gtk-update-icon-cache
    '';

    sys-get-hypr-class = ''
      hyprctl clients -j | jq .[].class
    '';

    app-scratch-new = ''
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

    app-scratch-browse = ''
      cd ~/Documents/Scratch/
      glow
    '';

    nix-run-ephemeral = ''
      set -x NIXPKGS_ALLOW_UNFREE 1
      nix run nixpkgs#$argv[1] --impure
    '';
    nix-pkg-search = ''
      nix-env -qaP | rg -Hi $argv[1]
    '';
    vm-shutdown-all = ''
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
    k8s-download-kubeconfig = ''
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
    vm-net-list-all = ''
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

    vm-pool-list-all = ''
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

    vm-img-list-all = ''
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

    vm-list-all = ''
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
    app-send-to-phone = ''
      if test (count $argv) -ne 1
          echo "Error: This function requires a file path as an argument."
          return 1
      end

      set file_path $argv[1]
      tailscale file cp $file_path maximus:
    '';
    k8s-set-config = ''
      set -l kubeconfig_dir ~/.kube/configs
      set -l selected_config (fd --type f . $kubeconfig_dir | xargs -n 1 basename | fzf --prompt="Select kubeconfig: ")
      if test -n "$selected_config"
        set -gx KUBECONFIG $kubeconfig_dir/$selected_config
        echo "KUBECONFIG set to $kubeconfig_dir/$selected_config"
      else
        echo "No kubeconfig selected."
      end
    '';
    k8s-set-namespace = ''
      set -l namespaces (kubectl get namespaces -o jsonpath="{.items[*].metadata.name}")
      set -l selected_namespace (echo $namespaces | tr ' ' '\n' | fzf --prompt="Select namespace: ")
      if test -n "$selected_namespace"
        kubectl config set-context --current --namespace=$selected_namespace
        echo "Namespace set to $selected_namespace"
      else
        echo "No namespace selected."
      end
    '';
    talos-set-config = ''
      set -l talosconfig_dir ~/.talos/configs
      set -l selected_config (fd --type f . $talosconfig_dir | xargs -n 1 basename | fzf --prompt="Select talosconfig: ")
      if test -n "$selected_config"
        set -gx TALOSCONFIG $talosconfig_dir/$selected_config
        echo "TALOSCONFIG set to $talosconfig_dir/$selected_config"
      else
        echo "No talosconfig selected."
      end
    '';

    k8s-ns-delete-all-resources = ''
      if test (count $argv) -ne 1
          echo "Error: This function requires a namespace as an argument."
          return 1
      end

      set namespace $argv[1]
      kubectl --namespace $namespace delete (kubectl api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//') --all
    '';
    k8s-ns-find-stuck = ''
          if test -z $argv[1]
              echo "Please provide a namespace."
              return 1
          end

          kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $argv[1]
    '';
    k8s-force-terminating-ns = ''
      set NS (kubectl get ns | grep Terminating | awk 'NR==1 {print $1}')
      kubectl get namespace $NS -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
    '';

    k8s-get-containers = ''
      if test -z $argv[1]
          echo "Please provide a namespace."
          return 1
      end

      set namespace $argv[1]

      kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' && echo
    '';

    vm-net-get-info = ''
          for net in (sudo virsh net-list --all | awk 'NR>2 {print $1}')
          if test -n "$net"
              echo "Network: $net"
              sudo virsh net-info $net | grep 'Bridge:'
          end
      end
    '';
    fs-remove-interactive = ''
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

    h = ''
      if test (count $argv) -eq 0
        hx .
      else
        hx $argv
      end
    '';

    dev-jlint = ''
      if test (count $argv) -eq 0
        ${pkgs.just}/bin/just lint
      else
        ${pkgs.just}/bin/just lint $argv[1]
      end
    '';

    dev-jcheck = ''
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

    # Media conversion functions
    media-video-1080p = ''
      if test (count $argv) -ne 1
        echo "Usage: media-video-1080p <input_file>"
        echo "Transcodes a video to a good-balance 1080p that's great for sharing online"
        return 1
      end

      set input $argv[1]
      set output (string replace -r '\.[^.]* '-1080p.mp4' $input)
      ffmpeg -i $input -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy $output
    end'';

    media-video-4k = ''
      if test (count $argv) -ne 1
        echo "Usage: media-video-4k <input_file>"
        echo "Transcodes a video to a good-balance 4K that's great for sharing online"
        return 1
      end

      set input $argv[1]
      set output (string replace -r '\.[^.]* '-optimized.mp4' $input)
      ffmpeg -i $input -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k $output
    end'';

    media-img-to-jpg = ''
      if test (count $argv) -ne 1
        echo "Usage: media-img-to-jpg <input_file>"
        echo "Transcodes any image to JPG that's great for shrinking wallpapers"
        return 1
      end

      set input $argv[1]
      set output (string replace -r '\.[^.]* '.jpg' $input)
      magick $input -quality 95 -strip $output
    end'';

    media-img-to-jpg-small = ''
      if test (count $argv) -ne 1
        echo "Usage: media-img-to-jpg-small <input_file>"
        echo "Transcodes any image to JPG that's great for sharing online without being too big"
        return 1
      end

      set input $argv[1]
      set output (string replace -r '\.[^.]* '.jpg' $input)
      magick $input -resize 1080x\> -quality 95 -strip $output
    end'';

    media-img-to-png = ''
      if test (count $argv) -ne 1
        echo "Usage: media-img-to-png <input_file>"
        echo "Transcodes any image to compressed-but-lossless PNG"
        return 1
      end

      set input $argv[1]
      set output (string replace -r '\.[^.]* '.png' $input)
      magick $input -strip -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        $output
    end'';
  };



  allShellAbbrs = {
    # Keep short abbreviations for frequently used commands
    k = "kubectl";
    t = "talosctl";
    tf = "terraform";
    g = "git";
    d = "docker";
    e = "hx";

    # Grouped abbreviations with consistent naming
    nix-lint = "fd -e nix --hidden --no-ignore --follow . -x statix check {}";
    nix-info = "nix-shell -p nix-info --run 'nix-info -m'";
    tf-apply = "terraform apply";
    tf-destroy = "terraform destroy";
    tf-init = "terraform init -upgrade";
    tf-plan = "terraform plan";
    tf-state = "terraform state list";
    dev-docker-compose = "docker compose";
    dev-git-commit-push = "git pull && git add . && git commit -S && git push";
    app-mpv-youtube = "mpv";
    app-pueue = "pueue";
    cam-list-devices = "v4l2-ctl --list-devices";
    cam-list-features = "v4l2-ctl --list-ctrls -d /dev/video0";
    cam-set-saturation = "v4l2-ctl --set-ctrl=saturation=50 -d /dev/video0";
  };



  allShellAliases = {
    # File system enhancements
    fs-list = "eza -lh --group-directories-first --icons=auto";
    fs-list-all = "fs-list -a";
    fs-tree = "eza --tree --level=2 --long --icons --git";
    fs-tree-all = "fs-tree -a";
    fs-find-files = "fzf --preview 'bat --style=numbers --color=always {}'";
    fs-nav-up = "cd ..";
    fs-nav-up-2 = "cd ../..";
    fs-nav-up-3 = "cd ../../..";
    fs-nav-up-4 = "cd ../../../..";
    fs-disk-usage = "${pkgs.du-dust}/bin/dust";
    fs-ncdu = "${pkgs.gdu}/bin/gdu";

    # Keep common aliases for muscle memory
    ls = "eza -lh --group-directories-first --icons=auto";
    lsa = "ls -a";
    lt = "eza --tree --level=2 --long --icons --git";
    lta = "lt -a";
    ff = "fzf --preview 'bat --style=numbers --color=always {}'";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    du = "${pkgs.du-dust}/bin/dust";
    ncdu = "${pkgs.gdu}/bin/gdu";

    # Development shortcuts (keep muscle memory)
    dev-git = "git";
    dev-docker = "docker";
    dev-edit = "hx";
    dev-process-list = "${pkgs.procs}/bin/procs";
    dev-help = "${pkgs.tealdeer}/bin/tldr";
    dev-top = "${pkgs.btop}/bin/btop";
    dev-ping = "${pkgs.gping}/bin/gping";
    dev-yaml-viewer = "${pkgs.jless}/bin/jless --yaml";

    # Keep common shortcuts
    vi = "hx";
    vim = "hx";
    man = "${pkgs.tealdeer}/bin/tldr";
    top = "${pkgs.btop}/bin/btop";
    htop = "${pkgs.btop}/bin/btop";
    ping = "${pkgs.gping}/bin/gping";
    ps = "${pkgs.procs}/bin/procs";
    yless = "${pkgs.jless}/bin/jless --yaml";

    # System commands
    sys-support-info = ", fastfetch --logo none -c ${user-settings.user.home}/dev/nix/nixcfg/modules/cli/fastfetch/support.jsonc | xclip -selection clipboard";
    sys-support-info-extended = ", fastfetch --logo none -c ${user-settings.user.home}/dev/nix/nixcfg/modules/cli/fastfetch/support-extended.jsonc | xclip -selection clipboard";
    sys-troubleshoot-last-boot = "sudo journalctl -b -1 | curl -F 'file=@-' 0x0.st";
    sys-logs-home-manager = "sudo systemctl restart home-manager-dustin.service; journalctl -xeu home-manager-dustin.service";
    sys-tailscale-up-laptop = "sudo tailscale up --ssh --accept-dns --accept-routes --operator=$USER";
    sys-tailscale-up-desktop = "sudo tailscale up --operator=$USER --ssh --accept-dns";
    sys-font-cache-refresh = "sudo fc-cache -f -v";
    sys-font-list = "fc-list";
    sys-get-video-id = "nix --experimental-features 'flakes nix-command' run github:eclairevoyant/pcids";
    sys-get-ips = "ip -o -4 addr list | awk '{print $2, $4}'";
    sys-docs-nixcfg = "${pkgs.man}/bin/man configuration.nix";
    sys-docs-home-manager = "${pkgs.man}/bin/man home-configuration.nix";
    sys-commit-rebuild = "clear && cd ~/dev/nix/nixcfg && git add . && git commit -S && rm -f ${user-settings.user.home}/.config/mimeapps.list && rebuild && cd ~/dev/nix/nixcfg && git push";
    sys-update-push = "fs-nav-nixcfg && git pull && nix-upgrade && git add -A && git commit -S && git push";

    # Nix commands
    nix-build = "clear && cd ~/dev/nix/nixcfg/; rm -f ${user-settings.user.home}/.config/mimeapps.list && ${pkgs.just}/bin/just build";
    nix-rebuild = "clear && echo;echo '***** UPDATE APPIMAGES PERIODIALLY *****'; echo;  sleep 1; cd ~/dev/nix/nixcfg/ && ${pkgs.just}/bin/just rebuild";
    nix-upgrade = "clear && cd ~/dev/nix/nixcfg/; ${pkgs.just}/bin/just upgrade";
    nix-test = "clear && cd ~/dev/nix/nixcfg/; rm -f ${user-settings.user.home}/.config/mimeapps.list && ${pkgs.just}/bin/just test";
    nix-pkg-search-cli = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
    nix-index-update = "nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'";

    # Keep backward compatibility
    nxb = "nix-build";
    nxr = "nix-rebuild";
    nxu = "nix-upgrade";
    nxt = "nix-test";
    nps = "nix-pkg-search-cli";
    ncommit = "sys-commit-rebuild";
    do-update = "sys-update-push";
    nixcfg = "sys-docs-nixcfg";
    hmcfg = "sys-docs-home-manager";
    font-cache-refresh = "sys-font-cache-refresh";
    font-list = "sys-font-list";
    nix-get-video-id = "sys-get-video-id";
    ips = "sys-get-ips";
    hm-logs = "sys-logs-home-manager";
    support-info = "sys-support-info";
    support-info-extended = "sys-support-info-extended";
    tshoot-last-boot = "sys-troubleshoot-last-boot";
    tailscale-up-lt = "sys-tailscale-up-laptop";
    tailscale-up-dt = "sys-tailscale-up-desktop";
    comma-db = "nix-index-update";

    # Kubernetes commands
    k8s = "${pkgs.kubecolor}/bin/kubecolor";
    k8s-setup-config = "sudo chown -R dustin ~/.kube && sudo chmod -R 0700 ~/.kube && cd ~/.kube && ${pkgs.just}/bin/just";
    k8s-scan = "${pkgs.docker}/bin/docker run -it --rm --name rustscan rustscan/rustscan:latest";

    # Keep backward compatibility
    kubectl = "k8s";
    kcfg = "k8s-setup-config";
    rustscan = "k8s-scan";

    # VM commands
    vm-list = "sudo ${pkgs.libvirt}/bin/virsh list --all";

    # Keep backward compatibility
    vms = "vm-list";

    # Navigation commands
    fs-nav-terraform = "cd ~/dev/terraform";
    fs-nav-terraform-clusters = "cd ~/dev/terraform/clusters/";
    fs-nav-terraform-modules = "cd ~/dev/terraform/modules/";
    fs-nav-terraform-edit = "cd ~/dev/terraform && code -r .";
    fs-nav-scratch = "cd ~/Documents/Scratch/";
    fs-nav-nixcfg = "cd ~/dev/nix/nixcfg";
    fs-nav-screenshots = "cd ~/Pictures/Screenshots/";
    dev-edit-nixcfg = "cd ~/dev/nix/nixcfg/; hx";
    dev-edit-vscode-nixcfg = "cd ~/dev/nix/nixcfg && code -r .";

    # Keep backward compatibility
    gotf = "fs-nav-terraform";
    gotfc = "fs-nav-terraform-clusters";
    gotfm = "fs-nav-terraform-modules";
    gotf-e = "fs-nav-terraform-edit";
    gos = "fs-nav-scratch";
    gon = "fs-nav-nixcfg";
    gon-e = "dev-edit-vscode-nixcfg";
    goscreen = "fs-nav-screenshots";
    n = "dev-edit-nixcfg";
    ny = "cd ~/dev/nix/nixcfg/; yazi";

    # Instruqt commands
    instruqt-pull = "instruqt track pull";
    instruqt-push = "instruqt track push";
    instruqt-logs = "instruqt track logs";

    # Keep backward compatibility
    ipull = "instruqt-pull";
    ipush = "instruqt-push";
    ilog = "instruqt-logs";

    # Application commands
    app-kubitect = "${pkgs.steam-run}/bin/steam-run /etc/profiles/per-user/dustin/bin/kubitect";

    # Keep backward compatibility
    kubitect = "app-kubitect";

    # Utility commands
    copy-icons = "copy_icons";
    echo-home = "echo ${user-settings.user.home}";
    bless = "sudo xattr -r -d com.apple.quarantine";
    # y = "cd ~/; yazi";

    # Help system
    help = "fish-help-rofi";
    "?" = "fish-help-rofi";
  };


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
    # Override fish package to remove desktop file
    nixpkgs.overlays = [
      (final: prev: {
        fish = prev.fish.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            rm -f $out/share/applications/fish.desktop
          '';
        });
      })
    ];

    # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you will also want to enable the fish shell in /etc/nixos/configuration.nix:
    programs.fish.enable = true;


    # Install fish script packages
    environment.systemPackages = fishScripts;

    home-manager.users."${user-settings.user.username}" = {
      programs.fish = {
        enable = true;
        shellInit =
          if isWorkstation then
            ''
              # Shell Init
              direnv hook fish | source
              source ${user-settings.user.home}/.config/op/plugins.sh

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
                  source ${user-settings.user.home}/.config/op/plugins.sh

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

        # Apply all functions
        functions = allFunctions;

        shellAbbrs = allShellAbbrs;

        # Apply all shell aliases
        shellAliases = allShellAliases;
      };

      # Add custom completions for jlint and jcheck
      home = {
        file = {
          ".config/fish/completions/dev-jlint.fish".text = ''
            # Tab completion for dev-jlint function
            complete -c dev-jlint -xa "(__fish_complete_directories)"
            complete -c dev-jlint -xa "(find . -name '*.nix' -type f 2>/dev/null | string replace './' \"\")"
          '';

          ".config/fish/completions/jlint.fish".text = ''
            # Backward compatibility alias for jlint
            complete -c jlint -xa "(__fish_complete_directories)"
            complete -c jlint -xa "(find . -name '*.nix' -type f 2>/dev/null | string replace './' \"\")"
          '';

          ".config/fish/completions/dev-jcheck.fish".text = ''
            # Tab completion for dev-jcheck function - supports multiple files
            complete -c dev-jcheck -xa "(find . -name '*.nix' -type f 2>/dev/null | string replace './' \"\")"
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
