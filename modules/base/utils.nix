{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.utils;
in
{
  options.systemModules.utils = {
    enable = lib.mkOption { type = lib.types.bool; default = config.systemModules.coreModules.enable; };
    
    # default enabled
    git.enable = lib.mkOption { type = lib.types.bool; default = true; };

    # optional
    mlocate.enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ( lib.mkIf cfg.git.enable {
      programs.git.enable = true;
      homeModules = [
        ({
          programs.git = {
            enable = true;
            extraConfig = {
              url."git@github.com:".insteadOf = "https://github.com/";
              credential.helper = "cache --timeout=36000";
              safe.directory = "*";
            };
            includes = [];
            ignores = [];
          };
        })
      ];
    })

    # locate command + systemd timer for updating database.
    ( lib.mkIf cfg.mlocate.enable {
      services.locate = {
        enable = true;
        localuser = null; # silence warning
        package = pkgs.mlocate;
        interval = "*-*-* 14:00:00"; # every day @ 14:00
      };
    })
  ]);
}
