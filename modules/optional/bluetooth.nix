{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.bluetooth;
in
{
  options.system_settings.bluetooth = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          EnableSecureSimplePairing = true; # Ensure that secure pairing (e.g., SSP - Secure Simple Pairing) is used.
          JustWorksRepairing = false; # Prevent weak "Just Works" pairing
          Disable = "ControllerMode,BR/EDR"; # Disable classic Bluetooth (BR/EDR)
        };
        Policy = {
          AutoAcceptPairing = false; # Do not automatically accept pairing requests
        };
      };
    };

    # GTK interface for managing bluetooth, which includes an applet (blueman-applet)
    services.blueman.enable = true;

    environment.systemPackages = with pkgs; [
      bluetui # TUI for managing bluetooth on Linux written in rust https://github.com/pythops/bluetui
    ];
  };
}
