{ flakeInputs, lib, config, ... }:
{
  options = {
    homeModules = lib.mkOption { default = []; };

    systemModules.coreModules.enable = lib.mkOption { type = lib.types.bool; default = true; };
  };

  # Import all the things. Everything is using an "enable" toggle
  imports = [
    ./base/bootLoader.nix
    ./base/editor.nix
    ./base/locale.nix
    ./base/network.nix
    ./base/nixos.nix
    ./base/primaryUser.nix
    ./base/privilegeEscalation.nix
    ./base/utils.nix
    ./base/virtualization.nix

    ./hardware/bluetooth.nix

    ./graphicalEnvironment
  ];

  config = {
    # home-manager setup
    home-manager = lib.mkIf config.systemModules.primary_user.enable {
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = { inherit flakeInputs; };
      users.${config.systemModules.primary_user.username} = {
        imports = config.homeModules;
        home.stateVersion = "${config.system.stateVersion}";
      };
    };
  };
}
