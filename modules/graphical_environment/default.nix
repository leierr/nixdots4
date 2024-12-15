{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.graphical_environment;
in
{
  options.system_settings.graphical_environment = {
    # Required
    enable = lib.mkEnableOption "";

    # Optional
    display_manager = {
      enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; }; # display_manager can be manually disabled.
      implementation = lib.mkOption { type = lib.types.enum [ "ly" "gdm" ]; default = "ly"; };
    };
  };

  imports = [
    ./base/applications.nix ./base/audio.nix ./base/cursor.nix
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
      system_settings.graphical_environment.cursor.enable = true;
      system_settings.graphical_environment.audio.enable = true;
      system_settings.graphical_environment.applications.enable = true;
      system_settings.graphical_environment.gtk.enable = true;
      system_settings.graphical_environment.qt.enable = true;
      system_settings.graphical_environment.fonts.enable = true;
      system_settings.graphical_environment.xdg.enable = true;
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
