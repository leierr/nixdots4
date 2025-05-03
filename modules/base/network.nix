{ config, lib, ... }:

let
  cfg = config.system_settings.network;
in
{
  options.system_settings.network.enable = lib.mkEnableOption "";

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi = {
          backend = "iwd";
          powersave = false;
          macAddress = "stable";
        };
        dhcp = "internal";
        dns = "default";
        ethernet.macAddress = "stable";
        logLevel = "WARN";
        settings = {
          main = {
            no-auto-default = "*"; # do not automatically create connection profiles.
          };
        };
      };
      useNetworkd = false;
      enableIPv6 = false; # all my homies use ipv4
      dhcpcd.enable = false; # vet ikke hvorfor NixOS enda har dhcpd som default enabled...
      useDHCP = false;
      firewall = {
        enable = true;
        # allowedTCPPorts = [ 80 443 ];
      };
      nftables = {
        enable = true;
        flushRuleset = true;
        ruleset = "";
      };
    };
  };
}
