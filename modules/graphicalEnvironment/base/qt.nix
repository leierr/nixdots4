{ pkgs, lib, config, ... }:

let
  cfg = config.systemModules.graphicalEnvironment.qt;
in
{
  options.systemModules.graphicalEnvironment.qt.enable = lib.mkEnableOption "";

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [ qgnomeplatform qgnomeplatform-qt6 adwaita-qt adwaita-qt6 ];

    qt = {
      enable = true;
      style = "adwaita-dark";
    };

    homeModules = [
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
