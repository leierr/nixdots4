{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.graphical_environment.fonts;
in
{
  options.system_settings.graphical_environment.fonts = {
    enable = lib.mkEnableOption "";

    default_fonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        cantarell-fonts
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        hack-font
        nerdfonts
        jetbrains-mono
      ];
    };
  };

  config = lib.mkIf (cfg.enable) {
    fonts.enableDefaultPackages = true;
    fonts.packages = cfg.default_fonts;
  };
}
