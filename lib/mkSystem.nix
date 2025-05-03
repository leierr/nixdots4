{ flakeInputs }: # so I dont have to specify it every time im creating a new system.
{ host_name, system_state_version, system ? "x86_64-linux" }:
let
  nixpkgs = flakeInputs.nixpkgs;
  configuration = ../systems/${host_name}/configuration.nix;
  hardware_configuration = ../systems/${host_name}/hardware_configuration.nix;
  monitors_configuration = if (builtins.pathExists ../systems/${host_name}/monitors.nix) then ../systems/${host_name}/monitors.nix else {};
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit flakeInputs; };
  modules = [
    configuration
    hardware_configuration
    monitors_configuration
    ../modules
    flakeInputs.home-manager.nixosModules.home-manager
    {
      system.stateVersion = system_state_version;
      networking.hostName = host_name;
    }
  ];
}
