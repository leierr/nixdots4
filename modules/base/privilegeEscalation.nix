{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.privilegeEscalation;
in
{
  options.systemModules.privilegeEscalation = {
    enable = lib.mkOption { type = lib.types.bool; default = config.systemModules.coreModules.enable or false; };

    implementation = lib.mkOption {
      type = lib.types.enum [ "sudo" "doas" ];
      default = "doas";
    };

    requirePasswordForWheel = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { security.polkit.enable = true; }

    (lib.mkIf (cfg.implementation == "doas") {
      security.doas.enable = true;
      security.sudo.enable = false;
      environment.etc."doas.conf".text = lib.mkForce ''
        permit ${ if !cfg.requirePasswordForWheel then "nopass" else "persist" } keepenv setenv { SSH_AUTH_SOCK TERMINFO TERMINFO_DIRS } :wheel

        # "root" is allowed to do anything.
        permit nopass keepenv root
      '';
      environment.interactiveShellInit = ''alias sudo="doas"'';
    })

    (lib.mkIf (cfg.implementation == "sudo") {
      security.sudo = {
        enable = true;
        wheelNeedsPassword = cfg.requirePasswordForWheel;
      };

      security.doas.enable = false;
    })
  ]);
}
