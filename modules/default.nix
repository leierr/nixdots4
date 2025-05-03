{ flakeInputs, lib, config, ... }:
{
  options = {
    home_manager_modules = lib.mkOption {
      default = []; description = "configuring home-manager in main config. List of home manager modules";
    };

    system_settings.core_modules.enable = lib.mkEnableOption "";
  };

  # Import all the things. Everything is using an "enable" toggle
  imports = [
    ./base/boot_loader.nix
    ./base/locale.nix
    ./base/network.nix
    ./base/nixos.nix
    ./base/primary_user.nix
    ./base/privilege_escalation.nix

    ./optional/bluetooth.nix
    ./optional/shell_environment.nix
    ./optional/virtualization.nix

    ./graphical_environment
  ];

  config = {
    # Enable core modules
    system_settings = lib.mkIf config.system_settings.core_modules.enable {
      boot_loader.enable = true;
      locale.enable = true;
      network.enable = true;
      nixos.enable = true;
      primary_user.enable = true;
      privilege_escalation.enable = true;
    };

    # home-manager setup
    home-manager = lib.mkIf config.system_settings.primary_user.enable {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = { inherit flakeInputs; };
      users.${config.system_settings.primary_user.username} = {
        imports = config.home_manager_modules;
        home.stateVersion = "${config.system.stateVersion}";
      };
    };
  };
}
