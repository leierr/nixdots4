{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.editor;
in
{
  options.systemModules.editor = {
    enable = lib.mkOption { type = lib.types.bool; default = config.systemModules.coreModules.enable or false; };
    program = lib.mkOption { type = lib.types.enum [ "nvim" ]; default = "nvim"; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { programs.nano.enable = false; } # bloat

    ( lib.mkIf ( cfg.program == "nvim" ) {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
      };
    })
  ]);
}
