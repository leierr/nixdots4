{ pkgs, lib, config, ... }:

let
  cfg = config.system_settings.graphical_environment.gtk;
in
{
  options.system_settings.graphical_environment.gtk.enable = lib.mkEnableOption "";

  config = lib.mkIf (cfg.enable) {
    # dependencies
    programs.dconf.enable = true;

    home_manager_modules = [
      ({ ... }@home_manager_inputs: {  
        gtk = {
          enable = true;

          # denne er skummel å leke med. Driter i size og setter en classic gnome default font her.
          font = {
            name = "gnome";
            package = pkgs.cantarell-fonts;
            size = null;
          };

          theme = {
            name = "Adwaita";
            package = pkgs.libadwaita;
          };

          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };

          # fuck gtk2, outdated fucker
          gtk2 = {
            configLocation = "${home_manager_inputs.config.xdg.configHome}/gtk-2.0/gtkrc";
            extraConfig = ''
              # dark theme - hell yea
              gtk-application-prefer-dark-theme = 1

              # sounds
              gtk-error-bell = 1
              gtk-enable-input-feedback-sounds = 1
              gtk-enable-event-sounds = 1

              # disable recent file history
              gtk-recent-files-limit = 0
              gtk-recent-files-max-age = 0

              # other stuff
              gtk-enable-animations = 1
            '';
          };

          gtk3 = {
            bookmarks = []; # for GTK file browsers mainly
            extraConfig = {
              # dark theme - hell yea
              gtk-application-prefer-dark-theme = 1;
              #
              gtk-enable-animations = 1;
              gtk-enable-primary-paste = 0; # middle click on a mouse should paste the ‘PRIMARY’ clipboard
              gtk-recent-files-enabled = 0; # unnecessary
              # sound shit
              gtk-enable-event-sounds = 1;
              gtk-enable-input-feedback-sounds = 1;
              gtk-error-bell = 1;
            };
            extraCss = '''';
          };

          gtk4 = {
            extraConfig = {
              # dark theme - hell yea
              gtk-application-prefer-dark-theme = 1;
              #
              gtk-enable-animations = 1;
              gtk-enable-primary-paste = 0; # middle click on a mouse should paste the ‘PRIMARY’ clipboard
              gtk-recent-files-enabled = 0; # unnecessary
              # sound shit
              gtk-enable-event-sounds = 1;
              gtk-enable-input-feedback-sounds = 1;
              gtk-error-bell = 1;
            };
            extraCss = '''';
          };
        };
        dconf = { settings."org/gnome/desktop/interface".color-scheme = "prefer-dark"; }; # GTK4
      })
    ];
  };
}
