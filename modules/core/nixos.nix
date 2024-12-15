{ config, lib, flakeInputs, ... }:

let
  cfg = config.system_settings.nixos;
in
{
  options.system_settings.nixos = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.hostPlatform = config.nixpkgs.system;

    # make unstable packages available as an nixpkgs overlay
    nixpkgs.overlays = [
      (final: prev: {
        unstable = import flakeInputs.nixpkgs_unstable {
          system = config.nixpkgs.system;
          config = config.nixpkgs.config;
        };
      })
    ];

    nixpkgs.config.allowUnfree = true;

    documentation.nixos.enable = false;

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      settings = {
        auto-optimise-store = true;
        flake-registry = ""; # Disable global registry
        experimental-features = [ "nix-command" "flakes" ];

        # extra cache sources
        substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };

      # Thanks to: https://nixos-and-flakes.thiscute.world/best-practices/nix-path-and-flake-registry#custom-nix-path-and-flake-registry
      registry.nixpkgs.flake = flakeInputs.nixpkgs; # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
      channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
      nixPath = [ "nixpkgs=${flakeInputs.nixpkgs.outPath}" ];
    };
  };
}
