{ pkgs, lib, flakeInputs, ... }:
{
  # user account
  system_settings.core_modules.enable = true;
  system_settings.primary_user.username = "leier";
  system_settings.privilege_escalation.requirePasswordForWheel = false;
  # shell
  system_settings.primary_user.shell = pkgs.zsh;
  system_settings.shell_environment.enable = true;
  system_settings.shell_environment.zsh.enable = true;
  #
  system_settings.graphical_environment.enable = true;
  system_settings.graphical_environment.desktops.hyprland.enable = true;
  system_settings.graphical_environment.desktops.gnome.enable = true;

  # overwriting home-manager values
  home_manager_modules = [
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
