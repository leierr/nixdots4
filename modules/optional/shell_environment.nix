{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.shell_environment;
in
{
  options.system_settings.shell_environment = {
    enable = lib.mkEnableOption "";
    # Optional
    mlocate.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    gnupg.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    git.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    editor.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    editor.program = lib.mkOption { type = lib.types.enum [ "nvim" ]; default = "nvim"; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # locate command + systemd timer for updating database.
    ( lib.mkIf cfg.mlocate.enable {
      services.locate = {
        enable = true;
        localuser = null; # silence warning
        package = pkgs.mlocate;
        interval = "*-*-* 14:00:00"; # every day @ 14:00
      };
    })

    # GnuPG
    ( lib.mkIf cfg.gnupg.enable {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = false;
      };
    })

    # Git
    ( lib.mkIf cfg.git.enable {
      programs.git.enable = true;
      home_manager_modules = [
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

    # NVIM
    ( lib.mkIf ( cfg.editor == "nvim" && cfg.editor.enable ) {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
      };
    })
  ]);
}
