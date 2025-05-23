{ config, lib, pkgs, flakeInputs, ... }:

let
  cfg = config.systemModules.graphicalEnvironment.desktops.hyprland;
  theme = config.systemModules.graphicalEnvironment.theme;
in
{
  options.systemModules.graphicalEnvironment.desktops.hyprland = {
    enable = lib.mkEnableOption "";
    hyprpaper.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    hyprlock.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    hypridle.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
    ags.enable = lib.mkOption { type = lib.types.bool; default = cfg.enable; };
  };

  config = lib.mkIf (cfg.enable) (lib.mkMerge [
    (lib.mkIf cfg.hyprpaper.enable (import ./hyprpaper { inherit lib pkgs theme; }))
    (lib.mkIf cfg.hyprlock.enable (import ./hyprlock { inherit lib pkgs theme; }))
    (lib.mkIf cfg.hypridle.enable (import ./hypridle { inherit lib pkgs; }))
    (lib.mkIf cfg.ags.enable (import ./ags { inherit lib pkgs theme flakeInputs; }))
    (import ./rofi { inherit lib pkgs theme; })

    {
      programs.hyprland.enable = true;
      programs.hyprland.package = flakeInputs.hyprland.packages.${pkgs.system}.hyprland;
      programs.hyprland.portalPackage = flakeInputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;

      xdg.portal.config.hyprland.default = [ "hyprland" "gtk" ];
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # det er currently issue https://github.com/NixOS/nixpkgs/issues/334260

      # NAUTILUS FUNCTIONALITY
      services.gvfs.enable = true;

      # Terminal of choice
      systemModules.graphicalEnvironment.applications.foot.enable = true;

      homeModules = [
        ({
          wayland.windowManager.hyprland = {
            enable = true;
            xwayland.enable = true;
            package = flakeInputs.hyprland.packages.${pkgs.system}.hyprland;
            plugins = [ flakeInputs.hyprsplit.packages.${pkgs.system}.hyprsplit ];
            settings = {
              # variables
              "$mod" = "SUPER";
              "$terminal" = "foot";
              "$browser" = "firefox";
              "$application_launcher" = "rofi -show drun -config ~/.config/rofi/drun.rasi";
              "$screenshot_exec" = "grimblast --freeze copy area";
              "$lockscreen" = "hyprlock";

              env = [
                "QT_QPA_PLATFORM,wayland"
                "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
                "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
                "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
                "MOZ_WEBRENDER,1"
                "SDL_VIDEODRIVER,wayland"
                "GDK_BACKEND,wayland"
                "ADW_DISABLE_PORTAL,1" # gtk4 please use config files
              ];

              # autostart
              exec-once = [ "$browser" ];
              exec = [
                "pidof hyprpaper || hyprpaper"
                "pidof hypridle || hypridle"
                "pidof ags || ags"
                "pidof nm-applet || nm-applet"
                "pidof ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 || ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
              ];

              general = {
                # borders
                border_size = 2;
                no_border_on_floating = false;
                "col.inactive_border" = "rgb(${builtins.replaceStrings ["#"] [""] theme.unfocused_border_color})";
                "col.active_border" = "rgb(${builtins.replaceStrings ["#"] [""] theme.green}) rgb(${builtins.replaceStrings ["#"] [""] theme.green}) rgb(${builtins.replaceStrings ["#"] [""] theme.green}) rgb(${builtins.replaceStrings ["#"] [""] theme.blue}) rgb(${builtins.replaceStrings ["#"] [""] theme.blue}) rgb(${builtins.replaceStrings ["#"] [""] theme.blue}) 30deg";

                # gaps
                gaps_in = 10;
                gaps_out = 20;

                # layout
                layout = "dwindle";
              };

              decoration = {
                rounding = 10;
                blur.enabled = false;
                shadow = {
                  enabled = true;
                  ignore_window = true;
                  range = 40;
                  render_power = 6;
                  offset = "0 0";
                  color = "rgba(0, 0, 0, 0.9)";
                };
              };

              animations = {
                enabled = false;
              };

              misc = {
                # disable default shit
                disable_hyprland_logo = true;
                disable_splash_rendering = true;
                focus_on_activate = true;
              };

              dwindle = {
                # spawn new windows to the right
                force_split = 2;
              };

              # window rules
              windowrulev2 = [
                # floaters
                "float, class:^(gnome-calculator|org\.gnome\.Calculator)$"
                "float, initialClass:^(gcr-prompter|nm-openconnect-auth-dialog|polkit-gnome-authentication-agent-1)$"

                # stay in focus
                "stayfocused, initialClass:^(gcr-prompter|polkit-gnome-authentication-agent-1)$"
                "stayfocused, class:^(Rofi)$"

                # pinned
                "pin, initialClass:^(gcr-prompter|polkit-gnome-authentication-agent-1|nm-openconnect-auth-dialog)$"

                # centered windows
                "center 1, initialClass:^(nm-openconnect-auth-dialog)$"

                # no decorations unless floating on single tile workspace
                "noborder, onworkspace:w[t1], floating:0"
                "rounding 0, onworkspace:w[t1], floating:0"
                "noshadow, onworkspace:w[t1], floating:0"

                # dont maximize on your own
                "suppressevent maximize, class:^(.*)$"

                # nm-auth-dialog size
                "size 640 510, initialClass:^(nm-openconnect-auth-dialog)$"

                # temporary floaties
                "tag +tempfloat, initialTitle:^(Open File)$"
                "tag +tempfloat, class:^(nm-connection-editor|pavucontrol)$"
                "float, tag:tempfloat"
                "size 45% 45%, tag:tempfloat"
              ];

              # workspace rules
              workspace = [
                "w[t1], gapsout:0" 
              ];

              layerrule = [
                "dimaround, rofi"
              ];

              # keyboard binds
              bind = [
                "$mod, Return, exec, $terminal"
                "$mod, D, exec, $application_launcher"
                "$mod, Q, exec, $screenshot_exec"
                #"$mod, B, exec, ${config.systemModules.gui.rofi.plugins.rbw.exec}/bin/rofi-rbw"

                # Window managment
                "$mod, W, killactive"
                "$mod, S, togglefloating"
                "$mod, F, fullscreen"
                "$mod, M, fullscreen, 1"

                # moving about the WM
                "$mod, 1, split:workspace, 1"
                "$mod, 2, split:workspace, 2"
                "$mod, 3, split:workspace, 3"
                "$mod, 4, split:workspace, 4"
                "$mod, 5, split:workspace, 5"
                "$mod, 6, split:workspace, 6"

                "$mod SHIFT, 1, split:movetoworkspacesilent, 1"
                "$mod SHIFT, 2, split:movetoworkspacesilent, 2"
                "$mod SHIFT, 3, split:movetoworkspacesilent, 3"
                "$mod SHIFT, 4, split:movetoworkspacesilent, 4"
                "$mod SHIFT, 5, split:movetoworkspacesilent, 5"
                "$mod SHIFT, 6, split:movetoworkspacesilent, 6"

                "$mod, O, focusmonitor, +1"
                "$mod SHIFT, O, movewindow, mon:+1"

                "$mod, C, cyclenext"
                "$mod SHIFT, C, swapnext"

                "$mod, h, movefocus, l"
                "$mod, l, movefocus, r"
                "$mod, k, movefocus, u"
                "$mod, j, movefocus, d"

                "$mod SHIFT, h, movewindow, l"
                "$mod SHIFT, l, movewindow, r"
                "$mod SHIFT, k, movewindow, u"
                "$mod SHIFT, j, movewindow, d"
              ];

              # mouse binds
              bindm = [
                "$mod, mouse:272, movewindow"
                "$mod, mouse:273, resizewindow"
              ];

              plugin = {
                hyprsplit = {
                  num_workspaces = 5;
                  persistent_workspaces = true;
                };
              };
            };

            extraConfig = ''
              # WM control center submap
              bind = $mod, X, exec, sleep 2 && hyprctl dispatch submap reset
              bind = $mod, X, submap, system_control
              submap = system_control

              # shut down computer
              bind = , ESCAPE, exec, systemctl poweroff
              bind = , ESCAPE, submap, reset

              # exit hyprland
              bind = , Q, exit
              bind = , Q, submap, reset

              # reload hyprland
              bind = , R, exec, hyprctl reload config-only
              bind = , R, submap, reset
              bind = $mod, R, exec, hyprctl reload
              bind = $mod, R, submap, reset

              # lockscreen
              bind = , L, exec, $lockscreen
              bind = , L, submap, reset

              bind = , catchall, submap, reset

              submap = reset
            '';
          };
        })
      ];

      # dependencies
      environment.systemPackages = with pkgs; [
        grimblast # screenshot tool
        wl-clipboard # clipboard manipulation tool
        nautilus sushi file-roller # filebrowser
        firefox-bin # browser
        networkmanagerapplet # dependencies
      ];
    }
  ]);
}
