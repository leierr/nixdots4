{
  outputs = { nixpkgs, home-manager, ... }@flakeInputs:
    let
      mkSystem = (import ./mkSystem.nix { inherit flakeInputs; });
    in {
      nixosConfigurations = {
        desktop = mkSystem { host_name = "desktop"; system_state_version = "24.11"; };
      };
    };

  inputs = {
    # Stable and Unstable Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprland and Hyprsplit
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland.git";
      submodules = true;
      ref = "refs/tags/v0.45.2";
    };
    hyprsplit = {
      type = "git";
      url = "https://github.com/shezdy/hyprsplit.git";
      ref = "refs/tags/v0.45.2";
      allRefs = true;
      inputs.hyprland.follows = "hyprland";
    };
  };
}
