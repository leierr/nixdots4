{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.privilege_escalation;
in
{
  options.system_settings.privilege_escalation = {
    # Required
    enable = lib.mkEnableOption "";

    # Optional
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
    (lib.mkIf (cfg.implementation == "doas") {
      security.doas = {
        enable = true;
        wheelNeedsPassword = cfg.requirePasswordForWheel;
        extraRules = lib.mkForce [{
          groups = [ "wheel" ];
          noPass = !cfg.requirePasswordForWheel;
          keepEnv = true;
        }];
      };
      environment.interactiveShellInit = ''alias sudo="doas"'';
      security.sudo.enable = false;
    })

    (lib.mkIf (cfg.implementation == "sudo") {
      security.sudo = {
        enable = true;
        wheelNeedsPassword = cfg.requirePasswordForWheel;
      };

      security.doas.enable = false;
    })

    {
      security.polkit.enable = true;
    }
  ]);
}
