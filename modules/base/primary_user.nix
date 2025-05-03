{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.primary_user;

  # Awesome hack to add my primary user to all the groups
  if_groups_exists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.system_settings.primary_user = {
    # Required
    enable = lib.mkEnableOption "";
    username = lib.mkOption { type = lib.types.singleLineStr; };

    # Optional
    description = lib.mkOption {
      type = lib.types.nullOr(lib.types.singleLineStr);
      default = cfg.username;
    };

    initialPassword = lib.mkOption {
      type = lib.types.nullOr(lib.types.singleLineStr);
      default = "123";
    };

    shell = lib.mkOption {
      type = lib.types.shellPackage;
      default = pkgs.bash;
    };

    home_directory = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/home/${cfg.username}";
    };

    secondary_groups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = if_groups_exists [
        "wheel" "video" "audio" "adm" "docker"
        "podman" "networkmanager" "git" "network"
        "wireshark" "libvirtd" "kvm" "mlocate"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Disable root password
    users.users.root.hashedPassword = "!";

    # Ensure group for user exists
    users.extraGroups.${cfg.username}.name = cfg.username;

    # Create the user account
    users.users.${cfg.username} = {
      isNormalUser = true;
      shell = cfg.shell;
      home = cfg.home_directory;
      homeMode = "0770";
      createHome = true;
      initialPassword = cfg.initialPassword;
      group = cfg.username;
      extraGroups = cfg.secondary_groups;
      description = cfg.description;
    };
  };
}
