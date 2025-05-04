{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.hardware.bluetooth;
in
{
  options.systemModules.hardware.bluetooth.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          JustWorksRepairing = "confirm";
          FastConnectable = false; # powersaving, might want to enable it.
        };

        Policy.AutoEnable = true; # Automatically enable adapters on boot
      };
    };

    # GTK interface for managing bluetooth, which includes an applet (blueman-applet)
    services.blueman.enable = config.systemModules.graphicalEnvironment.enable or false;

    environment.systemPackages = with pkgs; [
      bluetui # TUI for managing bluetooth on Linux written in rust https://github.com/pythops/bluetui
    ];
  };
}
