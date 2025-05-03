{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.graphical_environment.xdg;
in
{
  options.system_settings.graphical_environment.xdg.enable = lib.mkEnableOption "";

  config = lib.mkIf (cfg.enable) {
    # mimeapps dependencies
    environment.systemPackages = with pkgs; [ gthumb firefox-bin mpv transmission_4  ];

    home_manager_modules = [
      ({ ... }@home_manager_inputs: {
        xdg = {
          enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
            desktop = "${home_manager_inputs.config.home.homeDirectory}/Desktop";
            download = "${home_manager_inputs.config.home.homeDirectory}/Downloads";
            music = "${home_manager_inputs.config.home.homeDirectory}/Music";
            pictures = "${home_manager_inputs.config.home.homeDirectory}/Pictures";
            videos = "${home_manager_inputs.config.home.homeDirectory}/Videos";
            documents = "${home_manager_inputs.config.home.homeDirectory}/Documents";
            publicShare = "${home_manager_inputs.config.home.homeDirectory}/Documents/Public";
            templates = "${home_manager_inputs.config.home.homeDirectory}/Documents/Templates";
          };

          mimeApps = {
            enable = true;

            defaultApplications = {
              "x-scheme-handler/http" = [ "firefox.desktop" ];
              "x-scheme-handler/https" = [ "firefox.desktop" ];
              "x-scheme-handler/chrome" = [ "firefox.desktop" ];
              "text/html" = [ "firefox.desktop" ];
              "application/x-extension-htm" = [ "firefox.desktop" ];
              "application/x-extension-html" = [ "firefox.desktop" ];
              "application/x-extension-shtml" = [ "firefox.desktop" ];
              "application/xhtml+xml" = [ "firefox.desktop" ];
              "application/x-extension-xhtml" = [ "firefox.desktop" ];
              "application/x-extension-xht" = [ "firefox.desktop" ];

              # magnet links / torrenting
              "x-scheme-handler/magnet" = [ "transmission-gtk.desktop" ];
              "application/x-bittorrent" = [ "transmission-gtk.desktop" ];

              # Images
              "image/*" = [ "gthumb.desktop" ];

              # Videos
              "video/*" = [ "mpv.desktop" ];
            };
          };
        };
      })
    ];
  };
}
