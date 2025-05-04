{ pkgs, lib, flakeInputs, ... }:
{
  systemModules.privilegeEscalation.requirePasswordForWheel = false;
  #
  systemModules.graphicalEnvironment.enable = true;
  systemModules.graphicalEnvironment.desktops.hyprland.enable = true;
  systemModules.graphicalEnvironment.desktops.gnome.enable = true;

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

  networking.firewall.checkReversePath = false;

  environment.systemPackages = with pkgs; [ meld obsidian fastfetch spotify brave xfce.mousepad jq ];
}
