{ config, ... }:
{
  services.prometheus.exporters.wireguard = {
    enable = true;
    interfaces = [ "wg0" ];
    listenAddress = config.vpn.address;
    openFirewall = true;
  };
}
