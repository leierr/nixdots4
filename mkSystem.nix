{ flakeInputs }: # so I dont have to specify it every time im creating a new system.
{ host_name, system_state_version, system ? "x86_64-linux",
  monitors_configuration ? ( ./. + "./hosts/${host_name}/monitors.nix" ),
  hardware_configuration ? ( ./. + "./hosts/${host_name}/hardware_configuration.nix" ),
}:
let
  nixpkgs = flakeInputs.nixpkgs;
  configuration = ./hosts/${host_name}/configuration.nix;
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit flakeInputs;
  };
  modules = [
    configuration
    hardware_configuration
    monitors_configuration
    ./modules
    flakeInputs.home-manager.nixosModules.home-manager
    {
      system.stateVersion = system_state_version;
      networking.hostName = host_name;
    }
  ];
}