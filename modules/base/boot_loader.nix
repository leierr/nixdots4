{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.boot_loader;
in
{
  options.system_settings.boot_loader = {
    # Required
    enable = lib.mkEnableOption "";

    # Optional
    provider = lib.mkOption {
      type = lib.types.enum [ "grub" "systemd_boot" ]; default = "grub";
    };

    grub.useOSProber = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Generic configuration
    {
      boot.tmp.cleanOnBoot = true;
      boot.loader.efi.canTouchEfiVariables = true;
    }

    # GRUB configuration
    (lib.mkIf (cfg.provider == "grub") {
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = cfg.grub.useOSProber;

        # GRUB theme
        theme = pkgs.stdenv.mkDerivation {
          name = "grub_theme";
          src = pkgs.fetchFromGitHub {
            owner = "AdisonCavani";
            repo = "distro-grub-themes";
            rev = "c96f868e75707ea2b2eb2869a3d67bd9c151cee6";
            hash = "sha256-QHqsQUEYxa04je9r4FbOJn2FqRlTdBLyvwZXw9JxWlQ=";
          };
          installPhase = ''
            mkdir -p $out
            tar -xf themes/nixos.tar -C $out
          '';
        };
      };

      boot.loader.timeout = 5;
    })

    # Systemd-boot configuration
    (lib.mkIf (cfg.provider == "systemd_boot") {
      boot.loader = {
        grub.enable = false;

        systemd-boot = {
          enable = true;
          editor = true;
        };

        timeout = 3;
      };
    })
  ]);
}
