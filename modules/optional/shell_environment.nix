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
    starship.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    editor.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    editor.program = lib.mkOption { type = lib.types.enum [ "nvim" ]; default = "nvim"; };
    #
    zsh.enable = lib.mkEnableOption "";
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
              url."https://github.com/".insteadOf = "git@github.com:";
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
    ( lib.mkIf ( cfg.editor.program == "nvim" && cfg.editor.enable ) {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
      };
    })

    # Starship
    ( lib.mkIf ( cfg.starship.enable ) { programs.starship.enable = true; })

    # ZSH
    ( lib.mkIf cfg.zsh.enable {
      programs.zsh.enable = true;
      home_manager_modules = [
        ({
          programs.zsh = {
            enable = true;
            oh-my-zsh.enable = true;
            oh-my-zsh.plugins = [ "git" "kubectl" "tmux" "systemd" ];
            syntaxHighlighting.enable = true;
            autosuggestion.enable = true;
            envExtra = ''
              ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=246"
            '';
            history.save = 690000;
            history.size = 690000;
          };
        })
      ];
    })
  ]);
}
