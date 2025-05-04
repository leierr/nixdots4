{ config, lib, ... }:

let
  cfg = config.systemModules.graphicalEnvironment.audio;
in
{
  options.systemModules.graphicalEnvironment.audio.enable = lib.mkEnableOption "";

  config = lib.mkIf (cfg.enable) {
    # Enable sound with pipewire.
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
    };

    # Realtime Policy and Watchdog Daemon. Many programs depends on it like pipewire
    security.rtkit.enable = true;
  };
}
