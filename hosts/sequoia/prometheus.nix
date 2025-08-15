{ config, ... }:
{
  services.prometheus.exporters.wireguard = {
    interfaces = [ "wg0" ];
    listenAddress = config.vpn.address;
    openFirewall = true;
  };
}
