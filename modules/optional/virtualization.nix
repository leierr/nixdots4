{ config, lib, pkgs, ... }:

let
  cfg = config.system_settings.virtualization;
in
{
  options.system_settings.virtualization = {
    libvirt = {
      enable = lib.mkEnableOption "";
      virt_manager.enable = lib.mkEnableOption "";
    };

    docker = {
      enable = lib.mkEnableOption "";
      docker_compose.enable = lib.mkEnableOption "";
    };
  };

  config = (lib.mkMerge [
    # libvirt
    ( lib.mkIf cfg.libvirt.enable {
      virtualisation.libvirtd = {
        enable = true;
        # do not start libvirtd.service on boot
        onBoot = "ignore";
        # shutdown virtual hosts with physical host.
        onShutdown = "shutdown";
        # simple networking
        allowedBridges = [ "virbr0" ];
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [(pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd];
          };
        };
      };

      networking.firewall.trustedInterfaces = lib.mkIf cfg.libvirt.enable [ "virbr0" ];
    })

    # virt_manager
    ( lib.mkIf ( cfg.libvirt.enable && cfg.libvirt.virt_manager.enable ) {
      home_manager_modules = [
        ({
          dconf = {
            settings."org/virt-manager/virt-manager/connections".uris = [ "qemu:///session" ];
            settings."org/virt-manager/virt-manager/connections".autoconnect = [ "qemu:///session" ];
          };

          home.file.".config/libvirt/qemu.conf".text = ''
            nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
          '';
        })
      ];

      environment.systemPackages = with pkgs; [
        virt-manager
      ];
    })

    # docker - rootless ofc
    ( lib.mkIf cfg.docker.enable {
      virtualisation.docker.rootless = lib.mkIf cfg.docker.enable {
        enable = true;
        setSocketVariable = true;
      };
    })

    # docker compose
    ( lib.mkIf ( cfg.docker.enable && cfg.docker.docker_compose.enable) {
      environment.systemPackages = with pkgs; [ docker-compose ];
    })
  ]);
}
