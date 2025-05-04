{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.graphicalEnvironment.fonts;
in
{
  options.systemModules.graphicalEnvironment.fonts = {
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
