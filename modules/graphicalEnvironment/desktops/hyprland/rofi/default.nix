{ theme, lib, pkgs }:
(lib.mkMerge [
  {
    environment.systemPackages = with pkgs; [
    # dependencies to run correctly
    rofi-wayland
    hack-font
    nerdfonts
    papirus-icon-theme
  ];}

  ( import ./configs/theme.nix { inherit theme; })
  ( import ./configs/drun.nix )
])
