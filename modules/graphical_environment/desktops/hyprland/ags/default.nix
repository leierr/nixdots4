{ lib, pkgs, theme, flakeInputs }:
let
  hexColorPattern = "^#[0-9a-fA-F]{6}";
  # Function to generate SCSS variable declarations from theme attributes
  nixThemeToScssVariables = lib.concatStrings (lib.mapAttrsToList (name: value: 
    if lib.isString value && builtins.match hexColorPattern value != null then ''
      ''$${name}: ${value};
    '' else ""
  ) theme);
in
{
  home_manager_modules = [
    ({
      #home.file.".config/ags" = {
      #  source = ./config;
      #  recursive = true;
      #};

      home.file.".config/ags/style/nix_theme.scss".text = nixThemeToScssVariables;

      imports = [ flakeInputs.ags.homeManagerModules.default ];

      programs.ags = {
        enable = true;
        extraPackages = with pkgs; [
          flakeInputs.ags.packages.${pkgs.system}.hyprland
          flakeInputs.ags.packages.${pkgs.system}.tray
          flakeInputs.ags.packages.${pkgs.system}.notifd
          dart-sass
        ];
      };
    })
  ];
}