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
  system_settings.virtualization.libvirt = { enable = true; virt_manager.enable = true; };
  #
  system_settings.graphical_environment.enable = true;
  system_settings.graphical_environment.applications.gaming.enable = true;
  system_settings.graphical_environment.desktops.hyprland.enable = true;

  # scaling stuff
  system_settings.graphical_environment.cursor.size = 32;

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

  environment.systemPackages = with pkgs; [ tmux wireguard-tools age sops pavucontrol fzf meld obsidian fastfetch spotify brave xfce.mousepad jq wofi ];
}
