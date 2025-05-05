{ config, lib, pkgs, ... }:

let
  cfg = config.systemModules.primaryUser;

  # Awesome hack to add my primary user to all the groups
  if_groups_exists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.systemModules.primaryUser = {
    enable = lib.mkOption { type = lib.types.bool; default = config.systemModules.coreModules.enable; };
    username = lib.mkOption { type = lib.types.singleLineStr; default = "leier"; };
    shell = lib.mkOption { type = lib.types.enum [ "zsh" ]; default = "zsh"; };

    secondary_groups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = if_groups_exists [
        "wheel" "video" "audio" "adm" "docker"
        "podman" "networkmanager" "git" "network"
        "wireshark" "libvirtd" "kvm" "mlocate"
      ];
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Disable root user
      users.users.root.hashedPassword = "!";

      # Global defaul shell
      users.defaultUserShell = lib.mkForce pkgs.bashInteractive;
      programs.starship.enable = true;

      # Ensure group for user exists
      users.groups.${cfg.username} = {};

      # Create the user account
      users.users.${cfg.username} = {
        isNormalUser = true; # required by nixos...
        home = "/home/${cfg.username}";
        homeMode = "0770";
        createHome = true;
        initialPassword = "123";
        group = cfg.username;
        extraGroups = cfg.secondary_groups;
        description = cfg.username;
      };
    }

    (lib.mkIf (cfg.shell == "zsh") {
      users.users.${cfg.username}.shell = pkgs.zsh;

      programs.zsh = {
        enable = true;
        interactiveShellInit = "bindkey '^ ' autosuggest-accept";
        ohMyZsh.enable = true;
        ohMyZsh.plugins = [
          "history-substring-search"
          "z" # zoxide clone
          "sudo" # press escape twice to add sudo
          "extract" # extract file.tar.gz
        ];
        enableCompletion = true;
        autosuggestions.enable = true;
        autosuggestions.highlightStyle = "fg=246";
        syntaxHighlighting.enable = true;
        histSize = 10000; # in memory
      };

      homeModules = [
        ({
          programs.zsh = {
            enable = true;
            history.save = 690000; # in .zsh_history
            shellAliases = {
              k = "kubectl";
              ku = "kubie";
            };
          };
        })
      ];
    })
  ]);
}
