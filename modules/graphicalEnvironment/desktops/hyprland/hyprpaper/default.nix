{ lib, pkgs, theme }:
{
  environment.systemPackages = [ pkgs.hyprpaper ];

  homeModules = [
    ({
      services.hyprpaper = {
        enable = true;
        settings = {
          # disable IPC because I dont need it + battery consumption
          ipc = false;
          splash = false;
          preload = "${theme.wallpaper}";
          wallpaper = ",${theme.wallpaper}";
        };
      };

      # disable the systemd service that comes with services.hyprpaper.enable
      systemd.user.services.hyprpaper = lib.mkForce {};
    })
  ];
}
