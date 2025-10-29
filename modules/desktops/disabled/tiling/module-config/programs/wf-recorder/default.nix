{ pkgs, ... }:
let
  # wf-recorder script packages using standard pattern
  wfRecorderScripts = with pkgs; [
    (writeShellScriptBin "wf-recorder-toggle" (builtins.readFile ./scripts/wf-recorder-toggle.sh))
    (writeShellScriptBin "wf-recorder-area" (builtins.readFile ./scripts/wf-recorder-area.sh))
  ];

in
{
  environment.systemPackages = with pkgs; [

    # keep-sorted start case=no numeric=yes
    libnotify   # for notify-send
    slurp       # for area selection
    wf-recorder # screen recorder
    # keep-sorted end
  ] ++ wfRecorderScripts;
}