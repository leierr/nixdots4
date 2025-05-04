{ pkgs, lib, flakeInputs, ... }:
{
  systemModules.privilegeEscalation.requirePasswordForWheel = false;
  #
  systemModules.virtualization.libvirt.enable = true;
  #
  systemModules.graphicalEnvironment.enable = true;
  systemModules.graphicalEnvironment.applications.gaming.enable = true;
  systemModules.graphicalEnvironment.desktops.hyprland.enable = true;

  # scaling stuff
  systemModules.graphicalEnvironment.cursor.size = 32;

  # overwriting home-manager values
  homeModules = [
    ({
      programs.git.includes = [
        {
          condition = "hasconfig:remote.*.url:git@github.com:**/**";
          contents = {
            user = {
              name = "Lars Smith Eier";
              email = "hBm5BEqULhwPKUY@protonmail.com";
            };
          };
        }
      ];

      # more scaling stuff
      dconf.settings."org/gnome/desktop/interface".text-scaling-factor = 1.1;

      wayland.windowManager.hyprland.settings = {
        general.border_size = lib.mkForce 3;
        windowrulev2 = [ "monitor DP-2, class:^(vesktop)$" ];
        exec-once = [ "vesktop" ];
      };

      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = [ "~/.ssh/id_ed25519" ];
          };
        };
      };
    })
  ];

  networking.firewall.checkReversePath = false; # wireguard

  environment.systemPackages = with pkgs; [ tmux wireguard-tools unstable.bottles age sops pavucontrol fzf meld obsidian fastfetch spotify brave xfce.mousepad jq wofi gamemode ];
}
