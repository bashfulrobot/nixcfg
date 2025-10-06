_: {
  home-manager.sharedModules = [
    (_: {
      # Swaylock colors managed by stylix

      programs.swaylock.enable = true;
      programs.wlogout.enable = true;
    })
  ];
}
