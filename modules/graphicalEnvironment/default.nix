{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.graphicalEnvironment;
in
{
  options.systemModules.graphicalEnvironment = {
    # Required
    enable = lib.mkEnableOption "";

    # Optional
    display_manager = {
      enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; }; # display_manager can be manually disabled.
      implementation = lib.mkOption { type = lib.types.enum [ "ly" "gdm" ]; default = "ly"; };
    };
  };

  imports = [
    ./base/applications ./base/audio.nix ./base/cursor.nix
    ./base/fonts.nix ./base/gtk.nix ./base/qt.nix
    ./base/xdg.nix
    #
    ./desktops/gnome ./desktops/hyprland
    #
    ./theme
  ];

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Default enabled base of a graphical system
      systemModules.graphicalEnvironment.cursor.enable = true;
      systemModules.graphicalEnvironment.audio.enable = true;
      systemModules.graphicalEnvironment.applications.enable = true;
      systemModules.graphicalEnvironment.gtk.enable = true;
      systemModules.graphicalEnvironment.qt.enable = true;
      systemModules.graphicalEnvironment.fonts.enable = true;
      systemModules.graphicalEnvironment.xdg.enable = true;
    }

    # LY - a TUI display manager
    ( lib.mkIf ( cfg.display_manager.enable && cfg.display_manager.implementation == "ly") {
      services.displayManager.ly = {
        enable = true;
        package = pkgs.ly;
        settings = { hide_borders = true; };
      };
    })

    # GDM - The GNOME Display Manager
    ( lib.mkIf ( cfg.display_manager.enable && cfg.display_manager.implementation == "gdm") {
      services.xserver.displayManager.gdm = {
        enable = true;
        wayland = true;
        autoSuspend = false;
        settings = {};
      };
    })
  ]);
}
