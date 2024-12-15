{ pkgs, lib, config, ... }:

let
  cfg = config.system_settings.graphical_environment.qt;
in
{
  options.system_settings.graphical_environment.qt.enable = lib.mkEnableOption "";

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [ qgnomeplatform qgnomeplatform-qt6 adwaita-qt adwaita-qt6 ];

    qt = {
      enable = true;
      style = "adwaita-dark";
    };

    home_manager_modules = [
      ({
        qt = {
          enable = true;
          platformTheme.name = "adwaita";
          style.name = "adwaita-dark";
        };
      })
    ];
  };
}
