{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.graphical_environment.applications;
  theme = config.system_settings.graphical_environment.theme;
in
{
  options.system_settings.graphical_environment.applications = {
    enable = lib.mkEnableOption "";
    vscodium.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    vesktop.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    foot.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    gaming.enable = lib.mkEnableOption ""; # manual toggle
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # toggle for installing and configuring foot terminal
    ( lib.mkIf cfg.foot.enable (import ./foot_terminal { inherit theme; }) )
    # VSCODIUM
    ( lib.mkIf cfg.vscodium.enable {
      home_manager_modules = [
        ({
          programs.vscode = {
            enable = true;
            package = pkgs.vscodium;
            extensions = with pkgs.vscode-extensions; [
              bbenoist.nix # nix syntax highlighting
            ];
            userSettings = {
              "editor.tabSize" = 2;
              "editor.insertSpaces" = true;
              "security.workspace.trust.enabled" = false;
              "git.enableSmartCommit" = true;
              "git.autofetch" = true;
              "git.confirmSync" = false;
              "explorer.confirmDelete" = false;
              "explorer.confirmDragAndDrop" = false;
              "colorize.colorized_colors" = ["BROWSERS_COLORS" "HEXA" "RGB" "HSL"];
              "colorize.colorized_variables" = ["CSS"];
              "colorize.exclude" = ["**/.git" "**/.svn" "**/.hg" "**/CVS" "**/.DS_Store" "**/.git" "**/node_modules" "**/bower_components" "**/tmp" "**/dist" "**/tests"];
              "colorize.include" = ["**/*.nix" "**/*.css" "**/*.scss" "**/*.sass" "**/*.less" "**/*.styl"];
            };
          };
        })
      ];
    })

    # VESKTOP + discord alias
    ( lib.mkIf cfg.vesktop.enable {
      nixpkgs.overlays = [
        (final: prev:
        {
          vesktop = prev.vesktop.overrideAttrs (old: {
            desktopItems = [
              (pkgs.makeDesktopItem {
                name = "discord";
                exec = "vesktop %U";
                icon = "discord";
                desktopName = "Discord";
                genericName = "All-in-one cross-platform voice and text chat for gamers";
                categories = [ "Network" "InstantMessaging" ];
                mimeTypes = [ "x-scheme-handler/discord" ];
              })
            ];
          });
        })
      ];
      environment.systemPackages = [ pkgs.vesktop ];
    })

    # GAMERS UNITE
    ( lib.mkIf cfg.gaming.enable {
      # install steam
      programs.steam.enable = true;

      # udev rules for controllers etc
      hardware.steam-hardware.enable = true;

      # noe wayland ximput compatabillity drit
      # programs.steam.extest.enable = true;
      
      # good to just have lutris just in case I need it.
      environment.systemPackages = [ pkgs.lutris ];
    })
  ]);
}
